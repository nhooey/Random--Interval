# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Random-Interval.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Try::Tiny;
use Data::Dumper;

use strict;
use warnings;

my @invalid_intervals = (
	{
		interval => { -5 => -3, -7 => 2 },
		expected => "Overlapping intervals specified.\n",
	},
	{
		interval => { 0 => 5, 2 => 6 },
		expected => "Overlapping intervals specified.\n",
	},
	{
		interval => { 2 => 6, 0 => 5 },
		expected => "Overlapping intervals specified.\n",
	},
	{
		interval => { -10 => 17, 6 => 12 },
		expected => "Overlapping intervals specified.\n",
	},
	{
		interval => { 4 => undef, 5 => 7 },
		expected => "Undefined values not allowed in intervals.\n",
	},
);

use Test::More tests => 6;
BEGIN { use_ok('Random::Interval') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

for my $test (@invalid_intervals) {
	my $exception;
	try {
		my $rand_invalid = Random::Interval->new( intervals => $test->{interval} );
	} catch {
		$exception = $_;
	};
	ok defined $exception && $exception eq $test->{expected},
	   sprintf('Invalid interval detected, expected "%s"', $test->{expected});
}
