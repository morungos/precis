use strict; 
use warnings;

$| = 1;

use List::MoreUtils qw(indexes);
use JSON;
use Text::CSV;

use Precis::Iterator qw(iterate);
use Precis::Tokenizer qw(tokenize);

my $window_size = 10;

my $csv = Text::CSV->new ( { binary => 1 } );
$csv->eol("\n");

my $table = {};
my $decision_list_file = "../../data/decision_lists3.csv";
open my $fh, "<", $decision_list_file or die "$decision_list_file: $!";
while (my $line = <$fh>) {
  chomp($line);
  my ($key, $score) = split(",", $line);
  $table->{$key} = $score;
};
close($fh);

my $results = {};

iterate({
  training => 0,
  handler => sub {
    my ($training, $sense, $pmid, $symbol, $text) = @_;
    # print STDOUT "$training,$sense,$pmid,$symbol\n";

    return if (! $text);

    # Right, now we can start to do some real shit.
    my @tokens = tokenize($text);

    my @scores = ();

    foreach my $position (indexes { $_ eq $symbol } @tokens) {
      my $start = $position - $window_size;
      my $end = $position + $window_size;
      $start = 0 if ($start < 0);
      $end = $#tokens if ($end > $#tokens);

      my $total_score = 0.0;

      foreach my $i ($start..$end) {
        my $token = $tokens[$i];

        my $partition = 
          ($i == $position) ? 0 :
          ($i == $position - 1) ? 1 :
          ($i == $position + 1) ? 2 : 3;
        next if (! $partition);
        next if ($token eq $symbol);

        # At this stage, partition 1 = left adjacent, 2 = right adjacent, and 3 = window. We also have the
        # sense available. So we can now start to build the table. First, compose a new key, based on partition
        # and symbol. 

        my $key = "$partition:$token";
        next if (! exists($table->{$key}));
        my $score = $table->{$key};
        $total_score += $score;
      }

      push @scores, ['AGGREGATE', $total_score];
    }

    @scores = sort { abs($b->[1]) <=> abs($a->[1]); } @scores;
    my $maximum = $scores[0];

    if (! defined($maximum)) {
      $maximum = ['UNKNOWN', 0];
    }

    my $inferred_sense = ($maximum->[1] < 0) ? 1 : 0;

    my $data = [$sense, $inferred_sense, $symbol, $text, @$maximum];
    $csv->print(\*STDOUT, $data);

    $results->{$sense}->{$inferred_sense}++;
  }
});

print STDERR encode_json($results);