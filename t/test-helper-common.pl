
use strict;
use warnings;
use utf8;

use Carp::Always;

use Test::Deep      qw[ !cmp_deeply ];
use Test::More      0.96 import => [qw[ !ok !subtest !can_ok !is !is_deeply !fail ]];
use Test::Warnings  qw[ :no_end_test had_no_warnings ];

use Ref::Util       qw[];
use DDP;

use Context::Singleton;

contrive 'act-arguments' => (
	as => sub { [] },
);

contrive 'act-result-log' => (
	dep => [qw[ act act-arguments ]],
	as => sub {
		my ($coderef, $arguments) = @_;
		my $value;
		my $lives_ok = eval { $value = $coderef->(@$arguments); 1 };
		my $error = $@;

		+{
			'act-lives' => $lives_ok,
			'act-error' => $error,
			'act-value' => $value,
		};
	},
);

contrive 'act-lives' => (
	dep => [qw[ act-result-log ]],
	as  => sub { $_[0]->{'act-lives' } },
);

contrive 'act-error' => (
	dep => [qw[ act-result-log ]],
	as  => sub { $_[0]->{'act-error' } },
);

contrive 'act-value' => (
	dep => [qw[ act-result-log ]],
	as  => sub { $_[0]->{'act-value' } },
);

sub test_frame (&) {
	my ($code) = @_;

	frame {
		local $Test::Builder::Level = $Test::Builder::Level + 2;

		$code->()
	};
}

sub _build_got {
	my (%params) = @_;

	return $params{got} if exists $params{got};

	$params{act_with} = $params{args} if exists $params{args};

	proclaim 'act-arguments' => $params{act_with} if exists $params{act_with};
	die "Provide 'got' or 'act_with'"
		unless try_deduce 'act-arguments';

	my $got = deduce 'act-value';

	die "Act failed: ${\ deduce 'act-error' }"
		unless deduce 'act-lives';

	$got;
}

sub ok {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	Test::More::ok $params{got}, $title;
}

sub cmp_deeply {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	test_frame {
		my $got = _build_got %params;
		Test::Deep::cmp_deeply $got, $params{expect}, $title;
	};
}

sub it {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	test_frame {
		my $got = _build_got %params;
		Test::Deep::cmp_deeply $got, $params{expect}, $title
			or do {
				diag np $got;
				diag np $params{expect};
			};
	};
}

sub is {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	test_frame {
		my $got = _build_got %params;
		Test::Deep::cmp_deeply $got, $params{expect}, $title
			or do {
				diag np $got;
				diag np $params{expect};
			};
	};
}

sub can_ok {
	my (@can) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $package = is_deduced ('package')
		? deduce ('package')
		: shift @can
	;

	Test::More::can_ok $package, @can;
}

sub subtest {
	my ($title, $code) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	test_frame { Test::More::subtest $title, $code };
}

sub fail {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	return 1
		if exists $params{unless} && $params{unless};

	my $rv = Test::More::fail $title;

	if (exists $params{diag}) {
		Ref::Util::is_coderef ($params{diag})
			? map { diag $_ } $params{diag}->()
			: diag $params{diag}
			;
	}

	return $rv;
}

sub act (&) {
	my ($coderef) = @_;

	proclaim act => $coderef;
}

sub act_arguments {
	proclaim 'act-arguments' => [ @_ ];
}

sub act_throws {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $error = deduce 'act-error';

	return fail $title,
		diag   => sub {
			my $value = deduce 'act-value';
			+(
				"expect to die but lived and returned",
				np $value,
			);
		}
		unless $error;

	cmp_deeply $title,
		got => $error,
		expect => $params{throws},
	;
}

sub act_should_live {
	my ($title) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $error = deduce 'act-error';

	fail $title,
		unless => ! $error,
		diag   => sub { "expect to live but died with $error" },
		;
}

# Similar to Test::Exception except it uses Test::Deep
sub describe_package ($&) {
	my ($package, $code) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	subtest $package => sub {
		proclaim package => $package;

		$code->();
	}
}

1;
