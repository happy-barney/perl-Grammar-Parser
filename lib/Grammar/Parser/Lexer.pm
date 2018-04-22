
use v5.14;
use Syntax::Construct v1.8 qw[ package-version package-block ];

use strict;
use warnings;

package Grammar::Parser::Lexer v1.0.0 {
	use Moo;

	use Ref::Util qw[ is_arrayref ];
	use Ref::Util qw[ is_hashref ];
	use Ref::Util qw[ is_refref ];
	use Ref::Util qw[ is_regexpref ];
	use Ref::Util qw[ is_scalarref ];

	use Grammar::Parser::Grammar;

	use Grammar::Parser::X::Lexer::Notfound;
	use Grammar::Parser::Lexer::Token;

	sub _is_token_definition {
		my ($definition) = @_;

		return ! is_refref ($definition);
	}

	my $reference_prefix = 'd_';

	use namespace::clean;

	has rules           => (
		is              => 'ro',
		required        => 1,
	);

	has insignificant   => (
		is              => 'ro',
		lazy            => 1,
		default         => sub { +[] },
	);

	has final_token     => (
		is              => 'ro',
		lazy            => 1,
		default         => sub { },
	);

	has token_class     => (
		is              => 'ro',
		lazy            => 1,
		default         => sub { 'Grammar::Parser::Lexer::Token' },
	);

	has return_insignificant => (
		is              => 'ro',
		lazy            => 1,
		default         => sub { 0 },
	);

	has _tokens         => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_tokens',
	);

	has _patterns       => (
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_patterns',
	);

	has _significant_map => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_significant_map',
	);

	has _insignificant_map => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_insignificant_map',
	);

	has _data           => (
		init_arg        => undef,
		is              => 'rw',
		lazy            => 1,
		default         => sub { \ (my $o = '') },
	);

	has _data_pos       => (
		init_arg        => undef,
		is              => 'rw',
		lazy            => 1,
		default         => sub { 0 },
	);

	has _line           => (
		init_arg        => undef,
		is              => 'rw',
		lazy            => 1,
		default         => sub { 1 },
	);

	has _column         => (
		init_arg        => undef,
		is              => 'rw',
		lazy            => 1,
		default         => sub { 1 },
	);

	has _compiled_rules => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_compiled_rules',
	);

	has _regex_for_map  => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		default         => sub { +{} },
	);

	sub _build_tokens {
		my ($self) = @_;

		my $rules = $self->rules;

		return [
			grep _is_token_definition ($rules->{$_}),
			keys %$rules,
		];
	}

	sub _build_patterns {
		my ($self) = @_;

		my $rules = $self->rules;

		return [
			grep ! _is_token_definition ($rules->{$_}),
			keys %$rules,
		];
	}

	sub _build_significant_map {
		my ($self) = @_;

		my $insignificant_map = $self->_insignificant_map;

		return +{
			map +($_ => 1),
			grep ! exists $insignificant_map->{$_},
			$self->list_tokens,
		};
	}

	sub _build_insignificant_map {
		my ($self) = @_;

		my $rules = $self->rules;

		return +{
			map +($_ => 1),
			grep exists $rules->{$_},
			@{ $self->insignificant }
		};
	}

	sub _build_compiled_rules {
		my ($self) = @_;

		my $rules = $self->rules;
		my $compiled = {};

		for my $rule (keys %$rules) {
			my $regex = $self->_compile_regex ($rule => $rules->{$rule});
			my @refer = $self->_list_regex_referencies ($regex);

			$compiled->{$rule} = {
				regex => $self->_expand_regex_referencies ($regex),
				refer => \ @refer,
			};
		}

		return $compiled;
	}

	sub _compile_regex {
		my ($self, $rule, @definition) = @_;

		my @parts;
		while (defined (my $item = shift @definition)) {
			if (is_refref ($item)) {        # regex or proto
				unshift @definition, $$item;
				next;
			}

			if (is_arrayref ($item)) {      # alternatives
				unshift @definition, @$item;
				next;
			}

			if (is_regexpref ($item)) {     # plain regular expression
				push @parts, "$item";
				next;
			}

			if (is_scalarref ($item)) {     # reference to other regex or token
				push @parts, "(??{ '$$item' })";
				next;
			}

			unless (ref $item) {            # literal string
				push @parts, quotemeta $item;
				next;
			}

			die "Invalid regex definition $rule => ${\ ref $item }";
		}

		return $parts[0] if @parts < 2;

		return "(?:(?:${\ join ')|(?:', @parts }))";
	}

	sub _regex_for {
		my ($self, $rule) = @_;

		my $compiled_rules = $self->_compiled_rules;
		return unless exists $compiled_rules->{$rule};

		return $self->_regex_for_map->{$rule} //= do {
			my $regex = "(?> $compiled_rules->{$rule}{regex} (?{ '$rule' }) )";

			my $define = $self->_define_regex_referencies (
				@{ $compiled_rules->{$rule}{refer} },
			);

			use re 'eval';
			qr/($regex)$define/ux;
		};
	}

	sub _list_regex_referencies {
		my ($self, $regex) = @_;
		my $reference_regex = Grammar::Parser::Grammar->reference_regex;

		my %deps;
		while ($regex =~ m/$reference_regex/gc) {
			$deps{$+{reference}} = 1;
		}

		return sort keys %deps;
	}

	sub _expand_regex_referencies {
		my ($self, $regex) = @_;
		my $reference_regex = Grammar::Parser::Grammar->reference_regex;

		return $regex =~ s/$reference_regex/(?&$reference_prefix$+{reference})/gr;
	}

	sub _define_regex_referencies {
		my ($self, @referencies) = @_;
		return "" unless @referencies;

		my $compiled_rules = $self->_compiled_rules;

		my %define;
		while (my $reference = shift @referencies) {
			next if exists $define{$reference};

			my $rule = $compiled_rules->{$reference};

			$define{$reference} = $rule->{regex};
			push @referencies, @{ $rule->{refer} };
		}

		return join "\n",
			'(?(DEFINE)',
			(map "\t(?<$reference_prefix$_>$define{$_})", sort keys %define),
			')',
			;
	}

	sub _build_next_token_value {
		my ($self, $name, $match, $captures) = @_;

		return $self->token_class->new (
			name		=> $name,
			match		=> $match,
			line		=> $self->_line,
			column      => $self->_column,
			significant => ! exists $self->_insignificant_map->{$name},
			captures	=> $captures,
		);
	}

	sub _build_next_token {
		my ($self, $name, $match, $captures) = @_;

		return +[ $name => $self->_build_next_token_value ($name, $match, $captures) ];
	}

	sub _match_data {
		my ($self, $regex) = @_;

		my $pos = pos ${ $self->_data };

		my @match = ${ $self->_data } =~ m/\G$regex/gc
			? ($1, { %+ })
			: ();
	}

	sub _adjust_data {
		my ($self, $token) = @_;

		my $match_length = length $token->[1]->match;

		# Symbol found, so get rid of match
		my $full = substr ${ $self->_data }, $self->_data_pos, $match_length;
		my (@parts) = split m/\n/, $full, -1;

		$self->_data_pos ($self->_data_pos + $match_length);
		$self->_line ($self->_line + @parts - 1);
		$self->_column (
			(@parts > 1 ? 1 : $self->_column) + length $parts[-1]
		);

		();
	}

	sub _report_error {
		my ($self, @accepted) = @_;

		my $data = substr ${ $self->_data }, $self->_data_pos;

		substr ($data, 97) = '...' if length $data > 100;

		Grammar::Parser::X::Lexer::Notfound->throw (
			line        => $self->_line,
			column      => $self->_column,
			near_data   => $data,
			expected    => [ sort @accepted ],
		)
	}

	sub _build_accepted_next_token {
		my ($self, @accepted) = @_;

		return $self->_significant_map
			unless @accepted && defined $accepted[0];

		return $accepted[0]
			if is_hashref ($accepted[0]);

		@accepted = @{ $accepted[0] }
			if is_arrayref ($accepted[0]);

		return +{ map +($_ => 1), @accepted };
	}

	sub _build_allowed_next_token {
		my ($self, $accepted) = @_;

		return +{
			%$accepted,
			%{ $self->_insignificant_map },
		};
	}

	sub _end_of_data {
		my ($self) = @_;

		return pos (${ $self->_data}) == length (${ $self->_data });
	}

	sub lookup_regex_for {
		my ($self, $rule) = @_;

		my $compiled_rules = $self->_compiled_rules;

		return unless exists $compiled_rules->{$rule};

		my $regex = $compiled_rules->{$rule}{regex};
		my $define = $self->_define_regex_referencies (@{ $compiled_rules->{$rule}{refer} });

		return qr/$regex$define/x;
	}

	sub list_tokens {
		my ($self) = @_;

		return @{ $self->_tokens };
	}

	sub list_patterns {
		my ($self) = @_;

		return @{ $self->_patterns };
	}

	sub add_data {
		my ($self, @pieces) = @_;

		${ $self->_data } .= join '', @pieces;

		pos (${ $self->_data }) = $self->_data_pos;

		();
	}

	sub next_token {
		my ($self, @accepted) = @_;

		my $accepted = $self->_build_accepted_next_token (@accepted);
		my $allowed  = $self->_build_allowed_next_token ($accepted);

		while (1) {
			my $token = $self->_lookup_next_token ($allowed);

			last unless $token;

			$self->_adjust_data ($token);

			next
				unless $token->[1]->significant || $self->return_insignificant;

			return $token;
		}

		return [] if $self->_end_of_data;

		$self->_report_error (keys %$accepted);
	}

	1;
};

