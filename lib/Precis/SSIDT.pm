package Precis::SSIDT;

use common::sense; 

use MooseX::Singleton;
use namespace::autoclean;

use Precis::PartialFrame;

use YAML qw(LoadFile);
use File::Spec;
use Module::Load;

has scripts => (
  is      => 'ro',
  default => sub { [] },
);

sub BUILD {
  my ($self) = @_;
  my ($volume,$directories,$file) = File::Spec->splitpath(__FILE__);
  my $source = File::Spec->catpath($volume, $directories, "scripts.yml");
  $self->initialize_with_yaml($source);
};

sub initialize_with_yaml {
  my ($self, $source) = @_;
  my $data = LoadFile($source);

  foreach (@$data) {
    push @{$self->scripts()}, initialize_frame($_)
  }
}

sub initialize_frame {
  my ($self, $frame_data) = @_;

  my $name = $frame_data->{name};
  my $partial = Precis::PartialFrame->new();

  foreach my $cd_data (@{$frame_data->{cds}}) {
    my $class = $cd_data->{TYPE};
    load $class;
    my $cd = $class->new();

  }

  return $partial;
}

1;

=head1 NAME

Precis::SSIDT - Sketchy script discriminator tree

=head1 DESCRIPTION

The sketchy script discriminator tree is actually compiled from a range of
build-in scripts. We need to define these scripts, and then build the SSIDT
from their little pieces. Each script is a graph of conceptual dependencies,
probably with some additional constraints applied to them. 

=cut 
