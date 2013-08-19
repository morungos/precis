# This is an implementation, in Perl, of the "one sense per discourse, one sense per collation"
# technique for disambiguating gene symbols. See the papers by Yarowsky for full information.
# For baseline performance assessment, we'll use (eventually) the test collection from
# The Erasmus Medical Informatics folks.

use strict; 
use warnings;

use Text::CSV;
use PDL;

# First of all, we need a training collection. This should really be a subset of PubMed, but it
# doesn't need to be drawn from the same set used by Erasmus. It also ought to provide an interesting 
# range of ambiguous cases. We can start with something very small, though.

my $training_file = "data/training.csv";

my $window_size = 10;

# We don't care about word pairs for now. We only are interested in the following types of collocations:
# words immediately to the left, to the right, and in the window. There is also a good case that could
# be made for a title collocation, with title terms providing a context for the terms. Although we might
# well find that the first or last sentence is a better context. For now, we stick with the simple 
# contextual forms, though. 

my $relationships = [
  'left_adjacent',
  'right_adjacent',
  'window'
];

# STEP 2. We don't use hand-tagging, but we identify collocations that are totally unambiguous.

my $seed_tags = {
  "gene" => 'GENE',
  "phase" => 'NONGENE'
};

# Token types that we very probably want:
#  - mutations (we have regexes for these, approximately) - these are really good for us
#  - numbers, distinguishing floats, integers, percentages, and ranges of these
#  - maybe open/close parens
#  - greek letters
#  - relations, <, >, = 

# In many cases, what we need to be able to do is iterate through the collection focusing on terms
# with contextual windows available to us. This means we have a callback involving the term, and a
# useful window of contextual terms.

sub iterate_file {
  my ($file, $selector, $handler) = @_;
  my $csv = Text::CSV->new ({binary => 1}) or die "Cannot use CSV: ".Text::CSV->error_diag();
  open my $fh, "<", $file or die "file: $!";
  while (my $row = $csv->getline($fh)) {
    &$handler(&$selector($row));
  }
  $csv->eof or $csv->error_diag();
  close $fh;
}

sub abstract_selector {
  my ($row) = @_;
  return $row->[2];
}


# A simple tokenizer, using basic regular expressions. This should actually be sophisticated, as 
# tokens such as c-KIT need to be handled right. 
sub tokenize {
  my ($text) = @_;
  my @tokens = $text =~ m{\p{Word}+}g;
  return @tokens;
}

sub iterate_collocations {
  my ($tokens, $offset, $handler) = @_;
  my $last = $#$tokens;
  if ($offset > 0) {
    &$handler('left_adjacent', $tokens->[$offset - 1]);
  }
  if ($offset < $last) {
    &$handler('right_adjacent', $tokens->[$offset + 1]);
  }
  my $start = $offset - $window_size;
  $start = 0 if ($start < 0);
  my $end = $offset + $window_size;
  $end = $last if ($end > $last);
  for my $i ($start..$end) {
    if ($i < $offset - 1 || $i > $offset + 1) {
      &$handler('window', $tokens->[$i]);
    }
  }
  print "----\n";
}

iterate_file('data/sources.csv', \&abstract_selector, sub {
  my ($string) = @_;
  my @tokens = tokenize($string);
  my $index = 0;
  foreach my $token (@tokens) {
    if ($token eq 'KIT') {
      iterate_collocations(\@tokens, $index, sub { my ($type, $term) = @_; print "$type, $term\n"; });
    }
    $index++;
  }
});

