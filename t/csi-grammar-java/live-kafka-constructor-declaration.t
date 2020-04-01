#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'constructor_declaration';

plan tests => 3;

test_rule "constructor with some parameters" => (
	data => 'public ThroughputThrottler(long targetThroughput, long startMs) { }',
	expect => expect_element ('::Constructor::Declaration' => (
		expect_modifier_public,
		expect_type_name ('ThroughputThrottler'),
		expect_element ('::List::Parameters' => (
			expect_token_paren_open,
			expect_element ('::Parameter' => (
				expect_type_long,
				expect_variable_name ('targetThroughput'),
			)),
			expect_token_comma,
			expect_element ('::Parameter' => (
				expect_type_long,
				expect_variable_name ('startMs'),
			)),
			expect_token_paren_close,
		)),
		expect_element ('::Constructor::Body' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
	)),
);

test_rule "constructor with annotated parameter" => (
	#data => 'public DestroyTaskRequest(@JsonProperty("id") String id) { }',
	data => 'public DestroyTaskRequest(@JsonProperty String id) { }',
	expect => expect_element ('::Constructor::Declaration' => (
		expect_modifier_public,
		expect_type_name ('DestroyTaskRequest'),
		expect_element ('::List::Parameters' => (
			expect_token_paren_open,
			expect_element ('::Parameter' => (
				expect_modifier (
					expect_annotation (
						[qw[ JsonProperty ]],
						#expect_literal_string ('id'),
					),
				),
				expect_type_string,
				expect_variable_name ('id'),
			)),
			expect_token_paren_close,
		)),
		expect_element ('::Constructor::Body' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
	)),
);

had_no_warnings;

done_testing;

