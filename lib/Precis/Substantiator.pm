package Precis::Substantiator;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

use Log::Any qw($log);

sub substantiate {
  my ($self, $frame, $request) = @_;
  $log->debugf("Production request: %s", $request);

  # This is a knowledge-based component, so we want to be able to write contextual rules here. However
  # we also want these to be kind of scripty. In effect, it is the script that specifies an ordering
  # and even some locational knowledge to the component. And to do that, we need to elaborate scripts.

  return undef;
}

1;

=head1 NAME

Precis::Substantiator - Substantiator for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

