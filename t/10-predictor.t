use common::sense;

use Test::Most 'die', tests => 5;

use MooseX::ClassCompositor;
use Precis::Predictor;

use Precis::CD::Trial;
use Precis::PartialFrame;

# Test a role: see: http://www.perlmonks.org/?node_id=918837
my $class = MooseX::ClassCompositor->new({ class_basename => 'Test' })->class_for( 'Precis::Predictor' );

my $instance = $class->new();
ok($instance, "Made an instance OK");

my $cd = Precis::CD::Trial->new({type => 'TRIAL'});
$cd->randomized()->role('boolean');
$cd->phase()->role('phase');
$cd->hypothesis()->role('hypothesis');
$cd->outcome()->role('outcome');

my $frame = Precis::PartialFrame->new();
$frame->add_cd($cd);

my @result = $instance->predict($frame);
is(@result, 1, "Found predictions");

is($result[0]->{dependency_index}, 0, "Found the right dependency index");
is($result[0]->{slot}, "randomized", "Found the right dependency slot");
is($result[0]->{filler}, "*boolean*", "Found the right dependency filler");

1;