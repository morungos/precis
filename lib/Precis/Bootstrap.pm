package Precis::Bootstrap;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

use List::MoreUtils qw(indexes);

use Precis::Linguistics qw(get_all_verbs);
use Precis::Data qw(find_bootstrap_cd);

requires 'get_valid_form';

# A role that provides the get_bootstrap_targets method, which is the main component
# delivered by the Bootstrap module. This shouldn't need to know too much about the
# details of what we are after, as there is a lot of room for confirmation and 
# fleshing out the details afterwards. 

sub get_bootstrap_targets {
  my ($self) = @_;

  my $tagged_words = $self->tagged_words();
  # my @verbs = get_all_verbs($tagged_words);

  my @term_indexes = indexes {
    m{^trial/NN$}i || m{^trials/NNS$}i
  } @$tagged_words;

  # This is where Moose-like frame stuff would be extremely useful. 
  foreach my $index (@term_indexes) {
    my $tagged_word = $tagged_words->[$index];
    my ($word, $tag) = split("/", $tagged_word);
    my $descriptor = { phrase => $word, noun => $word, index => $index, start => $index, end => $index, tag => $tag};
    my $cd = Precis::CD->new({type => 'TRIAL', notes => $descriptor});
    my $slots = $cd->slots();
    $slots->{RANDOMIZED} = {type => '*boolean'};
    $slots->{PHASE} = {type => '*phase'};
    $slots->{HYPOTHESIS} = {type => '*hypothesis'};
    $slots->{OUTCOME} = {type => '*outcome'};
    my $frame = Precis::PartialFrame->new();
    $frame->add_cd($cd);
    $self->queue_frame($frame);
  }

}

1;

=head1 NAME

Precis::Bootstrap - Bootstrap for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

