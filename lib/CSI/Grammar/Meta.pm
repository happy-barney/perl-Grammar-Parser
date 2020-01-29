
use v5.14;
use warnings;

package CSI::Grammar::Meta v1.0.0 {
	use Moo;

	has 'for_class'
		=> is       => 'ro'
		=> init_arg => 'for_class'
	;

	has 'grammar'
		=> is       => 'ro'
		=> init_arg => undef
		=> default  => sub { +{} }
	;

	has 'dom'
		=> is       => 'ro'
		=> init_arg => undef
		=> default  => sub { +{} }
	;

	has 'actions'
		=> is       => 'ro'
		=> init_arg => undef
		=> default  => sub { +{} }
	;

	has 'insignificant'
		=> is       => 'ro'
		=> init_arg => undef
		=> default  => sub { +[] }
	;

	has 'action_lookup'
		=> is       => 'ro'
		=> init_arg => undef
		=> default  => sub { +[qw[ CSI::Grammar::Actions ]] }
	;

	has 'default_rule_action'
		=> is       => 'rw'
		=> init_arg => undef
		=> default  => sub { 'default' }
	;

	has 'default_token_action'
		=> is       => 'rw'
		=> init_arg => undef
		=> default  => sub { 'literal' }
	;

	has 'start'
		=> is       => 'rw'
	;

	sub add_rule {
		my ($self, $rule, $def) = @_;

		die "Rule '$rule' already defined"
			if $self->rule_exists ($rule);

		$self->grammar->{$rule} = $def;
	}

	sub append_rule {
		my ($self, $rule, $def) = @_;

		die "Rule '$rule' not defined yet"
			unless $self->rule_exists ($rule);

		my $append = $self->grammar->{$rule};

		push @{ Ref::Util::is_plain_arrayref ($def) ? $append : $$append }, $def;
	}

	sub rule_exists {
		my ($self, $rule) = @_;

		exists $self->grammar->{$rule};
	}

	sub add_action {
		my ($self, $rule, $action) = @_;

		return unless $action;

		$action = 'rule_' . $action
			unless ref $action;

		$self->actions->{$rule} = $action;
	}

	sub action_exists {
		my ($self, $rule) = @_;

		exists $self->actions->{$rule};
	}

	sub append_insignificant {
		my ($self, @rules) = @_;

		push @{ $self->insignificant }, @rules;
	}

	sub prepend_action_lookup {
		my ($self, @loookup) = @_;

		unshift @{ $self->action_lookup }, @loookup;
	}

	sub add_dom {
		my ($self, $rule, $class) = @_;

		$self->_dom->{$rule} = $class;
	}

	sub dom_for {
		my ($self, $rule) = @_;

		$self->_dom->{$rule};
	}

	1;
};
