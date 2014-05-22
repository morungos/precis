package Precis::Predictor;

use common::sense; 

use Moose::Role;
use namespace::autoclean;
use List::MoreUtils qw(first_index);

use Log::Any qw($log);

sub predict {
  my ($self, $partial) = @_;

  $log->debug("Calling predictor");

  # When we have a partial structure, we need to look at what do next. 
  # First of all, get the current CDs
  my $cds = $partial->cds();
  my @requests = ();

  if (! @$cds) {
    $log->debug("No dependencies: no prediction possible; returning");
    return @requests;
  }

  my $target_index = first_index { ! $_->is_complete() } @$cds;
  if ($target_index == -1) {
    $log->debug("No prediction possible; returning");
    return @requests;
  }

  my $target = $cds->[$target_index];

  # Rule: if we're a clinical trial and we don;t yet have a value for whether it's randomized,
  # let's queue a substantiation for that. 
  if ($target->{type} eq 'TRIAL' && ! exists($target->slots()->{RANDOMIZED}->{value})) {
    push @requests, {dependency_index => $target_index, slot => 'RANDOMIZED'};
  }

  # Okay, so we do have a target CD, and it isn't marked as complete. So we can
  # predict some expansions, and where to look for them. 

  return @requests;
}

1;

=head1 NAME

Precis::Predictor - Predictor for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

