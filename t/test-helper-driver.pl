
use v5.14;
use strict;
use warnings;

BEGIN { require "test-helper-common.pl" }

sub calc_rpn_grammar {
	my $number_re = qr/
		[-+]?               # sign
		(?! 0\d )           # can be '0' but cannot be '01'
		(?= \.? \d )        # must contain either integer or decimal digit
		\d*                 # integer part (optional)
		(?: \.\d* )?        # decimal part (optional)
	/x;

    +{
        whitespace => [ qr/\s+/ ],
        NUMBER => [ $number_re ],
        ADD    => [ '+' ],
        SUB    => [ '-' ],
        MUL    => [ '*', 'x' ],
        DIV    => [ '/', '÷' ],

        number => [ [ 'NUMBER' ] ],
        add => [ [ 'ADD' ] ],
        sub => [ [ 'SUB' ] ],
        mul => [ [ 'MUL' ] ],
        div => [ [ 'DIV' ] ],

        operator => [
            [ 'add' ],
            [ 'sub' ],
            [ 'mul' ],
            [ 'div' ],
        ],

        expression => [
            [ 'number' ],
            [ 'number', 'expression', 'operator' ],
        ],
    }
}

sub calc_rpn_action {
	'Sample::Calc::RPN::Action';
}

sub calc_rpn_start {
	'expression';
}

sub calc_rpn_insignificant {
	[qw[ whitespace ]];
}

sub calc_rpn_action_name {
	my (@params) = @_;
	#use DDP; say "action name for"; p @params;

	my $return = calc_rpn_action()->can ('action_name')->(@params);
	say " ===> ", $return // '[undef]';

	$return;
}

sub behaves_like_grammar_parser_driver_with_calc_rpn {
	my ($package, %params) = @_;

	plan tests => 1;

	my $driver = $package->new (
		grammar       => calc_rpn_grammar,
		action_lookup => [ calc_rpn_action ],
		action_name   => calc_rpn_action()->can ('action_name'),
		start         => calc_rpn_start,
		insignificant => calc_rpn_insignificant,
	);

	my $result = $driver->parse ('1 3 2 - +');
	my $expected = {
		expression => {
			number => '1',
			operator => 'add',
			expression => {
				number => '3',
				operator => 'sub',
				expression => { number => '2' },
			},
		},
	};

	cmp_deeply "$package should parse RPN",
		got    => $result,
		expect => $expected,
		;
}

sub behaves_like_grammar_parser_driver {
	local $Grammar::Parser::Driver::DIE_ON_MISSING_ACTION = 0;

	&behaves_like_grammar_parser_driver_with_calc_rpn;
}

package Sample::Calc::RPN::Action;

use Grammar::Parser::Action::Util (
	'action_name' => { as => 'action_name' },
	number     => { is => 'literal_value' },
	add        => { is => 'symbol' },
	sub        => { is => 'symbol' },
	mul        => { is => 'symbol' },
	div        => { is => 'symbol' },
	operator   => { is => 'alias' },
	expression => { is => 'default' },
	ADD        => { is => 'literal' },
	SUB        => { is => 'literal' },
	MUL        => { is => 'literal' },
	DIV        => { is => 'literal' },
);

1;


