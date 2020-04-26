
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
sub expect_token_colon                  { expect_token '::Token::Colon'                 => ':' }
sub expect_token_comma                  { expect_token '::Token::Comma'                 => ',' }
sub expect_token_dot                    { expect_token '::Token::Dot'                   => '.' }
sub expect_token_double_colon           { expect_token '::Token::Double::Colon'         => '::' }
sub expect_token_elipsis                { expect_token '::Token::Elipsis'               => '...' }
sub expect_token_paren_close            { expect_token '::Token::Paren::Close'          => ')' }
sub expect_token_paren_open             { expect_token '::Token::Paren::Open'           => '(' }
sub expect_token_question_mark          { expect_token '::Token::Question::Mark'        => '?' }
sub expect_token_semicolon              { expect_token '::Token::Semicolon'             => ';' }
sub expect_token_type_list_close        { expect_token '::Token::Type::List::Close'     => '>' }
sub expect_token_type_list_open         { expect_token '::Token::Type::List::Open'      => '<' }
sub expect_operator_addition            { expect_token '::Operator::Addition'               => '+' }
sub expect_operator_assign              { expect_token '::Operator::Assign'                 => '=' }
sub expect_operator_assign_addition     { expect_token '::Operator::Assign::Addition'       => '+=' }
sub expect_operator_assign_binary_and   { expect_token '::Operator::Assign::Binary::And'    => '&=' }
sub expect_operator_assign_binary_or    { expect_token '::Operator::Assign::Binary::Or'     => '|=' }
sub expect_operator_assign_binary_shift_left { expect_token '::Operator::Assign::Binary::Shift::Left' => '<<=' }
sub expect_operator_assign_binary_shift_right { expect_token '::Operator::Assign::Binary::Shift::Right' => '>>=' }
sub expect_operator_assign_binary_ushift_right { expect_token '::Operator::Assign::Binary::UShift::Right' => '>>>=' }
sub expect_operator_assign_binary_xor   { expect_token '::Operator::Assign::Binary::Xor'    => '^=' }
sub expect_operator_assign_division     { expect_token '::Operator::Assign::Division'       => '/=' }
sub expect_operator_assign_modulus      { expect_token '::Operator::Assign::Modulus'       => '%=' }
sub expect_operator_assign_multiplication { expect_token '::Operator::Assign::Multiplication' => '*=' }
sub expect_operator_assign_subtraction  { expect_token '::Operator::Assign::Subtraction'    => '-=' }
sub expect_operator_binary_and          { expect_token '::Operator::Binary::And'            => '&' }
sub expect_operator_binary_complement   { expect_token '::Operator::Binary::Complement'     => '~' }
sub expect_operator_binary_or           { expect_token '::Operator::Binary::Or'             => '|' }
sub expect_operator_binary_shift_left   { expect_token '::Operator::Binary::Shift::Left'    => '<<' }
sub expect_operator_binary_shift_right  { expect_token '::Operator::Binary::Shift::Right'   => '>>' }
sub expect_operator_binary_ushift_right { expect_token '::Operator::Binary::UShift::Right'  => '>>>' }
sub expect_operator_binary_xor          { expect_token '::Operator::Binary::Xor'            => '^' }
sub expect_operator_decrement           { expect_token '::Operator::Decrement'              => '--' }
sub expect_operator_division            { expect_token '::Operator::Division'               => '/' }
sub expect_operator_equality            { expect_token '::Operator::Equality'               => '==' }
sub expect_operator_greater_equal       { expect_token '::Operator::Greater::Equal'         => '>=' }
sub expect_operator_greater_than        { expect_token '::Operator::Greater'                => '>' }
sub expect_operator_increment           { expect_token '::Operator::Increment'              => '++' }
sub expect_operator_inequality          { expect_token '::Operator::Inequality'             => '!=' }
sub expect_operator_lambda              { expect_token '::Operator::Lambda'                 => '->' }
sub expect_operator_less_equal          { expect_token '::Operator::Less::Equal'            => '<=' }
sub expect_operator_less_than           { expect_token '::Operator::Less'                   => '<' }
sub expect_operator_logical_and         { expect_token '::Operator::Logical::And'           => '&&' }
sub expect_operator_logical_complement  { expect_token '::Operator::Logical::Complement'    => '!' }
sub expect_operator_logical_or          { expect_token '::Operator::Logical::Or'            => '||' }
sub expect_operator_modulus             { expect_token '::Operator::Modulus'                => '%' }
sub expect_operator_multiplication      { expect_token '::Operator::Multiplication'         => '*' }
sub expect_operator_subtraction         { expect_token '::Operator::Subtraction'            => '-' }
sub expect_operator_unary_minus         { expect_token '::Operator::Unary::Minus'           => '-' }
sub expect_operator_unary_plus          { expect_token '::Operator::Unary::Plus'            => '+' }

1;

