#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-common.pl" }

use Grammar::Parser;
use Grammar::Parser::Grammar;

our $DUMP_IT_GOT = 1;
our $DUMP_IT_EXPECTED = 1;

trigger 'csi-language' => sub {
	eval "require $_[0]" or die;
};

contrive 'csi-parser-start' => (
	deduce  => 'csi-language',
	builder => 'start_rule',
);

contrive 'csi-parser-grammar' => (
	deduce  => 'csi-language',
	builder => 'grammar',
);

contrive 'csi-parser-action-map' => (
	deduce  => 'csi-language',
	builder => 'actions',
);

contrive 'csi-parser-insignificant' => (
	deduce  => 'csi-language',
	builder => 'insignificant_rules',
);

contrive 'csi-parser-action-lookup' => (
	deduce  => 'csi-language',
	builder => 'action_lookup',
);

contrive 'csi-parser' => (
	class => 'Grammar::Parser',
	dep => {
		grammar       => 'csi-parser-grammar',
		action_lookup => 'csi-parser-action-lookup',
		action_map    => 'csi-parser-action-map',
		start         => 'csi-parser-start',
		insignificant => 'csi-parser-insignificant',
	},
);

contrive 'csi-grammar' => (
	class => 'Grammar::Parser::Grammar',
	dep => {
		grammar       => 'csi-parser-grammar',
		start         => 'csi-parser-start',
		insignificant => 'csi-parser-insignificant',
	},
);

contrive 'csi-grammar-lexer' => (
	deduce => 'csi-grammar',
	builder => 'lexer',
);


sub arrange_start_rule {
	my ($rule) = @_;

	proclaim 'csi-parser-start' => $rule;
}

sub is_arranged_start_rule {
	my ($rule) = @_;

	try_deduce 'csi-parser-start';
	is_deduced 'csi-parser-start';
}

sub test_rule {
	my ($title, %params) = @_;

	test_frame {
		act { deduce ('csi-parser')->parse (@_); };

		arrange_start_rule $params{rule}
			if defined $params{rule};

		arrange_start_rule $title
			unless is_arranged_start_rule;

		$title = $params{title}
			if exists $params{title};

		act_arguments $params{data};

		if (exists $params{throws}) {
			# TODO: better mechanism than local $...property
			use Grammar::Parser::Driver::Marpa::R2;
			local $Grammar::Parser::Driver::Marpa::R2::Instance::SHOW_PROGRESS_ON_ERROR = 0;

			act_throws $title =>
				throws => ignore,
				;

			return;
		}

		it $title => (
			expect => $params{expect},
		) or do {
			if ($DUMP_IT_GOT) {
				diag ("== Got");
				diag (do { my $value = deduce ('act-value'); np $value });
			}
			if ($DUMP_IT_EXPECTED) {
				diag ("== Expected");
				diag (np $params{expect});
			}
		};
	};
}

sub test_token {
	my ($title, %params) = @_;

	my $data     = delete $params{data} // $title;
	my $from_pos = delete $params{from_pos} // 0;

	my $expect_match = delete $params{expect_match} // $data;
	my $expect_token = delete $params{expect_token};

	my $lexer = deduce ('csi-grammar-lexer');
	my $regex = $lexer->_regex_for ($expect_token);

	pos ($data) = $from_pos;

	fail $title,
		unless => defined $regex,
		diag   => sub { "token $expect_token not found" },
		or return
		;

	fail $title,
		unless => scalar ($data =~ m/^$regex/gc),
		diag   => sub { "token $expect_token should match given data ($regex)" },
		or return
		;

	my $substr = substr ($data, 0, pos $data);
	unless ($expect_match eq $substr) {
		fail $title;

		diag "token $expect_token should exactly match given data";
		diag "got: ${\ np $substr}";
		diag "exp: ${\ np $expect_match }";

		return;
	}

	my @matches = grep {
		my $regex = $lexer->_regex_for ($_);
		$data =~ m/^$regex/
	} $lexer->list_tokens;

	fail $title,
		unless => @matches == 1,
		diag   => sub {+(
			"only one rule should match but ${\ scalar @matches } did",
			map " - $_", sort @matches
		)}
		or return
		;

	pass $title;
}

1;

