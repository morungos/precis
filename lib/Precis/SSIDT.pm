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

has tree => (
  is      => 'ro',
  default => sub { {} },
);

sub BUILD {
  my ($self) = @_;
  my ($volume,$directories,$file) = File::Spec->splitpath(__FILE__);
  my $source = File::Spec->catpath($volume, $directories, "scripts.yml");
  $self->initialize_with_yaml($source);
  $self->compile();
};

sub initialize_with_yaml {
  my ($self, $source) = @_;
  my $data = LoadFile($source);

  foreach (@$data) {
    push @{$self->scripts()}, $self->initialize_frame($_)
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
    $partial->add_cd($cd);

    delete($cd_data->{TYPE});
    my $meta = $cd->meta();
    foreach my $slot (keys %$cd_data) {
      my $attribute = $meta->find_attribute_by_name($slot);
      my $slot_object = $attribute->get_value($cd);
      my $values = $cd_data->{$slot};
      foreach my $data_key (keys %$values) {
        my $data_value = $values->{$data_key};
        $slot_object->$data_key($data_value);
      }
    }
  }

  return $partial;
}

# Routines for compiling the scripts into the SSIDT, so we can then work
# through the tree in the predictor.

sub compile {
  my ($self) = @_;
  my @scripts = @{$self->scripts()};
  foreach my $script (@scripts) {
    $self->compile_script($script);
  }
}

sub compile_script {
  my ($self, $script) = @_;
  my @cds = @{$script->cds()};
  foreach my $cd (@cds) {
    $self->compile_script_cd($script, $cd);
  }
}

sub compile_script_cd {
  my ($self, $script, $cd) = @_;
  my $class = $cd->meta()->name();
  my @slots = $cd->get_slot_attributes();

  my @tests = ("class:$class");
  foreach my $slot (@slots) {
    my $slot_name = $slot->name();
    my $role_value = $slot->get_value($cd)->role();
    push @tests, "slot:$slot_name:$role_value";
  }
  _compile_entry_aux($self, $script, $self->tree(), @tests);
}

sub _compile_entry_aux {
  my ($self, $script, $data, @tests) = @_;

  if (! @tests) {
    return;
  }
  my $first = shift @tests;
  if (! @tests) {
    $data->{$first} = $script;
  } else {
    $data->{$first} = {} if (! exists($data->{$first}));
    _compile_entry_aux($self, $script, $data->{$first}, @tests);
  }
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
