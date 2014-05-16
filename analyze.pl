#!/usr/bin/env perl -w

use strict; 
use warnings;

use feature qw(say);

use Text::CSV;
use WordNet::QueryData;
use Lingua::ENgenomic::Tagger;

sub process {
  my $wn = WordNet::QueryData->new(verbose => 0, noload => 1);
  my $tagger = Lingua::ENgenomic::Tagger->new();
  process_file({wordnet => $wn, tagger => $tagger}, "data/sources.csv");
}

sub process_file {
  my ($tools, $filename) = @_;

  my $csv = Text::CSV->new ({binary => 1}) or die "Cannot use CSV: ".Text::CSV->error_diag();
  open my $fh, "<:encoding(utf8)", $filename or die "$filename: $!";
  my $headers = $csv->getline($fh);
  while (my $row = $csv->getline($fh)) {
    my %data = ();
    @data{@$headers} = @$row;
    process_abstract($tools, \%data);
  }
  $csv->eof or $csv->error_diag();
  close $fh;
}

sub process_abstract {
  my ($tools, $data) = @_;

  my $symbol = "FGFR3";

  my $abstract = $data->{abstract};
  return unless ($abstract =~ m{\b$symbol\b});

  my $sentences = $tools->{tagger}->get_sentences($abstract);
  my $context = {sentences => $sentences};

  foreach my $sentence (@$sentences) {
    process_sentence($tools, $context, $sentence);
  }

  exit() if ($abstract =~ m{\b$symbol\b});
}

sub process_sentence {
  my ($tools, $context, $data) = @_;
  my $tagged = $tools->{tagger}->get_readable($data);
  my @tagged_words = split(qr{ }, $tagged);
  foreach my $tagged_word (@tagged_words) {
    my ($word, $tag) = split(qr{/}, $tagged_word);
    if ($tag =~ m{^VB}) {
      say $tagged_word;
    }
  }
  say $tagged;
}

sub tokenize {
  my ($string) = @_;
  my @tokens = ($string =~ m{(\w+)}g);
  return \@tokens;
}

# Now we're getting to the stage where we should start on the skimming component. Here we need to 
# model the data needed, which is basically a set of CD frames, which can be assembled into a set
# of scripts. The experiment script and the clinical trial script are probably the most significant,
# and we can use these to assemble the extraction components. However, we shouldn't lose sight of 
# the fact that gene symbol detection is a primary goal. 
#
# Here are some of the frames we need:
# * variant phenotype association
# * identifying a genetic difference (genotype#v)
# 
# Other thoughts: a gene is a container (IN)
# Genes and gene products are technically different, but that doesn't matter. ie, p53 is *about* TP53

# NOTES:
# - The tagger *often* classifies a gene name as a cardinal number/adjective, likely because of the
#   presence of a digit. That's a difference we need to handle in the tagging within our domain. 




process();

1;