#!/usr/bin/env perl

use v5.14;
use strict;
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

	is "expect_operator_addition" =>
		expect => expect_operator_addition,
		got    => { 'CSI::Language::Java::Operator::Addition' => '+' },
		;

	is "expect_operator_assign" =>
		expect => expect_operator_assign,
		got    => { 'CSI::Language::Java::Operator::Assign' => '=' },
		;

	is "expect_operator_assign_addition" =>
		expect => expect_operator_assign_addition,
		got    => { 'CSI::Language::Java::Operator::Assign::Addition' => '+=' },
		;

	is "expect_operator_assign_binary_and" =>
		expect => expect_operator_assign_binary_and,
		got    => { 'CSI::Language::Java::Operator::Assign::Binary::And' => '&=' },
		;

	is "expect_operator_assign_binary_or" =>
		expect => expect_operator_assign_binary_or,
		got    => { 'CSI::Language::Java::Operator::Assign::Binary::Or' => '|=' },
		;

	is "expect_operator_assign_binary_shift_left" =>
		expect => expect_operator_assign_binary_shift_left,
		got    => { 'CSI::Language::Java::Operator::Assign::Binary::Shift::Left' => '<<=' },
		;

	is "expect_operator_assign_binary_shift_right" =>
		expect => expect_operator_assign_binary_shift_right,
		got    => { 'CSI::Language::Java::Operator::Assign::Binary::Shift::Right' => '>>=' },
		;

	is "expect_operator_assign_binary_ushift_right" =>
		expect => expect_operator_assign_binary_ushift_right,
		got    => { 'CSI::Language::Java::Operator::Assign::Binary::UShift::Right' => '>>>=' },
		;

	is "expect_operatxor_assign_binary_xor" =>
		expect => expect_operator_assign_binary_xor,
		got    => { 'CSI::Language::Java::Operator::Assign::Binary::Xor' => '^=' },
		;

	is "expect_operator_assign_division" =>
		expect => expect_operator_assign_division,
		got    => { 'CSI::Language::Java::Operator::Assign::Division' => '/=' },
		;

	is "expect_operator_assign_modulus" =>
		expect => expect_operator_assign_modulus,
		got    => { 'CSI::Language::Java::Operator::Assign::Modulus' => '%=' },
		;

	is "expect_operator_assign_multiplication" =>
		expect => expect_operator_assign_multiplication,
		got    => { 'CSI::Language::Java::Operator::Assign::Multiplication' => '*=' },
		;

	is "expect_operator_assign_subtraction" =>
		expect => expect_operator_assign_subtraction,
		got    => { 'CSI::Language::Java::Operator::Assign::Subtraction' => '-=' },
		;

	is "expect_operator_binary_and" =>
		expect => expect_operator_binary_and,
		got    => { 'CSI::Language::Java::Operator::Binary::And' => '&' },
		;

	is "expect_operator_binary_complement" =>
		expect => expect_operator_binary_complement,
		got    => { 'CSI::Language::Java::Operator::Binary::Complement' => '~' },
		;

	is "expect_operator_binary_or" =>
		expect => expect_operator_binary_or,
		got    => { 'CSI::Language::Java::Operator::Binary::Or' => '|' },
		;

	is "expect_operator_binary_shift_left" =>
		expect => expect_operator_binary_shift_left,
		got    => { 'CSI::Language::Java::Operator::Binary::Shift::Left' => '<<' },
		;

	is "expect_operator_binary_shift_right" =>
		expect => expect_operator_binary_shift_right,
		got    => { 'CSI::Language::Java::Operator::Binary::Shift::Right' => '>>' },
		;

	is "expect_operator_binary_ushift_right" =>
		expect => expect_operator_binary_ushift_right,
		got    => { 'CSI::Language::Java::Operator::Binary::UShift::Right' => '>>>' },
		;

	is "expect_operator_binary_xor" =>
		expect => expect_operator_binary_xor,
		got    => { 'CSI::Language::Java::Operator::Binary::Xor' => '^' },
		;

	is "expect_operator_decrement" =>
		expect => expect_operator_decrement,
		got    => { 'CSI::Language::Java::Operator::Decrement' => '--' },
		;

	is "expect_operator_division" =>
		expect => expect_operator_division,
		got    => { 'CSI::Language::Java::Operator::Division' => '/' },
		;

	is "expect_operator_equality" =>
		expect => expect_operator_equality,
		got    => { 'CSI::Language::Java::Operator::Equality' => '==' },
		;

	is "expect_operator_greater_equal" =>
		expect => expect_operator_greater_equal,
		got    => { 'CSI::Language::Java::Operator::Greater::Equal' => '>=' },
		;

	is "expect_operator_greater_than" =>
		expect => expect_operator_greater_than,
		got    => { 'CSI::Language::Java::Operator::Greater' => '>' },
		;

	is "expect_operator_increment" =>
		expect => expect_operator_increment,
		got    => { 'CSI::Language::Java::Operator::Increment' => '++' },
		;

	is "expect_operator_inequality" =>
		expect => expect_operator_inequality,
		got    => { 'CSI::Language::Java::Operator::Inequality' => '!=' },
		;

	is "expect_operator_lambda" =>
		expect => expect_operator_lambda,
		got    => { 'CSI::Language::Java::Operator::Lambda' => '->' },
		;

	is "expect_operator_less_equal" =>
		expect => expect_operator_less_equal,
		got    => { 'CSI::Language::Java::Operator::Less::Equal' => '<=' },
		;

	is "expect_operator_less_than" =>
		expect => expect_operator_less_than,
		got    => { 'CSI::Language::Java::Operator::Less' => '<' },
		;

	is "expect_operator_logical_and" =>
		expect => expect_operator_logical_and,
		got    => { 'CSI::Language::Java::Operator::Logical::And' => '&&' },
		;

	is "expect_operator_logical_complement" =>
		expect => expect_operator_logical_complement,
		got    => { 'CSI::Language::Java::Operator::Logical::Complement' => '!' },
		;

	is "expect_operator_logical_or" =>
		expect => expect_operator_logical_or,
		got    => { 'CSI::Language::Java::Operator::Logical::Or' => '||' },
		;

	is "expect_operator_modulus" =>
		expect => expect_operator_modulus,
		got    => { 'CSI::Language::Java::Operator::Modulus' => '%' },
		;

	is "expect_operator_multiplication" =>
		expect => expect_operator_multiplication,
		got    => { 'CSI::Language::Java::Operator::Multiplication' => '*' },
		;

	is "expect_operator_subtraction" =>
		expect => expect_operator_subtraction,
		got    => { 'CSI::Language::Java::Operator::Subtraction' => '-' },
		;

	is "expect_operator_unary_minus" =>
		expect => expect_operator_unary_minus,
		got    => { 'CSI::Language::Java::Operator::Unary::Minus' => '-' },
		;

	is "expect_operator_unary_plus" =>
		expect => expect_operator_unary_plus,
		got    => { 'CSI::Language::Java::Operator::Unary::Plus' => '+' },
		;

	is "expect_token_type_list_close" =>
		expect => expect_token_type_list_close,
		got    => { 'CSI::Language::Java::Token::Type::List::Close' => '>' },
		;

	is "expect_token_type_list_open" =>
		expect => expect_token_type_list_open,
		got    => { 'CSI::Language::Java::Token::Type::List::Open' => '<' },
		;

	is "expect_token_question_mark" =>
		expect => expect_token_question_mark,
		got    => { 'CSI::Language::Java::Token::Question::Mark' => '?' },
		;

	is "expect_token_colon" =>
		expect => expect_token_colon,
		got    => { 'CSI::Language::Java::Token::Colon' => ':' },
		;

	done_testing;
};

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
