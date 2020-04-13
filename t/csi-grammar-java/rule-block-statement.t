#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'block_statement';

plan tests => 2;

test_rule "block statement / variable declaration" => (
	data => <<'EODATA',
float foo;
EODATA
	expect => [
		expect_element ('::Statement::Variable' => (
			expect_element ('::Variable' => (
				expect_type_float,
				expect_element ('::Variable::Declarator' => (
					expect_element ('::Variable::ID' => (
						expect_token ('::Variable::Name' => 'foo'),
					)),
				)),
			)),
			expect_token_semicolon,
		)),
	],
);


had_no_warnings;

done_testing;
