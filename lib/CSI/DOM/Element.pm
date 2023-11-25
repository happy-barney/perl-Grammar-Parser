
use v5.14;
use warnings;

use Syntax::Construct v1.8 qw (
	package-block
	package-version
);

package CSI::AST::Element v1.0.0 {
	use Moo;

	use Scalar::Util;

	use overload (
		q (bool) => sub { 1 },
		q ("")   => q (content),
		q (==)   => q (_equal_refs),
		q (eq)   => q (_equal_content),
	);

	use constant NO_CONTENT => q ();

	has _location =>
		is      => q (rw),
		writer  => q (_set_location),
		;

	has content =>
		is      => q (rw),
		default => sub { q () }
		;

	has next_sibling =>
		is      => q (rw),
		weaken  => 1,
		writer  => q (_set_next_sibling),
		;

	has parent  =>
		is      => q (rw),
		weaken  => 1,
		writer  => q (_set_parent),
		;

	has prev_sibling =>
		is      => q (rw),
		weaken  => 1,
		writer  => q (_set_prev_sibling),
		;

	sub _equal_refs  {
		my ($self, $other) = @_;

		return ref ($other)
			&& (Scalar::Util::refaddr($self) == Scalar::Util::refaddr($other))
			;
	}

	sub _equal_content {
		my ($self, $other) = @_;

		return defined ($other)
			&& $self->content eq "$other"
			;
	}

	sub _link_elements {
		my ($self, @elements) = @_;

		my $prev;
		for my $element (@elements) {
			$element->_unlink;
			$element->_set_parent ($self->parent);
			if ($prev) {
				$element->_set_prev_sibling ($prev);
				$prev->_set_next_sibling ($element);
			}
			$prev = $element;
		}

		return ($elements[0], $elements[-1]);
	}

	sub _unlink {
		my ($self) = @_;

		my $next = $self->next_element;
		my $prev = $self->prev_element;

		if ($self->parent) {
			$self->parent->_set_first_child ($next)
				unless $prev;

			$self->_set_parent ()
		}

		if ($next) {
			$next->_set_prev_sibling ($prev);
			$self->_set_next_sibling (undef);
		}

		if ($prev) {
			$prev->_set_next_sibling ($next);
			$self->_set_prev_sibling (undef);
		}
	}

	sub significant { 1 }
	sub class { ref($_[0]) }
	sub tokens { $_[0] }
	sub is_descendant_of {
		my ($self, $parent) = @_;

		return unless $parent;
		return 1 if $self == $parent;
		return $self->parent->is_descendant_of ($parent);
	}

	sub is_ancestor_of {
		my ($self, $child) = @_;

		return unless $child;
		return 1 if $self == $child;
		return $self->is_ancestor_of ($child->parent);
	}

	sub snext_sibling {
		my ($self) = @_;

		my $next = $self->next_sibling
			or return NO_CONTENT
			;

		return $next->snext_sibling
			unless $next->significant
			;

		return $next;
	}

	sub sprev_sibling {
		my ($self) = @_;

		return NO_CONTENT
			unless my $prev = $self->prev_sibling
			;

		return $prev->sprev_sibling
			unless $prev->significant
			;

		return $prev;
	}

	sub insert_after {
		my ($self, @elements) = @_;

		return $self->parent->insert_after_child ($self, @elements);
	}

	sub insert_before {
		my ($self, @elements) = @_;

		return $self->parent->insert_before_child ($self, @elements);
	}

	sub remove {
		my ($self) = @_;

		return $self->parent->remove_child ($self);
	}

	sub replace {
		my ($self, @elements) = @_;

		return $self->parent->replace_child ($self, @elements);
	}

	sub location;

	sub line_number {
		my ($self) = @_;

		return $self->location->{line};
	}

	sub column_number {
		my ($self) = @_;

		return $self->location->{column};
	}

	1;
};

# Based on PPI::Element but with different relationship management

