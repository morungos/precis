package Precis::Bootstrap;

use common::sense; 

use Moose::Role;

# A role that provides the get_bootstrap_targets method, which is the main component
# delivered by the Bootstrap module. 

sub get_bootstrap_targets {
  my ($self) = @_;

  my $tagged_words = $self->tagged_words();
  my $index = 0;
  foreach my $word (@$tagged_words) {
    my ($word, $tag) = split(qr{/}, $word);
    if ($tag =~ m{^VB}) {
      say "$index, $word, $tag";
    }
    $index++;
  }
}

1;

=head1 NAME

Precis::Bootstrap - Bootstrap for the text analyzer

=head1 SYNOPSIS

TBD.

=cut 

