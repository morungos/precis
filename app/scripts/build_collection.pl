# This is an implementation, in Perl, of the "one sense per discourse, one sense per collation"
# technique for disambiguating gene symbols. See the papers by Yarowsky for full information.
# For baseline performance assessment, we'll use (eventually) the test collection from
# The Erasmus Medical Informatics folks.

use strict; 
use warnings;

use DBI;
use Text::CSV;
use List::Util qw(shuffle);

# First of all, we need a training collection. This should really be a subset of PubMed, but it
# doesn't need to be drawn from the same set used by Erasmus. It also ought to provide an interesting 
# range of ambiguous cases. We can start with something very small, though.

my $collection_file = "data/weeber_AMIA2003_test_collection.txt";

my $csv = Text::CSV->new ({binary => 1, sep_char => "\t"}) or die "Cannot use CSV: ".Text::CSV->error_diag();

my $dbh = DBI->connect("dbi:mysql:database=pubmed;host=db1.hpc.oicr.on.ca;port=3306", "swatt", q{d1n0$aur}) or die DBI->errstr();

# Insert interesting query here!
my $statement = $dbh->prepare(qq{
SELECT a.title, a.pub_year, ab.abstract, ab.label, i.pmid 
FROM info i 
JOIN article a ON a.uid = i.uid
JOIN abstract ab ON ab.uid = i.uid
WHERE i.pmid = ?
ORDER BY ab.category_id ASC
}) or die $dbh->errstr();

sub write_row {
  my ($symbol, $sense, $training, $pmid) = @_;
  my $record = [$symbol, $sense, $training, $pmid];

  my $result = $statement->execute($pmid) or die $dbh->errstr();

  my $results = $statement->fetchall_arrayref([]);
  if (@$results) {
    my @elements = map { ($_->[3] ? "$_->[3]. " : "") . $_->[2] } @$results;
    my $abstract = join(" ", @elements);
    push @$record, $results->[0]->[0], $abstract;
  } else {
    print STDERR "Failed to find PubMed records: $pmid\n";
    return;
  }

  $csv->print(\*STDOUT, $record);
  print STDOUT "\n";
}

sub iterate_file {
  my ($file) = @_;

  open my $fh, "<", $file or die "file: $!";

  my $table = {};
  while (my $row = $csv->getline($fh)) {
    my $symbol = $row->[0];
    my $sense = $row->[1] ? 1 : 0;
    my $abstracts = $row->[2];
    $table->{$symbol}->{$sense} .= "$abstracts;";
  }
  $csv->eof or $csv->error_diag();
  close $fh;

  foreach my $symbol (sort keys %$table) {
    if (! $table->{$symbol}->{0} || ! $table->{$symbol}->{1}) {
      next;
    }
    my @abstracts1 = split(";", $table->{$symbol}->{0});
    my @abstracts2 = split(";", $table->{$symbol}->{1});
    if ($#abstracts1 < 5 || $#abstracts2 < 5) {
      next;
    }

    # Now pick a random five from each. Record these, but spit out a new tab file that allows us
    # to ensure we use the others for testing. This isn't entirely ideal, but it is in line with
    # Schijvenaars et al. (2005).

    my @shuffled1 = shuffle(@abstracts1);
    my @shuffled2 = shuffle(@abstracts2);

    my $index = 0;
    foreach my $id (@shuffled1) {
      write_row($symbol, 0, ($index++ < 5 ? 1 : 0), $id);
    }
    $index = 0;
    foreach my $id (@shuffled2) {
      write_row($symbol, 1, ($index++ < 5 ? 1 : 0), $id);
    }
  }
}

iterate_file($collection_file);

