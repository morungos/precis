package Precis::LexicalClassifier;

use common::sense;

my $special_tokens;
my $override_types;
my $types;

use Carp;
use YAML;
use File::Spec;
use Module::Load;

BEGIN {
  my ($volume,$directory,$file) = File::Spec->splitpath(__FILE__);
  my $data_directory = File::Spec->catdir($directory, 'Data');

  $special_tokens = YAML::LoadFile(File::Spec->catpath($volume, $data_directory, "SpecialTokens.yml"));
  $override_types = YAML::LoadFile(File::Spec->catpath($volume, $data_directory, "OverrideTypes.yml"));
  $types = YAML::LoadFile(File::Spec->catpath($volume, $data_directory, "Types.yml"));
}

use Sub::Exporter -setup => {
  exports => [ qw(classify_token) ],
};

sub classify_token {
  my ($token) = @_;

  my $index = rindex($token, "/");
  my $word = substr($token, 0, $index);
  my $tag = substr($token, $index + 1);

  # Non-acronyms are lowercased for special-case detection
  $word = "\L$word" if ($word ne "\U$word" );

  return $special_tokens->{$word} // $override_types->{$token} // $types->{$tag} // die "Unclassifiable tag: $word/$tag";
}

1;

=head1 NAME

Precis::LexicalClassifier - Lexical classifier for the text analyzer

=head1 DESCRIPTION

This

=head1 METHODS

=head2 $self->classify($token)

Classifies the token provided (this includes the POS tag) and returns one of the following
six values:

=over 4

=item event_builder

An event building token - typically an event-building verb

=item token_maker

A token maker, commonly identifying a picture producer which may point to a set of
possible events. Commonly a concrete noun.

=item token_refiner

Usually adjectives, modifying a noun.

=item event_refiner

Usually an adverb, modifying a verb/significant event.

=item function_word

Most other words.

=item non_word

For consistency, we allow punctuation to be passed through as a non_word class.

=back

=cut

