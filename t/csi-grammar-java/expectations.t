#!/usr/bin/env perl

use v5.14;
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

subtest "separators"                => sub {
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

subtest "words"                     => sub {
	plan tests => 5;

	subtest "literal / null" => sub {
		plan tests => 1;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.10.7";

		is_expectation 'expectation expect_word_null',
			expectation => expect_word_null,
			match       => build_csi_token ('::Token::Word::Null' => 'null'),
			;

		done_testing;
	};

	subtest "literal / boolean" => sub {
		plan tests => 2;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.10.3";

		is_expectation 'expectation expect_word_false',
			expectation => expect_word_false,
			match       => build_csi_token ('::Token::Word::False' => 'false'),
			;

		is_expectation 'expectation expect_word_true',
			expectation => expect_word_true,
			match       => build_csi_token ('::Token::Word::True' => 'true'),
			;

		done_testing;
	};

	subtest "reserved words / module declaration" => sub {
		plan tests => 10;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.9";

		is_expectation 'expectation expect_word_exports',
			expectation => expect_word_exports,
			match       => build_csi_token ('::Token::Word::Exports' => 'exports'),
			;

		is_expectation 'expectation expect_word_module',
			expectation => expect_word_module,
			match       => build_csi_token ('::Token::Word::Module' => 'module'),
			;

		is_expectation 'expectation expect_word_open',
			expectation => expect_word_open,
			match       => build_csi_token ('::Token::Word::Open' => 'open'),
			;

		is_expectation 'expectation expect_word_opens',
			expectation => expect_word_opens,
			match       => build_csi_token ('::Token::Word::Opens' => 'opens'),
			;

		is_expectation 'expectation expect_word_provides',
			expectation => expect_word_provides,
			match       => build_csi_token ('::Token::Word::Provides' => 'provides'),
			;

		is_expectation 'expectation expect_word_requires',
			expectation => expect_word_requires,
			match       => build_csi_token ('::Token::Word::Requires' => 'requires'),
			;

		is_expectation 'expectation expect_word_to',
			expectation => expect_word_to,
			match       => build_csi_token ('::Token::Word::To' => 'to'),
			;

		is_expectation 'expectation expect_word_transitive',
			expectation => expect_word_transitive,
			match       => build_csi_token ('::Token::Word::Transitive' => 'transitive'),
			;

		is_expectation 'expectation expect_word_uses',
			expectation => expect_word_uses,
			match       => build_csi_token ('::Token::Word::Uses' => 'uses'),
			;

		is_expectation 'expectation expect_word_with',
			expectation => expect_word_with,
			match       => build_csi_token ('::Token::Word::With' => 'with'),
			;

		done_testing;
	};

	subtest "identifiers with special meaning" => sub {
		plan tests => 1;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.9";

		is_expectation 'expectation expect_word_var',
			expectation => expect_word_var,
			match       => build_csi_token ('::Token::Word::Var' => 'var'),
			;

		done_testing;
	};

	subtest "keywords" => sub {
		plan tests => 51;
		note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.9";

		is_expectation 'expectation expect_word_abstract',
			expectation => expect_word_abstract,
			match       => build_csi_token ('::Token::Word::Abstract' => 'abstract'),
			;

		is_expectation 'expectation expect_word_assert',
			expectation => expect_word_assert,
			match       => build_csi_token ('::Token::Word::Assert' => 'assert'),
			;

		is_expectation 'expectation expect_word_boolean',
			expectation => expect_word_boolean,
			match       => build_csi_token ('::Token::Word::Boolean' => 'boolean'),
			;

		is_expectation 'expectation expect_word_break',
			expectation => expect_word_break,
			match       => build_csi_token ('::Token::Word::Break' => 'break'),
			;

		is_expectation 'expectation expect_word_byte',
			expectation => expect_word_byte,
			match       => build_csi_token ('::Token::Word::Byte' => 'byte'),
			;

		is_expectation 'expectation expect_word_case',
			expectation => expect_word_case,
			match       => build_csi_token ('::Token::Word::Case' => 'case'),
			;

		is_expectation 'expectation expect_word_catch',
			expectation => expect_word_catch,
			match       => build_csi_token ('::Token::Word::Catch' => 'catch'),
			;

		is_expectation 'expectation expect_word_char',
			expectation => expect_word_char,
			match       => build_csi_token ('::Token::Word::Char' => 'char'),
			;

		is_expectation 'expectation expect_word_class',
			expectation => expect_word_class,
			match       => build_csi_token ('::Token::Word::Class' => 'class'),
			;

		is_expectation 'expectation expect_word_const',
			expectation => expect_word_const,
			match       => build_csi_token ('::Token::Word::Const' => 'const'),
		;

		is_expectation 'expectation expect_word_continue',
			expectation => expect_word_continue,
			match       => build_csi_token ('::Token::Word::Continue' => 'continue'),
			;

		is_expectation 'expectation expect_word_default',
			expectation => expect_word_default,
			match       => build_csi_token ('::Token::Word::Default' => 'default'),
			;

		is_expectation 'expectation expect_word_do',
			expectation => expect_word_do,
			match       => build_csi_token ('::Token::Word::Do' => 'do'),
			;

		is_expectation 'expectation expect_word_double',
			expectation => expect_word_double,
			match       => build_csi_token ('::Token::Word::Double' => 'double'),
			;

		is_expectation 'expectation expect_word_else',
			expectation => expect_word_else,
			match       => build_csi_token ('::Token::Word::Else' => 'else'),
			;

		is_expectation 'expectation expect_word_enum',
			expectation => expect_word_enum,
			match       => build_csi_token ('::Token::Word::Enum' => 'enum'),
			;

		is_expectation 'expectation expect_word_extends',
			expectation => expect_word_extends,
			match       => build_csi_token ('::Token::Word::Extends' => 'extends'),
			;

		is_expectation 'expectation expect_word_final',
			expectation => expect_word_final,
			match       => build_csi_token ('::Token::Word::Final' => 'final'),
			;

		is_expectation 'expectation expect_word_finally',
			expectation => expect_word_finally,
			match       => build_csi_token ('::Token::Word::Finally' => 'finally'),
			;

		is_expectation 'expectation expect_word_float',
			expectation => expect_word_float,
			match       => build_csi_token ('::Token::Word::Float' => 'float'),
			;

		is_expectation 'expectation expect_word_for',
			expectation => expect_word_for,
			match       => build_csi_token ('::Token::Word::For' => 'for'),
			;

		is_expectation 'expectation expect_word_if',
			expectation => expect_word_if,
			match       => build_csi_token ('::Token::Word::If' => 'if'),
			;

		is_expectation 'expectation expect_word_goto',
			expectation => expect_word_goto,
			match       => build_csi_token ('::Token::Word::Goto' => 'goto'),
			;

		is_expectation 'expectation expect_word_implements',
			expectation => expect_word_implements,
			match       => build_csi_token ('::Token::Word::Implements' => 'implements'),
			;

		is_expectation 'expectation expect_word_import',
			expectation => expect_word_import,
			match       => build_csi_token ('::Token::Word::Import' => 'import'),
			;

		is_expectation 'expectation expect_word_instanceof',
			expectation => expect_word_instanceof,
			match       => build_csi_token ('::Token::Word::Instanceof' => 'instanceof'),
			;

		is_expectation 'expectation expect_word_int',
			expectation => expect_word_int,
			match       => build_csi_token ('::Token::Word::Int' => 'int'),
			;

		is_expectation 'expectation expect_word_interface',
			expectation => expect_word_interface,
			match       => build_csi_token ('::Token::Word::Interface' => 'interface'),
			;

		is_expectation 'expectation expect_word_long',
			expectation => expect_word_long,
			match       => build_csi_token ('::Token::Word::Long' => 'long'),
			;

		is_expectation 'expectation expect_word_native',
			expectation => expect_word_native,
			match       => build_csi_token ('::Token::Word::Native' => 'native'),
			;

		is_expectation 'expectation expect_word_new',
			expectation => expect_word_new,
			match       => build_csi_token ('::Token::Word::New' => 'new'),
			;

		is_expectation 'expectation expect_word_package',
			expectation => expect_word_package,
			match       => build_csi_token ('::Token::Word::Package' => 'package'),
			;

		is_expectation 'expectation expect_word_private',
			expectation => expect_word_private,
			match       => build_csi_token ('::Token::Word::Private' => 'private'),
			;

		is_expectation 'expectation expect_word_protected',
			expectation => expect_word_protected,
			match       => build_csi_token ('::Token::Word::Protected' => 'protected'),
			;

		is_expectation 'expectation expect_word_public',
			expectation => expect_word_public,
			match       => build_csi_token ('::Token::Word::Public' => 'public'),
			;

		is_expectation 'expectation expect_word_return',
			expectation => expect_word_return,
			match       => build_csi_token ('::Token::Word::Return' => 'return'),
			;

		is_expectation 'expectation expect_word_short',
			expectation => expect_word_short,
			match       => build_csi_token ('::Token::Word::Short' => 'short'),
			;

		is_expectation 'expectation expect_word_static',
			expectation => expect_word_static,
			match       => build_csi_token ('::Token::Word::Static' => 'static'),
			;

		is_expectation 'expectation expect_word_strictfp',
			expectation => expect_word_strictfp,
			match       => build_csi_token ('::Token::Word::Strictfp' => 'strictfp'),
			;

		is_expectation 'expectation expect_word_super',
			expectation => expect_word_super,
			match       => build_csi_token ('::Token::Word::Super' => 'super'),
			;

		is_expectation 'expectation expect_word_switch',
			expectation => expect_word_switch,
			match       => build_csi_token ('::Token::Word::Switch' => 'switch'),
			;

		is_expectation 'expectation expect_word_synchronized',
			expectation => expect_word_synchronized,
			match       => build_csi_token ('::Token::Word::Synchronized' => 'synchronized'),
			;

		is_expectation 'expectation expect_word_this',
			expectation => expect_word_this,
			match       => build_csi_token ('::Token::Word::This' => 'this'),
			;

		is_expectation 'expectation expect_word_throw',
			expectation => expect_word_throw,
			match       => build_csi_token ('::Token::Word::Throw' => 'throw'),
			;

		is_expectation 'expectation expect_word_throws',
			expectation => expect_word_throws,
			match       => build_csi_token ('::Token::Word::Throws' => 'throws'),
			;

		is_expectation 'expectation expect_word_transient',
			expectation => expect_word_transient,
			match       => build_csi_token ('::Token::Word::Transient' => 'transient'),
			;

		is_expectation 'expectation expect_word_try',
			expectation => expect_word_try,
			match       => build_csi_token ('::Token::Word::Try' => 'try'),
			;

		is_expectation 'expectation expect_word_void',
			expectation => expect_word_void,
			match       => build_csi_token ('::Token::Word::Void' => 'void'),
			;

		is_expectation 'expectation expect_word_volatile',
			expectation => expect_word_volatile,
			match       => build_csi_token ('::Token::Word::Volatile' => 'volatile'),
			;

		is_expectation 'expectation expect_word_while',
			expectation => expect_word_while,
			match       => build_csi_token ('::Token::Word::While' => 'while'),
			;

		is_expectation 'expectation expect_word_underscore',
			expectation => expect_word_underscore,
			match       => build_csi_token ('::Token::Word::_' => '_'),
			;

		done_testing;
	};

	done_testing;
};

subtest "literals"                  => sub {
	plan tests => 10;

	is_expectation "expect_literal_false" =>
		expectation => expect_literal_false,
		match       => build_csi_element (
			'::Literal::Boolean::False',
			build_csi_token ('::Token::Word::False' => 'false'),
		),
		;

	is_expectation "expect_literal_true" =>
		expectation => expect_literal_true,
		match       => build_csi_element (
			'::Literal::Boolean::True',
			build_csi_token ('::Token::Word::True' => 'true'),
		),
		;

	is_expectation "expect_literal_null" =>
		expectation => expect_literal_null,
		match       => build_csi_element (
			'::Literal::Null',
			build_csi_token ('::Token::Word::Null' => 'null'),
		),
		;

	is_expectation "expect_literal_string" =>
		expectation => expect_literal_string ('foo'),
		match       => build_csi_class ('::Literal::String')->new (
			children => [
				Grammar::Parser::Lexer::Token->new (
					match => '"foo"',
					captures => { value => 'foo' },
				),
			],
		);

	is_expectation "expect_literal_character" =>
		expectation => expect_literal_character ('f'),
		match       => build_csi_class ('::Literal::Character')->new (
			children => [
				Grammar::Parser::Lexer::Token->new (
					match => "'f'",
					captures => { value => 'f' },
				),
			],
		);
		;

	is_expectation "expect_literal_integral_binary" =>
		expectation => expect_literal_integral_binary ('0b0'),
		match       => build_csi_class ('::Number::Integral::Binary')->new (
			children => [
				Grammar::Parser::Lexer::Token->new (
					match => "0b0",
				),
			],
		);

	is_expectation "expect_literal_integral_decimal" =>
		expectation => expect_literal_integral_decimal ('0'),
		match       => build_csi_class ('::Number::Integral::Decimal')->new (
			children => [
				Grammar::Parser::Lexer::Token->new (
					match => "0",
				),
			],
		);

	is_expectation "expect_literal_integral_hex" =>
		expectation => expect_literal_integral_hex ('0x0'),
		match       => build_csi_class ('::Number::Integral::Hex')->new (
			children => [
				Grammar::Parser::Lexer::Token->new (
					match => "0x0",
				),
			],
		);

	is_expectation "expect_literal_integral_octal" =>
		expectation => expect_literal_integral_octal ('06'),
		match       => build_csi_class ('::Number::Integral::Octal')->new (
			children => [
				Grammar::Parser::Lexer::Token->new (
					match => "06",
				),
			],
		);
		;

	is_expectation "expect_literal_floating_decimal" =>
		expectation => expect_literal_floating_decimal ('.0'),
		match       => build_csi_class ('::Number::Float::Decimal')->new (
			children => [
				Grammar::Parser::Lexer::Token->new (
					match => ".0",
				),
			],
		);
		;

	done_testing;
};

subtest "expect_annotation"             => sub {
	plan tests => 3;

	is_expectation "expect_annotation / referenced by identifer" =>
		expectation => expect_annotation ([qw[ foo ]]),
		match       => build_csi_element (
			'::Annotation',
			build_csi_token ('::Token::Annotation' => '@'),
			build_csi_element (
				'::Reference',
				build_csi_token ('::Identifier' => 'foo'),
			),
		),
		;

	is_expectation "expect_annotation / referenced by qualified identifier" =>
		expectation => expect_annotation ([qw[ foo bar baz ]]),
		match       => build_csi_element (
			'::Annotation',
			build_csi_token ('::Token::Annotation' => '@'),
			build_csi_element (
				'::Reference',
				build_csi_token ('::Identifier' => 'foo'),
				build_csi_token ('::Token::Dot' => '.'),
				build_csi_token ('::Identifier' => 'bar'),
				build_csi_token ('::Token::Dot' => '.'),
				build_csi_token ('::Identifier' => 'baz'),
			),
		),
		;

	is_expectation "expect_annotation / with empty parameters" =>
		expectation => expect_annotation ([qw[ foo ]], undef),
		match       => build_csi_element (
			'::Annotation',
			build_csi_token ('::Token::Annotation' => '@'),
			build_csi_element (
				'::Reference',
				build_csi_token ('::Identifier' => 'foo'),
			),
			build_csi_token ('::Token::Paren::Open'  => '(' ),
			build_csi_token ('::Token::Paren::Close' => ')'),
		),
		;

	done_testing;
};

subtest "expect_reference"              => sub {
	plan tests => 4;

	is_expectation "expect_reference / single element" =>
		expectation => expect_reference (qw[ foo ]),
		match       => build_csi_element (
			'::Reference',
			build_csi_token ('::Identifier' => 'foo'),
		),
		;

	is_expectation "expect_reference / multiple elements" =>
		expectation => expect_reference (qw[ foo bar var ]),
		match       => build_csi_element (
			'::Reference',
			build_csi_token ('::Identifier' => 'foo'),
			build_csi_token ('::Token::Dot' => '.'),
			build_csi_token ('::Identifier' => 'bar'),
			build_csi_token ('::Token::Dot' => '.'),
			build_csi_token ('::Identifier' => 'var'),
		),
		;

	is_expectation "expect_reference / arrayref / single element" =>
		expectation => expect_reference ([qw[ foo ]]),
		match       => build_csi_element (
			'::Reference',
			build_csi_token ('::Identifier' => 'foo'),
		),
		;

	is_expectation "expect_reference / arrayref / multiple elements" =>
		expectation => expect_reference ([qw[ foo bar var ]]),
		match       => build_csi_element (
			'::Reference',
			build_csi_token ('::Identifier' => 'foo'),
			build_csi_token ('::Token::Dot' => '.'),
			build_csi_token ('::Identifier' => 'bar'),
			build_csi_token ('::Token::Dot' => '.'),
			build_csi_token ('::Identifier' => 'var'),
		),
		;

	done_testing;
};

subtest "expect_import_declaration"     => sub {
	plan tests => 4;

	is "expect_import_declaration / import" =>
		expect => expect_import_declaration (
			[qw[ foo bar ]],
		),
		got    => build_csi_element ('::Import::Declaration' => (
			build_csi_token ('::Token::Word::Import' => 'import'),
			build_csi_element ('::Reference' => (
				build_csi_token ('::Identifier' => 'foo'),
				build_csi_token ('::Token::Dot' => '.'),
				build_csi_token ('::Identifier' => 'bar'),
			)),
			build_csi_token ('::Token::Semicolon' => ';'),
		)),
		;

	is "expect_import_declaration / static import" =>
		expect => expect_import_declaration (
			'static',
			[qw[ foo bar ]],
		),
		got    => build_csi_element ('::Import::Declaration' => (
			build_csi_token ('::Token::Word::Import' => 'import'),
			build_csi_token ('::Token::Word::Static' => 'static'),
			build_csi_element ('::Reference' => (
				build_csi_token ('::Identifier' => 'foo'),
				build_csi_token ('::Token::Dot' => '.'),
				build_csi_token ('::Identifier' => 'bar'),
			)),
			build_csi_token ('::Token::Semicolon' => ';'),
		)),
		;

	is "expect_import_declaration / type import" =>
		expect => expect_import_declaration (
			[qw[ foo bar ]],
			'*',
		),
		got    => build_csi_element ('::Import::Declaration' => (
			build_csi_token ('::Token::Word::Import' => 'import'),
			build_csi_element ('::Reference' => (
				build_csi_token ('::Identifier' => 'foo'),
				build_csi_token ('::Token::Dot' => '.'),
				build_csi_token ('::Identifier' => 'bar'),
			)),
			build_csi_token ('::Token::Dot' => '.'),
			build_csi_token ('::Token::Import::Type' => '*'),
			build_csi_token ('::Token::Semicolon' => ';'),
		)),
		;

	is "expect_import_declaration / static type import" =>
		expect => expect_import_declaration (
			'static',
			[qw[ foo bar ]],
			'*',
		),
		got    => build_csi_element ('::Import::Declaration' => (
			build_csi_token ('::Token::Word::Import' => 'import'),
			build_csi_token ('::Token::Word::Static' => 'static'),
			build_csi_element ('::Reference' => (
				build_csi_token ('::Identifier' => 'foo'),
				build_csi_token ('::Token::Dot' => '.'),
				build_csi_token ('::Identifier' => 'bar'),
			)),
			build_csi_token ('::Token::Dot' => '.'),
			build_csi_token ('::Token::Import::Type' => '*'),
			build_csi_token ('::Token::Semicolon' => ';'),
		)),
		;

	done_testing;
};

subtest "expect_package_declaration"    => sub {
	plan tests => 2;

	is "expect_package_declaration / with just package name" =>
		expect => expect_package_declaration (
			[qw[ foo bar ]],
		),
		got    => build_csi_element ('::Package::Declaration' => (
			build_csi_token ('::Token::Word::Package' => 'package'),
			build_csi_element ('::Package::Name' => (
				build_csi_token ('::Identifier' => 'foo'),
				build_csi_token ('::Token::Dot' => '.'),
				build_csi_token ('::Identifier' => 'bar'),
			)),
			build_csi_token ('::Token::Semicolon' => ';'),
		)),
		;

	is "expect_package_declaration / with annotations" =>
		expect => expect_package_declaration (
			[qw[ foo bar ]],
			expect_modifiers (
				expect_annotation ([qw[ foo ]]),
			),
		),
		got    => build_csi_element ('::Package::Declaration' => (
			build_csi_element ('::Modifier' => (
				build_csi_element ('::Annotation' => (
					build_csi_token ('::Token::Annotation' => '@'),
					build_csi_element ('::Reference' => (
						build_csi_token ('::Identifier' => 'foo'),
					)),
				)),
			)),
			build_csi_token ('::Token::Word::Package' => 'package'),
			build_csi_element ('::Package::Name' => (
				build_csi_token ('::Identifier' => 'foo'),
				build_csi_token ('::Token::Dot' => '.'),
				build_csi_token ('::Identifier' => 'bar'),
			)),
			build_csi_token ('::Token::Semicolon' => ';'),
		)),
		;

	done_testing;
};

had_no_warnings;

done_testing;
