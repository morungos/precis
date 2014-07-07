package Precis::Heuristics;

use common::sense;

use Sub::Exporter -setup => {
  exports => [ qw(resolve_prefix_suffix_omissions) ],
};

# In many cases, because abstracts are written with a significant word pressure, we
# find a variety of compactions which we want to resolve before we continue. One of the
# common ones is, e.g., "inhibitor-sensitive and -resistant EGFR mutants". When we
# find a word which begins (or ends) with a hyphen, we can attempt to expand and
# resolve the abbreviation.

sub resolve_prefix_suffix_omissions {
  my ($tokens) = @_;
}

sub identify_acronyms {
  my ($tagged_words) = @_;

  my $end = @$tagged_words;
  for(my $i = 0; $i < $end; $i++) {

    # We start by finding left parentheses. In all cases, this is a good base case.
    if ($tagged_word->[$i] eq '(/LRB') {

    }
  }
}

1;

=head1 NAME

Precis::Heuristics - Heuristics for the text analyzer

=head1 SYNOPSIS

TBD.

=cut

