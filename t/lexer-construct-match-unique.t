
use strict;
use warnings;

use Grammar::Parser::Lexer::Match::Unique;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

# arrange_lexer_rules load_fixture rules => "sql-grammar-snippet";
#
# my $fixture = load_fixture "sql-grammar-snippet";
# arrange_lexer_rules $fixture->rules;
# arrange_lexer_rules $fixture->${\ "rules" };

sub RULES () {
	+{
		whitespace      => qr/(?> \s+ )/x,
		comment_sql     => qr/(?> -- \V* (??{ 'End_Of_Line' }) )/x,
		comment_c       => qr/(?> (??{ 'Comment_C_Start' }) (?s:.*?) (??{ 'Comment_C_End' }) )/x,
		CREATE          => qr/(?> \b CREATE \b)/xi,
		OR              => qr/(?> \b OR \b)/xi,
		REPLACE         => qr/(?> \b REPLACE \b)/xi,
		TABLE           => qr/(?> \b TABLE \b)/xi,
		SEMICOLON       => ';',
		identifier      => qr/(?> (?! (??{ 'Keyword' }) ) (?! \d ) (\w+) \b )/x,
		End_Of_Line     => \ qr/ (?= [\r\n] ) \r? \n? /x,
		Comment_C_Start => \ qr/ \/\* /x,
		Comment_C_End   => \ qr/ \*\/ /x,
		Keyword         => \ [
			\ 'CREATE',
			\ 'OR',
			\ 'REPLACE',
			\ 'TABLE',
		],
	};
}

sub INSIGNIFICANT () {
	+[
		qw[ whitespace  ],
		qw[ comment_sql ],
		qw[ comment_c   ],
		qw[ comment_cpp ],
	];
}

sub DATA () {
	"CREATE OR REPLACE"
}

sub test_lexer_helpers {
	my ($title, $lexer) = @_;

	subtest $title => sub {
		it "should initialize insignificant list",
			got => $lexer->insignificant,
			expect => [qw[ whitespace comment_sql comment_c comment_cpp ]],
			;

		it "should eliminate not-existing insignificant",
			got => $lexer->_insignificant_map,
			expect => { whitespace => 1, comment_c => 1, comment_sql => 1 },
			;

		it "should have initialized data",
			got => ${ $lexer->_data },
			expect => DATA,
			;

		it "should parse CREATE token",
			got => $lexer->next_token,
			expect => [ CREATE => ignore ],
			;

		it "should parse whitespace token",
			got => $lexer->next_token,
			expect => [ whitespace => ignore ],
			;
	};
}

my $lexer = Grammar::Parser::Lexer::Match::Unique->new (
	rules => RULES,
	insignificant => INSIGNIFICANT,
	return_insignificant => 1,
);

$lexer->add_data ('CREATE OR REPLACE');

arrange_lexer_rules %{ RULES() };
arrange_lexer_data  DATA;
arrange_lexer_insignificant @{ INSIGNIFICANT() };
arrange_return_insignificant 1;

test_lexer_helpers "using explicit lexer instance" => $lexer;
test_lexer_helpers "using context lexer instance" => deduce 'current-lexer';

done_testing;
