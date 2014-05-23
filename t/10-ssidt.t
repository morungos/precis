use common::sense;

use Test::Most 'die', tests => 4;
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

done_testing();