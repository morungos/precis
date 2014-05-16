package Precis::Context;

use strict; 
use warnings;

use Moo;
use namespace::clean;

use WordNet::QueryData;
use Lingua::ENgenomic::Tagger;

use Precis::Predictor;
use Precis::Substantiator;
use Precis::SSIDT;

use feature qw(say);

sub BUILD {
  my ($self) = @_;
  my $wn = WordNet::QueryData->new(verbose => 0, noload => 1);
  my $tagger = Lingua::ENgenomic::Tagger->new();
  $self->{_tools} = {wordnet => $wn, tagger => $tagger};
  $self->{_predictor} = Precis::Predictor->new();
  $self->{_substantiator} = Precis::Substantiator->new();  
  $self->{_ssidt} = Precis::SSIDT->new();  
}

sub analyze {
  my ($self, $text) = @_;

  my $tools = $self->{_tools};
  my $sentences = $tools->{tagger}->get_sentences($text);

  foreach my $sentence (@$sentences) {
    $self->analyze_sentence($sentence);
  }
}

sub analyze_sentence {
  my ($self, $sentence) = @_;

  my $tools = $self->{_tools};
  my $tagged = $tools->{tagger}->get_readable($sentence);
  my @tagged_words = split(qr{ }, $tagged);

  foreach my $tagged_word (@tagged_words) {
    my ($word, $tag) = split(qr{/}, $tagged_word);

    if ($tag =~ m{^VB}) {
      say $tagged_word;
    }
  }

  say $tagged;
}

1;
