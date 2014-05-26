use common::sense;

use Test::Most 'die', tests => 12;
use Precis::SSIDT;

my $ssidt = Precis::SSIDT->new();

ok(! $@, "Instantiated without error");
ok($ssidt, "Instantiated a value");

# Let's see that we have a first script at least
my $scripts = $ssidt->scripts();
ok($scripts, "Found some scripts");

subtest 'Check all scripts are Precis::MOP' => sub { 
  foreach my $frame (@$scripts) {
    isa_ok($frame, 'Precis::MOP');
  }
};

# Now let's poke at the first frame a bit more...
my $first = $scripts->[0];
my @cds = @{$first->cds()};
is(scalar @cds, 1, "Should be one dependency");

# This should have the right type
isa_ok($cds[0], 'Precis::CD::Trial');

# And now let's poke around at some of the data here.
my @slots = $cds[0]->get_slot_attribute_names();
is(scalar @slots, 4, "Found four slots");

is_deeply(\@slots, ["randomized", "phase", "hypothesis", "outcome"], "Checked proper slot names");

# The roles for these should also be set right
is($cds[0]->randomized()->role(), "*boolean*", "Checked role for slot: randomized");
is($cds[0]->phase()->role(), "*phase*", "Checked role for slot: phase");
is($cds[0]->hypothesis()->role(), "*hypothesis*", "Checked role for slot: hypothesis");
is($cds[0]->outcome()->role(), "*outcome*", "Checked role for slot: outcome");

done_testing();
