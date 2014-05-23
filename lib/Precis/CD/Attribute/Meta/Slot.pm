package Precis::CD::Attribute::Meta::Slot;

use Moose::Role;
use Precis::CD::Attribute::Slot;

Moose::Util::meta_attribute_alias('Slot');

# has role => (
#     is        => 'rw',
#     isa       => 'Str',
# );

# has is_completed => (
#     is        => 'rw',
#     isa       => 'Bool'
# );

# has value => (
#     is        => 'rw',
# );

# has role => (
#       is        => 'rw',
#       isa       => 'Str',
#       predicate => 'has_label',
#   );

sub attribute_to_string {
  my ($self, $instance) = @_;

  my $name = $self->name();
  my $slot = $self->get_value($instance);
  my $value = $slot->value() // "undef"; 
  my $role = $slot->role();
  my $complete = $slot->is_complete() ? "complete" : "incomplete";
  return "$name: $value (role: $role; $complete)";
}

1;
