package Precis::Context;

use common::sense; 

use Moose;
use namespace::autoclean;

use Carp::Assert;

use Log::Any qw($log);

with 'Precis::LanguageTools';
with 'Precis::Predictor';
with 'Precis::Substantiator';
with 'Precis::LexicalClassifier';

has tagged_words => (
  is => 'rw'
);
has sentence_bounds => (
  is => 'rw'
);
has queue => (
  is => 'rw'
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

  $self->tagged_words(\@context_tagged);
  $self->sentence_bounds(\@context_sentences);

  $log->debug("Abstract: " . join(" ", @context_tagged));

  $self->parse();
  return;
}

sub get_valid_form {
  my ($self, $word) = @_;
  my $tools = $self->tools();
  my ($form) = $tools->{wordnet}->validForms($word."#v");
  if (! defined($form)) {
    $form = $word."#v";
  }
  return $form;
}

sub queue_frame {
  my ($self, $frame) = @_;
  push @{$self->queue()}, $frame;
}

sub unqueue_frame {
  my ($self) = @_;
  return shift @{$self->queue()};
}

sub clear_queue_frames {
  my ($self) = @_;
  $self->queue([]);
}

sub print_queue {
  my ($self, $queue) = @_;
  my $frame_number = 1;
  foreach my $queued (@$queue) {
    say "Frame: $frame_number";
    say $queued->to_string();
    $frame_number++;
  }
  return;
}

# The core of teh parser. Based on the IPP general framework. 
sub parse {
  my ($self) = @_;

  my $tagged_words = $self->tagged_words();
  my $end = $#$tagged_words;

  my $index = 0;
  my $this_token = $tagged_words->[$index];
  my $this_type = $self->classify_token($this_token);

  my @buffer = ();

  while($index < $end) {
    my $next = $index + 1;
    my $next_token = $tagged_words->[$next];
    my $next_type = $self->classify_token($next_token);

    $log->debug("  Token: $this_token");

    if ($this_type eq 'event_builder') {
      $log->debug("Attempting to build an event: $this_token");
      $log->debugf("Buffer: %s", \@buffer);
      @buffer = ();
    } elsif ($this_type eq 'token_refiner') {
      push @buffer, [$this_type, $this_token];
    } elsif ($this_type eq 'event_refiner') {
      push @buffer, [$this_type, $this_token];
    }

    ($index, $this_token, $this_type) = ($next, $next_token, $next_type);
  }
}

1;
