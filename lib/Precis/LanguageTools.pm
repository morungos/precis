package Precis::LanguageTools;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

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

1;