
use v5.14;
use CSI::Common::Sense;

package CSI::Language::C::Lexer v1.0.0 {
	use Path::Tiny;
	use Ref::Util qw (is_plain_scalarref);
	use Safe::Isa qw ($_isa);

	use namespace::clean;

	our $tokenizer = qr (
		  (?> (?<WHITESPACE>        [^\S\n]+                    ))
		| (?> (?<NEW_LINE>          [\n]                        ))
		| (?> (?<NEW_LINE_ESCAPE>   [\\] [\n]                   ))
		| (?> (?<C_COMMENT>         [/] [*] (?s:.)*? [*] [/]    ))
		| (?> (?<CPP_COMMENT>       [/] [/] .*                  ))
#		| (?> (?<DOUBLE_HASH>       [#] [#]                     ))
		| (?> (?<IDENTIFIER>        (?! [0-9] ) [0-9a-zA-Z_]+   ))
		| (?> (?<STRING>            [\"] (?: [^\\\"]+ | (?: [\\] . )+)* ["] ))
		| (?> (?<CHARACTER>         [\'] [\\]? . [']            ))
		| (?> (?<LITERAL_DECIMAL>   (?! 0 \B) [0-9]+ \b         ))
#		| (?> (?<LITERAL_HEX>       [0] [xX] [a-fA-F0-9]+ \b    ))

		# Punctuations
		| (?> (?<AMPERSAND>         [&]                         ))
		| (?> (?<ASTERISK>          [*]                         ))
		| (?> (?<BRACE_CLOSE>       [\}]                        ))
		| (?> (?<BRACE_OPEN>        [\{]                        ))
		| (?> (?<BRACKET_CLOSE>     [\]]                        ))
		| (?> (?<BRACKET_OPEN>      [\[]                        ))
		| (?> (?<CARET>             [\^]                        ))
		| (?> (?<COLON>             [:]                         ))
		| (?> (?<COMMA>             [,]                         ))
		| (?> (?<DOT>               [.]                         ))
		| (?> (?<EQUALS_SIGN>       [=]                         ))
		| (?> (?<HASH>              [#]                         ))
		| (?> (?<EXCLAMATION_MARK>  [!]                         ))
		| (?> (?<GREATER_THAN>      [>]                         ))
		| (?> (?<LESS_THAN>         [<]                         ))
		| (?> (?<MINUS>             [-]                         ))
		| (?> (?<PAREN_CLOSE>       [\)]                        ))
		| (?> (?<PAREN_OPEN>        [\(]                        ))
		| (?> (?<PERCENT>           [%]                         ))
		| (?> (?<PLUS>              [+]                         ))
		| (?> (?<QUESTION_MARK>     [?]                         ))
		| (?> (?<SEMICOLON>         [;]                         ))
		| (?> (?<SOLIDUS>           [/]                         ))
		| (?> (?<TILDE>             [~]                         ))
		| (?> (?<VERTICAL_BAR>      [|]                         ))
	)x;

	sub tokenize {
		my ($self, $data) = @_;

		my @list;
		my ($line, $logical, $column) = (1, 1, 1);

		pos ($data) = 0;

		my $counter = 0;
		while ($data =~ m (\G $tokenizer )xgc) {
			my ($token, $match) = %+;

			push @list, {
				token   => $token,
				match   => $match,
				line    => $line,
				logical => $logical,
				column  => $column,
			};

			say qq (${line}:${column}: ${token} : ), substr ($match, 0, 32) =~ s ([\n]) (\\n)gr;

			$column += length $match;

			while ($match =~ m ( [\\] [\n] )xg) {
				$logical++;
			}

			while ($match =~ m ( [\n] (.*) )xg) {
				$line++;
				$column = 1 + length $1;
			}

			return if $line > 283;
		}

		my $pos = pos ($data);
		if ($data =~ m (\G .)xgc) {
			say STDERR qq (Cannot continue at line ${line}:${column}: '), substr ($data, $pos, 32) =~ s ([\n]) (\\n)gr =~ s ([']) (\\')gr, q (');
		}

		return @list;
	}

	1;
}

__END__

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

	my %keywords = map { $_ => 1 } qw (
		auto
		break
		case
		char
		const
		continue
		default
		do
		double
		else
		enum
		extern
		float
		for
		goto
		if
		int
		long
		register
		return
		short
		signed
		sizeof
		static
		struct
		switch
		typedef
		union
		unsigned
		void
		volatile
		while
	);

	my $tokenize = qr (
		# Whitespaces
		  (?> (?<WHITESPACE>        [^\S\n]+ ))
		| (?> (?<NEW_LINE>          [\n] ))
		| (?> (?<NEW_LINE_ESCAPE>   (?&Backslash) [\n] ))

		# Numbers
		| (?> (?<DIGIT_ZERO>          [0] ))
		| (?> (?<DIGITS_BINARY>       (?! [0] )               (?&Digit_Binary)+  \b ))
		| (?> (?<DIGITS_OCTAL>        (?! (?&Digit_Binary)  ) (?&Digit_Octal)+   \b ))
		| (?> (?<DIGITS_DECIMAL>      (?! (?&Digit_Octal)   ) (?&Digit_Decimal)+ \b ))
		| (?> (?<DIGITS_HEX>          (?! (?&Digit_Decimal) ) (?&Digit_Hex)+     \b ))

		# Used as radix identifiers
		| (?<LETTER_B>            [bB] (?! (?&Identifier_Char) (?<! (?&Digit_Binary) )))
		| (?<LETTER_X>            [xX] (?! (?&Identifier_Char) (?<! (?&Digit_Hex)    )))

		# Used as numeric suffixes
		| (?<LETTER_L>            [lL] )
		| (?<LETTER_Z>            [zZ] )
		| (?<LETTER_F>            [fF] )

		# Used as numeric suffix or string literal prefix
		| (?<LETTER_U>            [uU] (?! (?&Identifier_Char) (?<! (?&Suffix_Number) | (?&Digit_Decimal) )))

		# Used as integer suffix - i8, i16
		| (?<LETTER_I>            [iI] (?! (?&Identifier_Char) (?<! (?&Digit_Decimal) )))

		# Raw string
		| (?<LETTER_R>            [rR] \b )

		| (?<IDENTIFIER>          (?&Identifier_Char)+ )

		# Punctuation characters
		| (?<AMPERSAND>             [&] )
		| (?<APOSTROPHE>            ['] )
		| (?<ASTERISK>              [*] )
		| (?<BACKSLASH>             (?&Backslash) (?! [\n] ))
		| (?<BRACE_CLOSE>           (?&Brace_Close) )
		| (?<BRACE_OPEN>            (?&Brace_Open) )
		| (?<BRACKET_CLOSE>         (?&Bracket_Close) )
		| (?<BRACKET_OPEN>          (?&Bracket_Open) )
		| (?<CARET>                 (?&Caret) )
		| (?<COLON>                 (?&Colon) )
		| (?<COMMA>                 [,] )
		| (?<DOT>                   [.] )
		| (?<EQUALS_SIGN>           [=] )
		| (?<EXCLAMATION_MARK>      [!] )
		| (?<GREATER_THAN>          [>] )
		| (?<HASH>                  (?&Hash) )

		| (?<Unknown> .)

	((DEFINE)
		(?<Digit_Binary>            [0-1] )
		(?<Digit_Octal>             [0-7] )
		(?<Digit_Decimal>           [0-9] )
		(?<Digit_Hex>               [0-9a-fA-F] )
		(?<Suffix_Number>           [fluzFLUZ] )
		(?<Identifier_Char>         [a-zA-Z0-9_])

		(?<Not_An_Identifier>       (?!
			(?&Digit_Hex)
			| (?&LETTER_B)
			| (?&LETTER_F)
			| (?&LETTER_I)
			| (?&LETTER_L)
			| (?&LETTER_R)
			| (?&LETTER_U)
			| (?&LETTER_Z)
			| (?&LETTER_X)
		))

		# n-graphs start characters not starting n-graph
		# n-graphs are expanded before recognizing NEW_LINE_ESCAPE
		# so we can use simple negative lookahead

		(?<Colon>                   [:] (?! [>] ))
		(?<Less_Than>               [<] (?! [:%] ))
		(?<Percent>                 [%] (?! [:>] ))
		(?<Question_Mark>           [?] (?! [?] ))

		(?<Brace_Open>              [\{] | (?&Brace_Open_Digraph) | (?&Brace_Open_Trigraph))
		(?<Brace_Open_Digraph>      [<] [%] )
		(?<Brace_Open_Trigraph>     [?] [?] [<] )

		(?<Brace_Close>             [\}] | (?&Brace_Close_Digraph) | (?&Brace_Close_Trigraph))
		(?<Brace_Close_Digraph>     [%] [>] )
		(?<Brace_Close_Trigraph>    [?] [?] [>] )

		(?<Bracket_Open>            [\[] | (?&Bracket_Open_Digraph) | (?&Bracket_Open_Trigraph))
		(?<Bracket_Open_Digraph>    [<] [:] )
		(?<Bracket_Open_Trigraph>   [?] [?] [\(] )

		(?<Bracket_Close>           [\]] | (?&Bracket_Close_Digraph) | (?&Bracket_Close_Trigraph))
		(?<Bracket_Close_Digraph>   [:] [>] )
		(?<Bracket_Close_Trigraph>  [?] [?] [\)] )

		(?<Backslash>               [\\] | (?&Backslash_Trigraph))
		(?<Backslash_Trigraph>      [?] [?] [/] )

		(?<Caret>                   [\^] | (?&Caret_Trigraph))
		(?<Caret_Trigraph>          [?] [?] [\'] )

		(?<Hash>                    [\#] | (?&Hash_Digraph) | (?&Hash_Trigraph))
		(?<Hash_Digraph>            [%] [:] )
		(?<Hash_Trigraph>           [?] [?] [=] )

		(?<Tilde>                   [~] | (?&Tilde_Trigraph))
		(?<Tilde_Trigraph>          [?] [?] [-] )

		(?<Vertical_Bar>            [|] | (?&Vertical_Bar_Trigraph))
		(?<Vertical_Bar_Trigraph>   [?] [?] [!] )
	))x;


	sub new {
		my ($class, $data) = @_;

		$data = Path::Tiny::->new ($$data)
			if is_plain_scalarref ($data)
			;

		$data = $data->slurp_utf8
			if $data->$_isa (Path::Tiny::)
			;

		return bless {
			tokens => [ $class->_raw_tokens ($data) ],
		};
	}

	sub next_token {
		my ($self) = @_;

		shift @{ $self->{tokens} };
	}

	1;
};

