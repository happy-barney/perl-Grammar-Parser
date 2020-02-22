#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'block';

plan tests => 2;

test_rule "generic type variable" => (
	data => <<'EODATA',
{
	List<Logger> childLoggers;
}
EODATA
	expect => expect_element ('::Structure::Block' => (
		expect_token_brace_open,
		expect_element ('::Statement::Variable' => (
			expect_element ('::Variable' => (
				expect_type_class (
					[qw[ List ]],
					type_arguments => [ expect_type_class ([qw[ Logger ]]) ],
				),
				expect_element ('::Variable::Declarator' => (
					expect_element ('::Variable::ID' => (
						expect_variable_name ('childLoggers'),
					)),
				)),
			)),
			expect_token_semicolon,
		)),
		expect_token_brace_close,
	)),
);

had_no_warnings;

done_testing;
