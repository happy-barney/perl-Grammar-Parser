
use v5.14;
use warnings;

package CSI::Grammar::Base v1.0.0 {
	sub grammar {
		$_[0]->__csi_grammar->grammar;
	}

	sub actions {
		$_[0]->__csi_grammar->actions;
	}

	sub start_rule {
		$_[0]->__csi_grammar->start;
	}

	sub insignificant_rules {
		$_[0]->__csi_grammar->insignificant;
	}

	sub action_lookup {
		$_[0]->__csi_grammar->action_lookup;
	}

	sub _build_grammar {
		my ($self) = @_;

		Grammar::Parser::Grammar->new (
			grammar       => $self->grammar,
			start         => $self->start_rule,
			insignificant => $self->insignificant_rules,
		);
	}

	sub dom_for {
		$_[0]->__csi_grammar->dom_for ($_[1]);
	}

	1;
};

__END__

=pod

=encoding utf8

=head1 NAME

CSI::Grammar::Base

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file is part of L<< Grammar::Parser >>.
It can be distributed and/or modified under Artistic license 2.0

=cut
