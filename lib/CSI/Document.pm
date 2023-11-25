
use v5.14;
use warnings;

use Syntax::Construct 1.008 qw (
	package-block
	package-version
);

package CSI::Document v1.0.0 {
	use Moo;

	use Path::Tiny;
	use Ref::Util;
	use Scalar::Util;

	use namespace::clean;

	BEGIN { extends q (CSI::AST::Node) };

	has file =>
		is          => q (ro),
		;

	has grammar =>
		is          => q (ro),
		required    => 1,
		;

	has source =>
		is          => q (ro),
		;

	around BUILDARGS => sub {
		my ($orig, $class, %args) = @_;

		$args{file} = Path::Tiny->new ("$args{file}")
			if $args{file}
			;

		return $class->$orig (%args);
	};

	sub BUILD {
		my ($self) = @_;

		say qq (==> BUILD ), ref($self), Scalar::Util::refaddr ($self);
		$self
			->grammar
			->new ($self->_build_data)
			->parse ($self)
			;
	}

	sub _build_data {
		my ($self) = @_;

		return $self->source
			if $self->source
			;

		return $self->_slurp_file
			if $self->file
			;

		die qq (File or source required);
	}

	sub _slurp_file {
		my ($self) = @_;

		return \ $self->file->slurp_utf8;
	}

	sub _dump_format_content {
		my ($self, $element) = @_;

		return
			if $element->isa (CSI::AST::Node::)
			;

		return $element->content
			=~ s (\n) (\\n)gr
			=~ s (\t) (\\t)gr
			;
	}

	sub dump {
		my ($self) = @_;

		my $INDENT = 2;
		my $VALUE_ALIGN_COLUMN = 32;
		my $MIN_VALUE_ALIGN    = 1;
		my @queue = ([$self, 0]);

		my @lines;
		while (my $item = shift @queue) {
			my ($element, $indent_level) = @$item;

			my $name    = ref ($element);
			my $content = $self->_dump_format_content ($element);

			if ($element->isa (CSI::AST::Node::)) {
				unshift @queue, map +[ $_, $indent_level + $INDENT ], $element->children;
			};

			my $align = $VALUE_ALIGN_COLUMN - $indent_level - length ref ($element);
			$align += $INDENT
				while $align < $MIN_VALUE_ALIGN
				;

			push @lines, join q () => (
				q ( ) x ($indent_level),
				$name,
				defined ($content)
					? ( q ( ) x $align, q ('), $content, q (') )
					: ()
				,
				qq (\n),
			);
		}

		return @lines;
	}

	1;
};

