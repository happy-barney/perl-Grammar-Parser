#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

my %identifier_rules = (
	identifier      => \& expect_identifier,
	label_name      => \& expect_label_name,
	label_reference => \& expect_label_reference,
	variable_name   => \& expect_variable_name,
);

plan tests => 1 + scalar keys %identifier_rules;

note 'https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-Identifier';

for my $rule (sort keys %identifier_rules) {
	subtest $rule =~ tr/_/ /r => sub {
		plan tests => 6;

		arrange_start_rule $rule;

		test_rule 'should accept common identifier' => (
			data => 'foo',
			expect => $identifier_rules{$rule}->('foo'),
		);

		test_rule 'should accept common identifier with currency symbol' => (
			data => 'foo$bar',
			expect => $identifier_rules{$rule}->('foo$bar'),
		);

		test_rule 'should accept non-reserved keyword' => (
			data => 'module',
			expect => $identifier_rules{$rule}->('module'),
		);

		test_rule 'should accept word <var>' => (
			data => 'var',
			expect => $identifier_rules{$rule}->('var'),
		);

		test_rule 'should not accept reserved word' => (
			data => 'class',
			throws => 1,
		);

		test_rule 'accept reserved word with currency symbol' => (
			data => 'class$',
			expect => $identifier_rules{$rule}->('class$'),
		);

		done_testing;
	};
}

had_no_warnings;

done_testing;
