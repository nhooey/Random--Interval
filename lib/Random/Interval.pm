package Random::Interval;

use 5.008008;
use strict;
use warnings;

use Params::Validate qw(:all);
use POSIX qw(floor);

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Random::Interval ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	new
	rand
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	new
	rand
	_get_rand_max
);

our $VERSION = '0.01';

sub new {
	my $class = shift;
	my %args = @_;

	validate(@_, {
		intervals => {
			type     => ARRAYREF,
			optional => 0,
		},
		integer   => 0,
		inclusive => {
			depends  => ['integer'],
			optional => 1,
		},
		seed      => 0,
	});

	# Sort each pair of interval boundaries per interval
	for my $int (@{$args{intervals}}) {
		my ($a, $b) = ($int->[0], $int->[1]);

		die "Undefined values not allowed in intervals.\n"
			unless defined $a && defined $b;

		# Push the ranges in ascending order
		($a, $b) = $a < $b ? ($a, $b) : ($b, $a);
		$b = $args{inclusive} && $args{integer} ? $b + 1 : $b;

		$int->[0] = $a;
		$int->[1] = $b;
	}

	my @intervals = sort { $a->[0] <=> $b->[0] } @{$args{intervals}};
	$args{intervals} = \@intervals;

	my ($a_prev, $b_prev);
	for my $int (@{$args{intervals}}) {
		die "Overlapping intervals specified: $b_prev > $int->[0]\n"
			if defined $b_prev && $b_prev > $int->[0];

		($a_prev, $b_prev) = ($int->[0], $int->[1]);
	}

	return bless \%args, $class;
}

sub rand {
	my $self = shift;
	my %args = @_;

	validate(@_, {
		rand => 0,
	});

	my $rand_max = 0;
	for my $int (@{$self->{intervals}}) {
		$rand_max += abs($int->[1] - $int->[0]);
	}
	my $rand_rel = defined $args{rand} ? $args{rand} : rand($rand_max);

	my $rand_cum = 0;
	for my $int (@{$self->{intervals}}) {
		my ($a, $b) = ($int->[0], $int->[1]);
		my $in = $self->{inclusive} ? $rand_rel < $b - $a + $rand_cum : $rand_rel <= $b - $a + $rand_cum;
		my $result = $a + $rand_rel - $rand_cum;
		return ($self->{integer} ? floor $result : $result) if $in;
		$rand_cum += $b - $a;
	}
}

sub _get_rand_max {
	my $self = shift;

	my $rand_max = 0;
	for my $int (@{$self->{intervals}}) {
		$rand_max += abs($int->[1] - $int->[0]);
	}
	return $rand_max;
}

1;
__END__

=head1 NAME

Random::Interval - A module that, given a set of intervals, will return a random
number in one of those intervals, reasonably distributed as much as the built-in
Perl function rand() is.

=head1 SYNOPSIS

  use Random::Interval;
  my $ri = Random::Interval->new(
    intervals => [
	  [  -5,    -3 ],
	  [  -1,     7 ],
	  [ 8.5, 17.33 ],
	],
	inclusive => 0,
	integer   => 0,
  );

  # Could very well print:    -5, -2.23423, 0, 6.2
  # Will certainly not print: -3, 7, 17.33, or anything out of those ranges
  printf "%s\n", $ri->rand();

  my $ri2 = Random::Interval->new(
    intervals => [
	  [  -5,    -3 ],
	  [  -1,     7 ],
	],
	inclusive => 1,
	integer   => 1,
  );

  # Could very well print:    -5, -2, -3, 0, -1, 4, 7
  # Will certainly not print: anything out of those ranges, or any non-integer
  printf "%s\n", $ri2->rand();

=head1 DESCRIPTION

This module is useful for obtaining a random unicode character, given a set of
ranges, which would usually be characters in a series of languages.

You could also use it if you're too lazy to do the math for a random number
greater than x, but less than y, the trivial case of one interval. It might make
your code look nicer without the offsets.

=head2 EXPORT

new()
rand()

=head1 SEE ALSO

See the rand() function in the Perl function documentation, as this function is
used to generate the random numbers. Also see rand() and perlsec to see how
vulnerable this module might be to security threats to do with uneven
distribution of random numbers.

No website yet.

=head1 AUTHOR

Neil Hooey <lt>neil@shutterstock.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Shutterstock Images LLC

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
