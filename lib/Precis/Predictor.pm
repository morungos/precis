package Precis::Predictor;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

use Log::Any qw($log);

sub predict {
  my ($self, $partial) = @_;

  $log->debug("Calling predictor");

  # When we have a partial structure, we need to look at what do next. 
  # First of all, get the current CDs
  my $cds = $partial->cds();

  $log->debug("No prediction possible; returning");

  return ();
}

1;

=head1 NAME

Precis::Predictor - Predictor for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

