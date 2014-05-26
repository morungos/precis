package Precis::Context;

use common::sense; 

use Moose;
use namespace::autoclean;

use Carp::Assert;

use Log::Any qw($log);

with 'Precis::LanguageTools';
with 'Precis::Bootstrap';
with 'Precis::Predictor';
with 'Precis::Substantiator';

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
  $self->clear_queue_frames();

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

# The core of teh parser. It works as described on p74 of the Mauldin book. 
sub parse {
  my ($self) = @_;

  my $queue = $self->queue();
  $self->get_bootstrap_targets();
  return undef if (! @$queue);

  $self->print_queue($queue);

  while(my $frame = $self->unqueue_frame()) {
    assert($frame);
    if ($frame->is_complete()) {
      $log->debug("Parse complete");
      $frame->print_object(\*STDOUT);
      return;
    }

    my @requests = $self->predict($frame);
    foreach my $request (@requests) {
      
      # When we get these requests, we need to pass them into the substantiator.  
      # If we have a result, we should queue the new frame. If we don't get a response,
      # we can simply drop the frame. 
      if (my $modified_frame = $self->substantiate($frame, $request)) {
        $self->queue_frame($modified_frame);
      }
    }
  }
}

1;
