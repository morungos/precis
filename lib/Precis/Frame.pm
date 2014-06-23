package Precis::Frame;

use common::sense; 

use Moose;
use namespace::autoclean;

has mop => (
  is     => 'rw',
);

has action_units => (
  is     => 'rw',
  default => sub { [] },
);

1;

=head1 NAME

Precis::Frame - Frame for the text analyzer

=head1 DESCRIPTION

There will generally only be one frame, but it is a representation for the output
representation from the context. 

=head1 METHODS

=over 4

=item Precis::Expectation->new({test => sub {...}, action => sub {...}});

The constructor for a new expectation, which takes both the test and the action
as code references. Both attributes can be set at constructor time, but not modified
afterwards. 

=item $self->mop()

Attribute for the currently selected MOP, if we have one. 

=item $self->action_units()

Attribute for the current set of action units. These are primarily stored in an 
indexed array. 

=back

=cut 

