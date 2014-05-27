use common::sense;

use Test::Most 'die', tests => 5;

use Precis::Expectation;

my $actions = [];

sub expectation_test {
  my ($context, $word) = @_;
  return $word eq 'test';
}

sub expectation_action {
  my ($context, $word) = @_;
  push @$actions, "added-$word";
}

my $instance = Precis::Expectation->new({test => \&expectation_test, action => \&expectation_action});
ok($instance, "Made an instance OK");

my $value = $instance->test();
ok(&$value(undef, 'test'), "Succeeds for the matching value");
ok(! &$value(undef, 'test_other'), "Fails for a non-matching value");

is_deeply($actions, [], "No values yet");

$value = $instance->action();
&$value(undef, 'test');

is_deeply($actions, ['added-test'], "Now we have a value");
$actions = [];

1;