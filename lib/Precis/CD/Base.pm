package Precis::CD::Base;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

has notes => (
  is => 'ro',
  default => sub { {} }
);

has is_complete => (
  is => 'rw',
  default => sub { 0 }
);

sub to_string {
  my ($self) = @_;

  my @result = ();
  push @result, ref($self), "\n";

  my @attributes = $self->meta()->get_all_attributes();
  foreach my $attribute (@attributes) {
    if ($attribute->has_applied_traits('Precis::CD::Attribute::Meta::Slot')) {
      push @result, "   " . $attribute->attribute_to_string($self) . "\n";
    }
  }

  my $notes = $self->notes();
  foreach my $key (sort keys %$notes) {
    push @result, "  &" . $key . ": " . $notes->{$key} . "\n";
  }

  return join("", @result);
}

1;