
use v5.14;
use CSI::Common::Sense;

package CSI::Language::C::Lexer v1.0.0 {
	use List::Util ();

	use CSI::Lexer;

	use namespace::clean;

	pattern Digit           => qr ( [0-9] )x;
	pattern Digit_Hex       => qr ( [0-9a-fA-F] )x;
	pattern Identifier_Char => qr ( [0-9a-zA-Z_] )x;
	pattern Exponent        => qr ( [eE] [-+]? (??{ 'Digit' }) )x;
	pattern Suffix_Float    => qr ( [flFL] )x;
	pattern Suffix_Int      => qr ( [luLU] )x;

	token NEW_LINE_ESCAPE   => qr ((?> \\ \n ))x;
	token NEW_LINE          => qr ((?> \n ))x;

	token COMMENT_C         => qr ((?> [/][*] .*? [*][/] ))x;
	token COMMENT_CPP       => qr ((?> [/][/] (?: (?> [^\\\n]+ ) | (?> \\ . )+ )+ ))xsm;
	token LITERAL_DEC       => qr ((?> (?! [0] ) (??{ 'Digit' })+ (??{ 'Suffix_Int' }) \b ))xsm;
	token LITERAL_HEX       => qr ((?> 0 [xX] (??{ 'Digit_Hex' })+ (??{ 'Suffix_Int' }) \b ))xsm;
	token LITERAL_OCT       => qr ((?> 0      (??{ 'Digit' })+     (??{ 'Suffix_Int' }) \b))xsm;
	token LITERAL_CHAR      => qr ((?> [L]? ['] (?: (?> [^\\\n']+ ) | (?> \\ . ) ) ['] ))xsm;
	token LITERAL_STRING    => qr ((?> [L]? ["] (?: (?> [^\\\n"]+ ) | (?> \\ . ) ) ["] ))xsm;
	token LITERAL_FLOAT     => qr ((?>
	 	(?:
			(?> (??{ 'Digit' })+                      (??{ 'Exponent' })  )
		|	(?> (??{ 'Digit' })* [.] (??{ 'Digit' })+ (??{ 'Exponent' })? )
		|	(?> (??{ 'Digit' })+ [.] (??{ 'Digit' })* (??{ 'Exponent' })? )
		)
		(??{ 'Suffix_Float' })*
		`\b
	))xsm;
	token IDENTIFIER        => qr ((?! [0-9]) (?> [a-zA-Z_0-9]+ ))xsm;
	token ELLIPSIS          => qr ((?> [.] [.] [.] ))xsm;
	token RIGHT_ASSIGN      => qr ((?> [>] [>] [=] ))xsm;
	token LEFT_ASSIGN       => qr ((?> [<] [<] [=] ))xsm;
	token ADD_ASSIGN        => qr ((?> [+] [=] ))xsm;
	token SUB_ASSIGN        => qr ((?> [-] [=] ))xsm;
	token MUL_ASSIGN        => qr ((?> [*] [=] ))xsm;
	token DIV_ASSIGN        => qr ((?> [/] [=] ))xsm;
	token MOD_ASSIGN        => qr ((?> [%] [=] ))xsm;
	token AND_ASSIGN        => qr ((?> [&] [=] ))xsm;
	token XOR_ASSIGN        => qr ((?> [\^] [=] ))xsm;
	token OR_ASSIGN         => qr ((?> [|] [=] ))xsm;
	token RIGHT_OP          => qr ((?> [>] [>] ))xsm;
	token LEFT_OP           => qr ((?> [<] [<] ))xsm;
	token INC_OP            => qr ((?> [+] [+] ))xsm;
	token DEC_OP            => qr ((?> [-] [-] ))xsm;
	token PTR_OP            => qr ((?> [-] [>] ))xsm;
	token AND_OP            => qr ((?> [&] [&] ))xsm;
	token OR_OP             => qr ((?> [|] [|] ))xsm;
	token LE_OP             => qr ((?> [<] [=] ))xsm;
	token GE_OP             => qr ((?> [>] [=] ))xsm;
	token EQ_OP             => qr ((?> [=] [=] ))xsm;
	token NE_OP             => qr ((?> [!] [=] ))xsm;
	token SEMICOLON         => qr ((?> [;] ))xsm;
	token BRACE_LEFT        => qr ((?> [{]  | (?: [<] [%] ) ))xsm;
	token BRACE_RIGHT       => qr ((?> [}]  | (?: [%] [>] ) ))xsm;
	token BRACKET_LEFT      => qr ((?> [\[] | (?: [<] [:] ) ))xsm;
	token BRACKET_RIGHT     => qr ((?> [\]] | (?: [:] [>] ) ))xsm;
	token PAREN_LEFT        => qr ((?> [\(] ))xsm;
	token PAREN_RIGHT       => qr ((?> [\)] ))xsm;
	token COMMA             => qr ((?> [,] ))xsm;
	token COLON             => qr ((?> [:] ))xsm;
	token EQUAL             => qr ((?> [=] ))xsm;
	token DOT               => qr ((?> [.] ))xsm;
	token AMPERSAND         => qr ((?> [&] ))xsm;
	token EXCLAMATION       => qr ((?> [!] ))xsm;
	token TILDE             => qr ((?> [~] ))xsm;
	token MINUS             => qr ((?> [-] ))xsm;
	token PLUS              => qr ((?> [+] ))xsm;
	token ASTERISK          => qr ((?> [*] ))xsm;
	token SOLIDUS           => qr ((?> [/] ))xsm;
	token PERCENT           => qr ((?> [%] ))xsm;
	token LESS_THAN         => qr ((?> [<] ))xsm;
	token GREATER_THAN      => qr ((?> [>] ))xsm;
	token CIRCUMFLEX        => qr ((?> [\^] ))xsm;
	token VERTICAL_BAR      => qr ((?> [|] ))xsm;
	token QUESTION_MARK     => qr ((?> [?] ))xsm;
	token WHITESPACE        => qr ((?> [^\S\n]+ ))xsm;
	token PP_CONCAT         => qr ((?> [#] [#] ))xsm;
	token PP_HASH           => qr ((?> [#] ))xsm;
	token PP_STRING         => qr ((?> [#] ))xsm;

	1;
};

__END__
	sub next_token {
		my ($self) = @_;

		my $raw_token = $self->_next_raw_token;
		return unless ref $raw_token;
		my ($name, $match) = %$raw_token;

		return +{
			token => $name,
			match => $match,
		};
	}

	sub _next_raw_token {
		my ($self) = @_;

		return +{ %+ }
			if ${ $self->{data} } =~ m (
				\G

			  (?<COMMENT_C>           (?: [/][*] .*? [*][/] ))
			| (?<COMMENT_CPP>         (?: [/][/] (?: .*? [\\][\n])* .*? [\n] ))
			| (?<LITERAL_HEX>         (?: (?> [0]      [xX] (?&Hex_Digit)+ (?&Suffix_Int)) ))
			| (?<LITERAL_OCT>         (?: (?> [0]      (?&Digit)+          (?&Suffix_Int)) ))
			| (?<LITERAL_DEC>         (?: (?> (?! [0]) (?&Digit)+          (?&Suffix_Int)) ))
			| (?<LITERAL_CHAR>        (?: [L]? ['] (?: [^\\'] | [\\] [\\'] ) ['] ))
			| (?<LITERAL_STRING>      (?: [L]? ["] (?: (?> [^\\"]+ | [\\] . )* ["]) ))
			| (?<LITERAL_FLOAT>       (?:
				(?:
					(?&No_Match)
				| (?> (?&Digit)+                (?&Exponent)  )
				| (?> (?&Digit)* [.] (?&Digit)+ (?&Exponent)? )
				| (?> (?&Digit)+ [.] (?&Digit)* (?&Exponent)? )
				)
				(?&Suffix_Float)*
			))
			| (?<IDENTIFIER>          (?! [0-9]) (?> [a-zA-Z_0-9]+ ))
			| (?<ELLIPSIS>            (?> [.] [.] [.] ))
			| (?<RIGHT_ASSIGN>        (?> [>] [>] [=] ))
			| (?<LEFT_ASSIGN>         (?> [<] [<] [=] ))
			| (?<ADD_ASSIGN>          (?> [+] [=] ))
			| (?<SUB_ASSIGN>          (?> [-] [=] ))
			| (?<MUL_ASSIGN>          (?> [*] [=] ))
			| (?<DIV_ASSIGN>          (?> [/] [=] ))
			| (?<MOD_ASSIGN>          (?> [%] [=] ))
			| (?<AND_ASSIGN>          (?> [&] [=] ))
			| (?<XOR_ASSIGN>          (?> [\^] [=] ))
			| (?<OR_ASSIGN>           (?> [|] [=] ))
			| (?<RIGHT_OP>            (?> [>] [>] ))
			| (?<LEFT_OP>             (?> [<] [<] ))
			| (?<INC_OP>              (?> [+] [+] ))
			| (?<DEC_OP>              (?> [-] [-] ))
			| (?<PTR_OP>              (?> [-] [>] ))
			| (?<AND_OP>              (?> [&] [&] ))
			| (?<OR_OP>               (?> [|] [|] ))
			| (?<LE_OP>               (?> [<] [=] ))
			| (?<GE_OP>               (?> [>] [=] ))
			| (?<EQ_OP>               (?> [=] [=] ))
			| (?<NE_OP>               (?> [!] [=] ))
			| (?<SEMICOLON>           (?> [;] ))
			| (?<BRACE_LEFT>          (?> [{]  | (?: [<] [%] ) ))
			| (?<BRACE_RIGHT>         (?> [}]  | (?: [%] [>] ) ))
			| (?<BRACKET_LEFT>        (?> [\[] | (?: [<] [:] ) ))
			| (?<BRACKET_RIGHT>       (?> [\]] | (?: [:] [>] ) ))
			| (?<PAREN_LEFT>          (?> [\(] ))
			| (?<PAREN_RIGHT>         (?> [\)] ))
			| (?<COMMA>               (?> [,] ))
			| (?<COLON>               (?> [:] ))
			| (?<EQUAL>               (?> [=] ))
			| (?<DOT>                 (?> [.] ))
			| (?<AMPERSAND>           (?> [&] ))
			| (?<EXCLAMATION>         (?> [!] ))
			| (?<TILDE>               (?> [~] ))
			| (?<MINUS>               (?> [-] ))
			| (?<PLUS>                (?> [+] ))
			| (?<ASTERISK>            (?> [*] ))
			| (?<SOLIDUS>             (?> [/] ))
			| (?<PERCENT>             (?> [%] ))
			| (?<LESS_THAN>           (?> [<] ))
			| (?<GREATER_THAN>        (?> [>] ))
			| (?<CIRCUMFLEX>          (?> [\^] ))
			| (?<VERTICAL_BAR>        (?> [|] ))
			| (?<QUESTION_MARK>       (?> [?] ))
			| (?<WHITESPACE>          (?> [ \t\f]+ ))
			| (?<NEW_LINE>            (?> [\n] ))
			| (?<PREPROCESSOR_CONCAT> (?> [#] [#] ))
			| (?<PREPROCESSOR_DIRECTIVE> (?> ^ [#] ))
			| (?<PREPROCESSOR_STRING> (?> [#] ))
			| (?<UNRECOGNIZED>        . )

				((DEFINE)
					(?<Digit>           (?: [0-9]                   ))
					(?<Hex_Digit>       (?: [a-fA-F0-9]             ))
					(?<Identifier_Char> (?: [a-zA-Z_0-9]            ))
					(?<Exponent>        (?: [eE] [-+]? (?&Digit)+   ))
					(?<Suffix_Float>    (?: [flFL]                  ))
					(?<Suffix_Int>      (?: [luLU]                  ))
					(?<No_Match>        (?: \b \B                   ))
				)
			)xsmgc;
	}

	1;
;
}


