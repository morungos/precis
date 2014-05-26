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

1;