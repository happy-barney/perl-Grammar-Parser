#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'interface_method_declaration';

plan tests => 3;

test_rule "ordinary interface method declaration" => (
	data => 'public void method ();',
	expect => expect_element ('::Method::Declaration' => (
		expect_modifier_public,
		expect_element ('::Method::Result' => (
			expect_word_void,
		)),
		expect_method_name ('method'),
		expect_element ('::List::Parameters' => (
			expect_token_paren_open,
			expect_token_paren_close,
		)),
		expect_element ('::Method::Body' => (
			expect_token_semicolon,
		)),
	)),
);

test_rule "default interface method declaration" => (
	data => 'public default void method () { };',
	expect => expect_element ('::Method::Declaration' => (
		expect_modifier_public,
		expect_modifier_default,
		expect_element ('::Method::Result' => (
			expect_word_void,
		)),
		expect_method_name ('method'),
		expect_element ('::List::Parameters' => (
			expect_token_paren_open,
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
