package Precis::Context;

use common::sense; 

use Moose;
use namespace::autoclean;

use WordNet::QueryData;
use Lingua::ENgenomic::Tagger;
use Lingua::Stem::Snowball;

with 'Precis::Bootstrap';
with 'Precis::Predictor';
with 'Precis::Substantiator';
with 'Precis::SSIDT';

has tagged_words => (
  is => 'rw'
);
has sentence_bounds => (
  is => 'rw'
);
has tools => (
  is => 'rw'
);

sub BUILD {
  my ($self) = @_;
  my $wn = WordNet::QueryData->new(verbose => 0, noload => 1);
  my $tagger = Lingua::ENgenomic::Tagger->new();
  my $stemmer = Lingua::Stem::Snowball->new(lang => 'en');
  $self->tools({wordnet => $wn, tagger => $tagger, stemmer => $stemmer});
}

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

  say join(" ", @context_tagged). "\n";

  $self->get_bootstrap_targets();
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

1;
