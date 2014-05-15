#!/usr/bin/env perl -w

use strict;
use warnings;

use feature qw(say switch);

$| = 1;

use Carp;
use XML::LibXML qw(:libxml);
use XML::LibXML::Reader;
use JSON;

use MongoDB;

my $file = 'clinical_trials.xml';

my $data = {by_years => {}};

sub process {
  open my $fh, "<", $file or die "Can't open $file: $!";
  my $reader = XML::LibXML::Reader->new(IO => $fh);

  while($reader->read() && $reader->name() ne 'MedlineCitation') { };

  my $count = 0;

  my $database = open_database();

  while(1) {

    if (++$count % 10000 == 0) {
      print "$count ";
    }

    my $element = $reader->copyCurrentNode(1);
    my ($name, $attributes, $result) = convert_to_json($element);
    save_record($database, 'pubmed', $result, {w => 1});

    last unless $reader->nextElement('MedlineCitation');
  }

  close_database($database);
}

sub convert_to_json {
  my ($node) = @_;

  my $name = $node->nodeName();
  my $result;
  my $attributes;

  if ($node->hasAttributes()) {
    $attributes = {};
    foreach my $attribute ($node->attributes()) {
      my $name = $attribute->nodeName();
      my $value = $attribute->getValue();
      $attributes->{$name} = $value;
    }
  }

  if (my @childnodes = grep { $_->nodeType() eq XML_ELEMENT_NODE } $node->nonBlankChildNodes()) {

    $result = {};
    foreach my $child (@childnodes) {
      my ($child_name, $child_attributes, $child_result) = convert_to_json($child);
      if (defined $result->{$child_name} && ref $result->{$child_name} ne 'ARRAY') {
        $result->{$child_name} = [$result->{$child_name}];
      }
      if (ref $result->{$child_name} eq 'ARRAY') {
        push @{$result->{$child_name}}, $child_result;
      } else {
        $result->{$child_name} = $child_result;
      }

    }

  } else {

    $result = $node->textContent();
 
  }

  if ($name eq 'AbstractText' && defined($attributes->{Label})) {
    $result = "$attributes->{Label}. $result";
    return $name, {}, {Label => $attributes->{Label}, NlmCategory => $attributes->{NlmCategory}, AbstractText => $result};
  } else {
    return $name, $attributes, $result;
  }

}


process();

say "";


sub open_database {
  
  my $database_name = $ENV{HELIOTROPE_DATABASE_NAME} || "heliotrope";
  my $database_server = $ENV{HELIOTROPE_DATABASE_SERVER} || "localhost:27017";
  my $database_username = $ENV{HELIOTROPE_DATABASE_USERNAME};
  my $database_password = $ENV{HELIOTROPE_DATABASE_PASSWORD};
  
  my @options = (host => $database_server);
  push @options, username => $database_username if ($database_username);
  push @options, password => $database_password if ($database_password);

  my $conn = MongoDB::Connection->new(@options);  
  my $database = $conn->get_database($database_name);
  return $database;
}

sub close_database {

}

sub save_record {
  my ($database, $collection, $data, @options) = @_;
  my $result = eval {
    $database->get_collection($collection)->save($data, @options);
  };
  if ($@ && ! defined($result)) {
    carp($@);
  }
  return $result;
}

1;