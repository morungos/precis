package Precis::Bootstrap;

use common::sense; 

use Moose::Role;
use Precis::Linguistics qw(passive_filter);

# A role that provides the get_bootstrap_targets method, which is the main component
# delivered by the Bootstrap module. 

sub get_bootstrap_targets {
  my ($self) = @_;

  my $tagged_words = $self->tagged_words();
  my $index = 0;
  my $end = @$tagged_words;

  for(my $i = 0; $i < $end; $i++) {
    my ($index, $start, $length) = passive_filter($tagged_words, $i);
    if (defined($index)) {
      my @words = @$tagged_words[$start .. ($start + $length - 1)];
      my $phrase = join(" ", @words);
      say "$index, $start, $length, $phrase";
    }
  }
}

1;

=head1 NAME

Precis::Bootstrap - Bootstrap for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

