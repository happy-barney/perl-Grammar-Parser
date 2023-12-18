
use v5.14;
use CSI::Common::Sense;

package CSI::Lexer v1.0.0 {
	use parent q (Exporter::Tiny);

	use Exporter::Tiny v0.025; # exporter generator

	use CSI::Lexer::Meta;
	use CSI::Lexer::Base;

	our @EXPORT = (
		qw [ token ],
		qw [ pattern ],
	);

	my %meta;

	sub _exporter_validate_opts {
		my ($class, $globals) = @_;

		my $into = $globals->{into};
		$meta{$into} = CSI::Lexer::Meta::->new (for_class => $into);

		{
			no strict q (refs);
			push @{ "${into}::ISA" }, q (CSI::Lexer::Base);
		}

		$class->SUPER::_exporter_validate_opts(@_);
	}

	sub _lexer_for {
		my ($for) = @_;

		return $meta{$for};
	}

	sub token {
		_lexer_for (scalar caller)->register_token (@_);
	}

	sub pattern {
		_lexer_for (scalar caller)->register_pattern (@_);
	}

	1;
};

