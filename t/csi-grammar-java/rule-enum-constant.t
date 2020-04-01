#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'enum_constant';

plan tests => 5;

test_rule "simple enum constant" => (
	data => <<'EODATA',
    ENUM_CONSTANT
EODATA
	expect => expect_element ('::Enum::Constant' => (
		expect_token ('::Enum::Constant::Name' => 'ENUM_CONSTANT'),
	)),
);

test_rule "enum constant with annotations" => (
	data => <<'EODATA',
	@annotated
    ENUM_CONSTANT
EODATA
	expect => expect_element ('::Enum::Constant' => (
		expect_annotation ([qw[ annotated ]]),
		expect_token ('::Enum::Constant::Name' => 'ENUM_CONSTANT'),
	)),
);


test_rule "enum constant with arguments" => (
	data => <<'EODATA',
    ENUM_CONSTANT(0)
EODATA
	expect => expect_element ('::Enum::Constant' => (
		expect_token ('::Enum::Constant::Name' => 'ENUM_CONSTANT'),
		expect_element ('::Arguments' => (
			expect_token_paren_open,
			expect_literal_integral_decimal ('0'),
			expect_token_paren_close,
		)),
	)),
);

test_rule "enum constant with class body" => (
	data => <<'EODATA',
    ENUM_CONSTANT {
        public String value() { }
	}
EODATA
	expect => expect_element ('::Enum::Constant' => (
		expect_token ('::Enum::Constant::Name' => 'ENUM_CONSTANT'),
		expect_element ('::Class::Body' => (
			expect_token_brace_open,
			expect_element ('::Method::Declaration' => (
				expect_modifier_public,
				expect_element ('::Method::Result' => (
					expect_type_string,
				)),
				expect_method_name ('value'),
				expect_element ('::List::Parameters' => (
					expect_token_paren_open,
					expect_token_paren_close,
				)),
				expect_element ('::Method::Body' => (
					expect_element ('::Structure::Block' => (
						expect_token_brace_open,
						expect_token_brace_close,
					)),
				)),
			)),
			expect_token_brace_close,
		)),
	)),
);

had_no_warnings;

done_testing;
