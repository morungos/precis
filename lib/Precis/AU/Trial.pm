package Precis::CD::Trial;

use common::sense; 

use Moose;
use namespace::autoclean;

use Precis::CD::Attribute::Meta::Slot;

with 'Precis::CD::Base';

has randomized => (
  traits   => ['Precis::CD::Attribute::Meta::Slot'],
  is       => 'rw',
  isa      => 'Precis::CD::Attribute::Slot',
  default  => sub { Precis::CD::Attribute::Slot->new() },
);

has phase => (
  traits   => ['Precis::CD::Attribute::Meta::Slot'],
  is       => 'rw',
  isa      => 'Precis::CD::Attribute::Slot',
  default  => sub { Precis::CD::Attribute::Slot->new() },
);

has hypothesis => (
  traits   => ['Precis::CD::Attribute::Meta::Slot'],
  is       => 'rw',
  isa      => 'Precis::CD::Attribute::Slot',
  default  => sub { Precis::CD::Attribute::Slot->new() },
);

has outcome => (
  traits   => ['Precis::CD::Attribute::Meta::Slot'],
  is       => 'rw',
  isa      => 'Precis::CD::Attribute::Slot',
  default  => sub { Precis::CD::Attribute::Slot->new() },
);

1;
