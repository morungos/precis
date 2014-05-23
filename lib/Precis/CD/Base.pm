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

  my @attributes = $self->get_slot_attributes();
  foreach my $attribute (@attributes) {
    push @result, "   " . $attribute->attribute_to_string($self) . "\n";
  }

  my $notes = $self->notes();
  foreach my $key (sort keys %$notes) {
    push @result, "  &" . $key . ": " . $notes->{$key} . "\n";
  }

  return join("", @result);
}

sub get_slot_attributes {
  my ($self) = @_;
  my @attributes = $self->meta()->get_all_attributes();
  @attributes = grep { $_->has_applied_traits('Precis::CD::Attribute::Meta::Slot') } @attributes;
  @attributes = sort { $a->insertion_order() <=> $b->insertion_order() } @attributes;
  return @attributes;
}

sub get_slot_attribute_names {
  my ($self) = @_;
  return map { $_->name() } $self->get_slot_attributes();
}

1;