#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 4;

subtest "insignificant tokens"          => sub {
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

subtest "operators"                     => sub {
	plan tests => 38;

	note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.12";

	test_token "operator / token '='"   =>
		data => '=',
		expect_token => 'ASSIGN',
		;

	subtest    "operator / token '>'"   => sub {
		plan tests => 2;

		note "split into two rules to be able to distinguish '>>' from '> >' in generics";

		test_token "operator / token '>' / ambiguos" =>
			data => '>>>',
			expect_match => '>',
			expect_token => 'TOKEN_GT_AMBIGUOUS',
			;

		test_token "operator / token '>' / final" =>
			data => '>',
			expect_token => 'TOKEN_GT_FINAL',
			;

		done_testing;
	};

	test_token "operator / token '<'"   =>
		data => '<',
		expect_token => 'TOKEN_LT',
		;

	test_token "operator / token '!'"   =>
		data => '!',
		expect_token => 'LOGICAL_COMPLEMENT',
		;

	test_token "operator / token '~'"   =>
		data => '~',
		expect_token => 'BINARY_COMPLEMENT',
		;

	test_token "operator / token '?'"   =>
		data => '?',
		expect_token => 'QUESTION_MARK',
		;

	test_token "operator / token ':'"   =>
		data => ':',
		expect_token => 'COLON',
		;

	test_token "operator / token '->'"  =>
		data => '->',
		expect_token => 'LAMBDA',
		;

	test_token "operator / token '=='"  =>
		data => '==',
		expect_token => 'CMP_EQUALITY',
		;

	test_token "operator / token '>='"  =>
		data => '>=',
		expect_token => 'CMP_GREATER_THAN_OR_EQUAL',
		;

	test_token "operator / token '<='"  =>
		data => '<=',
		expect_token => 'CMP_LESS_THAN_OR_EQUAL',
		;

	test_token "operator / token '!='"  =>
		data => '!=',
		expect_token => 'CMP_INEQUALITY',
		;

	test_token "operator / token '&&'"  =>
		data => '&&',
		expect_token => 'LOGICAL_AND',
		;

	test_token "operator / token '||'"  =>
		data => '||',
		expect_token => 'LOGICAL_OR',
		;

	test_token "operator / token '++'"  =>
		data => '++',
		expect_token => 'INCREMENT',
		;

	test_token "operator / token '--'"  =>
		data => '--',
		expect_token => 'DECREMENT',
		;

	subtest    "operator / token '+'"   => sub {
		plan tests => 2;

		test_token "operator / token '+' / single plus"  =>
			data => '+',
			expect_token => 'TOKEN_PLUS',
			;

		test_token "operator / token '+' / followed by increment"  =>
			data => '+++',
			expect_match => '+',
			expect_token => 'TOKEN_PLUS',
			;

		done_testing;
	};

	subtest    "operator / token '-'"   => sub {
		plan tests => 2;

		test_token "operator / token '-' / single minus"  =>
			data => '-',
			expect_token => 'TOKEN_MINUS',
			;

		test_token "operator / token '-' / followed by decrement"  =>
			data => '---',
			expect_match => '-',
			expect_token => 'TOKEN_MINUS',
			;

		done_testing;
	};

	test_token "operator / token '*'"   =>
		data => '*',
		expect_token => 'TOKEN_ASTERISK',
		;

	test_token "operator / token '/'"   =>
		data => '/',
		expect_token => 'DIVISION',
		;

	test_token "operator / token '&'"   =>
		data => '&',
		expect_token => 'BINARY_AND',
		;

	test_token "operator / token '|'"   =>
		data => '|',
		expect_token => 'BINARY_OR',
		;

	test_token "operator / token '^'"   =>
		data => '^',
		expect_token => 'BINARY_XOR',
		;

	test_token "operator / token '%'"   =>
		data => '%',
		expect_token => 'MODULUS',
		;

	test_token "operator / token '<<'"  =>
		data => '<<',
		expect_token => 'BINARY_SHIFT_LEFT',
		;

	test_token "operator / token '>>'"  =>
		data => '>>',
		expect_match => '>',
		expect_token => 'TOKEN_GT_AMBIGUOUS',
		;

	test_token "operator / token '>>>'" =>
		data => '>>>',
		expect_match => '>',
		expect_token => 'TOKEN_GT_AMBIGUOUS',
		;

	test_token "operator / token '+='"  =>
		data => '+=',
		expect_token => 'ASSIGN_ADDITION',
		;

	test_token "operator / token '-='"  =>
		data => '-=',
		expect_token => 'ASSIGN_SUBTRACTION',
		;

	test_token "operator / token '*='"  =>
		data => '*=',
		expect_token => 'ASSIGN_MULTIPLICATION',
		;

	test_token "operator / token '/='"  =>
		data => '/=',
		expect_token => 'ASSIGN_DIVISION',
		;

	test_token "operator / token '&='"  =>
		data => '&=',
		expect_token => 'ASSIGN_BINARY_AND',
		;

	test_token "operator / token '|='"  =>
		data => '|=',
		expect_token => 'ASSIGN_BINARY_OR',
		;

	test_token "operator / token '^='"  =>
		data => '^=',
		expect_token => 'ASSIGN_BINARY_XOR',
		;

	test_token "operator / token '%='"  =>
		data => '%=',
		expect_token => 'ASSIGN_MODULUS',
		;

	test_token "operator / token '<<='" =>
		data => '<<=',
		expect_token => 'ASSIGN_BINARY_SHIFT_LEFT',
		;

	test_token "operator / token '>>='" =>
		data => '>>=',
		expect_token => 'ASSIGN_BINARY_SHIFT_RIGHT',
		;

	test_token "operator / token '>>>='" =>
		data => '>>>=',
		expect_token => 'ASSIGN_BINARY_USHIFT_RIGHT',
		;

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

