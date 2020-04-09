#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'statement_without_substatement';

plan tests => 17;

test_rule "assert statement" => (
	data => <<'EODATA',
assert foo >= bar;
EODATA
	expect => [
		expect_element ('::Statement::Assert' => (
			expect_word_assert,
			expect_element ('::Expression::Relational' => (
				expect_reference ('foo'),
				expect_operator_greater_equal,
				expect_reference ('bar'),
			)),
			expect_token_semicolon,
		)),
	],
);

test_rule "assert statement with detail message" => (
	data => <<'EODATA',
assert foo >= bar : "detail";
EODATA
	expect => [
		expect_element ('::Statement::Assert' => (
			expect_word_assert,
			expect_element ('::Expression::Relational' => (
				expect_reference ('foo'),
				expect_operator_greater_equal,
				expect_reference ('bar'),
			)),
			expect_token_colon,
			expect_literal_string ("detail"),
			expect_token_semicolon,
		)),
	],
);

test_rule "block" => (
	data => <<'EODATA',
{}
EODATA
	expect => [
		expect_element ('::Structure::Block' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
	],
);

test_rule "break statement" => (
	data => <<'EODATA',
break;
EODATA
	expect => [
		expect_element ('::Statement::Break' => (
			expect_word_break,
			expect_token_semicolon,
		)),
	],
);

test_rule "break statement with label" => (
	data => <<'EODATA',
break label;
EODATA
	expect => [
		expect_element ('::Statement::Break' => (
			expect_word_break,
			expect_token ('::Label::Reference' => 'label'),
			expect_token_semicolon,
		)),
	],
);

test_rule "continue statement" => (
	data => <<'EODATA',
continue;
EODATA
	expect => [
		expect_element ('::Statement::Continue' => (
			expect_word_continue,
			expect_token_semicolon,
		)),
	],
);

test_rule "continue statement with label" => (
	data => <<'EODATA',
continue label;
EODATA
	expect => [
		expect_element ('::Statement::Continue' => (
			expect_word_continue,
			expect_token ('::Label::Reference' => 'label'),
			expect_token_semicolon,
		)),
	],
);

test_rule "return statement" => (
	data => <<'EODATA',
return;
EODATA
	expect => [
		expect_element ('::Statement::Return' => (
			expect_word_return,
			expect_token_semicolon,
		)),
	],
);

test_rule "return statement with return value" => (
	data => <<'EODATA',
return null;
EODATA
	expect => [
		expect_element ('::Statement::Return' => (
			expect_word_return,
			expect_literal_null,
			expect_token_semicolon,
		)),
	],
);

test_rule "expression statement - assignment" => (
	data => <<'EODATA',
this.id = id;
EODATA
	expect => [
		expect_element ('::Statement::Expression' => (
			expect_element ('::Expression::Assignment' => (
				expect_element ('::Field::Access' => (
					expect_element ('::Expression::This' => (
						expect_word_this,
					)),
					expect_token_dot,
					expect_element ('::Field::Name' => (
						expect_identifier ('id'),
					)),
				)),
				expect_token ('::Operator::Assign' => '='),
				expect_reference ('id'),
			)),
			expect_token_semicolon,
		)),
	],
);

test_rule "empty statement" => (
	data => <<'EODATA',
;
EODATA
	expect => [
		expect_element ('::Statement::Empty' => (
			expect_token_semicolon,
		)),
	],
);

test_rule "do statement" => (
	data => <<'EODATA',
do { } while (true);
EODATA
	expect => [
		expect_element ('::Statement::Do' => (
			expect_word_do,
			expect_element ('::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
			expect_word_while,
			expect_element ('::Clause::Condition' => (
				expect_token_paren_open,
				expect_literal_true,
				expect_token_paren_close,
			)),
			expect_token_semicolon,
		)),
	],
);

test_rule "switch statement" => (
	data => <<'EODATA',
switch (expr) {
	case 1:
	case 2: foo(); break;
	case Enum.CONSTANT:
	default:
}
EODATA
	expect => [
		expect_element ('::Statement::Switch' => (
			expect_word_switch,
			expect_token_paren_open,
			expect_reference ('expr'),
			expect_token_paren_close,
			expect_token_brace_open,
			expect_element ('::Statement::Switch::Group' => (
				expect_element ('::Statement::Switch::Label' => (
					expect_word_case,
					expect_element ('::Expression::Constant' => (
						expect_literal_integral_decimal ('1'),
					)),
					expect_token_colon,
				)),
				expect_element ('::Statement::Switch::Label' => (
					expect_word_case,
					expect_element ('::Expression::Constant' => (
						expect_literal_integral_decimal ('2'),
					)),
					expect_token_colon,
				)),
				expect_element ('::Statement::Expression' => (
					expect_element ('::Method::Invocation' => (
						expect_method_name ('foo'),
						expect_element ('::Arguments' => (
							expect_token_paren_open,
							expect_token_paren_close,
						)),
					)),
					expect_token_semicolon,
				)),
				expect_element ('::Statement::Break' => (
					expect_word_break,
					expect_token_semicolon,
				)),
			)),
			expect_element ('::Statement::Switch::Label' => (
				expect_word_case,
				expect_element ('::Expression::Constant' => (
					expect_reference (qw[ Enum CONSTANT ]),
				)),
				expect_token_colon,
			)),
			expect_element ('::Statement::Switch::Label' => (
				expect_word_default,
				expect_token_colon,
			)),
			expect_token_brace_close,
		)),
	],
);

test_rule "synchronized statement" => (
	data => <<'EODATA',
synchronized (expr) {
}
EODATA
	expect => [
		expect_element ('::Statement::Synchronized' => (
			expect_word_synchronized,
			expect_token_paren_open,
			expect_reference ('expr'),
			expect_token_paren_close,
			expect_element ('::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

test_rule "throw statement" => (
	data => <<'EODATA',
throw new Exception ();
EODATA
	expect => [
		expect_element ('::Statement::Throw' => (
			expect_word_throw,
			expect_element ('::Instance::Creation' => (
				expect_word_new,
				expect_reference (qw[ Exception ]),
				expect_element ('::Arguments' => (
					expect_token_paren_open,
					expect_token_paren_close,
				)),
			)),
			expect_token_semicolon,
		)),
	],
);

test_rule "try statement" => (
	data => <<'EODATA',
try { } finally { }
EODATA
	expect => [
		expect_element ('::Statement::Try' => (
			expect_word_try,
			expect_element ('::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
			expect_element ('::Structure::Try::Finally' => (
				expect_word_finally,
				expect_element ('::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
