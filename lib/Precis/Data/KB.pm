package Precis::Data::KB;

use common::sense; 

use Moose::Role;
use namespace::autoclean;

use Carp;
use YAML qw(LoadFile);
use File::Spec;
use Module::Load;
use Scalar::Util qw(weaken);
use Log::Any qw($log);

use Precis::Data::AU;

# A reorganized version of the knowledge base, we really don't need the level of meta-work that we 
# used to use, this is defined more directly as a set of Moose structures.

has action_units => (
  is => 'ro',
  default => sub { {} }
);

has token_makers => (
  is => 'ro',
  default => sub { {} }
);

has event_builders => (
  is => 'ro',
  default => sub { {} }
);

sub BUILD {
  my ($self) = @_;
  $self->initialize_action_units();
  $self->initialize_token_makers();
  $DB::single = 1;
  return;
}

sub initialize_action_units {
  my ($self) = @_;

  my ($volume,$directories,$file) = File::Spec->splitpath(__FILE__);
  my $source = File::Spec->catpath($volume, $directories, "ActionUnits.yml");

  my $data = LoadFile($source);

  my $action_units = $self->action_units();

  while(my ($key, $value) = each %$data) {
    my $name = $key;
    my $args = {name => $name};
    $args->{parent} = $value->{isa} if (exists($value->{isa}));
    $args->{roles} = $value->{roles} if (exists($value->{roles}));
    $args->{attributes} = $value->{attributes} if (exists($value->{attributes}));
    my $au = Precis::Data::AU->new($args);
    $action_units->{$name} = $au;
  }

  # Change parent names to parent references
  # Add child references. Make these weak references. 
  while(my ($name) = each %$data) {
    my $au = $action_units->{$name};
    if (defined(my $parent = $au->parent())) {
      my $parent_ref = $action_units->{$parent};
      croak("Can't find AU: $parent") if (! defined($parent_ref));
      $au->parent($parent_ref);
      push @{$parent_ref->children()}, weaken($au);
    }
  }
}

sub initialize_token_makers {
  my ($self) = @_;

  my ($volume,$directories,$file) = File::Spec->splitpath(__FILE__);
  my $source = File::Spec->catpath($volume, $directories, "TokenMakers.yml");

  my $data = LoadFile($source);

  my $token_makers = $self->token_makers();
  my $action_units = $self->action_units();

  while(my ($key, $value) = each %$data) {
    $token_makers->{$key}->{name} = $key;
    if (defined(my $associated_aus = $value->{associated_action_units})) {
      foreach my $associated_au (@$associated_aus) {
        my $name = $associated_au->{name};
        my $au = $action_units->{$name} // croak "Can't find AU: $name";
        push @{$token_makers->{$key}->{associated_action_units}}, $au;
      }
    } elsif (defined(my $synonym = $value->{synonym})) {
      $token_makers->{$key}->{synonym} = $synonym;
    }
  }
}

sub get_token_maker {
  my ($self, $token_constituents) = @_;

  my $symbol = $token_constituents->[-1];

  my $index = rindex($symbol, "/");
  my $word = substr($symbol, 0, $index);
  my $tag = substr($symbol, $index + 1);

  if (lcfirst($word) eq lc($word)) {
    $symbol = lc($word) . "/" . $tag;
  }

  $log->debugf("Checking token: %s", $symbol);

  my $token_makers = $self->token_makers();
  my $entry = $token_makers->{$symbol} // return undef;
  while(exists($entry->{synonym})) {
    my $synonym = $entry->{synonym};
    $entry = $token_makers->{$synonym} // croak "Can't find token maker synonym: $synonym";
  }

  $log->debugf("Checking token: %s => %s", $symbol, $entry);
  return $entry;
}

1;
