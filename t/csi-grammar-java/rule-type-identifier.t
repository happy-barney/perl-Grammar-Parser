#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'type_identifier';

plan tests => 6;

note 'https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-TypeIdentifier';
note 'https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-SimpleTypeName';
note 'https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannTypeVariable';

test_rule 'type identifier should accept common identifier' => (
	data => 'foo',
	expect => expect_identifier ('foo'),
);

test_rule 'type identifier should accept common identifier with currency symbol' => (
	data => 'foo$bar',
	expect => expect_identifier ('foo$bar'),
);

test_rule 'type identifier should accept non-reserved keyword' => (
	data => 'module',
	expect => expect_identifier ('module'),
);

test_rule 'type identifier should not accept word <var>' => (
	data => 'var',
	throws => 1,
);

test_rule 'type identifier should accept var with currency symbol' => (
	data => 'var$',
	expect => expect_identifier ('var$'),
);

had_no_warnings;

done_testing;
