
use v5.14;
use warnings;

package CSI::Grammar v1.0.0 {
	use parent 'Exporter::Tiny';

	use Exporter::Tiny v0.025; # exporter generator
	use Sub::Name qw[];
	use Module::Load qw[];

	use CSI::Grammar::Base;
	use CSI::Grammar::Meta;
	use CSI::Grammar::Actions;

	our @EXPORT = (
		qw[ insignificant start ],
		qw[ rule regex token ],
	);

	sub _exporter_validate_opts {
		my ($class, $globals) = @_;

		my $into = $globals->{into};
		my $meta = CSI::Grammar::Meta->new (for_class => $into);
		$meta->add_action (PRIORITY_TOKEN =>  'skip');

		{
			no strict 'refs';

			*{"${into}::__csi_grammar"} = sub { $meta };
			push @{ "${into}::ISA" }, 'CSI::Grammar::Base';
		}

		for my $key (keys %$globals) {
			my $handler = $class->can ("_exporter_global_option_$key");
			$handler->($meta, $globals->{$key})
				if $handler;
		}

		$class->SUPER::_exporter_validate_opts(@_);
	}

	sub _exporter_global_option_default_token_action {
		my ($meta, $action) = @_;

		$meta->default_token_action ($action);
	}

	sub _exporter_global_option_default_rule_action {
		my ($meta, $action) = @_;

		$meta->default_rule_action ($action);
	}

	sub _exporter_global_option_action_lookup {
		my ($meta, $module) = @_;

		Module::Load::load $module;
		$meta->prepend_action_lookup ($module);
	}

	sub _common {
		my ($meta, $rule_name, @def) = @_;
		state $label_map = {
			action => 'ACTION',
			dom    => 'DOM',
			group  => 'GROUP',
			proto  => 'PROTO',
			dom_prefix => 'DOM_PREFIX',
		};

		my $dom_prefix = '';
		$meta = $meta->__csi_grammar unless ref $meta;

		while (@def) {
			last if ref $def[0];
			last unless exists $label_map->{$def[0]};

			my ($key, $value) = (shift @def, shift @def);
			goto $label_map->{$key};

			ACTION:
			$meta->add_action ($rule_name => $value)
				unless $meta->dom_for ($rule_name);
			next;

			DOM:
			$value = $dom_prefix . $value
				if $dom_prefix && $value =~ m/^::/;

			$meta->add_dom ($rule_name => $value);
			$meta->add_action ($rule_name => 'dom');
			next;

			DOM_PREFIX:
			$dom_prefix = $value;
			next;

			PROTO:
			$meta->add_rule ($value => \ [])
				unless $meta->rule_exists ($value);
			$meta->append_rule ($value => \ $rule_name);
			next;

			GROUP:
			unless ($meta->rule_exists ($value)) {
				$meta->add_rule ($value => []);
				$meta->add_action ($value, $meta->default_rule_action);
			}
			$meta->append_rule ($value => [ $rule_name ]);
			next;
		}

		\ @def;
	}

	sub _ensure_unique_grammar_symbol {
		my ($meta, $rule_name) = @_;

		die "Rule $rule_name already defined"
			if $meta->rule_exists ($rule_name);
	}

	sub _exporter_symbol_name {
		my ($class, $name, $args, $globals) = @_;

		$name =
			ref    $globals->{as} ? $globals->{as}->($name) :
			ref    $args->{-as}  ? $args->{-as}->($name) :
			exists $args->{-as}  ? $args->{-as} :
			$name
			;

		return unless $name;

		my $prefix = $args->{-prefix} // $globals->{prefix} // '';
		my $suffix = $args->{-suffix} // $globals->{suffix} // '';

		return "$prefix$name$suffix";
	}

	sub _exporter_subname {
		my ($class, $name, $args, $globals, $coderef) = @_;

		my $subname = $class->_exporter_symbol_name ($name, $args, $globals);

		Sub::Name::subname "$globals->{into}::$subname" => $coderef;
	}

	sub _generate_rule {
		my ($class, $name, $args, $globals) = @_;
		my $into = $globals->{into};
		my $meta = $into->__csi_grammar;
		my @dom_prefix = (dom_prefix => $globals->{dom_prefix});

		_exporter_subname $class, $name, $args, $globals,  sub {
			my ($rule_name, @def) = @_;

			_ensure_unique_grammar_symbol $meta, $rule_name;

			$meta->add_rule ($rule_name => _common $meta, $rule_name, @dom_prefix, @def);

			$meta->add_action ($rule_name, $meta->default_rule_action)
				unless $meta->action_exists ($rule_name);

			$rule_name;
		};
	}

	sub _generate_regex {
		my ($class, $name, $args, $globals) = @_;
		my $into = $globals->{into};
		my $meta = $into->__csi_grammar;

		_exporter_subname $class, $name, $args, $globals,  sub {
			my ($rule_name, @def) = @_;

			$meta->add_rule ($rule_name => \ [ @def ]);

			$rule_name;
		}
	}

	sub _generate_token {
		my ($class, $name, $args, $globals) = @_;
		my $into = $globals->{into};
		my $meta = $into->__csi_grammar;
		my @dom_prefix = (dom_prefix => $globals->{dom_prefix});

		_exporter_subname $class, $name, $args, $globals,  sub {
			my ($rule_name, @def) = @_;

			_ensure_unique_grammar_symbol $meta, $rule_name;

			$meta->add_rule ($rule_name => _common $meta, $rule_name, @dom_prefix, @def);

			$meta->add_action ($rule_name, $meta->default_token_action)
				unless $meta->action_exists ($rule_name);

			$rule_name;
		}
	}

	sub _generate_insignificant {
		my ($class, $name, $args, $globals) = @_;
		my $into = $globals->{into};
		my $meta = $into->__csi_grammar;

		_exporter_subname $class, $name, $args, $globals,  sub {
			my ($rule_name, @rest) = @_;

			$meta->append_insignificant ($rule_name);

			($rule_name, @rest);
		};
	}

	sub _generate_start {
		my ($class, $name, $args, $globals) = @_;
		my $into = $globals->{into};
		my $meta = $into->__csi_grammar;

		_exporter_subname $class, $name, $args, $globals,  sub {
			my ($rule_name, @rest) = @_;

			$meta->start ($rule_name);

			($rule_name, @rest);
		};
	}
};

1;
