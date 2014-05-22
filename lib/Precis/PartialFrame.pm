package Precis::PartialFrame;

use common::sense; 

use Moose;
use namespace::autoclean;

has cds => (
  is => 'rw',
  default => sub { [] }
);
has current_cd_index => (
  is => 'rw'
);

sub print_object {
  my ($self, $fh) = @_;

  my $index = 0;
  foreach my $cd (@{$self->cds()}) {
    $index++;
    $fh->print("$index. ");
    $cd->print_object($fh);
  }

  if ($index) {
    $fh->say("Current CD index: " . $self->current_cd_index() . "\n");
  }
}

sub add_cd {
  my ($self, $cd) = @_;
  my $cds = $self->cds();
  push @$cds, $cd;
  $self->current_cd_index($#$cds);
  return $cd;
}

1;

=head1 NAME

Precis::PartialFrame - A partial conceptual dependency graph frame

=head1 SYNOPSIS

TBD.

=cut 

