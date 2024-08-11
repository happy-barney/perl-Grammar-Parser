
use v5.14;
use warnings;

use Syntax::Construct v1.8 qw (
	package-block
	package-version
);

package CSI::Exporter v1.0.0 {
	use parent q (Exporter::Tiny);

	use Exporter::Tiny v0.025; # exporter generator

	use Module::Load;

	sub _exporter_validate_opts {
		my ($class, $globals) = @_;

		my $into = $globals->{into};

		if (my $class = $globals->{csi_meta_class}) {
			my $meta = $globals->{csi_meta_object} //= do {
				Module::Load::load ($class);
				$class->new (for_class => $into);
			};

			no strict q (refs);
			*{qq (${into}::__csi_meta) } = sub { $meta };
		}

		if (my $isa = $globals->{csi_isa}) {
			$isa = [ $isa ]
				unless ref $isa
				;

			if (@$isa) {
				Module::Load::load ($_) for @$isa;
				no strict q (refs);
				push @{ "${into}::ISA" }, @$isa;
			}
		}

		$class->SUPER::_exporter_validate_opts(@_);
	}

	1;
};

