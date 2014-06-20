use strict; 
use warnings;

use DBI;
use Text::CSV;

my $dbh = DBI->connect("dbi:mysql:database=gps;host=localhost;port=3306;user=root") or die DBI->errstr();

my $statement = $dbh->prepare(qq{
SELECT km.gene, ktt.name, cs.significance_evidence, cs.significance_reference
FROM known_mutation km
JOIN clinical_significance cs ON cs.mutation_id = km.id
JOIN known_tumour_type ktt ON cs.tumour_type_id = ktt.id
JOIN mutation_characteristics mc ON mc.mutation_id = km.id
WHERE cs.significance_evidence != '' AND cs.significance_evidence != '-'
}) or die $dbh->errstr();

my $csv = Text::CSV->new ({binary => 1, sep_char => "\t", quote_space => 0}) or die "Cannot use CSV: ".Text::CSV->error_diag();
$csv->eol("\n");

my $result = $statement->execute() or die $dbh->errstr();
while (my ($gene, $type, $evidence, $ids) = $statement->fetchrow_array()) {
  my @ids = split(',', $ids);
  foreach my $id (@ids) {
    $id =~ s/^\s+//;
    $id =~ s/\s+$//;
    next unless ($id);
    $csv->print(\*STDOUT, [$gene, $type, $evidence, $id]);
  }
}

1;