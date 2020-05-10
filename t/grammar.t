#!/usr/bin/env perl

use v5.14;

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-common.pl" }

use Grammar::Parser::Grammar;

sub build_grammar;

plan tests => 5;

subtest 'full grammar' => sub {
    my $grammar = build_grammar;
	my $effective = $grammar->effective;

    it 'should start with «equation» rule',
        got    => $effective->start,
        expect => 'equation',
    ;

    it 'should list all terminals',
        got    => [ $grammar->list_terminals ],
        expect => bag (qw[ equals number operator paren_l paren_r ]),
    ;

    it 'should provide list all rules',
        got    => [ $grammar->list_nonterminals ],
        expect => bag (qw[ equation expression ]),
    ;

	done_testing;
};

subtest 'effective full grammar' => sub {
    my $grammar = build_grammar
		->effective
		;

    it 'should start with «equation» rule',
        got    => $grammar->start,
        expect => 'equation',
    ;

    it 'should list all terminals',
        got    => [ $grammar->list_terminals ],
        expect => bag (qw[ equals number operator paren_l paren_r ]),
    ;

    it 'should provide list all rules',
        got    => [ $grammar->list_nonterminals ],
        expect => bag (qw[ equation expression ]),
    ;

	done_testing;
};

subtest 'sub-grammar' => sub {
    my $grammar = build_grammar
		->clone (start => 'expression')
		;

    it 'should start with «expression» rule',
        got    => $grammar->start,
        expect => 'expression',
    ;

    it 'should list all terminals',
        got    => [ $grammar->list_terminals ],
        expect => bag (qw[ equals number operator paren_l paren_r ]),
    ;

    it 'should provide list all rules',
        got    => [ $grammar->list_nonterminals ],
        expect => bag (qw[ equation expression ]),
    ;

	done_testing;
};

subtest 'effective sub-grammar' => sub {
    my $grammar = build_grammar
		->clone (start => 'expression')
		->effective
		;

    it 'should start with «expression» rule',
        got    => $grammar->start,
        expect => 'expression',
    ;

    it 'should list all terminals',
        got    => [ $grammar->list_terminals ],
        expect => bag (qw[ number operator paren_l paren_r ]),
    ;

    it 'should provide list all rules',
        got    => [ $grammar->list_nonterminals ],
        expect => bag (qw[ expression ]),
    ;

	done_testing;
};

had_no_warnings 'no unexpected warnings in Grammar::Parser::Grammar';

done_testing;

sub build_grammar {
	my (%params) = @_;

	$params{start} //= 'equation';
	$params{empty} //= [];
	$params{grammar} //= {
		equation => [
			[qw[ expression equals expression ]],
		],
		expression => [
			[qw[ number ]],
			[qw[ paren_l expression paren_r ]],
			[qw[ expression operator expression ]],
		],
		number => [ qw/\d+/ ],
		operator => [ '+', '-', '*', '/' ],
		paren_l => [ '(' ],
		paren_r => [ ')' ],
		equals => [ '=' ],
	};

	Grammar::Parser::Grammar->new (%params);
}