__END__

=encoding utf8

=head1 NAME

Grammar::Parser::Lexer - generic lexer

=head1 SYNOPSIS

	# part of SQL grammar
	my $lexer = Grammar::Parser::Lexer (
		tokens => {
			CREATE      => qr/(?> \b CREATE \b)/xi,
			TEMPORARY   => qr/(?> \b TEMP (?: ORARY ) \b)/xi,
			TABLE       => qr/(?> \b TABLE \b)/xi,
			identifier  => qr/(?> (?! (??{ 'keyword' }) (?! \d+ ) \w+/x
		},
		patterns => {
			keyword     => qr/(?> (?&CREATE) | (?&TEMPORARY) | (?&TABLE) )/x,
		},
		insignificant => [qw[ whitespaces comment ]],
	);

	$lexer->add_data ($_) while <>;

	my $token = $lexer->next_token;
	my $token = $lexer->next_token (@allowed);

=head1 DESCRIPTION

Module provides simple input data tokenization.

=head1 METHODS

=head2 new (%arguments)

Create new lexer.

Recognizes named arguments:

=over

=item tokens

Hashref with token name / token pattern pairs.

See L</"PATTERN DEFINITION">

=item patterns

Define named patterns.
Named pattern can be addressed in pattern definition but is not available
as a token (where token name is recognized).

See L</"PATTERN DEFINITION">

=item insignificant

List (arrayref) of tokens that are treated as insignificant.
Insignificant tokens are skipped unless explicitly required.

=item final_token

I<Not implemented yet>

Significant token name, will be treated as end of input data

Once reached, lexer will stop parsing and will add capture C<remaining_data>
(it doesn't affect token's C<match>).

Use case for example: parse HTTP header from HTTP response stream.

=back

=head2 add_data (@data)

Adds more data.

=head2 next_token (@accepted)

Examine current data to find next token.

Unless explicitly specified all significant tokens are considered.

Unless explicitly specified all insignificant tokens are skipped.

Returns C<name> => C<value> pair where name is a token name and value
is an instance of L<< Grammar::Parser::Lexer::Token >> with parse data.

Returns empty list if there is no more data or final token was reached.

If requested token is not found and there are still data left,
throws exception L<< Grammar::Parser::X::Lexer::Notfound >>.

=head1 PATTERN DEFINITION

Pattern definition can be scalar or regex or arrayref of them.

=over

=item SCALAR

Literal string.

For example:

	name => 'string',

	# is same as
	name => qr/\Qstring\E/,

=item REGEX

Perl regex.

Referencing other pattern by name is available via abusing expression C<(??{ 'pattern_name' })>.
Such construct with literal string with value of known pattern name will be replaced
with named regex reference and such reference will be available.

For example

	# Regex
	qr/(?! (??{ 'keyword' }) ) (\w+) \b/x,

	# will become
	qr/(?! (?&keyword) ) (\w+) \b (?(DEFINE) (?<keyword> ....))/x,

=item ARRAYREF

Acts as an another way how to write alternatives.

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file if part of L<Grammar::Parser>.
It can be distributed and modified under Artistic license 2.0

=cut

