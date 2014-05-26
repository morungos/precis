use common::sense;

use Test::Most 'die', tests => 18;

use Precis::CD::Trial;

my $instance = Precis::CD::Trial->new();
$instance->randomized()->role('boolean');
$instance->phase()->role('phase');
$instance->hypothesis()->role('hypothesis');
$instance->outcome()->role('outcome');

is($instance->randomized()->value(), undef, "Slot value is undefined");
is($instance->phase()->value(), undef, "Slot value is undefined");
is($instance->hypothesis()->value(), undef, "Slot value is undefined");
is($instance->outcome()->value(), undef, "Slot value is undefined");

ok(! $instance->randomized()->is_complete(), "Slot is incomplete");
ok(! $instance->phase()->is_complete(), "Slot is incomplete");
ok(! $instance->hypothesis()->is_complete(), "Slot is incomplete");
ok(! $instance->outcome()->is_complete(), "Slot is incomplete");

ok(! $instance->is_complete(), "CD is incomplete");

$instance->randomized()->value(1);

is($instance->randomized()->value(), 1, "Slot value is now set");
ok(! $instance->randomized()->is_complete(), "Slot is still incomplete");

$instance->randomized()->is_complete(1);
ok($instance->randomized()->is_complete(), "Slot is now complete");

ok(! $instance->is_complete(), "CD is still incomplete");

$instance->phase()->value("1");
$instance->hypothesis()->value("Some hypothesis");
$instance->outcome()->value(undef);

$instance->phase()->is_complete(1);
$instance->hypothesis()->is_complete(1);
$instance->outcome()->is_complete(1);

ok($instance->randomized()->is_complete(), "Slot is now complete");
ok($instance->phase()->is_complete(), "Slot is now complete");
ok($instance->hypothesis()->is_complete(), "Slot is now complete");
ok($instance->outcome()->is_complete(), "Slot is now complete");

ok($instance->is_complete(), "CD is now complete");

1;