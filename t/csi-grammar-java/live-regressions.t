#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

subtest "type parameters vs binary shift comparison" => sub {
	test_rule "arguments / binary shift expression" => (
		rule => 'arguments',
		data => '(foo >>> 1)',
		expect => ignore,
	);

	test_rule "method invocation / arguments / binary shift expression" => (
		rule => 'method_invocation',
		data => 'method (foo >>> 1)',
		expect => ignore,
	);

	test_rule "method invocation / arguments / binary shift expression" => (
		rule => 'method_invocation',
		data => 'foo().method (foo >>> 1)',
		expect => ignore,
	);

	test_rule "block / arguments / binary shift expression" => (
		rule => 'block',
		data => '{ foo().method (foo >>> 1); }',
		expect => ignore,
	);

	test_rule "statement / arguments / binary shift expression" => (
		rule => 'statement',
		data => '{ foo().method (foo >>> 1); }',
		expect => ignore,
	);

	test_rule "expression" => (
		rule => 'expression',
		data => 'foo > bar >>> 1',
		expect => ignore,
	);

	test_rule "expression" => (
		rule => 'expression',
		data => 'a > b && foo < bar >>> 1',
		expect => ignore,
	);

	done_testing;
};

subtest "interface with enum" => sub {
	test_rule "interface with enum" =>
		rule => 'interface_declaration',
		expect => ignore,
		data   => <<'EODATA',
interface Foo { enum Bar { } }
EODATA
		;
};

subtest "initialize from array creation access" => sub {
	#String type = new String[]{ "boolean", "long", "double" }[randomIndex];
	test_rule "interface with enum" =>
		rule   => 'expression',
		expect => ignore,
		data   => 'new String[] { "boolean", "long", "double" }',
		;

	test_rule "interface with enum" =>
		rule   => 'expression',
		expect => ignore,
		data   => 'new String[] { "boolean", "long", "double" }[randomIndex]',
		;

	done_testing;
};

subtest "string variable initializer" => sub {
	test_rule "empty string" =>
		rule   => 'variable_declaration_statement',
		expect => ignore,
		data   => 'String foo = "";',
		;

	test_rule "empty string" =>
		rule   => 'block_statement',
		expect => ignore,
		data   => 'String foo = "";',
		;

	test_rule "empty string" =>
		rule   => 'try_statement',
		expect => ignore,
		data   => 'try { String foo = ""; } finally { }',
		;

	test_rule "very long string" =>
		rule   => 'block_statement',
		expect => ignore,
		data   => "String foo = \"${\ (q/x/ x 4096) }\";",
		;

	test_rule "very long string" =>
		rule   => 'block_statement',
		expect => ignore,
		data   => 'String foo = "' . (q/x\\\\/ x 4096) . '";',
		;
};

subtest "assign lambda with assignment" => sub {
	test_rule "interface with enum" =>
		rule   => 'statement',
		expect => ignore,
		data   => 'foo = bar -> baz = true;',
		;

	done_testing;
};

test_rule "empty declaration (syntactically hidden)" =>
	rule => 'interface_member_declarations',
	expect => ignore,
	data   => <<'EODATA',
default void foo(){};
EODATA
;

test_rule "javac accepts empty import declaration" =>
	rule => 'import_declarations',
	expect => ignore,
	data   => <<'EODATA',
import foo.bar;
;
import bar.foo;
EODATA
;

test_rule "variable declaration / multi-dimensional array creation" =>
	rule => 'variable_declaration_statement',
	data => 'Object[][] rows = new Object[size()][13];',
	expect => ignore,
	;

had_no_warnings;

done_testing;
