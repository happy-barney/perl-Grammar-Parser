
use v5.14;
use CSI::Common::Sense;

use require::relative q (test-helper.pl);

my $program = do { local $/; <DATA> };

csi_lexer_should_tokenize q (hello world program)
	=> program => $program
	=> expect  => [
		expect_token (HASH         => line => 1, column => 1,  value => q (#)),
		expect_token (IDENTIFIER   => line => 1, column => 2,  value => q (include)),
		expect_token (WHITESPACE   => line => 1, column => 9,  value => q ( )),
		expect_token (LESS_THAN    => line => 1, column => 10, value => q (<)),
		expect_token (IDENTIFIER   => line => 1, column => 11, value => q (stdio)),
		expect_token (DOT          => line => 1, column => 16, value => q (.)),
		expect_token (IDENTIFIER   => line => 1, column => 17, value => q (h)),
		expect_token (GREATER_THAN => line => 1, column => 18, value => q (>)),
		expect_token (NEW_LINE     => line => 1, column => 19, value => qq (\n)),

		expect_token (SOLIDUS      => line => 2, column => 1,  value => q (/)),
		expect_token (ASTERISK     => line => 2, column => 2,  value => q (*)),
		expect_token (NEW_LINE     => line => 2, column => 3,  value => qq (\n)),

		expect_token (EQUALS_SIGN  => line => 3, column => 1,  value => q (=)),
		expect_token (IDENTIFIER   => line => 3, column => 2,  value => q (for)),
		expect_token (WHITESPACE   => line => 3, column => 5,  value => q ( )),
		expect_token (IDENTIFIER   => line => 3, column => 6,  value => q (apidoc)),
		expect_token (WHITESPACE   => line => 3, column => 12, value => q ( )),
		expect_token (IDENTIFIER   => line => 3, column => 13, value => q (newPVOP)),
		expect_token (NEW_LINE     => line => 3, column => 20, value => qq (\n)),

		expect_token (NEW_LINE     => line => 4, column => 1,  value => qq (\n)),

		expect_token (ASTERISK     => line => 5, column => 1,  value => q (*)),
		expect_token (SOLIDUS      => line => 5, column => 2,  value => q (/)),
		expect_token (NEW_LINE     => line => 5, column => 3,  value => qq (\n)),

		expect_token (IDENTIFIER   => line => 6, column => 1,  value => q (OP)),
		expect_token (WHITESPACE   => line => 6, column => 3,  value => q ( )),
		expect_token (ASTERISK     => line => 6, column => 4,  value => q (*)),
		expect_token (NEW_LINE     => line => 6, column => 5,  value => qq (\n)),

		expect_token (IDENTIFIER   => line => 7, column => 1,  value => q (Perl_newPVOP)),
		expect_token (PAREN_OPEN   => line => 7, column => 13, value => q <(>),
		expect_token (IDENTIFIER   => line => 7, column => 14, value => q (pTHX_)),
		expect_token (WHITESPACE   => line => 7, column => 19, value => q ( )),
		expect_token (LETTER_I     => line => 7, column => 20, value => q (I)),
		expect_token (DIGITS_OCTAL => line => 7, column => 21, value => q (32)),
		expect_token (WHITESPACE   => line => 7, column => 23, value => q ( )),
		expect_token (IDENTIFIER   => line => 7, column => 24, value => q (type)),
		expect_token (COMMA        => line => 7, column => 28, value => q (,)),
		expect_token (LETTER_I     => line => 7, column => 29, value => q (I)),
		expect_token (DIGITS_OCTAL => line => 7, column => 30, value => q (32)),
		expect_token (WHITESPACE   => line => 7, column => 32, value => q ( )),
		expect_token (LETTER_F     => line => 7, column => 33, value => q (f)),
		expect_token (LETTER_L     => line => 7, column => 34, value => q (l)),
		expect_token (IDENTIFIER   => line => 7, column => 35, value => q (ags)),
		expect_token (NEW_LINE     => line => 7, column => 38, value => qq (\n)),
	];

had_no_warnings;
done_testing;

=pod
Perl_newPVOP(pTHX_ I32 type, I32 flags, char *pv)
, I32 flags, char *pv) { }
=cut

__DATA__
#include <stdio.h>
/*
=for apidoc newPVOP

*/
OP *
Perl_newPVOP(pTHX_ I32 type, I32 flags
