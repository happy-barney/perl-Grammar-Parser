
use v5.14;
use warnings;

use require::relative 'test-helper-common.pl';

sub failed_constraint_exception {
	re (qr/did not pass type constraint/)
}

sub test_constraint (&) {
	my ($constraint) = @_;

	act {
		my $rv = $constraint->()->validate (@_);

		die $rv if $rv;

		1;
	};
}

sub constraint ($;@) {
	my ($message, %params) = @_;

	test_internals {
		$params{act_with} = act_with delete $params{value};

		it $message, %params;
	}
}

1;

