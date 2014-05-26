use common::sense;

use Test::Most 'die', tests => 2;

use MooseX::ClassCompositor;
use Precis::Predictor;

use Precis::CD::Trial;
use Precis::PartialFrame;

# Test a role: see: http://www.perlmonks.org/?node_id=918837
my $class = MooseX::ClassCompositor->new({ class_basename => 'Test' })->class_for( 'Precis::Substantiator' );

my $instance = $class->new();
ok($instance, "Made an instance OK");

my $cd = Precis::CD::Trial->new({type => 'TRIAL'});
$cd->randomized()->role('boolean');
$cd->phase()->role('phase');
$cd->hypothesis()->role('hypothesis');
$cd->outcome()->role('outcome');

my $frame = Precis::PartialFrame->new();
$frame->add_cd($cd);

my $result = $instance->substantiate($frame, {dependency_index => 0, slot => "randomized", filler => "*boolean*"});
is($result, undef, "Found no substantiation");

1;