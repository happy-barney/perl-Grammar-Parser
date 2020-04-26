#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 3;

subtest "operators"                     => sub {
	plan tests => 38 + 4;
	# 38 operator tokens
	# 4 dualities
	# - ADDITION / UNARY_PLUS
	# - SUBTRACTION / UNARY_MINUS
	# - CMP_LESS_THAN / TYPE_PARAMETER_LIST_OPEN
	# - CMP_GREATER_THAN / TYPE_PARAMETER_LIST_CLOSE
	note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.12";

	is_expectation "expect_operator_addition" =>
		expectation => expect_operator_addition,
		match       => build_csi_token ('::Operator::Addition' => '+'),
		;

	is_expectation "expect_operator_assign" =>
		expectation => expect_operator_assign,
		match       => build_csi_token ('::Operator::Assign' => '='),
		;

	is_expectation "expect_operator_assign_addition" =>
		expectation => expect_operator_assign_addition,
		match       => build_csi_token ('::Operator::Assign::Addition' => '+='),
		;

	is_expectation "expect_operator_assign_binary_and" =>
		expectation => expect_operator_assign_binary_and,
		match       => build_csi_token ('::Operator::Assign::Binary::And' => '&='),
		;

	is_expectation "expect_operator_assign_binary_or" =>
		expectation => expect_operator_assign_binary_or,
		match       => build_csi_token ('::Operator::Assign::Binary::Or' => '|='),
		;

	is_expectation "expect_operator_assign_binary_shift_left" =>
		expectation => expect_operator_assign_binary_shift_left,
		match       => build_csi_token ('::Operator::Assign::Binary::Shift::Left' => '<<='),
		;

	is_expectation "expect_operator_assign_binary_shift_right" =>
		expectation => expect_operator_assign_binary_shift_right,
		match       => build_csi_token ('::Operator::Assign::Binary::Shift::Right' => '>>='),
		;

	is_expectation "expect_operator_assign_binary_ushift_right" =>
		expectation => expect_operator_assign_binary_ushift_right,
		match       => build_csi_token ('::Operator::Assign::Binary::UShift::Right' => '>>>='),
		;

	is_expectation "expect_operatxor_assign_binary_xor" =>
		expectation => expect_operator_assign_binary_xor,
		match       => build_csi_token ('::Operator::Assign::Binary::Xor' => '^='),
		;

	is_expectation "expect_operator_assign_division" =>
		expectation => expect_operator_assign_division,
		match       => build_csi_token ('::Operator::Assign::Division' => '/='),
		;

	is_expectation "expect_operator_assign_modulus" =>
		expectation => expect_operator_assign_modulus,
		match       => build_csi_token ('::Operator::Assign::Modulus' => '%='),
		;

	is_expectation "expect_operator_assign_multiplication" =>
		expectation => expect_operator_assign_multiplication,
		match       => build_csi_token ('::Operator::Assign::Multiplication' => '*='),
		;

	is_expectation "expect_operator_assign_subtraction" =>
		expectation => expect_operator_assign_subtraction,
		match       => build_csi_token ('::Operator::Assign::Subtraction' => '-='),
		;

	is_expectation "expect_operator_binary_and" =>
		expectation => expect_operator_binary_and,
		match       => build_csi_token ('::Operator::Binary::And' => '&'),
		;

	is_expectation "expect_operator_binary_complement" =>
		expectation => expect_operator_binary_complement,
		match       => build_csi_token ('::Operator::Binary::Complement' => '~'),
		;

	is_expectation "expect_operator_binary_or" =>
		expectation => expect_operator_binary_or,
		match       => build_csi_token ('::Operator::Binary::Or' => '|'),
		;

	is_expectation "expect_operator_binary_shift_left" =>
		expectation => expect_operator_binary_shift_left,
		match       => build_csi_token ('::Operator::Binary::Shift::Left' => '<<'),
		;

	is_expectation "expect_operator_binary_shift_right" =>
		expectation => expect_operator_binary_shift_right,
		match       => build_csi_token ('::Operator::Binary::Shift::Right' => '>>'),
		;

	is_expectation "expect_operator_binary_ushift_right" =>
		expectation => expect_operator_binary_ushift_right,
		match       => build_csi_token ('::Operator::Binary::UShift::Right' => '>>>'),
		;

	is_expectation "expect_operator_binary_xor" =>
		expectation => expect_operator_binary_xor,
		match       => build_csi_token ('::Operator::Binary::Xor' => '^'),
		;

	is_expectation "expect_operator_decrement" =>
		expectation => expect_operator_decrement,
		match       => build_csi_token ('::Operator::Decrement' => '--'),
		;

	is_expectation "expect_operator_division" =>
		expectation => expect_operator_division,
		match       => build_csi_token ('::Operator::Division' => '/'),
		;

	is_expectation "expect_operator_equality" =>
		expectation => expect_operator_equality,
		match       => build_csi_token ('::Operator::Equality' => '=='),
		;

	is_expectation "expect_operator_greater_equal" =>
		expectation => expect_operator_greater_equal,
		match       => build_csi_token ('::Operator::Greater::Equal' => '>='),
		;

	is_expectation "expect_operator_greater_than" =>
		expectation => expect_operator_greater_than,
		match       => build_csi_token ('::Operator::Greater' => '>'),
		;

	is_expectation "expect_operator_increment" =>
		expectation => expect_operator_increment,
		match       => build_csi_token ('::Operator::Increment' => '++'),
		;

	is_expectation "expect_operator_inequality" =>
		expectation => expect_operator_inequality,
		match       => build_csi_token ('::Operator::Inequality' => '!='),
		;

	is_expectation "expect_operator_lambda" =>
		expectation => expect_operator_lambda,
		match       => build_csi_token ('::Operator::Lambda' => '->'),
		;

	is_expectation "expect_operator_less_equal" =>
		expectation => expect_operator_less_equal,
		match       => build_csi_token ('::Operator::Less::Equal' => '<='),
		;

	is_expectation "expect_operator_less_than" =>
		expectation => expect_operator_less_than,
		match       => build_csi_token ('::Operator::Less' => '<'),
		;

	is_expectation "expect_operator_logical_and" =>
		expectation => expect_operator_logical_and,
		match       => build_csi_token ('::Operator::Logical::And' => '&&'),
		;

	is_expectation "expect_operator_logical_complement" =>
		expectation => expect_operator_logical_complement,
		match       => build_csi_token ('::Operator::Logical::Complement' => '!'),
		;

	is_expectation "expect_operator_logical_or" =>
		expectation => expect_operator_logical_or,
		match       => build_csi_token ('::Operator::Logical::Or' => '||'),
		;

	is_expectation "expect_operator_modulus" =>
		expectation => expect_operator_modulus,
		match       => build_csi_token ('::Operator::Modulus' => '%'),
		;

	is_expectation "expect_operator_multiplication" =>
		expectation => expect_operator_multiplication,
		match       => build_csi_token ('::Operator::Multiplication' => '*'),
		;

	is_expectation "expect_operator_subtraction" =>
		expectation => expect_operator_subtraction,
		match       => build_csi_token ('::Operator::Subtraction' => '-'),
		;

	is_expectation "expect_operator_unary_minus" =>
		expectation => expect_operator_unary_minus,
		match       => build_csi_token ('::Operator::Unary::Minus' => '-'),
		;

	is_expectation "expect_operator_unary_plus" =>
		expectation => expect_operator_unary_plus,
		match       => build_csi_token ('::Operator::Unary::Plus' => '+'),
		;

	is_expectation "expect_token_type_list_close" =>
		expectation => expect_token_type_list_close,
		match       => build_csi_token ('::Token::Type::List::Close' => '>'),
		;

	is_expectation "expect_token_type_list_open" =>
		expectation => expect_token_type_list_open,
		match       => build_csi_token ('::Token::Type::List::Open' => '<'),
		;

	is_expectation "expect_token_question_mark" =>
		expectation => expect_token_question_mark,
		match       => build_csi_token ('::Token::Question::Mark' => '?'),
		;

	is_expectation "expect_token_colon" =>
		expectation => expect_token_colon,
		match       => build_csi_token ('::Token::Colon' => ':'),
		;

	done_testing;
};

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
