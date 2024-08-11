
use v5.14;
use CSI::Common::Sense;

use Test::YAFT;
use Context::Singleton;

use Ref::Util qw();

my $lexer_singleton = q (CSI::Test::Class::Lexer);

sub csi_lexer_class (&) {
	my ($code) = @_;

	proclaim $lexer_singleton => $code->();
}

sub csi_lexer_should_tokenize {
	my ($title, %options) = @_;

	Test::YAFT::test_frame {
		my $lexer_class = $options{class} // deduce $lexer_singleton;
		my $lexer = $lexer_class->new ($options{program});

		it qq (should tokenize $title)
			=> expect => $options{expect},
			=> got    {
				my @tokens;
				push @tokens, $lexer->next_token // return \ @tokens
					while 1
					;
			};
	};
}

sub deduce_lexer_class () {
	deduce $lexer_singleton;
}

sub expect_token {
	my ($token, %options) = @_;

	$options{match} //= delete $options{value};

	expect_superhash ({ token => $token, %options });
}

1;
