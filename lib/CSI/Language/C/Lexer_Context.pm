
use v5.14;
use CSI::Common::Sense;

package CSI::Language::C::Lexer_Context v1.0.0 {
	use Path::Tiny;
	use Ref::Util qw (is_plain_scalarref);
	use Safe::Isa qw ($_isa);

	use namespace::clean;

	use constant {
		TOKEN_WHITESPACE        => 1,
		TOKEN_NEW_LINE          => 2,
		TOKEN_NEW_LINE_ESCAPE   => 3,
		TOKEN_DIGIT_ZERO        => 4,
		TOKEN_DIGITS_BINARY     => 5,
		TOKEN_DIGITS_OCTAL      => 6,
		TOKEN_DIGITS_DECIMAL    => 7,
		TOKEN_DIGITS_HEX        => 8,
		TOKEN_LETTER_B          => 9,
		TOKEN_LETTER_X          => 10,
		TOKEN_LETTER_L          => 11,
		TOKEN_LETTER_F          => 12,
		TOKEN_LETTER_Z          => 13,
		TOKEN_LETTER_U          => 14,
		TOKEN_LETTER_I          => 15,
		TOKEN_LETTER_R          => 16,
		TOKEN_IDENTIFIER        => 17,
		TOKEN_AMPERSAND         => 18,
		TOKEN_APOSTROPHE        => 19,
		TOKEN_ASTERISK          => 20,
		TOKEN_BACKSLASH         => 21,
		TOKEN_BRACE_CLOSE       => 22,
		TOKEN_BRACE_OPEN        => 23,
		TOKEN_BRACKET_CLOSE     => 24,
		TOKEN_BRACKET_OPEN      => 25,
		TOKEN_CARET             => 26,
		TOKEN_COLON             => 27,
		TOKEN_COMMA             => 28,
		TOKEN_DOT               => 29,
		TOKEN_EQUALS_SIGN       => 30,
		TOKEN_EXCLAMATION_MARK  => 31,
		TOKEN_GREATER_THAN      => 32,
		TOKEN_HASH              => 33,
		TOKEN_LESS_THAN         => 34,
		TOKEN_MINUS             => 35,
		TOKEN_PAREN_CLOSE       => 36,
		TOKEN_PAREN_OPEN        => 37,
		TOKEN_PERCENT           => 38,
		TOKEN_PLUS              => 39,
		TOKEN_QUESTION_MARK     => 40,
		TOKEN_QUOTATION_MARK    => 41,
		TOKEN_SEMICOLON         => 42,
		TOKEN_SOLIDUS           => 43,
		TOKEN_TILDE             => 44,
		TOKEN_VERTICAL_BAR      => 45,
	};

	use constant {
		IS_PUNCT           => 1 << 0,
		IS_LITERAL         => 1 << 1,
		IS_NUMBER          => 1 << 2,
		IS_SIGNIFICANT     => 1 << 3,
		IS_IDENTIFIER      => 1 << 4,
		IS_NEWLINE         => 1 << 5,
		IS_LOGICAL_NEWLINE => 1 << 6,
		IS_PAIRED          => 1 << 7,
		IS_PAIRED_OPEN     => 1 << 8,
		IS_PAIRED_CLOSE    => 1 << 9,
		IS_OPERATOR        => 1 << 10,
		IS_COMMENT         => 1 << 11,
	};

	our %physical_token = (
		WHITESPACE        => 0,
		NEW_LINE          => IS_NEWLINE | IS_LOGICAL_NEWLINE,
		NEW_LINE_ESCAPE   => IS_NEWLINE,
		DIGIT_ZERO        => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		DIGITS_BINARY     => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		DIGITS_OCTAL      => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		DIGITS_DECIMAL    => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		DIGITS_HEX        => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		LETTER_B          => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		LETTER_X          => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		LETTER_L          => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		LETTER_F          => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		LETTER_Z          => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		LETTER_U          => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		LETTER_I          => IS_SIGNIFICANT | IS_LITERAL | IS_NUMBER | IS_IDENTIFIER,
		LETTER_R          => IS_SIGNIFICANT | IS_LITERAL | IS_IDENTIFIER,
		IDENTIFIER        => IS_SIGNIFICANT | IS_IDENTIFIER,
		AMPERSAND         => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		APOSTROPHE        => IS_SIGNIFICANT | IS_PUNCT | IS_LITERAL,
		ASTERISK          => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		BACKSLASH         => IS_SIGNIFICANT | IS_PUNCT,
		BRACE_CLOSE       => IS_SIGNIFICANT | IS_PUNCT | IS_PAIRED | IS_PAIRED_CLOSE,
		BRACE_OPEN        => IS_SIGNIFICANT | IS_PUNCT | IS_PAIRED | IS_PAIRED_OPEN,
		BRACKET_CLOSE     => IS_SIGNIFICANT | IS_PUNCT | IS_PAIRED | IS_PAIRED_CLOSE,
		BRACKET_OPEN      => IS_SIGNIFICANT | IS_PUNCT | IS_PAIRED | IS_PAIRED_OPEN,
		CARET             => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		COLON             => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		COMMA             => IS_SIGNIFICANT | IS_PUNCT,
		DOT               => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		EQUALS_SIGN       => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		EXCLAMATION_MARK  => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		GREATER_THAN      => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		HASH              => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		LESS_THAN         => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		MINUS             => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		PAREN_CLOSE       => IS_SIGNIFICANT | IS_PUNCT | IS_PAIRED | IS_PAIRED_CLOSE,
		PAREN_OPEN        => IS_SIGNIFICANT | IS_PUNCT | IS_PAIRED | IS_PAIRED_OPEN,
		PERCENT           => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		PLUS              => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		QUESTION_MARK     => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		QUOTATION_MARK    => IS_SIGNIFICANT | IS_PUNCT | IS_LITERAL,
		SEMICOLON         => IS_SIGNIFICANT | IS_PUNCT,
		SOLIDUS           => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		TILDE             => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
		VERTICAL_BAR      => IS_SIGNIFICANT | IS_PUNCT | IS_OPERATOR,
	);

	my %token_concat = (
		C_COMMENT => 
	);

	my $tokenizer = qr (
		((DEFINE)
			(?<Ampersand>               [&] )
			(?<Apostrophe>              ['] )
			(?<Asterisk>                [*] )
			(?<Backslash>               [\\] | (?&Backslash_Trigraph))
			(?<Backslash_Trigraph>      [?] [?] [/] )
			(?<C_Comment_Start>         [/] [*] )
			(?<C_Comment_End>           [*] [/] )
			(?<C_Comment_Content        (?: (?! (?&C_Comment_End) | (?&New_Line) | (?&New_Line_Escape) )
			(?<Cpp_Comment_Start>       [/] [/] )
			(?<Digit_Zero>              [0] )
			(?<Identifier>              (?! [0-9]) (?&Identifier_Char)+ )
			(?<Identifier_Char>         [a-zA-Z0-9_])
			(?<New_Line>                [\n]     )
			(?<New_Line_Escape>         (?&Backslash) [\n] )
			(?<Whitespace>              [^\S\n]+ )
		)
	)x;

#
#		# Punctuation characters
#		| (?<BACKSLASH>             (?&Backslash) (?! [\n] ))
#		| (?<BRACE_CLOSE>           (?&Brace_Close) )
#		| (?<BRACE_OPEN>            (?&Brace_Open) )
#		| (?<BRACKET_CLOSE>         (?&Bracket_Close) )
#		| (?<BRACKET_OPEN>          (?&Bracket_Open) )
#		| (?<CARET>                 (?&Caret) )
#		| (?<COLON>                 (?&Colon) )
#		| (?<COMMA>                 [,] )
#		| (?<DOT>                   [.] )
#		| (?<EQUALS_SIGN>           [=] )
#		| (?<EXCLAMATION_MARK>      [!] )
#		| (?<GREATER_THAN>          [>] )
#		| (?<HASH>                  (?&Hash) )
#		| (?<LESS_THAN>             (?&Less_Than) )
#		| (?<MINUS>                 [-] )
#		| (?<PAREN_CLOSE>           [\)] )
#		| (?<PAREN_OPEN>            [\(] )
#		| (?<PERCENT>               (?&Percent) )
#		| (?<PLUS>                  [+] )
#		| (?<QUESTION_MARK>         (?&Question_Mark) )
#		| (?<QUOTATION_MARK>        ["] )
#		| (?<SEMICOLON>             [;] )
#		| (?<SOLIDUS>               [/] )
#		| (?<TILDE>                 (?&Tilde) )
#		| (?<VERTICAL_BAR>          (?&Vertical_Bar) )
#
#		| (?<Unknown> .)
#
#	((DEFINE)
#		(?<Digit_Binary>            [0-1] )
#		(?<Digit_Octal>             [0-7] )
#		(?<Digit_Decimal>           [0-9] )
#		(?<Digit_Hex>               [0-9a-fA-F] )
#		(?<Suffix_Number>           [fluzFLUZ] )
#
#		(?<Not_An_Identifier>       (?!
#			(?&Digit_Hex)
#			| (?&LETTER_B)
#			| (?&LETTER_F)
#			| (?&LETTER_I)
#			| (?&LETTER_L)
#			| (?&LETTER_R)
#			| (?&LETTER_U)
#			| (?&LETTER_Z)
#			| (?&LETTER_X)
#		))
#
#		# n-graphs start characters not starting n-graph
#		# n-graphs are expanded before recognizing NEW_LINE_ESCAPE
#		# so we can use simple negative lookahead
#
#		(?<Colon>                   [:] (?! [>] ))
#		(?<Less_Than>               [<] (?! [:%] ))
#		(?<Percent>                 [%] (?! [:>] ))
#		(?<Question_Mark>           [?] (?! [?] ))
#
#		(?<Brace_Open>              [\{] | (?&Brace_Open_Digraph) | (?&Brace_Open_Trigraph))
#		(?<Brace_Open_Digraph>      [<] [%] )
#		(?<Brace_Open_Trigraph>     [?] [?] [<] )
#
#		(?<Brace_Close>             [\}] | (?&Brace_Close_Digraph) | (?&Brace_Close_Trigraph))
#		(?<Brace_Close_Digraph>     [%] [>] )
#		(?<Brace_Close_Trigraph>    [?] [?] [>] )
#
#		(?<Bracket_Open>            [\[] | (?&Bracket_Open_Digraph) | (?&Bracket_Open_Trigraph))
#		(?<Bracket_Open_Digraph>    [<] [:] )
#		(?<Bracket_Open_Trigraph>   [?] [?] [\(] )
#
#		(?<Bracket_Close>           [\]] | (?&Bracket_Close_Digraph) | (?&Bracket_Close_Trigraph))
#		(?<Bracket_Close_Digraph>   [:] [>] )
#		(?<Bracket_Close_Trigraph>  [?] [?] [\)] )
#
#		(?<Caret>                   [\^] | (?&Caret_Trigraph))
#		(?<Caret_Trigraph>          [?] [?] [\'] )
#
#		(?<Hash>                    [\#] | (?&Hash_Digraph) | (?&Hash_Trigraph))
#		(?<Hash_Digraph>            [%] [:] )
#		(?<Hash_Trigraph>           [?] [?] [=] )
#
#		(?<Tilde>                   [~] | (?&Tilde_Trigraph))
#		(?<Tilde_Trigraph>          [?] [?] [-] )
#
#		(?<Vertical_Bar>            [|] | (?&Vertical_Bar_Trigraph))
#		(?<Vertical_Bar_Trigraph>   [?] [?] [!] )
#	))x;

	my $context_INIT_regex = qr (
		(?<C_COMMENT>       (?&C_Comment_Start>))
		| (?<WHITESPACE>    (?&Whitespace>))

		$tokenizer
	)x;

	my %context_INIT = (
		regex         => $context_INIT_regex,
		context_push  => {
			C_COMMENT   => q (C_COMMENT),
		},
	);

	my $context_C_COMMENT_regex = qr (
		(?<C_COMMENT_END>     (?&C_Comment_End))
		| (?<C_COMMENT_CONTENT) (?&C_Comment_Content)
		| (?<NEW_LINE>        (?&New_Line))
		| (?<NEW_LINE_ESCAPE> (?&New_Line_Escape))

		$tokenizer
	)x;

	my %context = (
		INIT      => \ %context_INIT,
		C_COMMENT => \ %context_C_COMMENT,
	);

	sub new {
		my ($class, $data) = @_;

		$data = Path::Tiny::->new ($$data)
			if is_plain_scalarref ($data)
			;

		$data = $data->slurp_utf8
			if $data->$_isa (Path::Tiny::)
			;

		return bless {
			pos     => 0,
			context => q (INIT),
			data    => $data,
			line    => 1,
			column  => 1,
			logical => 1,
			queue   => [ ],
		};
	}

	sub next_token {
		my ($self) = @_;

		while (my $token = $self->_next_raw_token) {
			
	}

	sub _next_raw_token {
		my ($self) = @_;

		pos ($self->{data}) = $self->{pos};
		my $regex = $context{ $self->{context} };

		return
			unless $self->{data} =~ m (\G $regex /xgc)
			;

		$self->{pos} = pos ($self->{data});

		my ($match, $value) = %+;

		my $result = {
			token   => $match,
			match   => $match,
			line    => $self->{line},
			logical => $self->{logical},
			column  => $self->{column},
		};

		$self->{column} += length $match;

		if ($physical_token{$token} & IS_NEWLINE) {
			$self->{line}++;
			$self->{column} = 1;
		}

		if ($physical_token{$token} & IS_LOGICAL_NEWLINE) {
			$self->{logical}++;
		}

		return $result;
	}

	1;
};

