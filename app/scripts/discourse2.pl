use strict; 
use warnings;

use List::MoreUtils qw(indexes);

use Precis::Iterator qw(iterate);
use Precis::Tokenizer qw(tokenize);

my $window_size = 10;
my $alpha = 0.1;

my $table = {};

iterate({
  training => 1,
  handler => sub {
    my ($training, $sense, $pmid, $symbol, $text) = @_;
    # print STDOUT "$training,$sense,$pmid,$symbol\n";

    # Right, now we can start to do some real shit.
    my @tokens = tokenize($text);

    foreach my $position (indexes { $_ eq $symbol } @tokens) {
      my $start = $position - $window_size;
      my $end = $position + $window_size;
      $start = 0 if ($start < 0);
      $end = $#tokens if ($end > $#tokens);

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
        $table->{$key} = [0, 0] if (! exists($table->{$key}));
        $table->{$key}->[$sense]++;
      }
    }
  }
});

# Second pass, delete rare items, somewhat arbitarily
my @rare = grep { 
  my $counts = $table->{$_};
  $counts->[0] + $counts->[1] < 10
} keys %$table;
foreach my $key (@rare) {
  delete $table->{$key};
}

my $totals = {};
foreach my $key (keys %$table) {
  my ($partition, $symbol) = split(":", $key, 2);
  $totals->{$partition} = [0, 0] if (! exists($totals->{$partition})); 
  $totals->{$partition}->[0] += $table->{$key}->[0];
  $totals->{$partition}->[1] += $table->{$key}->[1];
}

# Now we can compute log likelihoods for each and every token. In this case, we
# also want to built a value into an array, so we can sort and print them afterwards. 
# This will form the basis for the decision list.

my $likelihoods = {};
foreach my $key (keys %$table) {
  my ($partition, $symbol) = split(":", $key, 2);
  my $counts = $table->{$key};
  my $total = $counts->[0] + $counts->[1];
  my $likelihood = log((($counts->[0] + $alpha) / ($total + $alpha)) /
                       (($counts->[1] + $alpha) / ($total + $alpha)));
  $likelihoods->{$key} = $likelihood;
}

# This is purely for display. At this stage, we can also save the data for use in 
# testing. For now, let's write out the data as a CSV file that we can read in 
# for the testing stage. 
my @sorted = sort { abs($likelihoods->{$b}) <=> abs($likelihoods->{$a}) } keys %$likelihoods;
foreach my $key (@sorted) {
  my $counts = $table->{$key};
  print "$key,$likelihoods->{$key},$counts->[0],$counts->[1]\n" unless ($likelihoods->{$key} == 0);
}
