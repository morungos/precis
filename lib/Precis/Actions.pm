package Precis::Actions;

use common::sense; 

use Log::Any qw($log);

use Sub::Exporter -setup => {
  exports => [ 
    qw(
      expectation_test_look_for_associated_action_units
      expectation_action_look_for_associated_action_units
    ) 
  ],
};

sub expectation_test_look_for_associated_action_units {
  my ($context, $expectation, $token) = @_;
  $log->debugf("Test %s: %s", $expectation->name(), $token);
  return 0;
}

sub expectation_action_look_for_associated_action_units {
  my ($context, $expectation, $token) = @_;
  $log->debugf("Action %s: %s", $expectation->name(), $token);
  ...;
}

1;