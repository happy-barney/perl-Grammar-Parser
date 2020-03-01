#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 2;

subtest "separators"                    => sub {
	plan tests => 12;
	note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.11";

	is_expectation "expect_token_annotation" =>
		expectation => expect_token_annotation,
		match       => build_csi_token ('::Token::Annotation' => '@'),
		;

	is_expectation "expect_token_brace_close" =>
		expectation => expect_token_brace_close,
		match       => build_csi_token ('::Token::Brace::Close' => '}'),
		;

	is_expectation "expect_token_brace_open" =>
		expectation => expect_token_brace_open,
		match       => build_csi_token ('::Token::Brace::Open' => '{'),
		;

	is_expectation "expect_token_bracket_close" =>
		expectation => expect_token_bracket_close,
		match       => build_csi_token ('::Token::Bracket::Close' => ']'),
		;

	is_expectation "expect_token_bracket_open" =>
		expectation => expect_token_bracket_open,
		match       => build_csi_token ('::Token::Bracket::Open' => '['),
		;

	is_expectation "expect_token_comma" =>
		expectation => expect_token_comma,
		match       => build_csi_token ('::Token::Comma' => ','),
		;

	is_expectation "expect_token_dot" =>
		expectation => expect_token_dot,
		match       => build_csi_token ('::Token::Dot' => '.'),
		;

	is_expectation "expect_token_double_colon" =>
		expectation => expect_token_double_colon,
		match       => build_csi_token ('::Token::Double::Colon' => '::'),
		;

	is_expectation "expect_token_elipsis" =>
		expectation => expect_token_elipsis,
		match       => build_csi_token ('::Token::Elipsis' => '...'),
		;

	is_expectation "expect_token_paren_close" =>
		expectation => expect_token_paren_close,
		match       => build_csi_token ('::Token::Paren::Close' => ')'),
		;

	is_expectation "expect_token_paren_open" =>
		expectation => expect_token_paren_open,
		match       => build_csi_token ('::Token::Paren::Open' => '('),
		;

	is_expectation "expect_token_semicolon" =>
		expectation => expect_token_semicolon,
		match       => build_csi_token ('::Token::Semicolon' => ';'),
		;

	done_testing;
};

had_no_warnings;

done_testing;
