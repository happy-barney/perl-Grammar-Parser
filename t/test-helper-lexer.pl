
use v5.14;
use strict;
use warnings;

BEGIN { require "test-helper-common.pl" }

require Grammar::Parser::Lexer;
require Grammar::Parser::Lexer::Match::Unique;

use Context::Singleton;

contrive 'Grammar::Parser::Lexer' => (
	value => 'Grammar::Parser::Lexer::Match::Unique',
);

contrive 'current-lexer-return-insignificant' => (
	value => 0,
);

contrive 'current-lexer-insignificant' => (
	value => [],
);

contrive 'current-lexer' => (
	class => 'Grammar::Parser::Lexer',
	dep   => {
		rules => 'current-lexer-rules',
		insignificant => 'current-lexer-insignificant',
		return_insignificant => 'current-lexer-return-insignificant',
		data => 'current-lexer-data',
	},
	as => sub {
		my ($class, %args) = @_;

		my $data = delete $args{data};
		my $instance = $class->new (%args);

		$instance->add_data ($data);

		$instance;
	},
);

sub _compare_expected {
	my ($mode, $got, $expect) = @_;
	my ($ok, $reason) = Test::Deep::cmp_details $got, $expect;

	$reason = "$mode:" . Test::Deep::deep_diag ($reason)
		unless $ok;

	($ok, $reason);
}

sub arrange_lexer_class {
	proclaim 'Grammar::Parser::Lexer' => 'Grammar::Parser::Lexer::Match::Unique';
}

sub arrange_lexer_rules {
	my (%lexer) = @_;

	proclaim 'current-lexer-rules' => \%lexer;
}

sub arrange_lexer_insignificant {
	my (@insignificant) = @_;

	proclaim 'current-lexer-insignificant' => \@insignificant;
}

sub arrange_lexer_data {
	my ($data) = @_;

	proclaim 'current-lexer-data' => $data;
}

sub arrange_return_insignificant {
	proclaim 'current-lexer-return-insignificant' => @_;
}

sub expect_token {
	my ($title, %params) = @_;

	# Context::Singleton issue - current lexer is not cached but
	my $lexer = deduce ('current-lexer');
	# diag "lexer: $lexer";

	test_frame {
		my $accept = $params{with_accept};
		$accept //= { $params{expect_token} => 1 }
			if defined $params{expect_token};

		my $token;
		act { $token = deduce ('current-lexer')->next_token ($accept) };

		return act_throws $title, throws => $params{throws}
			if exists $params{throws};

		act_should_live $title or return;

		# last token ...
		unless (defined $params{expect_token}) {
			return cmp_deeply $title,
				got => $token,
				expect => [],
			;
		}

		$params{expect_significant} = bool ($params{expect_significant})
			if defined $params{expect_significant} && ! ref $params{expect_significant};

		my ($ok, $reason) = (1, undef);

		($ok, $reason) = _compare_expected expect_token => $token->[0], $params{expect_token}
			if $ok && defined $params{expect_token};

		($ok, $reason) = _compare_expected expect_value => $token->[1]->value, $params{expect_value}
			if $ok && exists $params{expect_value};

		($ok, $reason) = _compare_expected expect_significant => $token->[1]->significant, $params{expect_significant}
			if $ok && exists $params{expect_significant};

		($ok, $reason) = _compare_expected expect_line => $token->[1]->line, $params{expect_line}
			if $ok && exists $params{expect_line};

		($ok, $reason) = _compare_expected expect_column => $token->[1]->column, $params{expect_column}
			if $ok && exists $params{expect_column};

		($ok, $reason) = _compare_expected expect_captures => $token->[1]->captures, $params{expect_captures}
			if $ok && exists $params{expect_captures};

		ok $title, got => $ok;
		diag $reason unless $ok;

		return $ok
	};
}

sub expect_next_token {
	my ($token, %params) = @_;

	my $value = delete $params{value};
	my $line = delete $params{line};
	my $significant = delete $params{significant};
	my $column = delete $params{column};
	my $throws = delete $params{throws};
	my $accept = delete $params{accept};

	my $title;
	$title //= "expecting $token should throw an exception" if $throws;
	$title //= "expecting $token «$value»" if defined $value;
	$title //= "expecting $token";

	expect_token $title,
		expect_token => $token,
		expect_value => $value,
		(expect_significant => $significant) x!! defined $significant,
		(expect_line => $line) x!! defined $line,
		(expect_column => $column) x!! defined $column,
		(expect_captures => { %params, value => $value }) x!! %params,
		(throws => $throws) x!! defined $throws,
		(with_accepted => $accept) x!! defined $accept,
		 ;
}

sub expect_last_token {
	expect_token "expect last token",
		expect_token => undef
}

1;
