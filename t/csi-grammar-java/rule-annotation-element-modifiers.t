#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'annotation_element_modifiers';

plan tests => 5;

test_rule "method modifiers / public" => (
	data => 'public',
	expect => [
		expect_modifiers (
			expect_modifier_public,
		),
	],
);

test_rule "method modifiers / abstract" => (
	data => 'abstract',
	expect => [
		expect_modifiers (
			expect_modifier_abstract,
		),
	],
);

test_rule "method modifiers / annotation" => (
	data => '@foo',
	expect => [
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
		),
	],
);

test_rule "method modifiers / multiple modifiers" => (
	data => 'abstract @foo@bar public@baz',
	expect => [
		expect_modifiers (
			expect_modifier_abstract,
			expect_annotation ([qw[ foo ]]),
			expect_annotation ([qw[ bar ]]),
			expect_modifier_public,
			expect_annotation ([qw[ baz ]]),
		),
	],
);

had_no_warnings;

done_testing;
