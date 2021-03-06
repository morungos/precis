package Precis::Context;

use common::sense;

use Moose;
use namespace::autoclean;

use Carp::Assert;
use List::MoreUtils qw(first_index);

use Log::Any qw($log);

use Precis::Frame;
use Precis::KB;
use Precis::LexicalClassifier qw(classify_token);

use Precis::Expectations::LookForAssociatedAUs;

with 'Precis::LanguageTools';

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

has buffer => (
  is => 'rw',
  default => sub { [] }
);

has passive_buffer => (
  is => 'rw',
  default => sub { [] }
);

has knowledge_base => (
  is => 'ro',
  default => sub {
    Precis::KB->new()
  }
);

has frame => (
  is => 'ro',
  default => sub {
    Precis::Frame->new()
  }
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

  $log->debug("Abstract: $text");

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
    my $token = $tagged_words->[$token_index];
    if ($peek) {
      $log->trace("  Peek token: $token");
    } else {
      $log->trace("Read token: $token");
    }
    return $token;
  }
}

# The core of teh parser. Based on the IPP general framework.
sub parse {
  my ($self) = @_;

  my $buffer = $self->buffer();
  my $passive_buffer = $self->passive_buffer();
  my $kb = $self->knowledge_base();
  my $expectations = $self->expectations();

  $#$buffer = -1;
  $#$passive_buffer = -1;

  $DB::single = 1;
  while (1) {
    my $token = $self->get_token();
    last if (! defined($token));

    # End of a sentence. Dump the buffer if we haven't seen anything interesting.
    if ($token eq './PP') {
      $log->debug("End of sentence");
      $#$buffer = -1;
      next;
    }

    # First off, do we match a pending expectation.
    my $expectation_index = first_index {
      $_->test($self, $token, @{$_->arguments()});
    } @$expectations;

    # If we match an expectation, execute it, remove it, and go back to the
    # reader.
    if ($expectation_index != -1) {
      $log->debugf("Expectation: $expectation_index");
      my $expectation = $expectations->[$expectation_index];
      splice($expectations, $expectation_index, 1);
      $expectation->action($self, $token, @{$expectation->arguments()});
      next;
    }

    # Here, we want to do bottom-up processing.
    my $token_type = classify_token($token);

    if ($token_type eq 'event_builder') {
      if (@$passive_buffer) {
        $log->debugf("Passive buffer: %s", $passive_buffer);
      }
      # $self->get_verb_info($token);
      $self->handle_event_builder($token, $token_type, $buffer);
      $#$buffer = -1;
      $#$passive_buffer = -1;
    } elsif ($token_type eq 'token_refiner') {
      push @$buffer, [$token_type, $token];
    } elsif ($token_type eq 'event_refiner') {
      push @$buffer, [$token_type, $token];
    } elsif ($token_type eq 'function_word') {
      push @$buffer, [$token_type, $token];
    } elsif ($token_type eq 'passive_auxiliary') {
      push @$passive_buffer, [$token_type, $token];
    } elsif ($token_type eq 'token_maker') {

      # More complex processing, so we can detect bigger tokens.
      # We're in a loop here, with a sub-context.

      my $token_constituents = [$token];
      my $interesting_token;
      $interesting_token //= $kb->interesting_token_constituent($token_constituents);

      TOKEN_MAKER: while (1) {

        # Peek at the next token
        my $next_token = $self->get_token(1);
        my $next_token_type = classify_token($next_token);

        if ($next_token_type ne 'token_maker') {
          last TOKEN_MAKER;
        }

        # It's a token maker, so add to the @token_constituents and gobble it
        push @$token_constituents, $next_token;

        $interesting_token //= $kb->interesting_token_constituent($token_constituents);

        $next_token = $self->get_token();
      }

      # Here we have a buffer of @token_constituents. Join it back with
      # spaces and push as a token maker.

      my $token_maker = join(" ", @$token_constituents);

      push @$buffer, [$token_type, $token_maker];

      if ($interesting_token) {
        $log->debugf("Interesting token: %s", $token_maker);
        my $expectation = Precis::Expectations::LookForAssociatedAUs->new({
          name => "LOOK FOR $interesting_token->{name} ASSOCIATED ACTION UNIT",
          arguments => [$interesting_token]
        });
        push @$expectations, $expectation;
      }
    }
  }
}

sub handle_event_builder {
  my ($self, $token, $token_type) = @_;
  my $buffer = $self->buffer();
  $log->debugf("Attempting to build an event: %s, %s => %s", $token, $token_type, $buffer);
}

1;
