package Precis::Expectations::LookForAssociatedAUs;

use common::sense; 

use Moose;
use namespace::autoclean;

use Log::Any qw($log);

with 'Precis::Expectation';

sub test {
  my ($self, $context, $token, $entry) = @_;
  $log->debugf("Test %s: %s", $self->name(), $token);
  $log->debugf("Buffer is: %s", $context->buffer());
  return 0;
}

sub action {
  my ($self, $context, $token, $entry) = @_;
  $log->debugf("Action %s: %s", $self->name(), $token);
  ...;
}

1;