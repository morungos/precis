use common::sense;

use Test::Most 'die', tests => 1;

use MooseX::ClassCompositor;
use Precis::LanguageTools;
use Precis::LexicalClassifier;

# Test a role: see: http://www.perlmonks.org/?node_id=918837
my $class = MooseX::ClassCompositor->new({class_basename => 'Test'})->class_for('Precis::LanguageTools', 'Precis::LexicalClassifier');

my $instance = $class->new();
ok($instance, "Made an instance OK");

my $result = $instance->classify_token("activation/NN");

1;