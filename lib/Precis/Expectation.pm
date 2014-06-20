package Precis::Expectation;

use common::sense; 

use Moose;
use namespace::autoclean;

has test => (
  is     => 'ro',
  isa    => 'CodeRef',
);
has action => (
  is     => 'ro',
  isa    => 'CodeRef',
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

=item $self->test()

Returns the test coderef, which is applied to (a) the context, and (b) the token.
If it returns true, then the action (below) is called with the same arguments.

=item $self->action()

Returns the action coderef, which is applied to (a) the context, and (b) the token.

=back

=cut 

