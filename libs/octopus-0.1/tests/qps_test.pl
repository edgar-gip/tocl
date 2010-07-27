use strict;
use warnings;

# Open the readme file
open(my $fin, "qps/qpdata.txt") or die "Can't open qps/qpdata.txt: $!\n";

# Read each problem
my @problems;
while (<$fin>) {
    # Format ?
    if (/^\s*(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+
         ([\+\-\d\.Ee]+)\s*$/x) {
	push(@problems, { 'name'                 => uc($1),
			  'constraints'          => $2,
			  'variables'            => $3,
			  'non_zero_constraints' => $4,
			  'quadratic_variables'  => $5,
			  'quadratic_non_zero'   => $6,
			  'objective'            => $7 });
    }
}

# Sort
@problems = sort { $a->{'variables'} <=>
		   $b->{'variables'} } @problems;

# For each one
foreach my $p (@problems) {
    # Find it
    my ($dir) = grep { -e "qps/qpdata$_/$p->{name}.QPS" } (1 .. 3);
    if (!defined($dir)) {
	warn "Cannot find file for problem $p->{name}\n";
	next;
    }

    # Call it
    system("octave -q qps_test.m qps/qpdata$dir/$p->{name}.QPS $p->{objective}");
}
