package Precis::Linguistics;

use common::sense; 

use Sub::Exporter -setup => {
  exports => [ qw(passive_filter get_all_verbs) ],
};

use Tree::Range::RB;

# my @modal = qw(may might must be being been am are is was were do does did should could would have has had will can shall);

# # @ = pronoun, * = not
# my $passive_patterns => {
#     present      => [ '@ BE * PART',                 'BE @ * PART' ],
#     present_prog => [ '@ BE * being PART',           'BE @ * being PART' ],
#     past         => [ '@ WAS * PART',                'WAS @ * PART' ],
#     past_prog    => [ '@ WAS * being PART',          'WAS @ * being PART' ],
#     perfect      => [ '@ HAVE * been PART',          'HAVE @ * been PART' ],
#     past_perfect => [ '@ had * been PART',           'had @ * been PART' ],
#     modal      =>   [ '@ MODAL * be PART',           'MODAL @ * be PART' ],
#     modal_perf =>   [ '@ MODAL * have been PART',    'MODAL @ * have been PART' ]
# }

# Returns the index if we have a passive verb, the index being that of the root 
# verb. Otherwise, we return undef. Since zero is conceptually if not actually possible
# best to use a definedness test for the result. 

sub passive_filter {
  my ($tokens, $index) = @_;
  my $original_index = $index;
  my $target = $tokens->[$index++] // return undef;

  if ($target =~ m{^(?:may|might|must|do|does|did|should|could|would|will|can|shall)/}) {
    my $auxiliary = $target;
    $target = $tokens->[$index++] // return undef;

    # If there's a not in there, we can legitimately skip it. We probably ought to 
    # do something with it, but now is not really the time. 
    if ($target =~ m{^not/}) {
      $target = $tokens->[$index++] // return undef;
    }
    
    # We can have either a "be" or a "have been" next
    if ($target =~ m{^be/}) {
      $target = $tokens->[$index++] // return undef;
    } elsif ($target =~ m{^have/}) {
      $target = $tokens->[$index++] // return undef;
      if ($target =~ m{^been/}) {
        $target = $tokens->[$index++] // return undef;
      } else {
        return undef;
      }
    } else {
      return undef;
    }

    # We might have an adverb, it's optional
    if ($target =~ m{/RB}) {
      $target = $tokens->[$index++] // return undef;
    }

    # And finally, the next thing should be a verb. If so, we return the 
    # index of the primary verb. If it isn't a verb, return false. 
    if ($target =~ m{^\w+/VB}) {
      my ($voice) = ($auxiliary =~ m{/(\w+)});
      return ($index - 1, $original_index, $index - 1, $voice);
    } else {
      return undef;
    }

  }

  if ($target =~ m{^(?:was|were|have|had|has|are|is)/VB}) {
    my $auxiliary = $target;
    $target = $tokens->[$index++] // return undef;

    # If there's a not in there, we can legitimately skip it. We probably ought to 
    # do something with it, but now is not really the time. 
    if ($target =~ m{^not/}) {
      $target = $tokens->[$index++] // return undef;
    }

    # We might have an adverb, it's optional
    if ($target =~ m{/RB}) {
      $target = $tokens->[$index++] // return undef;
    }

    # The next word could easily be: "been/being". Actually, we require that for had/have/has, because
    # if it isn't, it isn't passive. This mainly affects where we look for related 
    # info. 
    if ($target =~ m{^(?:being|been)/}) {
      $target = $tokens->[$index++] // return undef;
    } elsif ($auxiliary =~ m{^(?:have|had|has)/VB}) {
      return undef;
    }

    # And finally, the next thing should be a verb. If so, we return the 
    # index of the primary verb. If it isn't a verb, return false. 
    if ($target =~ m{^\w+/VB}) {
      my ($voice) = ($auxiliary =~ m{/(\w+)});
      return ($index - 1, $original_index, $index - 1, $voice);
    } else {
      return undef;
    }
  }

  return undef;
}

sub get_all_verbs {
  my ($tagged_words) = @_;
  my $end = @$tagged_words;

  my $nrt = Tree::Range::RB->new({ "cmp" => sub { $_[0] <=> $_[1]; } });

  for(my $i = 0; $i < $end; $i++) {
    my ($index, $start, $end, $voice) = passive_filter($tagged_words, $i);
    if (defined($index)) {
      my @words = @$tagged_words[$start .. $end];
      my $phrase = join(" ", @words);

      my $tagged_verb = $tagged_words->[$index];
      my ($verb) = split("/", $tagged_verb);

      # VBS - present passive
      # VBSP - past passive

      my $tag = "VBS";
      $tag = "VBSP" if ($voice =~ m{^VB[DN]$});

      $nrt->range_set($start, $end + 1, { phrase => $phrase, verb => $verb, index => $index, start => $start, end => $end, tag => $tag});

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

  my @verbs = ();
  my ($ic) = $nrt->range_iter_closure();
  while ((my ($descriptor, $lower, $upper) = $ic->())) {
    next unless (defined($descriptor));
    push @verbs, $descriptor;
  }

  return @verbs;
}

1;

=head1 NAME

Precis::Linguistics - Linguistics for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

