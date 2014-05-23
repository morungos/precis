use common::sense;

use Test::Most 'die', tests => 8;
use Precis::SSIDT;

my $ssidt = Precis::SSIDT->new();

ok(! $@, "Instantiated without error");
ok($ssidt, "Instantiated a value");

# Let's see that we have a first script at least
my $scripts = $ssidt->scripts();
ok($scripts, "Found some scripts");

subtest 'Check all scripts are Precis::PartialFrame' => sub { 
  foreach my $frame (@$scripts) {
    isa_ok($frame, 'Precis::PartialFrame');
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

done_testing();
