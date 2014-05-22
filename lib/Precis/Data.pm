package Precis::Data;

use common::sense; 

use Sub::Exporter -setup => {
  exports => [ qw(find_bootstrap_cd) ],
};

use Precis::CD;
use Precis::PartialFrame;

state $bootstrap_cds = {
  "mutate#v" => sub {
    my ($self, $index, $notes) = @_;
    return undef if ($notes->{tag} eq 'VBN');
    my $cd = Precis::CD->new({type => 'MUTATION', notes => $notes});
    my $slots = $cd->slots();
    $slots->{object} = {type => '*genomic_object'};
    return $cd;
  }
};

sub find_bootstrap_cd {
  my ($context, $word, $index, $notes) = @_;
  if (defined(my $cd_generator = $bootstrap_cds->{$word})) {
    return &$cd_generator($context, $index, $notes);
  } else {
    return undef;
  }
}

1;