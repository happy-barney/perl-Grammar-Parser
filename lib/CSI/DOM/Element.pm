
use v5.14;
use warnings;

package CSI::DOM::Element v1.0.0 {
	use Moo;

	has 'children'
		=> is       => 'ro'
		=> default  => sub { +[] }
	;

	has 'parent'
		=> is       => 'ro'
	;

	1;
};
