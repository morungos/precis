package Precis::Context;

use common::sense; 

use Moose;
use namespace::autoclean;

use Carp::Assert;
use List::MoreUtils qw(first_index);

use Log::Any qw($log);

with 'Precis::LanguageTools';
with 'Precis::Predictor';
with 'Precis::Substantiator';
with 'Precis::LexicalClassifier';

has tagged_words => (
  is => 'rw',
);
has token_index => (
  is => 'rw',
);
has sentence_bounds => (
  is => 'rw',
);
has expectations => (
  is => 'rw',
);

sub analyze {
  my ($self, $text) = @_;

  my $tools = $self->tools();

  my $sentences = $tools->{tagger}->get_sentences($text);
  my @context_tagged = ();
  my @context_sentences = ();
  my $index = 0;
  foreach my $sentence (@$sentences) {
    my @tagged_sentence = split(qr{ }, $tools->{tagger}->get_readable($sentence));
    push @context_sentences, [scalar(@context_tagged), scalar(@tagged_sentence)];
    push @context_tagged, @tagged_sentence;
  }

  # Initialize the context
  $self->tagged_words(\@context_tagged);
  $self->token_index(0);
  $self->sentence_bounds(\@context_sentences);
  $self->expectations([]);

  $log->debug("Abstract: " . join(" ", @context_tagged));

  $self->parse();
  return;
}

sub add_expectation {
  my ($self, $expectation) = @_;
  push @{$self->expectations()}, $expectation;
}

sub has_token {
  my ($self) = @_;
  my $tagged_words = $self->tagged_words();
  my $end_index = $#$tagged_words;
  my $token_index = $self->token_index();
  return ($token_index <= $end_index);
}

sub get_token {
  my ($self, $peek) = @_;
  my $tagged_words = $self->tagged_words();
  my $end_index = $#$tagged_words;
  my $token_index = $self->token_index();
  if ($token_index > $end_index) {
    return;
  } else {
    $self->token_index($token_index + 1) unless ($peek);
    return $tagged_words->[$token_index];    
  }
}

# The core of teh parser. Based on the IPP general framework. 
sub parse {
  my ($self) = @_;

  my @buffer = ();

  $DB::single = 1;
  while (1) {
    my $token = $self->get_token();
    last if (! defined($token));

    # End of a sentence. Dump the buffer if we haven't seen anything interesting.
    if ($token eq './PP') {
      $log->debug("End of sentence");
      @buffer = ();
      next;
    }

    # First off, do we match a pending expectation.
    my $expectations = $self->expectations();
    my $expectation_index = first_index { 
      my $test = $_->test();
      &$test($self, $token);
    } @$expectations;

    # If we match an expectation, execute it, remove it, and go back to the 
    # reader. 
    if ($expectation_index != -1) {
      $log->debugf("Expectation: $expectation_index");
      my $expectation = $expectations->[$expectation_index];
      my $action = $expectation->action();
      splice($expectations, $expectation_index, 1);
      &$action($self, $token);
      next;
    }

    # Here, we want to do bottom-up processing. 
    my $token_type = $self->classify_token($token);

    if ($token_type eq 'event_builder') {
      $log->debug("Attempting to build an event: $token, $token_type");
      $log->debugf("Buffer: %s", \@buffer);
      @buffer = ();
    } elsif ($token_type eq 'token_refiner') {
      push @buffer, [$token_type, $token];
    } elsif ($token_type eq 'event_refiner') {
      push @buffer, [$token_type, $token];
    }
  }

}

1;
