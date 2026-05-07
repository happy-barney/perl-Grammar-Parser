
use v5.24;
use warnings;

use Test::YAFT;
use CSI::Language::Postgresql::Tokenizer;
use Context::Singleton;

act { [ CSI::Language::Postgresql::Tokenizer->tokenize ($_[0]) ] } 'string';

sub expect_tokens {
	[
		map {
			my %map;
			@map{qw{type value}} = @$_;
			\%map
		} @_
	]
}

1;
