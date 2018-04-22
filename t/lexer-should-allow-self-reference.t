#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

not 1 and plan tests => 6;

note <<'';
Token definition should allow referecing itself.
Testing grammar
  - allows one decrement operator
  - it cannot be followed by unary minus
  - it can be preceeded by any number of unary minuses

arrange_lexer_rules (
	minus	  => '-',
	decrement => qr/
		(??{ 'minus' }) (??{ 'minus' })
		(?! (??{ 'decrement' }) )
		(?! (??{ 'minus' }) )
	/x,
);

arrange_lexer_insignificant;

subtest "data (1): -" => sub {
	arrange_lexer_data '-' x 1;

	expect_next_token minus     => (value => '-');
	expect_last_token;
};

subtest "data (2): --" => sub {
	arrange_lexer_data '-' x 2;

	expect_next_token decrement => (value => '--');
	expect_last_token;
};

subtest "data (3): ---" => sub {
	arrange_lexer_data '-' x 3;

	expect_next_token minus     => (value => '-');
	expect_next_token decrement => (value => '--');
	expect_last_token;
};

subtest "data (4): ----" => sub {
	arrange_lexer_data '-' x 4;

	expect_next_token minus     => (value => '-');
	expect_next_token minus     => (value => '-');
	expect_next_token decrement => (value => '--');
	expect_last_token;
};

subtest "data (5): -----" => sub {
	arrange_lexer_data '-' x 5;

	expect_next_token minus     => (value => '-');
	expect_next_token minus     => (value => '-');
	expect_next_token minus     => (value => '-');
	expect_next_token decrement => (value => '--');
	expect_last_token;
};

had_no_warnings;

done_testing;

