#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'interface_extends';

plan tests => 2;

test_rule "interface extends" => (
	data => 'extends Foo, Bar',
	expect => expect_interface_extends (
		expect_class_type ([qw[ Foo ]]),
		expect_class_type ([qw[ Bar ]]),
	),
	expectation_expanded => expect_element ('::Interface::Extends' => (
		expect_token ('::Token::Word::Extends' => 'extends'),
		expect_class_type ([qw[ Foo ]]),
		expect_token_comma,
		expect_class_type ([qw[ Bar ]]),
	)),
);

had_no_warnings;

done_testing;
