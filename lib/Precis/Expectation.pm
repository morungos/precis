package Precis::Expectation;

use common::sense;

use Moose::Role;
use namespace::autoclean;

has name => (
  is     => 'ro',
);
has arguments => (
  is     => 'ro',
);

requires 'test';
requires 'action';

1;

=head1 NAME

Precis::Expectation - Expectation for the text analyzer

=head1 DESCRIPTION

Expectations are test/action objects that drive the top-down parsing system.
Basically, they are generated so that when we encounter a word that we are
interested in, we can act accordingly.

=head1 ATTRIBUTES

=over 4

=item name

The expectation name, which isn't functional but is a very useful value
to have for debugging and tracking.

=item arguments

A list of additional arguments (after the context) which are added to the code
when it is called, both for the text and for the action. This makes it much easier
to parameterise the expectations, since they don't need to be turned into closures.

=back

=head1 METHODS

=over 4

=item $self->test($context, $token, ...)

Calls the test, which is applied to self, the context, and the token.
If it returns true, then the action (below) is called with the same arguments.

=item $self->action($context, $token, ...)

Returns the action coderef, which is applied to self, the context, and the token.

=back

=cut

