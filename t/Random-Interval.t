use Try::Tiny;
use Data::Dumper;

use strict;
use warnings;

my @invalid_intervals = (
	{
		intervals => [ [ -5, -3 ], [ -7 => 2 ] ],
		expected  => "Overlapping intervals specified: 2 > -5\n",
	},
	{
		intervals => [ [ 0, 5 ], [ 2 => 6 ] ],
		expected  => "Overlapping intervals specified: 5 > 2\n",
	},
	{
		intervals => [ [ 2, 6 ], [ 0 => 5 ] ],
		expected  => "Overlapping intervals specified: 5 > 2\n",
	},
	{
		intervals => [ [ -10, 17 ], [ 6 => 12 ] ],
		expected  => "Overlapping intervals specified: 17 > 6\n",
	},
	{
		intervals => [ [ 4, undef ], [ 5 => 7 ] ],
		expected  => "Undefined values not allowed in intervals.\n",
	},
);

my @valid_intervals = (
	{
		intervals => [
			[ -5, -3 ],
			[ -1,  6 ],
			[  8, 15 ],
		],
		rand_max  => 16,
		params    => {
			rand => {
				0   => -5,
				1   => -4,
				1.5 => -3.5,
				3   =>  0,
				2   => -3,
				14  => 13,
			},
		},
	},
	{
		intervals => [
			[ -5, -3 ],
			[ -1,  6 ],
			[  8, 15 ],
		],
		rand_max  => 19,
		integer   => 1,
		inclusive => 1,
		params    => {
			rand => {
				0   => -5,
				0.5 => -5,
				2   => -3,
				18  => 15,
			},
		},
	},
);

use Test::More tests => 1 + 5 + (1+6 + 1+4);
BEGIN { use_ok('Random::Interval') };

for my $test (@invalid_intervals) {
	my $exception;
	try {
		my $rand_invalid = Random::Interval->new( intervals => $test->{intervals} );
	} catch {
		$exception = $_;
	};
	ok defined $exception && $exception eq $test->{expected},
	   sprintf('Exception check: Expected: "%s", Got: %s', $test->{expected}, $exception || '(nothing)');
}

for my $test (@valid_intervals) {
	my $ri = Random::Interval->new(
		intervals => $test->{intervals},
		integer   => $test->{integer},
		inclusive => $test->{inclusive},
	);
	ok $ri->_get_rand_max() == $test->{rand_max},
	   'Check rand_max is correct.';
	while (my ($rand, $expected) = each %{$test->{params}->{rand}}) {
		my $result = $ri->rand(rand => $rand);
		ok $result == $expected,
		   sprintf('Check rand(rand => %d) == %d and %d match', $rand, $result, $expected);
	}
}
