package Precis::CD::Attribute::Slot;

use common::sense; 

use Moose;
use namespace::autoclean;

has role => (
  is        => 'rw',
  isa       => 'Str',
);

has is_complete => (
  is        => 'rw',
  isa       => 'Bool',
);

has value => (
  is        => 'rw',
  predicate => 'has_value',
);

1;