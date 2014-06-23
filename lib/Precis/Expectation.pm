package Precis::Expectation;

use common::sense; 

use Moose;
use namespace::autoclean;

has name => (
  is     => 'ro',
);
has test => (
  is     => 'ro',
  isa    => 'CodeRef',
);
has action => (
  is     => 'ro',
  isa    => 'CodeRef',
);
has arguments => (
  is     => 'ro',
);

1;

=head1 NAME

Precis::Expectation - Expectation for the text analyzer

=head1 DESCRIPTION

Expectations are test/action pairs that drive the top-down parsing system.
Basically, they are generated so that when we encounter a word that we are
interested in, we can act accordingly. 

=head1 METHODS

=over 4

=item Precis::Expectation->new({test => sub {...}, action => sub {...}});

The constructor for a new expectation, which takes both the test and the action
as code references. Both attributes can be set at constructor time, but not modified
afterwards. 

=item $self->name()

Returns the expecttaion name, which isn't functional but is a very useful value
to have for debugging and tracking.

=item $self->test()

Returns the test coderef, which is applied to (a) the context, and (b) the token.
If it returns true, then the action (below) is called with the same arguments.

=item $self->action()

Returns the action coderef, which is applied to (a) the context, and (b) the token.

=item $self->arguments()

A list of additional arguments (after the context) which are added to the code
when it is called, both for the text and for the action. This makes it much easier
to parameterise the expectations, since they don't need to be turned into closures.

=back

=cut 

