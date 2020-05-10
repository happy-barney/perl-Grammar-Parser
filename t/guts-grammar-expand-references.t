#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-common.pl" }

use Grammar::Parser::Grammar;
use List::Util v1.45 qw[ uniqstr ];

act { [ uniqstr sort Grammar::Parser::Grammar->_expand_references (@_) ] };

it 'should recognize nonterminal referencies' => (
	act_with => [
		+[
			[qw[ foo bar ]],
			[qw[ bar baz ]],
		],
	],
	expect => [qw[ bar baz foo ]],
);

it 'should recognize token regex referencies' => (
	act_with => [
		+[
			qr/(??{ 'foo' })(??{ 'bar' })/,
			qr/(??{ 'bar' })(??{ 'baz' })/,
		],
	],
	expect => [qw[ bar baz foo ]],
);

it 'should recognize pattern regex referencies' => (
	act_with => [
		\ [
			qr/(??{ 'foo' })(??{ 'bar' })/,
			qr/(??{ 'bar' })(??{ 'baz' })/,
		],
	],
	expect => [qw[ bar baz foo ]],
);

it 'should recognize pattern symbolic referencies' => (
	act_with => [
		\ [
			\ 'foo',
			\ 'bar',
			\ 'baz',
		],
	],
	expect => [qw[ bar baz foo ]],
);

had_no_warnings;

done_testing;
