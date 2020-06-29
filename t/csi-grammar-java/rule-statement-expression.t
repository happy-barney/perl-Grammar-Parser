#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'statement_expression';

plan tests => 26;

test_rule "primary expression - literal - null" => (
	data => 'null',
	expect => [ expect_literal_null ],
);

test_rule "primary expression - literal - integer number" => (
	data => '0L',
	expect => [ expect_literal_integral_decimal ('0L') ],
);

test_rule "primary expression - class literal" => (
	data => 'String.class',
	expect => [ expect_literal_class (expect_reference ([qw[ String ]])) ]
);

test_rule "primary expression - group expression" => (
	data => '(null)',
	expect => [
		expect_token_paren_open,
		expect_literal_null,
		expect_token_paren_close,
	],
);

test_rule "primary expression - double-group expression" => (
	data => '((null))',
	expect => [
		expect_token_paren_open,
		expect_token_paren_open,
		expect_literal_null,
		expect_token_paren_close,
		expect_token_paren_close,
	],
);

test_rule "primary expression - this" => (
	data => 'this',
	expect => [
		expect_element ('CSI::Language::Java::Expression::This' => (
			expect_word_this,
		)),
	],
);

test_rule "primary expression - qualified this" => (
	data => 'Foo.Bar.this',
	expect => [
		expect_element ('CSI::Language::Java::Expression::This' => (
			expect_identifier ('Foo'),
			expect_token_dot,
			expect_identifier ('Bar'),
			expect_token_dot,
			expect_word_this,
		)),
	],
);

test_rule "primary expression - method reference" => (
	data => 'Foo.Bar::method',
	expect => [
		expect_element ('CSI::Language::Java::Method::Reference' => (
			expect_type_class ([qw[ Foo Bar ]]),
			expect_token ('CSI::Language::Java::Token::Double::Colon' => '::'),
			expect_method_name ('method'),
		)),
	],
);

test_rule "primary expression - method invocation" => (
	data => 'Foo.Bar.method()',
	expect => [
		expect_element ('CSI::Language::Java::Method::Invocation' => (
			expect_element ('CSI::Language::Java::Method::Invocant' => (
				expect_reference (qw[ Foo Bar ]),
			)),
			expect_token_dot,
			expect_method_name ('method'),
			expect_element ('CSI::Language::Java::Arguments' => (
				expect_token_paren_open,
				expect_token_paren_close,
			)),
		)),
	],
);

test_rule "primary expression - instance creation" => (
	data => 'new Foo ()',
	expect => [
		expect_element ('CSI::Language::Java::Instance::Creation' => (
			expect_word_new,
			expect_reference (qw[ Foo ]),
			expect_element ('CSI::Language::Java::Arguments' => (
				expect_token_paren_open,
				expect_token_paren_close,
			)),
		)),
	],
);

test_rule "postfix expression - decrement" => (
	data => 'foo--',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Postfix' => (
			expect_reference ('foo'),
			expect_operator_decrement,
		)),
	],
);

test_rule "prefix expression - decrement" => (
	data => '--foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_decrement,
			expect_reference ('foo'),
		)),
	],
);

test_rule "multiplicative expression" => (
	data => '--foo * 2',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Multiplicative' => (
			expect_element ('CSI::Language::Java::Expression::Prefix' => (
				expect_operator_decrement,
				expect_reference ('foo'),
			)),
			expect_operator_multiplication,
			expect_literal_integral_decimal ('2'),
		)),
	],
);

test_rule "additive expression" => (
	data => 'foo + 2',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Additive' => (
			expect_reference ('foo'),
			expect_operator_addition,
			expect_literal_integral_decimal ('2'),
		)),
	],
);

test_rule "binary shift expression" => (
	data => 'foo >> 2',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::Shift' => (
			expect_reference ('foo'),
			expect_operator_binary_shift_right,
			expect_literal_integral_decimal ('2'),
		)),
	],
);

test_rule "relational expression" => (
	data => 'foo > 2',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Relational' => (
			expect_reference ('foo'),
			expect_operator_greater_than,
			expect_literal_integral_decimal ('2'),
		)),
	],
);

test_rule "equality expression" => (
	data => 'foo == 2',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Equality' => (
			expect_reference ('foo'),
			expect_operator_equality,
			expect_literal_integral_decimal ('2'),
		)),
	],
);

test_rule "binary and expression" => (
	data => 'foo & 2',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::And' => (
			expect_reference ('foo'),
			expect_operator_binary_and,
			expect_literal_integral_decimal ('2'),
		)),
	],
);

test_rule "binary xor expression" => (
	data => 'foo ^ 2',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::Xor' => (
			expect_reference ('foo'),
			expect_operator_binary_xor,
			expect_literal_integral_decimal ('2'),
		)),
	],
);

test_rule "binary or expression" => (
	data => 'foo | 2',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::Or' => (
			expect_reference ('foo'),
			expect_operator_binary_or,
			expect_literal_integral_decimal ('2'),
		)),
	],
);

test_rule "logical and expression" => (
	data => 'foo && bar',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Logical::And' => (
			expect_reference ('foo'),
			expect_operator_logical_and,
			expect_reference ('bar'),
		)),
	],
);

test_rule "logical or expression" => (
	data => 'foo || bar',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Logical::Or' => (
			expect_reference ('foo'),
			expect_operator_logical_or,
			expect_reference ('bar'),
		)),
	],
);

test_rule "lambda expression" => (
	data => '() -> {}',
	expect => [
		expect_lambda (
			parameters => expect_lambda_parameters,
			expect_block,
		),
	],
);

test_rule "ternary expression" => (
	data => 'foo == null ? null : foo.method()',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Ternary' => (
			expect_element ('CSI::Language::Java::Expression::Equality' => (
				expect_reference ('foo'),
				expect_operator_equality,
				expect_literal_null,
			)),
			expect_token_question_mark,
			expect_literal_null,
			expect_token_colon,
			expect_element ('CSI::Language::Java::Method::Invocation' => (
				expect_element ('CSI::Language::Java::Method::Invocant' => (
					expect_reference (qw[ foo ]),
				)),
				expect_token_dot,
				expect_method_name ('method'),
				expect_element ('CSI::Language::Java::Arguments' => (
					expect_token_paren_open,
					expect_token_paren_close,
				)),
			)),
		)),
	],
);

test_rule "assignment" => (
	data => 'foo = null',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign' => '='),
			expect_literal_null,
		)),
	],
);

had_no_warnings;

done_testing;
