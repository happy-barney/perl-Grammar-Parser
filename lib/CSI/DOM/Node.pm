
use v5.14;
use warnings;

use Syntax::Construct v1.8 qw (
	package-block
	package-version
);

package CSI::AST::Node v1.0.0 {
	use Moo;

	BEGIN { extends q (CSI::AST::Element) };

	has _children =>
		is          => q (ro),
		init_arg    => undef,
		default     => sub { [] }
		;

	sub _splice_children {
		my ($self, $index, $shift, $length, @elements) = @_;

		if (defined $index) {
			$_->_set_parent ($self)
				for @elements
				;
			$_->_set_parent (undef)
				for splice @{ $self->_children }, $index + $shift, $length, @elements
				;
		}

		return $index;
	}

	sub _replace_children {
		my ($self, $child, $shift, $length, @elements) = @_;

		return $self->_splice_children (
			$self->child_index ($child),
			$shift,
			$length,
			@elements
		);
	}

	sub append_children {
		my ($self, @children) = @_;

		if (@children) {
			$self->_splice_children (scalar $self->children, 0, 0, @children);
			return $children[-1];
		}

		return undef;
	}

	sub child_index {
		my ($self, $child) = @_;

		my $children = $self->_children;
		return List::Util::first { $children->[$_] == $child } 0 .. $#$children;
	}

	sub children {
		my ($self) = @_;

		return @{ $self->{_children} };
	}

	sub content {
		my ($self) = @_;

		return join q () => map { $_->content } $self->children;
	}

	sub first_child {
		my ($self) = @_;

		return undef
			unless @{ $self->_children }
			;

		return $self->_children->[0];
	}

	sub insert_after_child {
		my ($self, $child, @children) = @_;

		return $self->_replace_children ($child, 1, 0, @children);
	}

	sub insert_before_child {
		my ($self, $child, @children) = @_;

		return $self->_replace_children ($child, 0, 0, @children);
	}

	sub insert_children {
		my ($self, @children) = @_;

		if (@children) {
			$self->_splice_children (0, 0, 0, @children);
			return $children[0];
		}

		return undef;
	}

	sub last_child {
		my ($self) = @_;

		return undef
			unless @{ $self->_children }
			;

		return $self->_children->[-1];
	}

	sub location {
		my ($self) = @_;

		return undef
			unless my $first_child = $self->first_child;

		return $first_child->location;
	}

	sub remove_child {
		my ($self, $child) = @_;

		return $self->replace_child ($child);
	}

	sub replace_child {
		my ($self, $child, @children) = @_;

		return $self->_replace_children ($child, 0, 1, @children);
	}

	1;
};

