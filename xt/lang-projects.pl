#!/usr/bin/env perl

use feature 'say';
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../t";

use Getopt::Long;
use Path::Tiny;
use Path::Iterator::Rule;
use Sub::Override;

my %params = (
	checkout_root => '~/git/foreign',
	language      => 'java',
	suffix        => [qw[ java ]],
);

GetOptions (
	\ %params,

	'checkout_root|checkout-root|root=s',
	'language=s',
	'suffix=s@',
	'failed',
	'max=i',
	'verbose',
);

sub prove_state_file {
	my ($mode) = @_;

	".prove-lang-$params{language}-$mode";
}

sub checkout_root {
	Path::Tiny->new ($params{checkout_root});
}

sub work_dir {
	Path::Tiny->new ($FindBin::Bin);
}

sub language_project_list {
	my $path = work_dir->child ("lang-$params{language}.list");

	$path->lines_utf8 ({chomp => 1});
}

sub language_project_map {
	my %map;
	for my $project (language_project_list) {
		my $name = lc join '-', $params{language}, (split qr/(?<= [a-z])(?= [A-Z])/x, (split '/', $project)[-1]);
		my $path = checkout_root->child ($name);

		$map{ $path } = $project;
	}

	\%map;
}

sub language_project_dirs {
	sort values %{ language_project_map; };
}

sub language_project_checkout {
	my $map = language_project_map;

	use Term::ANSIColor qw[ :constants ];

	for my $path (keys %$map) {
		say "\N{HEAVY CHECK MARK} ", $path and next
			if -e $path;
		system qw[ git clone --depth 1 -o upstream ], $map->{$path}, $path;
	}
}

sub files_iterator {
	my $regex = qr/
		\.
		(?: ${ \
			join '|',
			map "(?:" . quotemeta ($_) . ")",
			@{ $params{suffix} }
		})
		$
	/x;

	my $iterator = Path::Iterator::Rule->new
		->file
		->skip_git
		->name ($regex)
		;

	my $next = $iterator->iter (language_project_dirs);
}

sub prove {
	my ($mode) = @_;

	my $prove = My::App::Prove ->new (
		mode => "run-$mode-test",
	);

	my @files;
	unless ($params{failed}) {
		my $iterator = files_iterator;
		while (my $file = $iterator->()) {
			push @files, $file;
			next unless defined $params{max};
			last unless @files < $params{max};
		}
	}

	$prove->process_args (
		'--state' => $params{failed} ? 'failed' : 'save',
		'--statefile' => prove_state_file ($mode),
		'--timer',
		('--verbose') x!! $params{verbose},
		@files,
	);

	$prove->run;
}

sub prove_lexer {
	prove 'lexer';
}

sub prove_parser {
	prove 'parser';
}

sub arrange_csi_language {
	my $language = 'CSI::Language::' . (ucfirst lc $params{language}) . '::Grammar';
	eval "use $language; 1;" or die $@;

	eval 'require "test-helper-csi.pl";';

	proclaim ('csi-language' => $language);
}

sub run_lexer_test {
	my ($file) = @_;

	arrange_csi_language;

	my $lexer = deduce ('csi-grammar-lexer');

	$lexer->add_data (Path::Tiny->new ($file)->slurp_utf8);

	my $tokens = 0;
	eval { $tokens++ while @{ $lexer->next_token } };

	ok ("parsed $tokens tokens", got => ! $@, expect => bool (1));
	done_testing();
}

sub run_parser_test {
	my ($file) = @_;

	arrange_csi_language;

	my $parser = deduce ('csi-parser');

	ok (
		"parse $file",
		got => scalar eval { $parser->parse (Path::Tiny->new ($file)->slurp_utf8) },
		expect => bool (1),
	) || diag ($@);

	done_testing();
}

sub dispatch_command {
	my ($command, @argv) = @_;

	my %command_map = (
		'checkout'        => \& language_project_checkout,
		'list'            => \& language_project_list,
		'run-lexer-test'  => \& run_lexer_test,
		'run-parser-test' => \& run_parser_test,
		'prove-lexer'     => \& prove_lexer,
		'prove-parser'    => \& prove_parser,
	);

	die "Missing command" unless defined $command && length $command;
	die "Unknown command $command" unless exists $command_map{$command};

	return $command_map{$command}->(@argv);
}

binmode STDOUT, ':utf8';

dispatch_command (@ARGV);

BEGIN {
	package My::App::Prove {
		use parent 'App::Prove';

		sub new {
			my ($class, %params) = @_;
			my $self = $class->SUPER::new;

			$self->{mode} = $params{mode};

			$self;
		}

		sub process_args {
			my $self = shift;

			$self->SUPER::process_args (
				@_,
				'--exec' => "$0 $self->{mode}",
			);

			$self->{jobs} = $self->{verbose}
				? 1
				: 2 + `nproc --all`
				;
		}
	};
}
