package Precis::Bootstrap;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

use Tree::Range::RB;

use Precis::Linguistics qw(get_all_verbs);
use Precis::Data qw(find_bootstrap_cd);

requires 'get_valid_form';

# A role that provides the get_bootstrap_targets method, which is the main component
# delivered by the Bootstrap module. 

sub get_bootstrap_targets {
  my ($self) = @_;

  my $tagged_words = $self->tagged_words();
  my @verbs = get_all_verbs($tagged_words);

  my @cds = ();
  foreach my $descriptor (@verbs) {
    my $form = $self->get_valid_form($descriptor->{verb});
    my $index = $descriptor->{index};
    $descriptor->{form} = $form;

    my $cd = find_bootstrap_cd($self, $form, $index, $descriptor) // next;
    push @cds, $cd;
  }

  foreach my $cd (@cds) {
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

