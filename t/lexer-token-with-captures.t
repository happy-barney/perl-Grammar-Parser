#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

plan tests => 2;

note <<'';
	Lexer should propagate named captures group into token
	------------------------------------------------------


# snippet  of SQL grammar
arrange_lexer_rules (
	LITERAL_STRING => qr/(?>
		(?<delimiter> \")
		(?<value> [^\"]* )
		\"
	)/sx,
);

arrange_lexer_data '"some string"';

use Grammar::Parser::Lexer::Match::Unique;

expect_next_token LITERAL_STRING => (value => 'some string', delimiter => '"');

had_no_warnings;

done_testing;

