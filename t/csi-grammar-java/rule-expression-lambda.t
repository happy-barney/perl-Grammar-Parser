#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 7;

test_rule "lambda expression / expression lambda" => (
	data => '() -> null',
	expect => [
		expect_lambda (
			parameters => expect_lambda_parameters,
			expect_literal_null,
		),
	],
);

test_rule "lambda expression / empty block lambda" => (
	data => '() -> {}',
	expect => [
		expect_lambda (
			parameters => expect_lambda_parameters,
			expect_block,
		),
	],
);

test_rule "lambda expression / with variable name parameter" => (
	data => 'a -> {}',
	expect => [
		expect_lambda (
			parameters => expect_lambda_parameter (expect_variable_name ('a')),
			expect_block,
		),
	],
);

test_rule "lambda expression / with multiple variable name parameters" => (
	data => '(a, b) -> {}',
	expect => [
		expect_lambda (
			parameters => expect_lambda_parameters (
				expect_variable_name ('a'),
				expect_variable_name ('b'),
			),
			expect_block,
		),
	],
);

test_rule "lambda expression / with cast operator" => (
	data => '(Foo) () -> {}',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Cast' => (
			expect_element ('CSI::Language::Java::Operator::Cast' => (
				expect_token_paren_open,
				expect_type_class ([qw[ Foo ]]),
				expect_token_paren_close,
			)),
			expect_lambda (
				parameters => expect_lambda_parameters,
				expect_block,
			),
		)),
	],
);

test_rule "lambda expression / with binary expression" => (
	data => 'a -> a > 1',
	expect => [
		expect_lambda (
			parameters => expect_lambda_parameter (
				expect_variable_name ('a'),
			),
			expect_element ('CSI::Language::Java::Expression::Relational' => (
				expect_reference ('a'),
				expect_operator_greater_than,
				expect_literal_integral_decimal ('1'),
			)),
		),
	],
);

not 1 and test_rule "lambda expression / precedence / casted lambda with binary expression" => (
	data => '(Foo) a -> a > 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Cast' => (
			expect_element ('CSI::Language::Java::Operator::Cast' => (
				expect_token_paren_open,
				expect_type_class ([qw[ Foo ]]),
				expect_token_paren_close,
			)),
			expect_lambda (
				parameters => expect_lambda_parameter (
					expect_variable_name ('a'),
				),
				expect_element ('CSI::Language::Java::Expression::Relational' => (
					expect_reference ('a'),
					expect_operator_greater_than,
					expect_literal_integral_decimal ('1'),
				)),
			),
		)),
	],
);

had_no_warnings;

done_testing;
