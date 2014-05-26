package Precis::Substantiator;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

use Log::Any qw($log);

sub substantiate {
  my ($self, $frame, $request) = @_;
  $log->debugf("Production request: %s", $request);

  return undef;
}

1;

=head1 NAME

Precis::Substantiator - Substantiator for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

