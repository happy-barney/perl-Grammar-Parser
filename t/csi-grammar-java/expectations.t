#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 2;

subtest "separators"                => sub {
	plan tests => 12;
	note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.11";

	is "expect_token_annotation" =>
		expect => expect_token_annotation,
		got    => {
			'CSI::Language::Java::Token::Annotation' => '@',
		},
		;

	is "expect_token_brace_close" =>
		expect => expect_token_brace_close,
		got    => {
			'CSI::Language::Java::Token::Brace::Close' => '}',
		},
		;

	is "expect_token_brace_open" =>
		expect => expect_token_brace_open,
		got    => {
			'CSI::Language::Java::Token::Brace::Open' => '{',
		},
		;

	is "expect_token_bracket_close" =>
		expect => expect_token_bracket_close,
		got    => {
			'CSI::Language::Java::Token::Bracket::Close' => ']',
		},
		;

	is "expect_token_bracket_open" =>
		expect => expect_token_bracket_open,
		got    => {
			'CSI::Language::Java::Token::Bracket::Open' => '[',
		},
		;

	is "expect_token_comma" =>
		expect => expect_token_comma,
		got    => {
			'CSI::Language::Java::Token::Comma' => ',',
		},
		;

	is "expect_token_dot" =>
		expect => expect_token_dot,
		got    => {
			'CSI::Language::Java::Token::Dot' => '.',
		},
		;

	is "expect_token_double_colon" =>
		expect => expect_token_double_colon,
		got    => {
			'CSI::Language::Java::Token::Double::Colon' => '::',
		},
		;

	is "expect_token_elipsis" =>
		expect => expect_token_elipsis,
		got    => {
			'CSI::Language::Java::Token::Elipsis' => '...',
		},
		;

	is "expect_token_paren_close" =>
		expect => expect_token_paren_close,
		got    => {
			'CSI::Language::Java::Token::Paren::Close' => ')',
		},
		;

	is "expect_token_paren_open" =>
		expect => expect_token_paren_open,
		got    => {
			'CSI::Language::Java::Token::Paren::Open' => '(',
		},
		;

	is "expect_token_semicolon" =>
		expect => expect_token_semicolon,
		got    => {
			'CSI::Language::Java::Token::Semicolon' => ';',
		},
		;


	done_testing;
};

had_no_warnings;

done_testing;
