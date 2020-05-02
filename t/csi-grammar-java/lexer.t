#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 6;

subtest 'identifier'                    => sub {
	plan tests => 4;

	test_token 'identifier / identifer' => (
		data => 'foo',
		expect_token => 'IDENTIFIER',
	);

	test_token 'identifier / identifer with currency symbol' => (
		data => '$foo',
		expect_token => 'IDENTIFIER',
	);

	test_token 'identifier / identifier starting with keyword' => (
		data => 'do_someting',
		expect_token => 'IDENTIFIER',
	);

	test_token 'identifier / identifier starting with keyword with currency symbol' => (
		data => 'do$',
		expect_token => 'IDENTIFIER',
	);

	done_testing;
};

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

subtest "separators"                    => sub {
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

subtest "words"                         => sub {
	plan tests => 5;

	subtest "literal / null" => sub {
		plan tests => 1;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.10.7";

		test_token "null" => expect_token => 'NULL';

		done_testing;
	};

	subtest "literal / boolean" => sub {
		plan tests => 2;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.10.3";

		test_token "false" => expect_token => 'FALSE';
		test_token "true"  => expect_token => 'TRUE';

		done_testing;
	};

	subtest "reserved words / module declaration" => sub {
		plan tests => 10;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.9";

		test_token "exports"    => expect_token => 'EXPORTS';
		test_token "module"     => expect_token => 'MODULE';
		test_token "open"       => expect_token => 'OPEN';
		test_token "opens"      => expect_token => 'OPENS';
		test_token "provides"   => expect_token => 'PROVIDES';
		test_token "requires"   => expect_token => 'REQUIRES';
		test_token "to"         => expect_token => 'TO';
		test_token "transitive" => expect_token => 'TRANSITIVE';
		test_token "uses"       => expect_token => 'USES';
		test_token "with"       => expect_token => 'WITH';

		done_testing;
	};

	subtest "identifiers with special meaning" => sub {
		plan tests => 1;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.9";

		test_token "var" => expect_token => 'VAR';

		done_testing;
	};

	subtest "keywords" => sub {
		plan tests => 51;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.9";

		test_token "abstract"     => expect_token => 'ABSTRACT';
		test_token "assert"       => expect_token => 'ASSERT';
		test_token "boolean"      => expect_token => 'BOOLEAN';
		test_token "break"        => expect_token => 'BREAK';
		test_token "byte"         => expect_token => 'BYTE';
		test_token "case"         => expect_token => 'CASE';
		test_token "catch"        => expect_token => 'CATCH';
		test_token "char"         => expect_token => 'CHAR';
		test_token "class"        => expect_token => 'CLASS';
		test_token "const"        => expect_token => 'CONST';
		test_token "continue"     => expect_token => 'CONTINUE';
		test_token "default"      => expect_token => 'DEFAULT';
		test_token "do"           => expect_token => 'DO';
		test_token "double"       => expect_token => 'DOUBLE';
		test_token "else"         => expect_token => 'ELSE';
		test_token "enum"         => expect_token => 'ENUM';
		test_token "extends"      => expect_token => 'EXTENDS';
		test_token "final"        => expect_token => 'FINAL';
		test_token "finally"      => expect_token => 'FINALLY';
		test_token "float"        => expect_token => 'FLOAT';
		test_token "for"          => expect_token => 'FOR';
		test_token "if"           => expect_token => 'IF';
		test_token "goto"         => expect_token => 'GOTO';
		test_token "implements"   => expect_token => 'IMPLEMENTS';
		test_token "import"       => expect_token => 'IMPORT';
		test_token "instanceof"   => expect_token => 'INSTANCEOF';
		test_token "int"          => expect_token => 'INT';
		test_token "interface"    => expect_token => 'INTERFACE';
		test_token "long"         => expect_token => 'LONG';
		test_token "native"       => expect_token => 'NATIVE';
		test_token "new"          => expect_token => 'NEW';
		test_token "package"      => expect_token => 'PACKAGE';
		test_token "private"      => expect_token => 'PRIVATE';
		test_token "protected"    => expect_token => 'PROTECTED';
		test_token "public"       => expect_token => 'PUBLIC';
		test_token "return"       => expect_token => 'RETURN';
		test_token "short"        => expect_token => 'SHORT';
		test_token "static"       => expect_token => 'STATIC';
		test_token "strictfp"     => expect_token => 'STRICTFP';
		test_token "super"        => expect_token => 'SUPER';
		test_token "switch"       => expect_token => 'SWITCH';
		test_token "synchronized" => expect_token => 'SYNCHRONIZED';
		test_token "this"         => expect_token => 'THIS';
		test_token "throw"        => expect_token => 'THROW';
		test_token "throws"       => expect_token => 'THROWS';
		test_token "transient"    => expect_token => 'TRANSIENT';
		test_token "try"          => expect_token => 'TRY';
		test_token "void"         => expect_token => 'VOID';
		test_token "volatile"     => expect_token => 'VOLATILE';
		test_token "while"        => expect_token => 'WHILE';
		test_token "underscore"   => data => '_', expect_token => '_';
		done_testing;
	};

	done_testing;
};

had_no_warnings;

done_testing;

