#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'class_method_declaration';

plan tests => 3;

test_rule "IsNullConditional.nullableVersions" => (
	data => <<'EODATA',
IsNullConditional nullableVersions(Versions nullableVersions) {
}
EODATA
	expect => expect_element ('::Method::Declaration' => (
		expect_element ('::Method::Result' => (
			expect_type_class (['IsNullConditional']),
		)),
		expect_element ('::Method::Name' => (
			expect_identifier ('nullableVersions'),
		)),
		expect_element ('::List::Parameters' => (
			expect_token_paren_open,
			expect_element ('::Parameter' => (
				expect_type_class (['Versions']),
				expect_variable_name ('nullableVersions'),
			)),
			expect_token_paren_close,
		)),
		expect_element ('::Method::Body' => (
			expect_element ('::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	)),
);

test_rule "CodeBuffer.printf" => (
	data => <<'EODATA',
public void printf(String format, Object... args) {
}
EODATA
	expect => expect_element ('::Method::Declaration' => (
		expect_modifier_public,
		expect_element ('::Method::Result' => (
			expect_word_void,
		)),
		expect_element ('::Method::Name' => (
			expect_identifier ('printf'),
		)),
		expect_element ('::List::Parameters' => (
			expect_token_paren_open,
			expect_element ('::Parameter' => (
				expect_type_string,
				expect_variable_name ('format'),
			)),
			expect_token_comma,
			expect_element ('::Parameter' => (
				expect_type_class ([qw[ Object ]]),
				expect_token_elipsis,
				expect_variable_name ('args'),
			)),
			expect_token_paren_close,
		)),
		expect_element ('::Method::Body' => (
			expect_element ('::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	)),
);

had_no_warnings;

done_testing;
