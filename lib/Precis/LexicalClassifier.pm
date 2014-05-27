package Precis::LexicalClassifier;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

requires 'tools';

my $DOMAIN = {
  "proto-oncogene" => {
    "type" => "token_maker",
    "action_units" => []
  }
};

# Probably these tavbles should really be read from a YAML file. Some day. 

my $special_tokens = {
  "have"    => 'function_word',
  "is"      => 'function_word',
  "was"     => 'function_word',
  "been"    => 'function_word',
  "being"   => 'function_word',
  "not"     => 'function_word',
};

my $types = {
  DET  => 'function_word',
  IN   => 'function_word',
  CC   => 'function_word',
  TO   => 'function_word',
  WDT  => 'function_word',
  WRB  => 'function_word',
  WPS  => 'function_word',
  MD   => 'function_word',
  PRP  => 'function_word',
  PRPS => 'function_word',
  WP   => 'function_word',
  EX   => 'function_word',

  NN   => 'token_maker',
  NNS  => 'token_maker',
  NNP  => 'token_maker',
  NNPS => 'token_maker',

  VB   => 'event_builder',
  VBD  => 'event_builder',
  VBG  => 'event_builder',
  VBN  => 'event_builder',
  VBP  => 'event_builder',
  VBZ  => 'event_builder',

  JJ   => 'token_refiner',
  JJS  => 'token_refiner',
  JJR  => 'token_refiner',
  CD   => 'token_refiner',

  RB   => 'event_modifier',
  RBR  => 'event_modifier',
  RBS  => 'event_modifier',

  PP   => 'non_word',
  PPC  => 'non_word',
  PPL  => 'non_word',
  PPS  => 'non_word',
  POS  => 'non_word',
  LRB  => 'non_word',
  RRB  => 'non_word',
  SYM  => 'non_word',
  FW   => 'non_word',
};

sub classify_token {
  my ($self, $token) = @_;

  my $index = rindex($token, "/");
  my $word = substr($token, 0, $index);
  my $tag = substr($token, $index + 1);

  # Non-acronyms are lowercased for special-case detection
  $word = "\L$word" if ($word ne "\U$word" );

  return $special_tokens->{$word} // $types->{$tag} // die "Unclassifiable tag: $word/$tag";
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

