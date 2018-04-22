#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

plan tests => 3;

note <<'';
Snippet of real-live lexer (SQL grammar)
  - insignificant ....... whitespace, comment_sql, comment_c
  - keywords ............ CREATE, OR REPLACE TABLE
  - symbols (scalar) .... SEMICOLON
  - named regexes ....... End_Of_Line, Comment_C_Start, Comment_C_End
  - named regex group ... Keyword
  - regex reference ..... comment_sql, comment_c
  - group reference ..... identifier


# snippet  of SQL grammar
arrange_lexer_rules (
	whitespace      => qr/(?> \s+ )/x,
	comment_sql     => qr/(?> -- \V* (??{ 'End_Of_Line' }) )/x,
	comment_c       => qr/(?> (??{ 'Comment_C_Start' }) (?s:.*?) (??{ 'Comment_C_End' }) )/x,
	CREATE          => qr/(?> \b CREATE \b)/xi,
	OR              => qr/(?> \b OR \b)/xi,
	REPLACE         => qr/(?> \b REPLACE \b)/xi,
	TABLE           => qr/(?> \b TABLE \b)/xi,
	SEMICOLON       => ';',
	identifier      => qr/(?> (?! (??{ 'Keyword' }) ) (?! \d ) (\w+) \b )/x,
	End_Of_Line     => \ qr/ (?= [\r\n] ) \r? \n? /x,
	Comment_C_Start => \ qr/ \/\* /x,
	Comment_C_End   => \ qr/ \*\/ /x,
	Keyword         => \ [
		\ 'CREATE',
		\ 'OR',
		\ 'REPLACE',
		\ 'TABLE',
	],
);

arrange_lexer_insignificant (
	qw[ whitespace  ],
	qw[ comment_sql ],
	qw[ comment_c   ],
);

arrange_lexer_data <<'EODATA';
	-- SQL comment (insignificant by default)
	/* C comment (insignificant by default) */

	CREATE or rEPLACE TEMPORARY TABLE foo;
EODATA

use Grammar::Parser::Lexer::Match::Unique;

subtest "with insignificant tokens ignored" => sub {
	arrange_return_insignificant 0;

	expect_next_token CREATE     => (value => 'CREATE');
	expect_next_token OR         => (value => 'or');
	expect_next_token REPLACE    => (value => 'rEPLACE');
	expect_next_token identifier => (value => 'TEMPORARY');
	expect_next_token TABLE      => (value => 'TABLE');
	expect_next_token identifier => (value => 'foo');
	expect_next_token SEMICOLON  => (value => ';');
};

subtest "with insignificant tokens expected" => sub {
	arrange_return_insignificant 1;

	expect_next_token whitespace  => (value => "\t");
	expect_next_token comment_sql => (value => "-- SQL comment (insignificant by default)\n");
	expect_next_token whitespace  => (value => "\t");
	expect_next_token comment_c   => (value => "/* C comment (insignificant by default) */");
	expect_next_token whitespace  => (value => "\n\n\t");
	expect_next_token CREATE      => (value => 'CREATE');
	expect_next_token whitespace  => (value => " ");
	expect_next_token OR          => (value => 'or');
	expect_next_token whitespace  => (value => " ");
	expect_next_token REPLACE     => (value => 'rEPLACE');
	expect_next_token whitespace  => (value => " ");
	expect_next_token identifier  => (value => 'TEMPORARY');
	expect_next_token whitespace  => (value => " ");
	expect_next_token TABLE       => (value => 'TABLE');
	expect_next_token whitespace  => (value => " ");
	expect_next_token identifier  => (value => 'foo');
	expect_next_token SEMICOLON   => (value => ';');
	expect_next_token whitespace  => (value => "\n");
};

had_no_warnings;

done_testing;

