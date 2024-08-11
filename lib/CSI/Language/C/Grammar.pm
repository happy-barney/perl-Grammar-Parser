
use v5.14;
use CSI::Common::Sense;

package CSI::Language::C::Grammar v1.0.0 {
	use CSI::Language::C::Lexer;

	use CSI::AST::Node;
	use CSI::AST::Token;
	use CSI::AST::Token::Comment;
	use CSI::AST::Token::Whitespace;

	my %ast_map = (
		COMMENT_C       => CSI::AST::Token::Comment::,
		COMMENT_CPP     => CSI::AST::Token::Comment::,

		WHITESPACE      => CSI::AST::Token::Whitespace::,
		NEW_LINE        => CSI::AST::Token::Whitespace::,
	);

	sub new {
		my ($class, $program) = @_;

		bless { data => $program }, $class;
	}

	sub build_lexer {
		my ($self) = @_;

		return CSI::Language::C::Lexer::->new ($self->{data});
	}

	sub parse {
		my ($self, $document) = @_;

		say qq (==> BUILD ), ref($document), Scalar::Util::refaddr ($document);

		my $lexer   = $self->build_lexer;
		my $current = $document // CSI::AST::Node::->new;

		while (my $token = $lexer->next_token) {
			#say "=> tokent $token->{token}";
			if ($token->{match} =~ m (^[\[\(\{])) {
				$current->append_children (CSI::AST::Node::->new);
				$current = $current->last_child;
			}

			my $class = $ast_map{ $token->{token} } // CSI::AST::Token::;

			$current->append_children ($class->new (content => $token->{match}));

			if ($token->{match} =~ m (^[\]\)\}])) {
				$current = $current->parent;
			}
		}

		return $current;
	}

	1;
};

