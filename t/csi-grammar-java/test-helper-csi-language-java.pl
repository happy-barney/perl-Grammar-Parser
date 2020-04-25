
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

	$token =~ s/^::/CSI::Language::Java::/;

	+{ $token => $value // ignore };
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

######################################################################

sub expect_token_annotation             { expect_token '::Token::Annotation'            => '@' }
sub expect_token_brace_close            { expect_token '::Token::Brace::Close'          => '}' }
sub expect_token_brace_open             { expect_token '::Token::Brace::Open'           => '{' }
sub expect_token_bracket_close          { expect_token '::Token::Bracket::Close'        => ']' }
sub expect_token_bracket_open           { expect_token '::Token::Bracket::Open'         => '[' }
sub expect_token_comma                  { expect_token '::Token::Comma'                 => ',' }
sub expect_token_dot                    { expect_token '::Token::Dot'                   => '.' }
sub expect_token_double_colon           { expect_token '::Token::Double::Colon'         => '::' }
sub expect_token_elipsis                { expect_token '::Token::Elipsis'               => '...' }
sub expect_token_paren_close            { expect_token '::Token::Paren::Close'          => ')' }
sub expect_token_paren_open             { expect_token '::Token::Paren::Open'           => '(' }
sub expect_token_semicolon              { expect_token '::Token::Semicolon'             => ';' }

1;

