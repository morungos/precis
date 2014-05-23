package Precis::PartialFrame;

use common::sense; 

use Moose;
use namespace::autoclean;

use List::MoreUtils qw(all);

has cds => (
  is => 'rw',
  default => sub { [] }
);

sub to_string {
  my ($self) = @_;

  my @result = ();
  my $index = 0;
  foreach my $cd (@{$self->cds()}) {
    $index++;
    push @result, "$index. ";
    push @result, $cd->to_string();
  }
  return join("", @result);
}

sub add_cd {
  my ($self, $cd) = @_;
  my $cds = $self->cds();
  push @$cds, $cd;
  return $cd;
}

sub is_complete {
  my ($self) = @_;
  return all { $_->is_complete() } @{$self->cds()};
}

1;

=head1 NAME

Precis::PartialFrame - A partial conceptual dependency graph frame

=head1 SYNOPSIS

TBD.

=cut 

