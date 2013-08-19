package Precis::Iterator;

use strict;
use warnings;

use Exporter::Declare;
use File::SortedSeek qw(alphabetic);
use List::Util qw(shuffle);
use List::MoreUtils qw(pairwise);

exports qw(iterate);

use Text::CSV;

my $collection_file = "../../data/weeber_AMIA2003_test_collection.txt";
my $abstracts_file = "../../data/abstracts.csv";

our $abstracts_fh;
our $abstracts_csv;

sub _get_text_id_from_line { 
  my $x = shift; 
  my ($r) = $x =~ m{(\d+)}; 
  return $r; 
}

sub get_text_from_id {
  my ($pmid) = @_;

  my $seek = alphabetic($abstracts_fh, $pmid, \&_get_text_id_from_line);
  $abstracts_fh->seek($seek, 0);
  my $row = $abstracts_csv->getline($abstracts_fh);

  return $row->[2];
}

sub iterate {
  my ($options) = @_;

  my $test = $options->{training};
  my $handler = $options->{handler};
  my $test_size = $options->{test_size} // 5;
  my $random_seed = $options->{random_seed} // 42;

  my $csv = Text::CSV->new ({binary => 1, sep_char => "\t"}) or die "Cannot use CSV: ".Text::CSV->error_diag();

  $abstracts_csv = Text::CSV->new ({binary => 1, sep_char => ","}) or die "Cannot use CSV: ".Text::CSV->error_diag();

  open my $fh, "<", $collection_file or die "$collection_file: $!";
  open $abstracts_fh, "<", $abstracts_file or die "$abstracts_file: $!";

  my $table = {};
  while (my $row = $csv->getline($fh)) {
    my $symbol = $row->[0];
    my $sense = $row->[1] ? 1 : 0;
    my $abstracts = $row->[2];
    $table->{$symbol}->{$sense} .= "$abstracts;";
  }
  $csv->eof or $csv->error_diag();
  close $fh;

  # Don't actually be random. We seed with a value which means we ought to get predictable
  # values out of randomness. This is intentional - we get a pseudo-random distribution, but 
  # we can rely on the same pseudo-random values for training and testing, so the test set 
  # complements the training set properly. This could be done better. 
  srand($random_seed);
  
  foreach my $symbol (sort keys %$table) {

    if (! $table->{$symbol}->{0} || ! $table->{$symbol}->{1}) {
      next;
    }
    my @abstracts1 = split(";", $table->{$symbol}->{0});
    my @abstracts2 = split(";", $table->{$symbol}->{1});
    if ($#abstracts1 < $test_size || $#abstracts2 < $test_size) {
      next;
    }

    # Always shuffle everything. Otherwise the amount of randomness consumption may vary
    # from training to test, leading to non-orthogonal sets.
    my @shuffled1 = shuffle(@abstracts1);
    my @shuffled2 = shuffle(@abstracts2);
    my @shuffled1_idx = (0..$#shuffled1);
    my @shuffled2_idx = (0..$#shuffled2);

    my @points = ((pairwise { [($a++ < $test_size ? 1 : 0), 0, $b] } @shuffled1_idx, @shuffled1), 
                  (pairwise { [($a++ < $test_size ? 1 : 0), 1, $b] } @shuffled2_idx, @shuffled2));

    foreach my $point (@points) {
      if ($point->[0] == $test) {
        my $abstract = get_text_from_id($point->[2]);
        &$handler(@$point, $symbol, $abstract);
      }
    }
  }
  close $abstracts_fh;
}

1;