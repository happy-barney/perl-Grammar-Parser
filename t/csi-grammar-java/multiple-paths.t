#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 5;

test_rule "block statement / cast in non-unary expression" => (
	rule => 'block_statement',
	data => <<'EODATA',
(long) Integer.MAX_VALUE + 1;
EODATA
	expect => ignore,
);

test_rule "annotation with class literal" => (
	rule => 'annotation',
	data => <<'EODATA',
@Test(expected = InvalidTopicException.class)
EODATA
	expect => ignore,
);

test_rule "expression / binary and expression treated as cast operator" => (
	rule => 'expression',
	data => <<'EODATA',
~(same & diff) + "foo"
EODATA
	expect => ignore,
);

test_rule "expression / binary and expression treated vs cast operator" => (
	rule => 'expression',
	data => <<'EODATA',
(x & y) + ((x ^ y) >> 1)
EODATA
	expect => ignore,
);

had_no_warnings;

done_testing;
