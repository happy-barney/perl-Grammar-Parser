
use v5.14;
use Syntax::Construct v1.8 qw[ package-version package-block ];

use warnings;

package CSI::CQL v1.0.0 {
	use parent 'Exporter::Tiny';

	use Safe::Isa;

	use Context::Singleton;

	our @EXPORT = (
		'line',
		'search',
		#'child',
		#'children',
		#'find',
		#'where',
		#'count',
		#'descendants',
		#'ancestors',
		#'sibling',
		#'siblings',
		#'preceding_siblings',
		#'following_siblings',
	);

	sub line {
		my ($node) = @_;

		while (1) {
			return -1 unless $node;
			my ($values) = values %$node;
			return $values->line if $values->$_isa ('Grammar::Parser::Lexer::Token');

			say "not an array: $values" and return 1 unless Ref::Util::is_plain_arrayref ($values);
			($node) = @$values;
		}
	}

	sub search {
		my ($node, @query) = @_;

		@query = map { ref $_ ? $_ : CSI::CQL::Package->new ($_) } @query;
		@query = (CSI::CQL::Identity->new)
			unless @query;

		my @nodes = ($node);
		for my $query (@query) {
			@nodes = $query->query (@nodes);
		}

		@nodes;
	}

	sub self {
		deduce ('CSI::CQL->self');
	}

	sub where (&) {
		my ($code) = @_;

		CSI::CQL::Where->new ($code);
	}

	1;
};

package CSI::CQL::Query v1.0.0 {
	sub new {
		my ($class, @data) = @_;

		bless \@data, $class;
	}

	sub _expand_nodes {
		my ($self, @nodes) = @_;
		my @result = @nodes;
		while (my $node = shift @nodes) {
			die "$node is not an hashref"
				unless Ref::Util::is_plain_hashref ($node);

			my @values = values %$node;

			die "$node contains more than one key"
				unless @values == 1;

			next unless Ref::Util::is_plain_arrayref ($values[0]);

			use feature qw(postderef);
			my @children = Ref::Util::is_plain_arrayref ($values[0])
				? $values[0]->@*
				: @values
				;

			push @result, @children;
			push @nodes, @children;
		}

		@result;
	}

	1;
};

package CSI::CQL::Package v1.0.0 {
	use base 'CSI::CQL::Query';

	sub query {
		my ($self, @nodes) = @_;

		say __PACKAGE__, " => ", $self->[0];

		grep exists $_->{$self->[0]}, $self->_expand_nodes (@nodes);
	}
};

package CSI::CQL::Identity v1.0.0 {
	use base 'CSI::CQL::Query';

	sub query {
		my ($self, @nodes) = @_;

		$self->_expand_nodes (@nodes);
	}

	1;
};

