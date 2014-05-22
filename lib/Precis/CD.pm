package Precis::CD;

use common::sense; 

use Moose;
use namespace::autoclean;

has type => (
  is => 'rw'
);
has slots => (
  is => 'ro',
  default => sub { {} }
);
has notes => (
  is => 'ro',
  default => sub { {} }
);

sub print_object {
  my ($self, $fh) = @_;

  $fh->say("TYPE: ".$self->type());
  my $slots = $self->slots();
  foreach my $key (sort keys %$slots) {
    $fh->say("   $key: ".$slots->{$key});
  }
  my $notes = $self->notes();
  foreach my $key (sort keys %$notes) {
    $fh->say("  &$key: ".$notes->{$key});
  }
}

1;

=head1 NAME

Precis::CD - A single conceptual dependency

=head1 SYNOPSIS

TBD.

=cut 

