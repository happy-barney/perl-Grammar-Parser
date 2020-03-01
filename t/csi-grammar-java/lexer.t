#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 3;

subtest "insignificant tokens"      => sub {
	plan tests => 4;
	note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.6";
	note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.7";

	test_token 'insignificant / whitespaces' => (
		with_data => " \t\n\t ",
		expect_token => 'whitespaces',
	);

	test_token 'insignificant / C++ comment' => (
		with_data => "// ... ",
		expect_token => 'comment_cpp',
	);

	test_token 'insignificant / C comment' => (
		with_data => "/* /*\n */",
		expect_token => 'comment_c',
	);

	test_token 'insignificant / Javadoc comment' => (
		with_data => "/** /*\n */",
		expect_token => 'comment_javadoc',
	);

	done_testing;
};

subtest "separators"                => sub {
	plan tests => 12;
	note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.11";

	test_token 'separator / annotation'     =>
		with_data    => '@',
		expect_token => 'ANNOTATION',
		;

	test_token 'separator / brace close'    =>
		with_data    => '}',
		expect_token => 'BRACE_CLOSE',
		;

	test_token 'separator / brace open'     =>
		with_data    => '{',
		expect_token => 'BRACE_OPEN',
		;

	test_token 'separator / bracket close'  =>
		with_data    => ']',
		expect_token => 'BRACKET_CLOSE',
		;

	test_token 'separator / bracket open'   =>
		with_data    => '[',
		expect_token => 'BRACKET_OPEN',
		;

	test_token 'separator / comma'          =>
		with_data    => ',',
		expect_token => 'COMMA',
		;

	test_token 'separator / dot'            =>
		with_data    => '.',
		expect_token => 'DOT',
		;

	test_token 'separator / double colon'   =>
		with_data    => '::',
		expect_token => 'DOUBLE_COLON',
		;

	test_token 'separator / elipsis'        =>
		with_data    => '...',
		expect_token => 'ELIPSIS',
		;

	test_token 'separator / paren close'    =>
		with_data    => ')',
		expect_token => 'PAREN_CLOSE',
		;

	test_token 'separator / paren open'     =>
		with_data    => '(',
		expect_token => 'PAREN_OPEN',
		;

	test_token 'separator / semicolon'      =>
		with_data    => ';',
		expect_token => 'SEMICOLON',
		;

	done_testing;
};

had_no_warnings;

done_testing;

