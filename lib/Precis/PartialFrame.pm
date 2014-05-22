package Precis::PartialFrame;

use common::sense; 

use Moose;
use namespace::autoclean;

has cds => (
  is => 'rw',
  default => sub { [] }
);

sub print_object {
  my ($self, $fh) = @_;

  my $index = 0;
  foreach my $cd (@{$self->cds()}) {
    $index++;
    $fh->print("$index. ");
    $cd->print_object($fh);
  }
}

sub add_cd {
  my ($self, $cd) = @_;
  my $cds = $self->cds();
  push @$cds, $cd;
  return $cd;
}

1;

=head1 NAME

Precis::PartialFrame - A partial conceptual dependency graph frame

=head1 SYNOPSIS

TBD.

=cut 

