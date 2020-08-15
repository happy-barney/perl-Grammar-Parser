
use v5.14;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";

BEGIN { require "test-helper-csi.pl" }

use CSI::Language::Java::Grammar;
require Ref::Util;

proclaim 'csi-language' => 'CSI::Language::Java::Grammar';

sub expect_token {
	my ($token, $value) = @_;

	+{ $token => defined $value ? methods (value => $value) : ignore };
}

sub expect_element {
	my ($name, @expect_content) = @_;

	+{ $name => @expect_content ? \@expect_content : Test::Deep::ignore };
}

sub _list_with_separator {
	my $separator = [];
	my $transform = sub { @_ };

	$separator = shift if Ref::Util::is_plain_arrayref $_[0];
	$transform = shift if Ref::Util::is_plain_coderef  $_[0];

	my @content = map $transform->($_), @_;

	return @content if @content < 2;

	my $head = shift @content;

	return ($head, map { @$separator, $_ } @content);
}

sub expect_dom_token {
	my ($token, $value) = @_;
	$token = build_csi_class ($token);

	my $expectation = obj_isa ($token);

	if (defined $value) {
		$expectation &= methods (children => [
			all (
				obj_isa ('Grammar::Parser::Lexer::Token'),
				methods (value => $value ),
			)
		]);
	}

	$expectation;
}

1;

