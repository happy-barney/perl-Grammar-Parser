
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Language::Java::Grammar v1.0.0 {
	use CSI::Grammar v1.0.0
		{
			default_rule_action  => 'pass_through',
			default_token_action => 'pass_through',
			action_lookup        => 'CSI::Language::Java::Actions',
			dom_prefix           => 'CSI::Language::Java',
		},
	;

	sub word {
		my ($keyword, @opts) = @_;
		$keyword = ucfirst lc $keyword;
		my $re = qr/ (?> \b ${\ lc $keyword } (?! (??{ 'Identifier_Character' }) ) ) /sx;

		my @dom   = (dom => "::Token::Word::$keyword");
		my @proto = (proto => 'Prohibited_Identifier');
		my @group = (group => 'keyword');

		while (@opts) {
			my $key   = shift @opts;
			my $value = shift @opts;

			goto $key;

			dom:
			$dom[1] = $value;
			next;

			group:
			push @group, group => $value unless $value eq $group[1];
			next;

			proto:
			push @proto, proto => $value unless $value eq $proto[1];
			next;
		}

		$dom[1] =~ s/^::/CSI::Language::Java::/;

		token uc $keyword => @proto, @group, $re;
		rule  lc $keyword => @dom, [ uc $keyword ]
			unless $keyword eq '_';
	}

	sub operator {
		my ($name, $dom, @params) = @_;

		my $code = Ref::Util::is_plain_arrayref ($params[-1])
			? \& rule
			: \& token
			;

		$dom =~ s/^::/CSI::Language::Java::/;

		$code->($name, dom => $dom, @params);
	}


	start rule TOP                          => dom => 'CSI::Document',
		[qw[  compilation_unit  ]],
		[],
		;

	regex Identifier_Character              => qr/(?>
		[_\p{Letter}\p{Letter_Number}\p{Digit}\p{Currency_Symbol}]
	)/sx;

	insignificant token whitespaces         => dom => 'CSI::Language::Java::Token::Whitespace',
		qr/(?>
			\s+
		)/sx;

	insignificant token comment_c           => dom => 'CSI::Language::Java::Token::Comment::C',
		qr/(?>
			\/\*
			(?! \* [^*] )
			.*?
			\*\/
		)/sx;

	insignificant token comment_cpp         => dom => 'CSI::Language::Java::Token::Comment::Cpp',
		qr/(?>
			\/\/
			\V*
		)/sx;

	insignificant token comment_javadoc     => dom => 'CSI::Language::Java::Token::Comment::Javadoc',
		qr/(?>
			\/\*
			(?= \* [^*] )
			.*?
			\*\/
		)/sx;

	token IDENTIFIER                        =>
        qr/(?>
			(?! \p{Digit} )
			(?! (??{ 'Prohibited_Identifier' }) (?! (??{ 'Identifier_Character' }) ) )
			(?<value> (??{ 'Identifier_Character' })+ )
		) /sx;

	token ANNOTATION                        => dom => 'CSI::Language::Java::Token::Annotation'      => '@';
	token BRACE_CLOSE                       => dom => 'CSI::Language::Java::Token::Brace::Close'    => '}';
	token BRACE_OPEN                        => dom => 'CSI::Language::Java::Token::Brace::Open'     => '{';
	token BRACKET_CLOSE                     => dom => 'CSI::Language::Java::Token::Bracket::Close'  => ']';
	token BRACKET_OPEN                      => dom => 'CSI::Language::Java::Token::Bracket::Open'   => '[';
	token COLON                             => dom => 'CSI::Language::Java::Token::Colon'           => qr/ : (?! : )/sx;
	token COMMA                             => dom => 'CSI::Language::Java::Token::Comma'           => ',';
	token DOUBLE_COLON                      => dom => 'CSI::Language::Java::Token::Double::Colon'   => '::';
	token DOT                               => dom => 'CSI::Language::Java::Token::Dot'             => qr/ \. (?! [.[:digit:]] )/sx;
	token ELIPSIS                           => dom => 'CSI::Language::Java::Token::Elipsis'         => '...';
	token PAREN_CLOSE                       => dom => 'CSI::Language::Java::Token::Paren::Close'    => ')';
	token PAREN_OPEN                        => dom => 'CSI::Language::Java::Token::Paren::Open'     => '(';
	token QUESTION_MARK                     => dom => 'CSI::Language::Java::Token::Question::Mark'  => '?';
	token SEMICOLON                         => dom => 'CSI::Language::Java::Token::Semicolon'       => ';';
	token TOKEN_ASTERISK                    => qr/ \* (?! [=] )/sx;
	token TOKEN_GT_AMBIGUOUS                => qr/ > (?= > ) (?! >{1,2} = ) /sx;
	token TOKEN_GT_FINAL                    => qr/ > (?! [>=] ) /sx;
	token TOKEN_LT                          => qr/ < (?! < | = | <= )/sx;
	token TOKEN_PLUS                        => qr/ \+ (?! [=]  ) (?= (?: \+ \+ )* (?! \+ ) )/sx;
	token TOKEN_MINUS                       => qr/  - (?! [=>] ) (?= (?:  -  - )* (?!  - ) )/sx;
	operator ADDITION                       => '::Operator::Addition'                       => [qw[  TOKEN_PLUS  ]];
	operator ASSIGN                         => '::Operator::Assign'                         => qr/ = (?! [=] )/sx;
	operator ASSIGN_ADDITION                => '::Operator::Assign::Addition'               => '+=';
	operator ASSIGN_BINARY_AND              => '::Operator::Assign::Binary::And'            => '&=';
	operator ASSIGN_BINARY_OR               => '::Operator::Assign::Binary::Or'             => '|=';
	operator ASSIGN_BINARY_SHIFT_LEFT       => '::Operator::Assign::Binary::Shift::Left'    => '<<=';
	operator ASSIGN_BINARY_SHIFT_RIGHT      => '::Operator::Assign::Binary::Shift::Right'   => '>>=';
	operator ASSIGN_BINARY_USHIFT_RIGHT     => '::Operator::Assign::Binary::UShift::Right'  => '>>>=';
	operator ASSIGN_BINARY_XOR              => '::Operator::Assign::Binary::Xor'            => '^=';
	operator ASSIGN_DIVISION                => '::Operator::Assign::Division'               => '/=';
	operator ASSIGN_MODULUS                 => '::Operator::Assign::Modulus'                => '%=';
	operator ASSIGN_MULTIPLICATION          => '::Operator::Assign::Multiplication'         => '*=';
	operator ASSIGN_SUBTRACTION             => '::Operator::Assign::Subtraction'            => '-=';
	operator BINARY_AND                     => '::Operator::Binary::And'                    => qr/ & (?! [&=] )/sx;
	operator BINARY_COMPLEMENT              => '::Operator::Binary::Complement'             => '~';
	operator BINARY_OR                      => '::Operator::Binary::Or'                     => qr/ \| (?! [|=] )/sx;
	operator BINARY_SHIFT_LEFT              => '::Operator::Binary::Shift::Left'            => qr/ << (?! [=] )/sx;
	operator BINARY_SHIFT_RIGHT             => '::Operator::Binary::Shift::Right'           => [qw[  TOKEN_GT_AMBIGUOUS  TOKEN_GT_FINAL  ]];
	operator BINARY_USHIFT_RIGHT            => '::Operator::Binary::UShift::Right'          => [qw[  TOKEN_GT_AMBIGUOUS  TOKEN_GT_AMBIGUOUS  TOKEN_GT_FINAL  ]];
	operator BINARY_XOR                     => '::Operator::Binary::Xor'                    => qr/ \^ (?! [=] )/sx;
	operator CMP_EQUALITY                   => '::Operator::Equality'                       => '==';
	operator CMP_GREATER_THAN               => '::Operator::Greater'                        => [qw[  TOKEN_GT_FINAL ]];
	operator CMP_GREATER_THAN_OR_EQUAL      => '::Operator::Greater::Equal'                 => '>=';
	operator CMP_INEQUALITY                 => '::Operator::Inequality'                     => '!=';
	operator CMP_LESS_THAN                  => '::Operator::Less'                           => [qw[  TOKEN_LT  ]];
	operator CMP_LESS_THAN_OR_EQUAL         => '::Operator::Less::Equal'                    => '<=';
	operator DECREMENT                      => '::Operator::Decrement'                      => qr/  -  - (?= (?:  -  - )* (?!  - ) )/sx;
	operator DIVISION                       => '::Operator::Division'                       => qr/ \/ (?! [\/*=] )/sx;
	operator INCREMENT                      => '::Operator::Increment'                      => qr/ \+ \+ (?= (?: \+ \+ )* (?! \+ ) )/sx;
	operator LAMBDA                         => '::Operator::Lambda'                         => '->';
	operator LOGICAL_AND                    => '::Operator::Logical::And'                   => '&&';
	operator LOGICAL_COMPLEMENT             => '::Operator::Logical::Complement'            => qr/ ! (?! [=]) /sx;
	operator LOGICAL_OR                     => '::Operator::Logical::Or'                    => '||';
	operator MODULUS                        => '::Operator::Modulus'                        => qr/  % (?! [=] )/sx;
	operator MULTIPLICATION                 => '::Operator::Multiplication'                 => [qw[  TOKEN_ASTERISK  ]];
	operator SUBTRACTION                    => '::Operator::Subtraction'                    => [qw[  TOKEN_MINUS  ]];
	operator UNARY_MINUS                    => '::Operator::Unary::Minus'                   => [qw[  TOKEN_MINUS  ]];
	operator UNARY_PLUS                     => '::Operator::Unary::Plus'                    => [qw[  TOKEN_PLUS  ]];
	word  ABSTRACT                          => ;
	word  ASSERT                            => ;
	word  BOOLEAN                           => ;
	word  BREAK                             => ;
	word  BYTE                              => ;
	word  CASE                              => ;
	word  CATCH                             => ;
	word  CHAR                              => ;
	word  CLASS                             => ;
	word  CONST                             => ;
	word  CONTINUE                          => ;
	word  DEFAULT                           => ;
	word  DO                                => ;
	word  DOUBLE                            => ;
	word  ELSE                              => ;
	word  ENUM                              => ;
	word  EXPORTS                           => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  EXTENDS                           => ;
	word  FALSE                             => ;
	word  FINAL                             => ;
	word  FINALLY                           => ;
	word  FLOAT                             => ;
	word  FOR                               => ;
	word  GOTO                              => ;
	word  IF                                => ;
	word  IMPLEMENTS                        => ;
	word  IMPORT                            => ;
	word  INSTANCEOF                        => ;
	word  INT                               => ;
	word  INTERFACE                         => ;
	word  LONG                              => ;
	word  MODULE                            => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  NATIVE                            => ;
	word  NEW                               => ;
	word  NULL                              => ;
	word  OPEN                              => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  OPENS                             => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  PACKAGE                           => ;
	word  PRIVATE                           => ;
	word  PROTECTED                         => ;
	word  PROVIDES                          => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  PUBLIC                            => ;
	word  REQUIRES                          => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  RETURN                            => ;
	word  SHORT                             => ;
	word  STATIC                            => ;
	word  STRICTFP                          => ;
	word  SUPER                             => ;
	word  SWITCH                            => ;
	word  SYNCHRONIZED                      => ;
	word  THIS                              => ;
	word  THROW                             => ;
	word  THROWS                            => ;
	word  TO                                => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  TRANSIENT                         => ;
	word  TRANSITIVE                        => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  TRUE                              => ;
	word  TRY                               => ;
	word  USES                              => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  VAR                               => group => 'keyword_identifier';
	word  VOID                              => ;
	word  VOLATILE                          => ;
	word  WHILE                             => ;
	word  WITH                              => group => 'keyword_identifier', group => 'keyword_type_identifier';
	word  _                                 => ;

	1;
};

__END__
	sub Decimal_Numeral             :REGEX {
		qr/(?>
			(?! 0 [_[:digit:]] )
			(?= [[:digit:]])
			[_[:digit:]]+
			(?<= [[:digit:]])
		)/sx;
	}

	sub Hex_Numeral                 :REGEX {
		qr/(?>
			0 [xX]
			[_[:xdigit:]]+
			(?<= [[:xdigit:]])
		)/sx;
	}

	sub Octal_Numeral               :REGEX {
		qr/(?>
			0
			[_0-7]+
			(?<= [0-7])
		)/sx;
	}

	sub Binary_Numeral              :REGEX {
		qr/(?>
			0 [bB]
			[_01]+
			(?<= [01])
		)/sx;
	}

	sub Integer_Type_Suffix         :REGEX {
		qr/
			[lL]
		/sx;
	}

	sub Escape_Sequence             :REGEX {
		qr/(?>
			\\
			(?:
				  (?<char_escape> (?: [btnrf\'\"\\] ))
				| (?<octal_escape> (?: (?= [0-7]) [0-3]? [0-7]{1,2} ))
				| (?: u+ (?<hex_escape> [[:xdigit:]]{4} ))
			)
		)/sx;
	}

	sub LITERAL_INTEGER             :TOKEN :TRANSFORM(integer_value) :ACTION_LITERAL_VALUE {
		qr/(?>
			(?:
				  (?<decimal_value> (??{ 'Decimal_Numeral' }) )
				| (?<hex_value>     (??{ 'Hex_Numeral'     }) )
				| (?<octal_value>   (??{ 'Octal_Numeral'   }) )
				| (?<binary_value>  (??{ 'Binary_Numeral'  }) )
			)
			(?<type_suffix> (??{ 'Integer_Type_Suffix' }) )?
			\b
		)/sx;
	}

	sub LITERAL_CHARACTER           :TOKEN :ACTION_LITERAL_VALUE {
		qr/(?>
			\'
			(?<value> [^\'\\] | (??{ 'Escape_Sequence' }) )
			\'
		)/sx;
	}

	sub LITERAL_STRING              :TOKEN :ACTION_LITERAL_VALUE {
		qr/(?>
			\"
			(?<value> (?: [^\"\\] | (??{ 'Escape_Sequence' }) )* )
			\"
		)/sx;

	sub TYPE_PARAMETER_LIST_OPEN    :TOKEN {
		'<'
	}

	sub TYPE_PARAMETER_LIST_CLOSE   :TOKEN {
		'>'
	}

	1;
};

1;

