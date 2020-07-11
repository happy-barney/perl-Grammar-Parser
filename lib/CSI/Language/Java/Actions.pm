
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Language::Java::Actions v1.0.0 {
	use Ref::Util qw[ is_plain_arrayref ];
	use Ref::Util qw[ is_blessed_arrayref ];
	use List::Util qw[ first ];
	use Scalar::Util qw[ blessed ];

	require Grammar::Parser::Action::Util;
	require Grammar::Parser::Lexer::Token;

	sub _flatten {
		map { is_plain_arrayref ($_) ? @$_ : $_ } @_;
	}

	sub rule_dom {
		my ($parser, $name, @context) = _flatten @_;

		my $result;

		TOKENS_ONLY:
		{
			for my $element (@context) {
				next if blessed ($element) && $element->isa ('Grammar::Parser::Lexer::Token');
				last TOKENS_ONLY;
			}

			$result = rule_dom_token ($parser, $name, @context);
		}

		$result //= rule_default ($parser, $name, @context);

		my $instance = CSI::Language::Java::Grammar->dom_for ($name)->new (
			children => $result->{$name},
		);

		if (Ref::Util::is_plain_arrayref ($result->{$name})) {
			$_->parent ($instance) for @{ $result->{$name} }
		}

		$instance;
	}

	sub rule_dom_token {
		my ($context, $name, @tokens) = @_;

		my $token = $tokens[0];

		if (@tokens > 1) {
			$token = Grammar::Parser::Lexer::Token->new (
				name => $name,
				match => join ('', map $_->match, @tokens),
				value => join ('', map $_->value, @tokens),
				line => $token->line,
				column => $token->column,
				significant => 1,
			);
		}

		my $previous = $context->stash->{previous_token};
		$context->stash->{previous_token} = $token;

		if ($previous ) {
			$previous->next ($token);
			$token->previous ($previous);
		}

		return +{ $name => $token };
	}

	my %char_escape_map = (
		# eg: https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-EscapeSequence
		'b' => 0x0008,
		't' => 0x0009,
		'n' => 0x000a,
		'f' => 0x000c,
		'r' => 0x000d,
		'"' => 0x0022,
		"'" => 0x0027,
		'\\' => 0x005c,
	);

	sub _unescape {
		my ($value) = @_;

		my $regex = CSI::Language::Java::Grammar->grammar->{Escape_Sequence};
		$regex = $$regex;
		$regex = $regex->[0];

		$value =~ s{$regex}{
			my $result;
			$result //= chr $char_escape_map{$+{char_escape}} if exists $+{char_escape};
			$result //= chr oct $+{octal_escape} if exists $+{octal_escape};
			$result //= chr hex $+{hex_escape} if exists $+{hex_escape};
			$result;
		}ger;
	}

	sub rule_integral_value {
		my ($context, $name, @values) = @_;
		my $token = first { blessed $_ } @values;

		return +{ $name => $token };
	}

	sub rule_float_value {
		my ($context, $name, @values) = @_;
		my $token = first { blessed $_ } @values;

		return +{ $name => $token };
	}

	sub rule_literal_unescape {
		my ($instance, $name, @values) = @_;
		my $token = first { blessed $_ } @values;

		$token->captures->{value} = _unescape ($token->captures->{value})
			if exists $token->captures->{value};

		rule_dom ($instance, $name, $token);
	}

	sub rule_skip {
		[];
	}

	sub rule_token {
		my ($context, $name, $token) = @_;

		+{ $name => $token->value };
	}

	sub rule_default {
		my ($context, $name, @elements) = _flatten @_;

		+{ $name => \@elements };
	}

	sub rule_pass_through {
		my ($context, $name, @elements) = _flatten @_;

		\@elements;
	}

	sub rule_list {
		my ($context, $name, @elements) = _flatten @_;

		my $list = exists $elements[-1]{$name}
			? pop @elements
			: { $name => [] },
			;

		unshift @{ $list->{$name} }, @elements;

		$list;
	}
};

1;

