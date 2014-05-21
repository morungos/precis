package Precis::Data;

use common::sense; 

use Sub::Exporter -setup => {
  exports => [ qw(get_bootstrap_frames) ],
};

sub get_bootstrap_frames {

  state $result = {
    "mutate#v-VBx" => sub {
      my ($self, $index, $notes) = @_;
      my $cd = Precis::CD->new({type => 'ASSOCIATION'});
    }
  };

  return $result;
}

1;