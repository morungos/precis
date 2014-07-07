package Precis::Data::AU;

use common::sense;

use Moose;

# A reorganized version of the knowledge base, we really don't need the level of meta-work that we
# used to use, this is defined more directly as a set of Moose structures.

has name => (
  is => 'ro',
);

has parent => (
  is => 'rw',
);

has children => (
  is => 'rw',
  default => sub { [] },
);

has roles => (
  is => 'rw',
);

has attributes => (
  is => 'rw',
);

1;
