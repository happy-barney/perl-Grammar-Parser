
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package Grammar::Parser::Lexer::Match::Unique v1.0.0 {
	use Moo;

	extends 'Grammar::Parser::Lexer';

	has _next_token_lookup_regex => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_next_token_lookup_regex',
	);

	has _next_token => (
		init_arg       => undef,
		is             => 'ro',
		default        => sub { +[] },
	);

	sub _build_next_token_lookup_regex {
		my ($self) = @_;

		my $compiled_rules = $self->_compiled_rules;

		my $regex = join "\n\t |",
			map "(?> $compiled_rules->{$_}{regex} (?{ '$_' }) )",
			sort $self->list_tokens,
			;

		my $define = $self->_define_regex_referencies (
			map @{ $compiled_rules->{$_}{refer} },
			$self->list_tokens,
		);

		use re 'eval';

		return qr/\G($regex)$define/ux;
	}

	sub _search_next_token {
		my ($self) = @_;

		unless (scalar @{ $self->_next_token }) {
			my @match = $self->_match_data ($self->_next_token_lookup_regex);

			return unless @match;
			push @{ $self->_next_token }, $self->_build_next_token ($^R => @match);
		}

		return $self->_next_token->[0]->[0];
	}

	sub _lookup_next_token {
		my ($self, $accepted) = @_;

		my $name = $self->_search_next_token;

		return unless $name;
		return unless exists $accepted->{$name};

		return shift @{ $self->_next_token };
	}
};

1;

__END__

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

