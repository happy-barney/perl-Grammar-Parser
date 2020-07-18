
use v5.14;
use Syntax::Construct v1.8 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::DOM::Node v1.0.0 {
	use Moo;

	has children => (
		is => 'ro',
		default => sub { +[] },
	);

	has parent => (
		is => 'rw',
	);

	1;
};
