
use v5.14;
use Syntax::Construct v1.8 qw[ package-version package-block ];

use strict;
use warnings;

package Grammar::Parser::Grammar v1.0.0 {
	use Moo;

	use Clone 	   qw[ ];
	use Ref::Util  qw[ is_arrayref ];
	use Ref::Util  qw[ is_refref ];
	use Ref::Util  qw[ is_regexpref ];
	use Ref::Util  qw[ is_scalarref ];

	use namespace::clean;

	sub BUILD {
		my ($self) = @_;

		eval "require ${\ $self->lexer_class };";
	}

	has grammar     => (
		is          => 'ro',
		required    => 1,
	);

	has start       => (
		is          => 'lazy',
		default     => sub { 'TOP' },
	);

	has insignificant => (
		is          => 'ro',
		default     => sub { +[qw[ whitespace comment ]] },
	);

	has empty       => (
		is          => 'ro',
		default     => sub { +[] },
	);

	has lexer_class => (
		is          => 'ro',
		default     => sub { 'Grammar::Parser::Lexer::Match::Unique' },
	);

	has _list_patterns => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_list_patterns',
	);

	has _list_terminals => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_list_terminals',
	);

	has _list_nonterminals => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_list_nonterminals',
	);

	sub _empty_rule {
		[[]]
	}

	sub reference_regex {
		qr/(
			\( \? \? \{
			\s*
            \\? \s*
			(?<delimiter> [\'\"] )
			(?<reference> (\w+)  )
			\g{delimiter}
			\s*
			\} \)
		)/x;
	  }

	sub _list_regex_references {
		my ($self, $regex) = @_;

		my $reference_regex = $self->reference_regex;

		my %deps;
		$deps{$+{reference}} = 1
			while $regex =~ m/$reference_regex/gc;

		return sort keys %deps;
	}

	sub _expand_references {
		my ($self, @def) = @_;

		my @references;
		while (@def) {
			my $head = shift @def;

			push @references, $head and next
				unless ref $head;

			push @references, $$head and next
				if is_scalarref $head;

			push @def, @$head and next
				if is_arrayref $head;

			push @def, $$head and next
				if is_refref $head;

			push @def, $self->_list_regex_references ($head) and next
				if is_regexpref $head;
		}

		return @references;
	}

	sub _build_list_nonterminals {
		my ($self) = @_;
		my $grammar = $self->grammar;

		return [
			grep is_arrayref $grammar->{$_}[0],
			grep is_arrayref $grammar->{$_},
			keys %{ $grammar }
		];
	}

	sub _build_list_terminals {
		my ($self) = @_;
		my $grammar = $self->grammar;

		return [
			grep ! is_arrayref $grammar->{$_}[0],
			grep is_arrayref $grammar->{$_},
			keys %{ $grammar }
		];
	}

	sub _build_list_patterns {
		my ($self) = @_;
		my $grammar = $self->grammar;

		return [
			grep is_refref $grammar->{$_},
			keys %{ $grammar }
		];
	}

	sub clone {
		my ($self, %params) = @_;

		$params{grammar}       //= $self->grammar;
		$params{empty}         //= $self->empty;
		$params{start}         //= $self->start;
		$params{insignificant} //= $self->insignificant;
		$params{lexer_class}   //= $self->lexer_class;

		$self->new (%params);
	}

	sub effective {
		my ($self) = @_;

		my $grammar = Clone::clone $self->grammar;
		$grammar->{$_} = $self->_empty_rule for @{ $self->empty };

		my $result = {};
		my @effective_rules = ($self->start, @{ $self->insignificant });

		while (my $rule = shift @effective_rules) {
			next # rule already processed
				if exists $result->{$rule};

			next # rule doesn't exist, ignored
				unless exists $grammar->{$rule};

			$result->{$rule} = $grammar->{$rule};

			push @effective_rules, $self->_expand_references ($result->{$rule});
		}

		return $self->clone (
			grammar => $result,
		);
	}

	sub rule {
		my ($self, $name) = @_;

		return $self->grammar->{$name};
	}

	sub list_patterns {
		my ($self) = @_;

		return @{ $self->_list_patterns };
	}

	sub list_terminals {
		my ($self) = @_;

		return @{ $self->_list_terminals };
	}

	sub list_nonterminals {
		my ($self) = @_;

		return @{ $self->_list_nonterminals };
	}

	sub lexer {
		my ($self) = @_;

		my $rules = Clone::clone $self->grammar;
		$rules->{$_} = $self->_empty_rule for @{ $self->empty };

		delete $rules->{$_}
			for grep is_arrayref ($rules->{$_}) && is_arrayref ($rules->{$_}[0]),
			keys %$rules;

		return $self->lexer_class->new (
			rules => $rules,
			insignificant => $self->insignificant,
		);
	}

	1;

}

__END__

=encoding utf8

=head1 NAME

Grammar::Parser::Grammar

=head1 SYNOPSIS

	my $grammar = Grammar::Parser::Grammar->new (
		grammar => $grammar,
		start   => 'my_start',
	);

=head1 DESCRIPTION

=head1 METHODS

=head2 new

Creates new instance, accepts named parameters:

=over

=item grammar

Grammar definition, see L<< /"GRAMMAR DEFINITION" >> section below.

=item empty

	# Default
	empty => [],

List of grammar rule names that should be evaluated as an empty rule.

=item start

	# Default
	start => 'start',

Starting (top level) rule name.

=item insignificant

	# Default
	insignificant => [qw[ whitespace comment ]],

List of terminal symbols treated as insignificant.
Lexer will skip insignificant symbols unless exactly requested.

Using BNF-like description, grammar rule

	rule := foo bar

Will behave like

	rule := insignificant* foo insignificant* bar insignificant*

=item lexer_class

	# Default
	lexer_class => 'Grammar::Parser::Lexer::Match::Unique',

Lexer implementation class.

=back

=head2 clone

Creates clone of current grammar. Accepts same parameters as C<new> and uses
current instance as source of default values.

=head2 effective

Optimized grammar. Currently only unused rules are eliminated.

=head2 lexer

Build new C<lexer_class> instance.

=head2 list_terminals

Returns names of terminals

=head2 list_nonterminals

Return names of nonterminal rules

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file if part of L<< Grammar::Parser >>.
It can be distributed and/or modified under Artistic license 2.0

=cut
