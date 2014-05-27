#!/usr/bin/env perl -w

use strict; 
use warnings;

use feature qw(say);

use Text::CSV;
use Precis::Context;

# use Log::Log4perl;
# use Log::Any::Adapter;

# Log::Log4perl::init('log4perl.conf');
# Log::Any::Adapter->set('Log4perl');
use Log::Any::Adapter('Stdout');

use Log::Any qw($log);

sub process {
  my $context = Precis::Context->new();
  process_file($context, "data/sources.csv");
}

sub process_file {
  my ($context, $filename) = @_;

  my $csv = Text::CSV->new ({binary => 1}) or die "Cannot use CSV: ".Text::CSV->error_diag();
  open my $fh, "<:encoding(utf8)", $filename or die "$filename: $!";
  my $headers = $csv->getline($fh);
  while (my $row = $csv->getline($fh)) {
    my %data = ();
    @data{@$headers} = @$row;
    next unless ($data{group} eq '1');
    my $title = $data{title};
    my $abstract = $data{abstract};
    $title .= "." unless ($title =~ m{[\.\?]$});
    my $text = $title . "\n" . $abstract;
    $context->analyze($text);
  }
  $csv->eof or $csv->error_diag();
  close $fh;
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