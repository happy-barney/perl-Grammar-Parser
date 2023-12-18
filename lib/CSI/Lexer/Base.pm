
use v5.14;
use CSI::Common::Sense;

package CSI::Lexer::Base v1.0.0 {
	use Scalar::Util;

	sub _adapt_position {
		my ($self) = @_;

		my $match = $self->{previous_token}{match};

		if (my $lines = (@{[ $match =~ m (\n) ]})) {
			$self->{line} += $lines;
			$self->{column} = 0;
		}

		my ($col) = $match =~ m ([^\n]*$);
		$self->{column} += length ($col) + 7 * @{[ $col =~ m (\t)g ]};

		();
	}

	sub _build_token {
		my ($self, %raw) = @_;

		my $name = $self->_decode_token_name (\ %raw);
		my $match = delete $raw{$name};

		my $token = $self->{previous_token} = +{
			token       => $name,
			match       => $match,
			line        => $self->{line},
			column      => $self->{column},
			previous    => $self->{previous_token},
			values      => \ %raw,
		};

		if (my $previous = $token->{previous}) {
			Scalar::Util::weaken $token->{previous};
			$previous->{next} = $token;
			Scalar::Util::weaken $previous->{next};
		}

		return $token;
	}

	sub _decode_token_name {
		my ($self, $raw_token) = @_;

		my $by_name = $self->{meta}{by_name};
		for my $key (keys %$raw_token) {
			return $key if exists $by_name->{$key};
		}

		die q (Cannot determine token name);
	}

	sub new {
		my ($class, $program) = @_;

		bless {
			class => $class,
			data => \ $program,
			line => 0,
			column => 0,
			previous_token => undef,
		}, $class;
	}

	sub lexer_regex {
		my ($self) = @_;

		$self->{lexer_regex} //= do {
			my $meta = $self->{meta} = CSI::Lexer::_lexer_for ($self->{class});

			my $by_name = $meta->{by_name};
			my %compiled;
			while (my ($name, $regex) = each %{ $by_name }) {
				$regex =~ s
					{ [\(] [?] [?] [{] \s* ['] (\w+) ['] \s* [}] [\)] }
					{
						die qq (Lexer pattern/token '$1' not defined)
							unless exists $by_name->{$1}
							;

						qq ((?&$1))
					}egx;

				$compiled{$name} = qq ((?<$name> $regex));
			}

			my $patterns = join qq (\n\t), @compiled{@{ $meta->{pattern} }};
			my $tokens   = join qq (\n\t|), @compiled{@{ $meta->{token} }};

			my $compiled_regex = qq (\t  $tokens);
			$compiled_regex .= qq (\n\t((DEFINE)(\n\t$patterns\n)))
				if $patterns;

			qr/$compiled_regex/x;
		};
	}

	sub next_token {
		my ($self) = @_;

		my $regex = $self->lexer_regex;

		return
			unless ${ $self->{data} } =~ m(\G $regex)xgs
			;

		my $token = $self->_build_token (%+);

		$self->_adapt_position;

		return $token;
	}

	sub _next_raw_token {
		my ($self) = @_;

		my $regex = $self->lexer_regex;

		return %+
			if ${ $self->{data} } =~ $regex
			;

		return;
	}

	1;
}
