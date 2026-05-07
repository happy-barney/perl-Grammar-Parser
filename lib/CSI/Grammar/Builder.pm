
use v5.14;
use warnings;
use Syntax::Construct qw (package-block package-version);

package CSI::Grammar::Builder {
	use parent qq (Exporter::Tiny);

	use Sub::Install;

	my %code;
	my %declarations;

	sub _build_instance {
		my ($type, $caller, $name) = @_;

		$type->new (
			caller => $caller, namet => $name);
	}

	sub as {
		@_;
	}

	sub declare ($$;@) :Exported {
		my ($type, $name, @definition) = @_;

		my $caller = caller;

		my $instance = $declarations{$caller}{$name

		die qq (Invalid rule '$name': must be identifier)
			unless $name =~ qr ( ^ (?! \d ) \w+ $ )x
			;

		my $instance = $declarations->{$name} //= $type->build (
			caller => $caller,
			name   => $name,
		);

		warn qq (Redeclared rule '$name')
			if @definition
			&& $instance->is_declared
			;

		$instance->declare (@definition);

		$declarations->{-code} //= Sub::Install::install_sub (
			code => sub { $instance },
			into => $caller,
			name => $name,
		);

		$instance;
	}

	1;
}

