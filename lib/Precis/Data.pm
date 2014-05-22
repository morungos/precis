package Precis::Data;

use common::sense; 

use Sub::Exporter -setup => {
  exports => [ qw(find_bootstrap_frame) ],
};

use Precis::CD;
use Precis::PartialFrame;

state $bootstrap_frames = {
  "mutate#v" => sub {
    my ($self, $index, $notes) = @_;
    return undef if ($notes->{tag} eq 'VBN');
    my $cd = Precis::CD->new({type => 'MUTATION', notes => $notes});
    my $slots = $cd->slots();
    $slots->{object} = {type => '*genomic_object'};
    my $frame = Precis::PartialFrame->new();
    $frame->add_cd($cd);
    return $frame;
  }
};

sub find_bootstrap_frame {
  my ($context, $word, $index, $notes) = @_;
  if (defined(my $frame = $bootstrap_frames->{$word})) {
    return &$frame($context, $index, $notes);
  } else {
    return undef;
  }
}

1;