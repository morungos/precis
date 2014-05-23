package Precis::Data;

use common::sense; 

use Sub::Exporter -setup => {
  exports => [ qw(find_bootstrap_cd) ],
};

use Precis::PartialFrame;

# Much of the data here is really about what should be considered an inclusive form
# for the data we are looking for, and where's the evidence. As such, it's largely about
# detecting whether something is a clinical trial or not, or perhaps some other kind of
# study. What goes on inside a clinical trial is a later issue. So we can start with
# bootstrapping from something other than a verb that indicates a mutation. This happens
# to be one of the factors that comes up later. 

state $bootstrap_cds = {
  # "mutate#v" => sub {
  #   my ($self, $index, $notes) = @_;
  #   return undef if ($notes->{tag} eq 'VBN');
  #   my $cd = Precis::CD->new({type => 'MUTATION', notes => $notes});
  #   my $slots = $cd->slots();
  #   $slots->{object} = {type => '*genomic_object'};
  #   return $cd;
  # }
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