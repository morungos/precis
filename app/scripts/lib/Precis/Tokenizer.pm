package Precis::Tokenizer;

use strict;
use warnings;

use Exporter::Declare;

exports qw(tokenize);

# Token types that we very probably want:
#  - mutations (we have regexes for these, approximately) - these are really good for us
#  - numbers, distinguishing floats, integers, percentages, and ranges of these
#  - maybe open/close parens
#  - greek letters
#  - relations, <, >, = 

my @greek = qw(
  alpha    beta      gamma    delta    epsilon  zeta
  eta      theta     iota     kappa    lambda   mu
  nu       xi        omicron  pi       rho      sigma
  tau      upsilon   phi      chi      psi      omega
);

my $bases = qr/[ACGT]/;
my $acids = qr/[ACDEGFHIKLMNPQRSTWVY*]/;

my $numbers_re = qr/\b(?<NUM>\d+(?:\.\d+)?)\b/;
my $relations_re = "\b(?<REL>=|<|>)\b";
my $mutations_re = qr/\b(?<MUT>\b(${acids}[1-9]\d{1,3}${acids}|${acids}[1-9]\d{1,3}(?:_${acids}[1-9]\d{1,3})?(?:fs|ins${acids}+|del${acids}+|${acids}+>${acids}+)))\b/;
my $longacids_re = qr/\b(?<ACI>Ala|Arg|Asn|Asp|Cys|Glu|Gln|Gly|His|Ile|Lys|Met|Phe|Pro|Leu|Ser|Thr|Tyr|Trp|Val|X)\b/;
my $word_re = qr/\b(?<WORD>\p{Word}+)\b/;

my $pattern = qr{(?:$word_re)};

# Word tokenizing additional rules. Words which are <UPPER><LOWER>{2,} are converted to 
# lowercase. 


sub tokenize {
  my ($text) = @_;

  my @tokens = ();
  MATCH: while($text =~ m{$pattern}g) {
    if ($+{WORD}) { 
      my $token = $+{WORD};
      if ($token =~ m{^\p{Upper}\p{Lower}{2,}$}) {
        $token = lc($token);
      }
      push @tokens, $token; 
      next MATCH; 
    }
    if ($+{NUM})  { push @tokens, '$NUM'; next MATCH; }
    if ($+{REL})  { push @tokens, '$REL'; next MATCH; }
    if ($+{ACI})  { push @tokens, '$ACI'; next MATCH; }
    if ($+{MUT})  { push @tokens, '$MUT'; next MATCH; }
  }
 
  return @tokens;
}

1;