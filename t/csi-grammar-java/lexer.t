#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

test_token 'insignificant / whitespaces' => (
	data => " \t\n\t ",
	expect_token => 'whitespaces',
);

test_token 'insignificant / C++ comment' => (
	data => "// ... ",
	expect_token => 'comment_cpp',
);

test_token 'insignificant / C comment' => (
	data => "/* /*\n */",
	expect_token => 'comment_c',
);

test_token 'insignificant / Javadoc comment' => (
	data => "/** /*\n */",
	expect_token => 'comment_javadoc',
);

had_no_warnings;

done_testing;

