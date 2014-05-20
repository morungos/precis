package Precis::PartialFrame;

use common::sense; 

use Moose;
use namespace::autoclean;

has cds => (
  is => 'rw'
);
has focus_index => (
  is => 'rw'
);

sub print_object {
  my ($self, $fh) = @_;

  my $index = 0;
  foreach my $cd (@{$self->cds()}) {
    $fh->print("$index. ");
    $cd->print_object($fh);
  }

  $fh->say("Focus index: " . $self->focus_index());
}

1;

=head1 NAME

Precis::PartialFrame - A partial conceptual dependency graph frame

=head1 SYNOPSIS

TBD.

=cut 

