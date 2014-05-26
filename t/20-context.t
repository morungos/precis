use common::sense;

use Test::Most 'die', tests => 1;

use Precis::Context;

my $self = Precis::Context->new();
ok($self, "Instantiated a context OK");

1;