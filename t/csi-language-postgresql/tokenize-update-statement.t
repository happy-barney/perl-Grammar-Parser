#!/usr/bin/env perl

use v5.24;
use warnings;

use require::relative "test-helper-postgresql-tokenizer.pl";

it "should tokenize simple update statement"
	=> with_string => <<~'CODE',
	uPDaTE my_TabLE SeT a = 5;
	CODE
	=> expect => expect_tokens (
		[ KEYWORD_UPDATE => 'uPDaTE' ],
		[ WHITESPACE     => ' ' ],
		[ IDENTIFIER     => 'my_TabLE' ],
		[ WHITESPACE     => ' ' ],
		[ KEYWORD_SET    => 'SeT' ],
		[ WHITESPACE     => ' ' ],
		[ IDENTIFIER     => 'a' ],
		[ WHITESPACE     => ' ' ],
		[ EQUALS_SIGN    => '=' ],
		[ WHITESPACE     => ' ' ],
		[ NUMBER         => '5' ],
		[ SEMICOLON      => ';' ],
		[ NEW_LINE       => "\n" ],
	);

