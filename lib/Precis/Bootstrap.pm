package Precis::Bootstrap;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

use Tree::Range::RB;

use Precis::Linguistics qw(passive_filter);
use Precis::Data qw(get_bootstrap_frames);

requires 'get_valid_form';

# A role that provides the get_bootstrap_targets method, which is the main component
# delivered by the Bootstrap module. 

sub get_bootstrap_targets {
  my ($self) = @_;

  my $tagged_words = $self->tagged_words();
  my $end = @$tagged_words;

  my $nrt = Tree::Range::RB->new({ "cmp" => sub { $_[0] <=> $_[1]; } });

  my $frames = get_bootstrap_frames();

  for(my $i = 0; $i < $end; $i++) {
    my ($index, $start, $end) = passive_filter($tagged_words, $i);
    if (defined($index)) {
      my @words = @$tagged_words[$start .. $end];
      my $phrase = join(" ", @words);

      my $tagged_verb = $tagged_words->[$index];
      my ($verb, $tag) = split("/", $tagged_verb);

      $nrt->range_set($start, $end + 1, { phrase => $phrase, verb => $verb, index => $index, start => $start, end => $end, tag => "VBx"});

      $i = $end;
    }
  }


  for(my $i = 0; $i < $end; $i++) {
    my $tagged_word = $tagged_words->[$i];
    if ($tagged_word =~ m{^(\w+)/VB}) {
      my ($word, $tag) = split("/", $tagged_word);
      next if ($tag eq 'VBG');

      my $match = $nrt->get_range($i);
      if (! $match) {
        $nrt->range_set($i, $i + 1, { phrase => $word, verb => $word, index => $i, start => $i, end => $i, tag => $tag});
      }
    }
  }

  my ($ic) = $nrt->range_iter_closure();
  while ((my ($descriptor, $lower, $upper) = $ic->())) {
    next unless (defined($descriptor));
    my $form = $self->get_valid_form($descriptor->{verb});
    $descriptor->{form} = $form;

    say "$descriptor->{index}, $descriptor->{end}, $descriptor->{end}, $descriptor->{phrase}, $descriptor->{form}, $descriptor->{tag}";

  }
}

1;

=head1 NAME

Precis::Bootstrap - Bootstrap for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

