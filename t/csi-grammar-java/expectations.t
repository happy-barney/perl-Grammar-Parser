#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 9;

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

subtest "separators"                    => sub {
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

subtest "words"                         => sub {
	plan tests => 5;

	subtest "literal / null" => sub {
		plan tests => 1;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.10.7";

		it 'expectation expect_word_null',
			got    => expect_word_null,
			expect => expect_token ('CSI::Language::Java::Token::Word::Null' => 'null'),
			;

		done_testing;
	};

	subtest "literal / boolean" => sub {
		plan tests => 2;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.10.3";

		it 'expectation expect_word_false',
			got    => expect_word_false,
			expect => expect_token ('CSI::Language::Java::Token::Word::False' => 'false'),
			;

		it 'expectation expect_word_true',
			got    => expect_word_true,
			expect => expect_token ('CSI::Language::Java::Token::Word::True' => 'true'),
			;

		done_testing;
	};

	subtest "reserved words / module declaration" => sub {
		plan tests => 10;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.9";

		it 'expectation expect_word_exports',
			got    => expect_word_exports,
			expect => expect_token ('CSI::Language::Java::Token::Word::Exports' => 'exports'),
			;

		it 'expectation expect_word_module',
			got    => expect_word_module,
			expect => expect_token ('CSI::Language::Java::Token::Word::Module' => 'module'),
			;

		it 'expectation expect_word_open',
			got    => expect_word_open,
			expect => expect_token ('CSI::Language::Java::Token::Word::Open' => 'open'),
			;

		it 'expectation expect_word_opens',
			got    => expect_word_opens,
			expect => expect_token ('CSI::Language::Java::Token::Word::Opens' => 'opens'),
			;

		it 'expectation expect_word_provides',
			got    => expect_word_provides,
			expect => expect_token ('CSI::Language::Java::Token::Word::Provides' => 'provides'),
			;

		it 'expectation expect_word_requires',
			got    => expect_word_requires,
			expect => expect_token ('CSI::Language::Java::Token::Word::Requires' => 'requires'),
			;

		it 'expectation expect_word_to',
			got    => expect_word_to,
			expect => expect_token ('CSI::Language::Java::Token::Word::To' => 'to'),
			;

		it 'expectation expect_word_transitive',
			got    => expect_word_transitive,
			expect => expect_token ('CSI::Language::Java::Token::Word::Transitive' => 'transitive'),
			;

		it 'expectation expect_word_uses',
			got    => expect_word_uses,
			expect => expect_token ('CSI::Language::Java::Token::Word::Uses' => 'uses'),
			;

		it 'expectation expect_word_with',
			got    => expect_word_with,
			expect => expect_token ('CSI::Language::Java::Token::Word::With' => 'with'),
			;

		done_testing;
	};

	subtest "identifiers with special meaning" => sub {
		plan tests => 1;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.9";

		it 'expectation expect_word_var',
			got    => expect_word_var,
			expect => expect_token ('CSI::Language::Java::Token::Word::Var' => 'var'),
			;

		done_testing;
	};

	subtest "keywords" => sub {
		plan tests => 51;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.9";

		it 'expectation expect_word_abstract',
			got    => expect_word_abstract,
			expect => expect_token ('CSI::Language::Java::Token::Word::Abstract' => 'abstract'),
			;

		it 'expectation expect_word_assert',
			got    => expect_word_assert,
			expect => expect_token ('CSI::Language::Java::Token::Word::Assert' => 'assert'),
			;

		it 'expectation expect_word_boolean',
			got    => expect_word_boolean,
			expect => expect_token ('CSI::Language::Java::Token::Word::Boolean' => 'boolean'),
			;

		it 'expectation expect_word_break',
			got    => expect_word_break,
			expect => expect_token ('CSI::Language::Java::Token::Word::Break' => 'break'),
			;

		it 'expectation expect_word_byte',
			got    => expect_word_byte,
			expect => expect_token ('CSI::Language::Java::Token::Word::Byte' => 'byte'),
			;

		it 'expectation expect_word_case',
			got    => expect_word_case,
			expect => expect_token ('CSI::Language::Java::Token::Word::Case' => 'case'),
			;

		it 'expectation expect_word_catch',
			got    => expect_word_catch,
			expect => expect_token ('CSI::Language::Java::Token::Word::Catch' => 'catch'),
			;

		it 'expectation expect_word_char',
			got    => expect_word_char,
			expect => expect_token ('CSI::Language::Java::Token::Word::Char' => 'char'),
			;

		it 'expectation expect_word_class',
			got    => expect_word_class,
			expect => expect_token ('CSI::Language::Java::Token::Word::Class' => 'class'),
			;

		it 'expectation expect_word_const',
			got    => expect_word_const,
			expect => expect_token ('CSI::Language::Java::Token::Word::Const' => 'const'),
		;

		it 'expectation expect_word_continue',
			got    => expect_word_continue,
			expect => expect_token ('CSI::Language::Java::Token::Word::Continue' => 'continue'),
			;

		it 'expectation expect_word_default',
			got    => expect_word_default,
			expect => expect_token ('CSI::Language::Java::Token::Word::Default' => 'default'),
			;

		it 'expectation expect_word_do',
			got    => expect_word_do,
			expect => expect_token ('CSI::Language::Java::Token::Word::Do' => 'do'),
			;

		it 'expectation expect_word_double',
			got    => expect_word_double,
			expect => expect_token ('CSI::Language::Java::Token::Word::Double' => 'double'),
			;

		it 'expectation expect_word_else',
			got    => expect_word_else,
			expect => expect_token ('CSI::Language::Java::Token::Word::Else' => 'else'),
			;

		it 'expectation expect_word_enum',
			got    => expect_word_enum,
			expect => expect_token ('CSI::Language::Java::Token::Word::Enum' => 'enum'),
			;

		it 'expectation expect_word_extends',
			got    => expect_word_extends,
			expect => expect_token ('CSI::Language::Java::Token::Word::Extends' => 'extends'),
			;

		it 'expectation expect_word_final',
			got    => expect_word_final,
			expect => expect_token ('CSI::Language::Java::Token::Word::Final' => 'final'),
			;

		it 'expectation expect_word_finally',
			got    => expect_word_finally,
			expect => expect_token ('CSI::Language::Java::Token::Word::Finally' => 'finally'),
			;

		it 'expectation expect_word_float',
			got    => expect_word_float,
			expect => expect_token ('CSI::Language::Java::Token::Word::Float' => 'float'),
			;

		it 'expectation expect_word_for',
			got    => expect_word_for,
			expect => expect_token ('CSI::Language::Java::Token::Word::For' => 'for'),
			;

		it 'expectation expect_word_if',
			got    => expect_word_if,
			expect => expect_token ('CSI::Language::Java::Token::Word::If' => 'if'),
			;

		it 'expectation expect_word_goto',
			got    => expect_word_goto,
			expect => expect_token ('CSI::Language::Java::Token::Word::Goto' => 'goto'),
			;

		it 'expectation expect_word_implements',
			got    => expect_word_implements,
			expect => expect_token ('CSI::Language::Java::Token::Word::Implements' => 'implements'),
			;

		it 'expectation expect_word_import',
			got    => expect_word_import,
			expect => expect_token ('CSI::Language::Java::Token::Word::Import' => 'import'),
			;

		it 'expectation expect_word_instanceof',
			got    => expect_word_instanceof,
			expect => expect_token ('CSI::Language::Java::Token::Word::Instanceof' => 'instanceof'),
			;

		it 'expectation expect_word_int',
			got    => expect_word_int,
			expect => expect_token ('CSI::Language::Java::Token::Word::Int' => 'int'),
			;

		it 'expectation expect_word_interface',
			got    => expect_word_interface,
			expect => expect_token ('CSI::Language::Java::Token::Word::Interface' => 'interface'),
			;

		it 'expectation expect_word_long',
			got    => expect_word_long,
			expect => expect_token ('CSI::Language::Java::Token::Word::Long' => 'long'),
			;

		it 'expectation expect_word_native',
			got    => expect_word_native,
			expect => expect_token ('CSI::Language::Java::Token::Word::Native' => 'native'),
			;

		it 'expectation expect_word_new',
			got    => expect_word_new,
			expect => expect_token ('CSI::Language::Java::Token::Word::New' => 'new'),
			;

		it 'expectation expect_word_package',
			got    => expect_word_package,
			expect => expect_token ('CSI::Language::Java::Token::Word::Package' => 'package'),
			;

		it 'expectation expect_word_private',
			got    => expect_word_private,
			expect => expect_token ('CSI::Language::Java::Token::Word::Private' => 'private'),
			;

		it 'expectation expect_word_protected',
			got    => expect_word_protected,
			expect => expect_token ('CSI::Language::Java::Token::Word::Protected' => 'protected'),
			;

		it 'expectation expect_word_public',
			got    => expect_word_public,
			expect => expect_token ('CSI::Language::Java::Token::Word::Public' => 'public'),
			;

		it 'expectation expect_word_return',
			got    => expect_word_return,
			expect => expect_token ('CSI::Language::Java::Token::Word::Return' => 'return'),
			;

		it 'expectation expect_word_short',
			got    => expect_word_short,
			expect => expect_token ('CSI::Language::Java::Token::Word::Short' => 'short'),
			;

		it 'expectation expect_word_static',
			got    => expect_word_static,
			expect => expect_token ('CSI::Language::Java::Token::Word::Static' => 'static'),
			;

		it 'expectation expect_word_strictfp',
			got    => expect_word_strictfp,
			expect => expect_token ('CSI::Language::Java::Token::Word::Strictfp' => 'strictfp'),
			;

		it 'expectation expect_word_super',
			got    => expect_word_super,
			expect => expect_token ('CSI::Language::Java::Token::Word::Super' => 'super'),
			;

		it 'expectation expect_word_switch',
			got    => expect_word_switch,
			expect => expect_token ('CSI::Language::Java::Token::Word::Switch' => 'switch'),
			;

		it 'expectation expect_word_synchronized',
			got    => expect_word_synchronized,
			expect => expect_token ('CSI::Language::Java::Token::Word::Synchronized' => 'synchronized'),
			;

		it 'expectation expect_word_this',
			got    => expect_word_this,
			expect => expect_token ('CSI::Language::Java::Token::Word::This' => 'this'),
			;

		it 'expectation expect_word_throw',
			got    => expect_word_throw,
			expect => expect_token ('CSI::Language::Java::Token::Word::Throw' => 'throw'),
			;

		it 'expectation expect_word_throws',
			got    => expect_word_throws,
			expect => expect_token ('CSI::Language::Java::Token::Word::Throws' => 'throws'),
			;

		it 'expectation expect_word_transient',
			got    => expect_word_transient,
			expect => expect_token ('CSI::Language::Java::Token::Word::Transient' => 'transient'),
			;

		it 'expectation expect_word_try',
			got    => expect_word_try,
			expect => expect_token ('CSI::Language::Java::Token::Word::Try' => 'try'),
			;

		it 'expectation expect_word_void',
			got    => expect_word_void,
			expect => expect_token ('CSI::Language::Java::Token::Word::Void' => 'void'),
			;

		it 'expectation expect_word_volatile',
			got    => expect_word_volatile,
			expect => expect_token ('CSI::Language::Java::Token::Word::Volatile' => 'volatile'),
			;

		it 'expectation expect_word_while',
			got    => expect_word_while,
			expect => expect_token ('CSI::Language::Java::Token::Word::While' => 'while'),
			;

		it 'expectation expect_word_underscore',
			got    => expect_word_underscore,
			expect => expect_token ('CSI::Language::Java::Token::Word::_' => '_'),
			;

		done_testing;
	};

	done_testing;
};

subtest "literals"          => sub {
	plan tests => 10;

	is "expect_literal_false" =>
		expect => expect_literal_false,
		got    => {
			'CSI::Language::Java::Literal::Boolean::False' => [
				{ 'CSI::Language::Java::Token::Word::False' => 'false' },
			],
		},
		;

	is "expect_literal_true" =>
		expect => expect_literal_true,
		got    => {
			'CSI::Language::Java::Literal::Boolean::True' => [
				{ 'CSI::Language::Java::Token::Word::True' => 'true' },
			],
		},
		;

	is "expect_literal_null" =>
		expect => expect_literal_null,
		got    => {
			'CSI::Language::Java::Literal::Null' => [
				{ 'CSI::Language::Java::Token::Word::Null' => 'null' },
			],
		},
		;

	is "expect_literal_string" =>
		expect => expect_literal_string ('foo'),
		got    => {
			'LITERAL_STRING' => "foo",
		},
		;

	is "expect_literal_character" =>
		expect => expect_literal_character ('f'),
		got    => {
			'LITERAL_CHARACTER' => "f",
		},
		;

	it "expect_literal_integral_binary" =>
		expect => expect_literal_integral_binary ('0b0'),
		got => {
			'LITERAL_INTEGRAL_BINARY' => '0b0',
		},
		;

	is "expect_literal_integral_decimal" =>
		expect => expect_literal_integral_decimal ('0'),
		got    => {
			'LITERAL_INTEGRAL_DECIMAL' => "0",
		},
		;

	it "expect_literal_integral_hex" =>
		expect => expect_literal_integral_hex ('0x0'),
		got => {
			'LITERAL_INTEGRAL_HEX' => '0x0',
		},
		;

	it "expect_literal_integral_octal" =>
		expect => expect_literal_integral_octal ('06'),
		got => {
			'LITERAL_INTEGRAL_OCTAL' => '06',
		},
		;

	it "expect_literal_floating_decimal" =>
		expect => expect_literal_floating_decimal ('.0'),
		got => {
			'LITERAL_FLOAT_DECIMAL' => '.0',
		},
		;

	done_testing;
};

subtest "expect_annotation"             => sub {
	plan tests => 3;

	is "expect_annotation / referenced by identifer" =>
		expect => expect_annotation ([qw[ foo ]]),
		got    => { 'CSI::Language::Java::Annotation' => [
			{ 'CSI::Language::Java::Token::Annotation' => '@' },
			{ 'CSI::Language::Java::Reference' => [
				{ 'CSI::Language::Java::Identifier' => 'foo' },
			] },
		] },
		;

	is "expect_annotation / referenced by qualified identifier" =>
		expect => expect_annotation ([qw[ foo bar baz ]]),
		got    => { 'CSI::Language::Java::Annotation' => [
			{ 'CSI::Language::Java::Token::Annotation' => '@' },
			{ 'CSI::Language::Java::Reference' => [
				{ 'CSI::Language::Java::Identifier' => 'foo' },
				{ 'CSI::Language::Java::Token::Dot' => '.'   },
				{ 'CSI::Language::Java::Identifier' => 'bar' },
				{ 'CSI::Language::Java::Token::Dot' => '.'   },
				{ 'CSI::Language::Java::Identifier' => 'baz' },
			] },
		] },
		;

	is "expect_annotation / with empty parameters" =>
		expect => expect_annotation ([qw[ foo ]], undef),
		got    => { 'CSI::Language::Java::Annotation' => [
			{ 'CSI::Language::Java::Token::Annotation' => '@' },
			{ 'CSI::Language::Java::Reference' => [
				{ 'CSI::Language::Java::Identifier' => 'foo' },
			] },
			{ 'CSI::Language::Java::Token::Paren::Open'  => '(' },
			{ 'CSI::Language::Java::Token::Paren::Close' => ')' },
		] },
		;

	done_testing;
};

subtest "expect_reference"              => sub {
	plan tests => 4;

	is "expect_reference / single element" =>
		expect => expect_reference (qw[ foo ]),
		got    => { 'CSI::Language::Java::Reference' => [
			{ 'CSI::Language::Java::Identifier' => 'foo' },
		] },
		;

	is "expect_reference / multiple elements" =>
		expect => expect_reference (qw[ foo bar var ]),
		got    => { 'CSI::Language::Java::Reference' => [
			{ 'CSI::Language::Java::Identifier' => 'foo' },
			{ 'CSI::Language::Java::Token::Dot' => '.'   },
			{ 'CSI::Language::Java::Identifier' => 'bar' },
			{ 'CSI::Language::Java::Token::Dot' => '.'   },
			{ 'CSI::Language::Java::Identifier' => 'var' },
		] },
		;

	is "expect_reference / arrayref / single element" =>
		expect => expect_reference ([qw[ foo ]]),
		got    => { 'CSI::Language::Java::Reference' => [
			{ 'CSI::Language::Java::Identifier' => 'foo' },
		] },
		;

	is "expect_reference / arrayref / multiple elements" =>
		expect => expect_reference ([qw[ foo bar var ]]),
		got    => { 'CSI::Language::Java::Reference' => [
			{ 'CSI::Language::Java::Identifier' => 'foo' },
			{ 'CSI::Language::Java::Token::Dot' => '.'   },
			{ 'CSI::Language::Java::Identifier' => 'bar' },
			{ 'CSI::Language::Java::Token::Dot' => '.'   },
			{ 'CSI::Language::Java::Identifier' => 'var' },
		] },
		;

	done_testing;
};

subtest "expect_import_declaration"     => sub {
	plan tests => 4;

	is "expect_import_declaration / import" =>
		expect => expect_import_declaration (
			[qw[ foo bar ]],
		),
		got    => { 'CSI::Language::Java::Import::Declaration' => [
			{ 'CSI::Language::Java::Token::Word::Import' => 'import'},
			{ 'CSI::Language::Java::Reference' => [
				{ 'CSI::Language::Java::Identifier' => 'foo' },
				{ 'CSI::Language::Java::Token::Dot' => '.' },
				{ 'CSI::Language::Java::Identifier' => 'bar' },
			] },
			{ 'CSI::Language::Java::Token::Semicolon' => ';' },
		] },
		;

	is "expect_import_declaration / static import" =>
		expect => expect_import_declaration (
			'static',
			[qw[ foo bar ]],
		),
		got    => { 'CSI::Language::Java::Import::Declaration' => [
			{ 'CSI::Language::Java::Token::Word::Import' => 'import'},
			{ 'CSI::Language::Java::Token::Word::Static' => 'static'},
			{ 'CSI::Language::Java::Reference' => [
				{ 'CSI::Language::Java::Identifier' => 'foo' },
				{ 'CSI::Language::Java::Token::Dot' => '.' },
				{ 'CSI::Language::Java::Identifier' => 'bar' },
			] },
			{ 'CSI::Language::Java::Token::Semicolon' => ';' },
		] },
		;

	is "expect_import_declaration / type import" =>
		expect => expect_import_declaration (
			[qw[ foo bar ]],
			'*',
		),
		got    => { 'CSI::Language::Java::Import::Declaration' => [
			{ 'CSI::Language::Java::Token::Word::Import' => 'import'},
			{ 'CSI::Language::Java::Reference' => [
				{ 'CSI::Language::Java::Identifier' => 'foo' },
				{ 'CSI::Language::Java::Token::Dot' => '.' },
				{ 'CSI::Language::Java::Identifier' => 'bar' },
			] },
			{ 'CSI::Language::Java::Token::Dot' => '.' },
			{ 'CSI::Language::Java::Token::Import::Type' => '*' },
			{ 'CSI::Language::Java::Token::Semicolon' => ';' },
		] },
		;

	is "expect_import_declaration / static type import" =>
		expect => expect_import_declaration (
			'static',
			[qw[ foo bar ]],
			'*',
		),
		got    => { 'CSI::Language::Java::Import::Declaration' => [
			{ 'CSI::Language::Java::Token::Word::Import' => 'import'},
			{ 'CSI::Language::Java::Token::Word::Static' => 'static'},
			{ 'CSI::Language::Java::Reference' => [
				{ 'CSI::Language::Java::Identifier' => 'foo' },
				{ 'CSI::Language::Java::Token::Dot' => '.' },
				{ 'CSI::Language::Java::Identifier' => 'bar' },
			] },
			{ 'CSI::Language::Java::Token::Dot' => '.' },
			{ 'CSI::Language::Java::Token::Import::Type' => '*' },
			{ 'CSI::Language::Java::Token::Semicolon' => ';' },
		] },
		;

	done_testing;
};

subtest "expect_package_declaration"    => sub {
	plan tests => 2;

	is "expect_package_declaration / with just package name" =>
		expect => expect_package_declaration (
			[qw[ foo bar ]],
		),
		got    => { 'CSI::Language::Java::Package::Declaration' => [
			{ 'CSI::Language::Java::Token::Word::Package' => 'package'},
			{ 'CSI::Language::Java::Package::Name' => [
				{ 'CSI::Language::Java::Identifier' => 'foo' },
				{ 'CSI::Language::Java::Token::Dot' => '.' },
				{ 'CSI::Language::Java::Identifier' => 'bar' },
			] },
			{ 'CSI::Language::Java::Token::Semicolon' => ';' },
		] },
		;

	is "expect_package_declaration / with annotations" =>
		expect => expect_package_declaration (
			[qw[ foo bar ]],
			expect_annotation ([qw[ foo ]]),
		),
		got    => { 'CSI::Language::Java::Package::Declaration' => [
			{ 'CSI::Language::Java::Annotation' => [
				{ 'CSI::Language::Java::Token::Annotation' => '@' },
				{ 'CSI::Language::Java::Reference' => [
					{ 'CSI::Language::Java::Identifier' => 'foo' },
				] },
			] },
			{ 'CSI::Language::Java::Token::Word::Package' => 'package'},
			{ 'CSI::Language::Java::Package::Name' => [
				{ 'CSI::Language::Java::Identifier' => 'foo' },
				{ 'CSI::Language::Java::Token::Dot' => '.' },
				{ 'CSI::Language::Java::Identifier' => 'bar' },
			] },
			{ 'CSI::Language::Java::Token::Semicolon' => ';' },
		] },
		;

	done_testing;
};

had_no_warnings;

done_testing;
