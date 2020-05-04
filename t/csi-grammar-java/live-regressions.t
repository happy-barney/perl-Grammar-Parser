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
		data   => 'new String[] { "boolean", "long", "double" }[index]',
		;

	done_testing;
};

had_no_warnings;

done_testing;
