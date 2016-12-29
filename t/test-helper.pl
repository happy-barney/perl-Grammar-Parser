
use v5.14;
use warnings;

use open q (:std) => q (:encoding(utf-8));
use utf8;

use Carp::Always;
use Data::Printer -colored => 0;
use Ref::Util;

use Context::Singleton;
use Test::YAFT;

sub context {
	my ($title, $test) = @_;

	frame { subtest $title => $test }
}

sub describe {
	my ($title, $test) = @_;

	frame { subtest $title => $test };
}

sub describe_package ($&) {
	my ($package, $code) = @_;

	Test::YAFT::test_frame {
		subtest $package => sub {
			proclaim package => $package;

			$code->();
		}
	}
}

sub starts_with {
	my ($string, $substring) = @_;

	! rindex $string, $substring, 0;
}

1;
