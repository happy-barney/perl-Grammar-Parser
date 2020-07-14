#!/usr/bin/env perl

use feature 'say';
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

BEGIN { require "test-helper-csi-language-java.pl" }

use Path::Tiny;

my $parser = deduce ('csi-parser');
my $result = $parser->parse (Path::Tiny->new ($FindBin::Bin, "data", "IPFinder.java")->slurp_utf8);

use CSI::CQL (
	'search',
	'line',
);

there "should be 1 try block" =>
	expect => 1,
	got    => scalar search (
		$result,
		'CSI::Language::Java::Statement::Try',
	),
	;

there "should be 16 method invocations" =>
	expect => 16,
	got    => scalar search (
		$result,
		'CSI::Language::Java::Method::Invocation',
	),
	;

my @nodes = cql_search (
	$result,
	'CSI::Language::Java::Method::Invocation',
);

say "found ${\ scalar @nodes } nodes";

use DDP;
for my $node (@nodes) {
	say "at line ", line ($node);
}

#p @nodes;

#my @nodes = find (
#	'::Statement::Try',
#	where { count (children ('::Structure::Try::Catch')) > 3 },
#);

