#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 3;

subtest "insignificant tokens"      => sub {
	plan tests => 4;

	test_token 'insignificant / whitespaces' => (
		data => " \t\n\t ",
		expect_token => 'whitespaces',
	);

	test_token 'insignificant / C++ comment' => (
		data => "// ... ",
		expect_token => 'comment_cpp',
	);

	test_token 'insignificant / C comment' => (
		data => "/* /*\n */",
		expect_token => 'comment_c',
	);

	test_token 'insignificant / Javadoc comment' => (
		data => "/** /*\n */",
		expect_token => 'comment_javadoc',
	);

	done_testing;
};

subtest "separators"                => sub {
	plan tests => 12;
	note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.11";

	test_token 'separator / annotation'     =>
		data => '@',
		expect_token => 'ANNOTATION',
		;

	test_token 'separator / brace close'    =>
		data => '}',
		expect_token => 'BRACE_CLOSE',
		;

	test_token 'separator / brace open'     =>
		data => '{',
		expect_token => 'BRACE_OPEN',
		;

	test_token 'separator / bracket close'  =>
		data => ']',
		expect_token => 'BRACKET_CLOSE',
		;

	test_token 'separator / bracket open'   =>
		data => '[',
		expect_token => 'BRACKET_OPEN',
		;

	test_token 'separator / comma'          =>
		data => ',',
		expect_token => 'COMMA',
		;

	test_token 'separator / dot'            =>
		data => '.',
		expect_token => 'DOT',
		;

	test_token 'separator / double colon'   =>
		data => '::',
		expect_token => 'DOUBLE_COLON',
		;

	test_token 'separator / elipsis'        =>
		data => '...',
		expect_token => 'ELIPSIS',
		;

	test_token 'separator / paren close'    =>
		data => ')',
		expect_token => 'PAREN_CLOSE',
		;

	test_token 'separator / paren open'     =>
		data => '(',
		expect_token => 'PAREN_OPEN',
		;

	test_token 'separator / semicolon'      =>
		data => ';',
		expect_token => 'SEMICOLON',
		;

	done_testing;
};

had_no_warnings;

done_testing;

