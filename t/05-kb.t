use common::sense;

use Test::Most 'die', tests => 4;
use Precis::Data::KB;

my $kb = Precis::Data::KB->new();

ok(! $@, "Instantiated without error");
ok($kb, "Instantiated a value");

my $entry = $kb->get_token_maker('tumors/NNS');
ok($entry, "Found an entry");
is($entry->{name}, 'tumor/NN', "Correctly found synonym");

done_testing();
