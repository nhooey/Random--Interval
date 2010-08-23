package Random::Interval;

use 5.008008;
use strict;
use warnings;

use Params::Validate qw(:all);
use POSIX qw(ceil);

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
			type     => HASHREF,
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
	my %intervals;
	my ($a_prev, $b_prev);
	for my $key (sort keys %{$args{intervals}}) {
		my ($a, $b) = ($key, $args{intervals}->{$key});

		die "Undefined values not allowed in intervals.\n"
			unless defined $a && defined $b;

		# Push the ranges in ascending order
		($a, $b) = $a < $b ? ($a, $b) : ($b, $a);
		$b = $args{inclusive} && $args{integer} ? $b + 1 : $b;

		die "Overlapping intervals specified.\n"
			if defined $b_prev && $b_prev > $a;

		$intervals{$a} = $b;
		($a_prev, $b_prev) = ($a, $b);
	}
	$args{intervals} = \%intervals;

	my $self = bless \%args, $class;
	return $self;
}

sub rand {
	my $self = shift;
	my %args = @_;

	validate(@_, {
		rand => 0,
	});

	my $rand_max = 0;
	while (my ($a, $b) = each %{$self->{intervals}}) {
		$rand_max += abs($b - $a);
	}
	my $rand_rel = defined $args{rand} ? $args{rand} : rand($rand_max);

	my $rand_cum = 0;
	while (my ($a, $b) = each %{$self->{intervals}}) {
		my $in = $self->{inclusive} ? $rand_rel < $b - $a + $rand_cum : $rand_rel <= $b - $a + $rand_cum;
		my $result = $a + $rand_rel - $rand_cum;
		return ($self->{integer} ? int $result : $result) if $in;
		$rand_cum += $b - $a;
	}
}

sub _get_rand_max {
	my $self = shift;

	my $rand_max = 0;
	while (my ($a, $b) = each %{$self->{intervals}}) {
		$rand_max += abs($b - $a);
	}
	return $rand_max;
}


# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Random::Interval - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Random::Interval;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Random::Interval, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>neil@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
