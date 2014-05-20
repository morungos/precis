package Precis::Bootstrap;

use common::sense; 

use Moose::Role;
use Precis::Linguistics qw(passive_filter);

# A role that provides the get_bootstrap_targets method, which is the main component
# delivered by the Bootstrap module. 

sub get_bootstrap_targets {
  my ($self) = @_;

  my $tools = $self->tools();
  my $tagged_words = $self->tagged_words();
  my $end = @$tagged_words;

  for(my $i = 0; $i < $end; $i++) {
    my $tagged_word = $tagged_words->[$i];
    if ($tagged_word =~ m{^(\w+)/VB}) {
      my ($word, $tag) = split("/", $tagged_word);
      next if ($tag eq 'VBG');
      say "$i, $tagged_word";
    }
  }

  for(my $i = 0; $i < $end; $i++) {
    my ($index, $start, $length) = passive_filter($tagged_words, $i);
    if (defined($index)) {
      my @words = @$tagged_words[$start .. ($start + $length - 1)];
      my $phrase = join(" ", @words);
      $DB::single = 1;
      say "$index, $start, $length, $phrase";

      my $tagged_verb = $tagged_words->[$index];
      my ($verb, $tag) = split("/", $tagged_verb);
      my ($form) = $tools->{wordnet}->validForms("$verb"."#v");
      say $form;
    }
  }
}

1;

=head1 NAME

Precis::Bootstrap - Bootstrap for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

