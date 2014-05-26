package Precis::Predictor;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

use Carp;
use List::MoreUtils qw(first_index);

use Log::Any qw($log);

use Precis::SSIDT;

sub predict {
  my ($self, $partial) = @_;

  my $ssidt = Precis::SSIDT->instance();

  $log->debug("Calling predictor; SSIDT: $ssidt");

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

  # Okay, so we do have a target CD, and it isn't marked as complete. So we can
  # predict some expansions, and where to look for them. 

  my $target = $cds->[$target_index];
  my @discriminators = $ssidt->find_discriminators($target);

  foreach my $discriminator (@discriminators) {
    if ($discriminator =~ m{^slot:(\w+):(.*)}) {
      push @requests, {dependency_index => $target_index, slot => $1, filler => $2};
    } else {
      croak "Can't handle discriminator: $discriminator";
    }
  }

  return @requests;
}

1;

=head1 NAME

Precis::Predictor - Predictor for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

