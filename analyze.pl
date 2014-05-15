#!/usr/bin/env perl -w

use strict; 
use warnings;

use feature qw(say);

use Text::CSV;
use WordNet::QueryData;

sub process {
  my $wn = WordNet::QueryData->new(verbose => 0, noload => 1);
  process_file($wn, "data/sources.csv");
}

sub process_file {
  my ($wn, $filename) = @_;

  my $csv = Text::CSV->new ({binary => 1}) or die "Cannot use CSV: ".Text::CSV->error_diag();
  open my $fh, "<:encoding(utf8)", $filename or die "$filename: $!";
  my $headers = $csv->getline($fh);
  while (my $row = $csv->getline($fh)) {
    my %data = ();
    @data{@$headers} = @$row;
    process_abstract($wn, \%data);
  }
  $csv->eof or $csv->error_diag();
  close $fh;
}

sub process_abstract {
  my ($wn, $data) = @_;

  my $tokens = tokenize($data->{abstract});
  foreach my $token (@$tokens) {
    my ($type) = $wn->validForms($token);
    $type //= "unknown";
    say "$token => $type";
  }
}

sub tokenize {
  my ($string) = @_;
  my @tokens = ($string =~ m{(\w+)}g);
  return \@tokens;
}

process();

1;