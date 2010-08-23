# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Random-Interval.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Try::Tiny;
use Data::Dumper;

my %invalid_intervals = (
	{    -5 => -3, -7 => 2  } => "Overlapping intervals specified.\n",
	{     0 =>  5,  2 => 6  } => "Overlapping intervals specified.\n",
	{     2 =>  6,  0 => 5  } => "Overlapping intervals specified.\n",
	{   -10 => 17,  6 => 12 } => "Overlapping intervals specified.\n",
	{ undef =>  4,  5 => 7  } => "Overlapping intervals specified.\n",
);

use Test::More tests => 2 + scalar(keys(%invalid_intervals));
BEGIN { use_ok('Random::Interval') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

while (my ($interval, $expected) = each %invalid_intervals) {
	my $exception;
	try {
		my $rand_invalid = Random::Interval->new( intervals => $interval );
	} catch {
		$exception = $_;
	};
	chomp $expected;
	ok defined $exception && $exception eq $expected,
	   sprintf('Invalid interval detected, expected "%s"', $expected);
}

ok(defined $rand, "Class instance defined");
