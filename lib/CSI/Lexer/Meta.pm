
use v5.14;
use CSI::Common::Sense;

package CSI::Lexer::Meta v1.0.0 {
	use Moo;

	has for_class
		=> is       => ro
		=> required => 1
		;

	has by_name
		=> is       => ro
		=> default  => sub { +{} }
		=> init_arg => undef
		;

	has pattern
		=> is       => ro
		=> default  => sub { +[] }
		=> init_arg => undef
		;

	has token
		=> is       => ro
		=> default  => sub { +[] }
		=> init_arg => undef
		;

	has lexer_regex
		=> is       => ro
		=> builder  => _build_lexer_regex
		=> init_arg => undef
		;

	sub _compile_regexes {
		my ($self, $join, $names) = @_;

		return join $join,
			map { $self->_compile_single_regex ($_) }
			@$names
			;
	}

	sub _build_lexer_regex {
		my ($self) = @_;

		my $token_regexp   = $self->_compile_regexes (qq (\n| ), $self->token);
		my $pattern_regexp = $self->_compile_regexes (qq (\n\t), $self->pattern);

		return qr ($token_regexp\n((DEFINE)\n\t$pattern_regexp\n))x;
	}

	sub _compile_single_regex {
		my ($self, $name) = @_;

		my $by_name = $self->by_name;
		my $regex = $by_name->{$name};
		$regex =~ s
			{ [\(] [?] [?] [{] \s* ['] (\w+) ['] \s* [}] [\)] }
			{
				die qq (Lexer pattern/token '$1' not defined)
					unless exists $by_name->{$1}
					;

				qq ((?&$1))
			}egx;

		return $regex;
	}

	sub _registry {
		my ($self, $what, $name, $regex) = @_;

		die qq (\u$what '$name' is already defined)
			if exists $self->by_name ($name)
			;

		push @{ $self->$what }, $regex;

		();
	}

	sub registry_pattern {
		my $self = shift;

		$self->_registry (pattern => @_);
	}

	sub registry_token {
		my $self = shift;

		$self->_registry (token => @_);
	}

	1;
};
