package Precis::LanguageTools;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

use WordNet::QueryData;
use Lingua::ENgenomic::Tagger;
use Lingua::Stem::Snowball;

sub BUILD {
  my ($self) = @_;
  my $wn = WordNet::QueryData->new(verbose => 0, noload => 1);
  my $tagger = Lingua::ENgenomic::Tagger->new();
  my $stemmer = Lingua::Stem::Snowball->new(lang => 'en');
  $self->{_tools} = {wordnet => $wn, tagger => $tagger, stemmer => $stemmer};
}

sub tools {
  my ($self) = @_;
  return $self->{_tools};
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