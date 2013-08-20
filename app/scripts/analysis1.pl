#!/usr/bin/env perl -w

use strict;
use warnings;

use feature qw(say);

$| = 1;

use XML::LibXML::Reader;
use JSON;

my $file = 'clinical_trials.xml';

my $data = {by_years => {}};

sub process {
  open my $fh, "<", $file or die "Can't open $file: $!";
  my $reader = XML::LibXML::Reader->new(IO => $fh);

  while($reader->read() && $reader->name() ne 'MedlineCitation') { };

  my $count = 0;

  while(1) {

    if (++$count % 10000 == 0) {
      print "$count ";
    }

    my $element = $reader->copyCurrentNode(1);

    my $year = $element->findvalue('Article/descendant::PubDate/Year');
    if ($year eq '') {
      my $date = $element->findvalue('Article/descendant::PubDate/MedlineDate');
      if ($date =~ m{((?:19|20)\d\d)}) {
        $year = $1;
      }
    }

    $data->{by_years}->{$year} = {} if (! exists($data->{by_years}->{$year}));
    my $year_data = $data->{by_years}->{$year};
    
    # Here we have a clinical trial candidate. Now we can start to do some analysis on it.
    $data->{count}++;
    $year_data->{count}++;

    if ($element->findvalue('Article/PublicationTypeList/PublicationType[text() = "Clinical Trial"]')) {
      $data->{publication_type_count}++;  
      $year_data->{publication_type_count}++;
    }

    # Now let's check out the MESH terms
    if ($element->findvalue('MeshHeadingList/MeshHeading/DescriptorName[contains(text(), "Clinical Trials as Topic")]')) {
      $data->{mesh_count}++;  
      $year_data->{mesh_count}++;      
    }

    if ($element->findvalue('ChemicalList/Chemical/NameOfSubstance[contains(text(), "protein, human")]')) {
      $data->{protein_count}++;  
      $year_data->{protein_count}++; 
    }

    # And now, let's look for gene/protein stuff

    last unless $reader->nextElement('MedlineCitation');
  }
}

process();

say "";

my @keys = qw(count publication_type_count mesh_count protein_count);
say "\t" . join("\t", @keys);
foreach my $year (sort keys %{$data->{by_years}}) {
  say $year . "\t" . join("\t", map { $data->{by_years}->{$year}->{$_} // '' } @keys);
}



my $current = 0;

sub set_tab {
  my ($tab) = @_;
  if (! defined($current)) {
    print STDOUT ("\t" x $tab);
    $current = $tab;
  } elsif ($tab > $current) {
    print STDOUT "\t" x ($tab - $current);
    $current = $tab;
  } elsif ($tab < $current) {
    print STDOUT "\n" . ("\t" x $tab);
    $current = $tab;
  }
}

sub print_indented {
  my ($data, $indent) = @_;
  $indent //= 0;
  if (ref($data) eq 'HASH') {
    foreach my $key (sort keys %$data) {
      set_tab($indent);
      print STDOUT $key;
      print_indented($data->{$key}, $indent + 1);
    }
  } else {
    set_tab($indent);
    print STDOUT $data . "\n";
    $current = undef;
  }
}

# print_indented($data);


# say JSON->new->encode($data);