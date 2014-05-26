package Precis::LexicalClassifier;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

requires 'tools';

sub classify_token {
  my ($self, $token) = @_;

  my ($word, $tag) = split("/", $token);

  # say $tag;
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

