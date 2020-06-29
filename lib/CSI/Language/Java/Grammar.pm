
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

	use Ref::Util;

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

	regex Binary_Exponent                   => qr/(?>
		[pP]
	)/sx;

	regex Binary_Numeral                    => qr/(?>
		0 [bB]
		[_01]+
		(?<= [01])
	)/sx;

	regex Decimal_Numeral                   => qr/(?>
		(?! 0 [_[:digit:]] )
		(?= [[:digit:]])
		[_[:digit:]]+
		(?<= [[:digit:]])
	)/sx;

	regex Escape_Sequence                   => qr/(?>
		\\
		(?:
			  (?<char_escape> (?: [btnrf\'\"\\] ))
			| (?<octal_escape> (?: (?= [0-7]) [0-3]? [0-7]{1,2} ))
			| (?: u+ (?<hex_escape> [[:xdigit:]]{4} ))
		)
	)/sx;

	regex Exponent_Part                     => qr/(?>
		[eE]
		[+-]?
		(??{ 'Decimal_Numeral' })
	)/sx;

	regex Floating_Type_Suffix              => qr/(?>
		[fFdD]
	)/sx;

	regex Hex_Digits                        => qr/(?>
		(?! _ )
		[_[:xdigit:]]+
		(?<! _)
	)/sx;

	regex Hex_Numeral                       => qr/(?>
		(??{ 'Hex_Prefix' })
		(??{ 'Hex_Digits' })
	)/sx;

	regex Hex_Prefix                        => qr/(?>
		0 [xX]
	)/sx;

	regex Identifier_Character              => qr/(?>
		[_\p{Letter}\p{Letter_Number}\p{Digit}\p{Currency_Symbol}]
	)/sx;

	regex Integral_Type_Suffix              => qr/(?>
		[lL]
	)/sx;

	regex Octal_Numeral                     => qr/(?>
		0
		[_0-7]+
		(?<= [0-7])
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

	token LITERAL_CHARACTER                 => action => 'literal_unescape',
		qr/(?>
			\'
			(?<value> [^\'\\] | (??{ 'Escape_Sequence' }) )
			\'
		)/sx;

	token LITERAL_FLOAT_DECIMAL             => action => 'float_value',
		qr/(?>
			(?:
				(?<value>
					(?= \.? [[:digit:]] )
					(??{ 'Decimal_Numeral' })?
					\.
					0* (??{ 'Decimal_Numeral' }) ?
					(??{ 'Exponent_Part'   }) ?
					(?<type_suffix> (??{ 'Floating_Type_Suffix' }) ) ?
				)
			)
			|
			(?:
				(?<value>
					(??{ 'Decimal_Numeral' })
					(??{ 'Exponent_Part'   })
					(?<type_suffix> (??{ 'Floating_Type_Suffix' }) ) ?
				)
			)
			|
			(?:
				(?<value>
					(??{ 'Decimal_Numeral' })
					(??{ 'Exponent_Part'   }) ?
					(?<type_suffix> (??{ 'Floating_Type_Suffix' }) )
				)
			)
		)/sx;

	token LITERAL_FLOAT_HEX                 => action => 'float_value',
		qr/(?>
			(?<hex_value>
				(?: (??{ 'Hex_Numeral' }) \.? )
			|   (?: (??{ 'Hex_Prefix' }) (??{ 'Hex_Digits' })? \. (??{ 'Hex_Digits' }) )
			)
			(??{ 'Binary_Exponent' })
			(?<binary_exponent>
				[+-]? (??{ 'Decimal_Numeral' })
			)
			(?<type_suffix> (??{ 'Floating_Type_Suffix' }) ) ?
		)/sx;

	token LITERAL_INTEGRAL_BINARY           => action => 'integral_value',
		qr/(?>
			(?<binary_value>  (??{ 'Binary_Numeral'  }) )
			(?<type_suffix>   (??{ 'Integral_Type_Suffix' }) )?
			\b
		)/sx;

	token LITERAL_INTEGRAL_DECIMAL          => action => 'integral_value',
		qr/(?>
			(?<decimal_value> (??{ 'Decimal_Numeral' }) ) (?! \. )
			(?<type_suffix>   (??{ 'Integral_Type_Suffix' }) )?
			\b
		)/sx;

	token LITERAL_INTEGRAL_HEX              => action => 'integral_value',
		qr/(?>
			(?<hex_value>     (??{ 'Hex_Numeral'     }) )
			(?<type_suffix>   (??{ 'Integral_Type_Suffix' }) )?
			\b
			(?! \. )
		)/sx;

	token LITERAL_INTEGRAL_OCTAL            => action => 'integral_value',
		qr/(?>
			(?<octal_value>   (??{ 'Octal_Numeral'   }) )
			(?<type_suffix>   (??{ 'Integral_Type_Suffix' }) )?
			\b
		)/sx;

	token LITERAL_STRING                    => action => 'literal_unescape',
		qr/(?>
			\"
			(?<value> (?: [^\"\\\r\n] | (??{ 'Escape_Sequence' }) )* )
			\"
		)/sx;

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

	ensure_rule_name_order;

	rule  TYPE_LIST_CLOSE                   => dom => 'CSI::Language::Java::Token::Type::List::Close',
		[qw[  TOKEN_GT_AMBIGUOUS  ]],
		[qw[  TOKEN_GT_FINAL      ]],
		;

	rule  TYPE_LIST_OPEN                    => dom => 'CSI::Language::Java::Token::Type::List::Open',
		[qw[  TOKEN_LT  ]],
		;

	rule  additional_bound                  =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-4.html#jls-AdditionalBound
		[qw[  BINARY_AND  class_type                    ]],
		[qw[  BINARY_AND  class_type  additional_bound  ]],
		;

	rule  additive_element                  =>
		[qw[  multiplicative_element     ]],
		[qw[  multiplicative_expression  ]],
		;

	rule  additive_elements                 =>
		[qw[  additive_element  additive_operator  additive_elements  ]],
		[qw[  additive_element  additive_operator  additive_element   ]],
		;

	rule  additive_expression               => dom => 'CSI::Language::Java::Expression::Additive',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-AdditiveExpression
		[qw[  additive_elements  ]],
		;

	rule  additive_operator                 =>
		[qw[  ADDITION     ]],
		[qw[  SUBTRACTION  ]],
		;

	rule  allowed_identifier                =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-Identifier
		[qw[  IDENTIFIER          ]],
		[qw[  keyword_identifier  ]],
		;

	rule  allowed_type_identifier           =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-TypeIdentifier
		[qw[  IDENTIFIER               ]],
		[qw[  keyword_type_identifier  ]],
		;

	rule  annotated_class_type              => dom => 'CSI::Language::Java::Type::Class',
		[qw[  annotations  type_identifier  type_arguments  ]],
		[qw[  annotations  type_identifier                  ]],
		[qw[  class_reference                               ]],
		;

	rule  annotation                        => dom => 'CSI::Language::Java::Annotation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-Annotation
		[qw[  marker_annotation          ]],
		[qw[  normal_annotation          ]],
		[qw[  single_element_annotation  ]],
		;

	rule  annotation_body                   => dom => 'CSI::Language::Java::Structure::Body::Annotation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-AnnotationTypeBody
		[qw[  BRACE_OPEN  annotation_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                BRACE_CLOSE  ]],
		;

	rule  annotation_body_declaration       =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-AnnotationTypeMemberDeclaration
		[qw[  annotation_declaration          ]],
		[qw[  annotation_element_declaration  ]],
		[qw[  class_declaration               ]],
		[qw[  constant_declaration            ]],
		[qw[  empty_declaration               ]],
		[qw[  enum_declaration                ]],
		[qw[  interface_declaration           ]],
		;

	rule  annotation_body_declarations      =>
		[qw[  annotation_body_declaration  annotation_body_declarations  ]],
		[qw[  annotation_body_declaration                                ]],
		;

	rule  annotation_declaration            => dom => 'CSI::Language::Java::Declaration::Annotation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-AnnotationTypeDeclaration
		[qw[  interface_modifiers  ANNOTATION  interface  type_name  annotation_body  ]],
		[qw[                       ANNOTATION  interface  type_name  annotation_body  ]],
		;

	rule  annotation_default_value          => dom => 'CSI::Language::Java::Annotation::Default::Value',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-DefaultValue
		[qw[  default  element_value  ]],
		;

	rule  annotation_element_declaration    => dom => 'CSI::Language::Java::Annotation::Element',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-AnnotationTypeElementDeclaration
		[qw[  annotation_element_modifiers  annotation_element_declarator  dims  annotation_default_value  SEMICOLON  ]],
		[qw[                                annotation_element_declarator  dims  annotation_default_value  SEMICOLON  ]],
		[qw[  annotation_element_modifiers  annotation_element_declarator  dims                            SEMICOLON  ]],
		[qw[                                annotation_element_declarator  dims                            SEMICOLON  ]],
		[qw[  annotation_element_modifiers  annotation_element_declarator        annotation_default_value  SEMICOLON  ]],
		[qw[                                annotation_element_declarator        annotation_default_value  SEMICOLON  ]],
		[qw[  annotation_element_modifiers  annotation_element_declarator                                  SEMICOLON  ]],
		[qw[                                annotation_element_declarator                                  SEMICOLON  ]],
		;

	rule  annotation_element_declarator     =>
		[qw[  variable_type  variable_name  PAREN_OPEN  PAREN_CLOSE  ]],
		;

	rule  annotation_element_modifier       => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  public      ]],
		[qw[  abstract    ]],
		;

	rule  annotation_element_modifiers      =>
		[qw[  annotation_element_modifier  annotation_element_modifiers  ]],
		[qw[  annotation_element_modifier                                ]],
		;

	rule  annotation_reference              => dom => 'CSI::Language::Java::Annotation::Reference',
		[qw[  qualified_identifier  ]],
		;

	rule  annotations                       =>
		[qw[  annotation  annotations  ]],
		[qw[  annotation               ]],
		;

	rule  arguments                         => dom => 'CSI::Language::Java::Arguments',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ArgumentList
		[qw[  PAREN_OPEN  expressions  PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN               PAREN_CLOSE  ]],
		;

	rule  array_access                      => dom => 'CSI::Language::Java::Array::Access',
		[qw[  primary_no_new_array  BRACKET_OPEN  expression  BRACKET_CLOSE  ]],
		;

	rule  array_creation_dims               =>
		[qw[  dim_expressions  dims                     ]],
		[qw[  dim_expressions                           ]],
		[qw[                   dims  array_initializer  ]],
		;

	rule  array_creation_expression         => dom => 'CSI::Language::Java::Array::Creation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ArrayCreationExpression
		[qw[  new  primitive_type  array_creation_dims  ]],
		[qw[  new  class_type      array_creation_dims  ]],
		;

	rule  array_initializer                 => dom => 'CSI::Language::Java::Array::Initializer',
		[qw[  BRACE_OPEN  variable_initializers  COMMA  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  variable_initializers         BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                         COMMA  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                BRACE_CLOSE  ]],
		;

	rule  array_type                        => dom => 'CSI::Language::Java::Type::Array',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannArrayType
		[qw[  data_type  dim  ]],
		;

	rule  assert_statement                  => dom => 'CSI::Language::Java::Statement::Assert',
		[qw[  assert  expression  COLON  expression  SEMICOLON  ]],
		[qw[  assert  expression                     SEMICOLON  ]],
		;

	rule  assignment                        => dom => 'CSI::Language::Java::Expression::Assignment',
		# TODO: assignment chain as a list
		[qw[  left_hand_side  assignment_operands  ]],
		;

	rule  assignment_element                =>
		[qw[  lambda_expression   ]],
		[qw[  cast_expression_lambda   ]],
		[qw[  ternary_element     ]],
		[qw[  ternary_expression  ]],
		;

	rule  assignment_expression             =>
		[qw[  assignment ]],
		;

	rule  assignment_operand                =>
		[qw[ assignment_operator  assignment_element  ]],
		;

	rule  assignment_operands               =>
		[qw[  assignment_operand  assignment_operands  ]],
		[qw[  assignment_operand                       ]],
		;

	rule  assignment_operator               =>
		[qw[  ASSIGN                      ]],
		[qw[  ASSIGN_ADDITION             ]],
		[qw[  ASSIGN_BINARY_AND           ]],
		[qw[  ASSIGN_BINARY_OR            ]],
		[qw[  ASSIGN_BINARY_SHIFT_LEFT    ]],
		[qw[  ASSIGN_BINARY_SHIFT_RIGHT   ]],
		[qw[  ASSIGN_BINARY_USHIFT_RIGHT  ]],
		[qw[  ASSIGN_BINARY_XOR           ]],
		[qw[  ASSIGN_DIVISION             ]],
		[qw[  ASSIGN_MODULUS              ]],
		[qw[  ASSIGN_MULTIPLICATION       ]],
		[qw[  ASSIGN_SUBTRACTION          ]],
		;

	rule  binary_and_element                =>
		[qw[  equality_element     ]],
		[qw[  equality_expression  ]],
		;

	rule  binary_and_elements               =>
		[qw[  binary_and_element  BINARY_AND  binary_and_elements  ]],
		[qw[  binary_and_element  BINARY_AND  binary_and_element   ]],
		;

	rule  binary_and_expression             => dom => 'CSI::Language::Java::Expression::Binary::And',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-AndExpression
		[qw[  binary_and_elements  ]],
		;

	rule  binary_or_element                 =>
		[qw[  binary_xor_element     ]],
		[qw[  binary_xor_expression  ]],
		;

	rule  binary_or_elements                =>
		[qw[  binary_or_element  BINARY_OR  binary_or_elements  ]],
		[qw[  binary_or_element  BINARY_OR  binary_or_element   ]],
		;

	rule  binary_or_expression              => dom => 'CSI::Language::Java::Expression::Binary::Or',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-InclusiveOrExpression
		[qw[  binary_or_elements  ]],
		;

	rule  binary_shift_element              =>
		[qw[  additive_element     ]],
		[qw[  additive_expression  ]],
		;

	rule  binary_shift_elements             =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ShiftExpression
		[qw[  binary_shift_element  binary_shift_operator  binary_shift_elements  ]],
		[qw[  binary_shift_element  binary_shift_operator  binary_shift_element   ]],
		;

	rule  binary_shift_expression           => dom => 'CSI::Language::Java::Expression::Binary::Shift',
		[qw[  binary_shift_elements ]],
		;

	rule  binary_shift_operator             =>
		[qw[  BINARY_SHIFT_LEFT    ]],
		[qw[  BINARY_SHIFT_RIGHT   ]],
		[qw[  BINARY_USHIFT_RIGHT  ]],
		;

	rule  binary_xor_element                =>
		[qw[  binary_and_element     ]],
		[qw[  binary_and_expression  ]],
		;

	rule  binary_xor_elements               =>
		[qw[  binary_xor_element  BINARY_XOR  binary_xor_elements  ]],
		[qw[  binary_xor_element  BINARY_XOR  binary_xor_element   ]],
		;

	rule  binary_xor_expression             => dom => 'CSI::Language::Java::Expression::Binary::Xor',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ExclusiveOrExpression
		[qw[  binary_xor_elements  ]],
		;

	rule  block                             => dom => 'CSI::Language::Java::Structure::Block',
		[qw[  BRACE_OPEN  block_statements  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                    BRACE_CLOSE  ]],
		;

	rule  block_statement                   =>
		[qw[  class_declaration               ]],
		[qw[  enum_declaration                ]],
		[qw[  statement                       ]],
		[qw[  variable_declaration_statement  ]],
		;

	rule  block_statements                  =>
		[qw[  block_statement  block_statements  ]],
		[qw[  block_statement                    ]],
		;

	rule  break_statement                   => dom => 'CSI::Language::Java::Statement::Break',
		[qw[  break  label_reference  SEMICOLON  ]],
		[qw[  break                   SEMICOLON  ]],
		;

	rule  cast_element                      =>
		[qw[  postfix_element     ]],
		[qw[  postfix_expression  ]],
		;

	rule  cast_expression                   => dom => 'CSI::Language::Java::Expression::Cast',
		#[qw[  cast_reference_operator  lambda_expression                ]],
		[qw[  cast_reference_operator  prefix_element                   ]],
		[qw[  cast_reference_operator  unary_expression_not_plus_minus  ]],
		[qw[  cast_primary_operator    prefix_element                   ]],
		[qw[  cast_primary_operator    prefix_expression                ]],
		;

	rule  cast_expression_lambda            => dom => 'CSI::Language::Java::Expression::Cast',
		[qw[  cast_reference_operator  lambda_expression                ]],
		[qw[  cast_reference_operator  cast_expression_lambda           ]],
		;

	rule  cast_primary_operator             => dom => 'CSI::Language::Java::Operator::Cast',
		[qw[  PAREN_OPEN  primitive_type                    PAREN_CLOSE  ]],
		;

	rule  cast_reference_operator           => dom => 'CSI::Language::Java::Operator::Cast',
		[qw[  PAREN_OPEN  reference_type                    PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN  reference_type  additional_bound  PAREN_CLOSE  ]],
		;

	rule  class_body                        => dom => 'CSI::Language::Java::Class::Body',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-ClassBody
		[qw[  BRACE_OPEN  class_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                           BRACE_CLOSE  ]],
		;

	rule  class_body_declaration            =>
		[qw[  class_member_declaration  ]],
		[qw[  constructor_declaration   ]],
		[qw[  instance_initializer      ]],
		[qw[  static_initializer        ]],
		;

	rule  class_body_declarations           =>
		[qw[  class_body_declaration  class_body_declarations  ]],
		[qw[  class_body_declaration                           ]],
		;

	rule  class_declaration                 => dom => 'CSI::Language::Java::Class::Declaration',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-NormalClassDeclaration
		[qw[  class_modifiers  class  type_name  type_parameters  class_extends  class_implements  class_body  ]],
		[qw[  class_modifiers  class  type_name  type_parameters  class_extends                    class_body  ]],
		[qw[  class_modifiers  class  type_name  type_parameters                 class_implements  class_body  ]],
		[qw[  class_modifiers  class  type_name  type_parameters                                   class_body  ]],
		[qw[  class_modifiers  class  type_name                   class_extends  class_implements  class_body  ]],
		[qw[  class_modifiers  class  type_name                   class_extends                    class_body  ]],
		[qw[  class_modifiers  class  type_name                                  class_implements  class_body  ]],
		[qw[  class_modifiers  class  type_name                                                    class_body  ]],
		[qw[                   class  type_name  type_parameters  class_extends  class_implements  class_body  ]],
		[qw[                   class  type_name  type_parameters  class_extends                    class_body  ]],
		[qw[                   class  type_name  type_parameters                 class_implements  class_body  ]],
		[qw[                   class  type_name  type_parameters                                   class_body  ]],
		[qw[                   class  type_name                   class_extends  class_implements  class_body  ]],
		[qw[                   class  type_name                   class_extends                    class_body  ]],
		[qw[                   class  type_name                                  class_implements  class_body  ]],
		[qw[                   class  type_name                                                    class_body  ]],
		;

	rule  class_extends                     => dom => 'CSI::Language::Java::Class::Extends',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-Superclass
		[qw[  extends  class_type  ]],
		;

	rule  class_implements                  => dom => 'CSI::Language::Java::Class::Implements',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-Superinterfaces
		[qw[  implements  class_types  ]],
		;

	rule  class_literal                     => dom => 'CSI::Language::Java::Literal::Class',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ClassLiteral
		[qw[  type_reference  class_literal_dims  DOT  class  ]],
		[qw[  type_reference                      DOT  class  ]],
		[qw[  primitive_type  class_literal_dims  DOT  class  ]],
		[qw[  primitive_type                      DOT  class  ]],
		[qw[  void                                DOT  class  ]],
		;

	rule  class_literal_dim                 => dom => 'CSI::Language::Java::Literal::Class::Dim',
		[qw[  BRACKET_OPEN  BRACKET_CLOSE  ]],
		;

	rule  class_literal_dims                =>
		[qw[  class_literal_dim  class_literal_dims  ]],
		[qw[  class_literal_dim                      ]],
		;

	rule  class_member_declaration          =>
		[qw[  annotation_declaration    ]],
		[qw[  class_declaration         ]],
		[qw[  empty_declaration         ]],
		[qw[  enum_declaration          ]],
		[qw[  field_declaration         ]],
		[qw[  interface_declaration     ]],
		[qw[  class_method_declaration  ]],
		;

	rule  class_method_declaration          => dom => 'CSI::Language::Java::Method::Declaration',
		[qw[  method_modifiers  method_declaration  ]],
		[qw[                    method_declaration  ]],
		;

	rule  class_modifier                    => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  private     ]],
		[qw[  protected   ]],
		[qw[  public      ]],
		[qw[  abstract    ]],
		[qw[  final       ]],
		[qw[  static      ]],
		[qw[  strictfp    ]],
		;

	rule  class_modifiers                   =>
		[qw[  class_modifier  class_modifiers  ]],
		[qw[  class_modifier                   ]],
		;

	rule  class_reference                   =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannClassType
		[qw[  type_identifier  type_arguments  ]],
		[qw[  type_identifier  type_arguments  DOT  class_type_identifiers  ]],
		[qw[  type_identifier  type_arguments  DOT  type_identifier  ]],
		[qw[  type_identifier                  ]],
		[qw[  qualified_identifier DOT  type_identifier             ]],
		[qw[  qualified_identifier DOT  class_type_identifiers      ]],
		;

	rule  class_type                        => dom => 'CSI::Language::Java::Type::Class',
		[qw[  class_reference  ]],
		;

	rule  class_type_identifier             =>
		[qw[  annotations  type_identifier  type_arguments  ]],
		[qw[  annotations  type_identifier                  ]],
		[qw[               type_identifier  type_arguments  ]],
		;

	rule  class_type_identifiers            =>
		[qw[                               class_type_identifier  ]],
		[qw[  class_type_identifiers  DOT  class_type_identifier  ]],
		[qw[  class_type_identifiers  DOT        type_identifier  ]],
		;

	rule  class_types                       =>
		[qw[  class_type  COMMA  class_types  ]],
		[qw[  class_type                      ]],
		;

	rule  compilation_unit                  =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-7.html#jls-CompilationUnit
		[qw[  ordinary_compilation_unit  ]],
		[qw[  modular_compilation_unit   ]],
		;

	rule  condition_clause                  => dom => 'CSI::Language::Java::Clause::Condition',
		[qw[  PAREN_OPEN  expression  PAREN_CLOSE  ]],
		;

	rule  constant_declaration              => dom => 'CSI::Language::Java::Constant::Declaration' =>
		[qw[  constant_modifiers  data_type  variable_declarators  SEMICOLON  ]],
		[qw[                      data_type  variable_declarators  SEMICOLON  ]],
		;

	rule  constant_expression               => dom => 'CSI::Language::Java::Expression::Constant',
		[qw[  expression  ]],
		;

	rule  constant_modifier                 => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  public      ]],
		[qw[  final       ]],
		[qw[  static      ]],
		;

	rule  constant_modifiers                =>
		[qw[  constant_modifier  constant_modifiers  ]],
		[qw[  constant_modifier                      ]],
		;

	rule  constructor_body                  => dom => 'CSI::Language::Java::Constructor::Body',
		[qw[  BRACE_OPEN  explicit_constructor_invocation   block_statements  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  explicit_constructor_invocation                     BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                    block_statements  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                                      BRACE_CLOSE  ]],
		;

	rule  constructor_declaration           => dom => 'CSI::Language::Java::Constructor::Declaration',
		[qw[   constructor_modifiers  constructor_declarator  throws_clause  constructor_body  ]],
		[qw[   constructor_modifiers  constructor_declarator                 constructor_body  ]],
		[qw[                          constructor_declarator  throws_clause  constructor_body  ]],
		[qw[                          constructor_declarator                 constructor_body  ]],
		;

	rule  constructor_declarator            =>
		[qw[  type_parameters  type_name  parameters  ]],
		[qw[                   type_name  parameters  ]],
		;

	rule  constructor_modifier              => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  private     ]],
		[qw[  protected   ]],
		[qw[  public      ]],
		;

	rule  constructor_modifiers             =>
		[qw[  constructor_modifier  constructor_modifiers  ]],
		[qw[  constructor_modifier                         ]],
		;

	rule  continue_statement                => dom => 'CSI::Language::Java::Statement::Continue',
		[qw[  continue  label_reference  SEMICOLON  ]],
		[qw[  continue                   SEMICOLON  ]],
		;

	rule  data_type                         =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannType
		[qw[  primitive_type  ]],
		[qw[  reference_type  ]],
		;

	rule  dim                               => dom => 'CSI::Language::Java::Array::Dimension',
		[qw[  annotations  BRACKET_OPEN  BRACKET_CLOSE  ]],
		[qw[               BRACKET_OPEN  BRACKET_CLOSE  ]],
		;

	rule  dim_expression                    => dom => 'CSI::Language::Java::Array::Dimension::Expression',
		[qw[  annotations  BRACKET_OPEN  expression  BRACKET_CLOSE  ]],
		[qw[               BRACKET_OPEN  expression  BRACKET_CLOSE  ]],
		;

	rule  dim_expressions                   =>
		[qw[  dim_expression  dim_expressions  ]],
		[qw[  dim_expression                   ]],
		;

	rule  dims                              =>
		[qw[  dim  dims  ]],
		[qw[  dim        ]],
		;

	rule  do_statement                      => dom => 'CSI::Language::Java::Statement::Do',
		[qw[  do  statement  while  condition_clause  SEMICOLON  ]],
		;

	rule  element_value                     =>
		[qw[  annotation                       ]],
		[qw[  element_value_array_initializer  ]],
		[qw[  ternary_element                  ]],
		[qw[  ternary_expression               ]],
		;

	rule  element_value_array_initializer   => dom => 'CSI::Language::Java::Element::Value::Array',
		[qw[  BRACE_OPEN  element_values  COMMA  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                  COMMA  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  element_values         BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                         BRACE_CLOSE  ]],
		;

	rule  element_value_pair                => dom => 'CSI::Language::Java::Element::Value::Pair',
		[qw[  identifier  ASSIGN  element_value  ]],
		;

	rule  element_value_pairs               =>
		[qw[  element_value_pair  COMMA  element_value_pairs  ]],
		[qw[  element_value_pair                              ]],
		;

	rule  element_values                    =>
		[qw[  element_value  COMMA  element_values  ]],
		[qw[  element_value                         ]],
		;

	rule  empty_declaration                 => dom => 'CSI::Language::Java::Empty::Declaration',
		[qw[ SEMICOLON ]],
		;

	rule  empty_statement                   => dom => 'CSI::Language::Java::Statement::Empty',
		[qw[  SEMICOLON  ]],
		;

	rule  enum_body                         => dom => 'CSI::Language::Java::Enum::Body',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-EnumBody
		[qw[  BRACE_OPEN  enum_constants  COMMA  enum_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  enum_constants  COMMA                          BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  enum_constants         enum_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN  enum_constants                                 BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                  COMMA  enum_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                  COMMA                          BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                         enum_body_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                                 BRACE_CLOSE  ]],
		;

	rule  enum_body_declarations            =>
		[qw[  SEMICOLON  class_body_declarations  ]],
		[qw[  SEMICOLON                           ]],
		;

	rule  enum_constant                     => dom => 'CSI::Language::Java::Enum::Constant',
		[qw[  enum_constant_modifiers  enum_constant_name  arguments    class_body   ]],
		[qw[  enum_constant_modifiers  enum_constant_name  arguments                 ]],
		[qw[  enum_constant_modifiers  enum_constant_name               class_body   ]],
		[qw[  enum_constant_modifiers  enum_constant_name                            ]],
		[qw[                           enum_constant_name  arguments    class_body   ]],
		[qw[                           enum_constant_name  arguments                 ]],
		[qw[                           enum_constant_name               class_body   ]],
		[qw[                           enum_constant_name                            ]],
		;

	rule  enum_constant_modifier            =>
		[qw[  annotation  ]],
		;

	rule  enum_constant_modifiers           =>
		[qw[  enum_constant_modifier  enum_constant_modifiers  ]],
		[qw[  enum_constant_modifier                           ]],
		;

	rule  enum_constant_name                => dom => 'CSI::Language::Java::Enum::Constant::Name',
		[qw[  IDENTIFIER          ]],
		[qw[  keyword_identifier  ]],
		;

	rule  enum_constants                    =>
		[qw[  enum_constant  COMMA  enum_constants  ]],
		[qw[  enum_constant                         ]],
		;

	rule  enum_declaration                  => dom => 'CSI::Language::Java::Enum::Declaration',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-EnumDeclaration
		[qw[  class_modifiers  enum  type_name  class_implements  enum_body  ]],
		[qw[  class_modifiers  enum  type_name                    enum_body  ]],
		[qw[                   enum  type_name  class_implements  enum_body  ]],
		[qw[                   enum  type_name                    enum_body  ]],
		;

	rule  equality_element                  =>
		[qw[  relational_element     ]],
		[qw[  relational_expression  ]],
		;

	rule  equality_elements                 =>
		[qw[  equality_element  equality_operator  equality_elements  ]],
		[qw[  equality_element  equality_operator  equality_element   ]],
		;

	rule  equality_expression               => dom => 'CSI::Language::Java::Expression::Equality',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-EqualityExpression
		[qw[  equality_elements  ]],
		;

	rule  equality_operator                 =>
		[qw[  CMP_EQUALITY    ]],
		[qw[  CMP_INEQUALITY  ]],
		;

	rule  exception_type                    =>
		[qw[  class_type  ]],
		;

	rule  exception_types                   =>
		[qw[  exception_type  COMMA  exception_types  ]],
		[qw[  exception_type                          ]],
		;

	rule  explicit_constructor_invocation   => dom => 'CSI::Language::Java::Constructor::Invocation',
		[qw[  primary          DOT  type_arguments  super  arguments  SEMICOLON  ]],
		[qw[  primary          DOT                  super  arguments  SEMICOLON  ]],
		#[qw[  expression_name  DOT  type_arguments  super  invocation_arguments  SEMICOLON  ]],
		#[qw[  expression_name  DOT                  super  invocation_arguments  SEMICOLON  ]],
		[qw[                        type_arguments  super  arguments  SEMICOLON  ]],
		[qw[                                        super  arguments  SEMICOLON  ]],
		[qw[                        type_arguments  this   arguments  SEMICOLON  ]],
		[qw[                                        this   arguments  SEMICOLON  ]],
		;

	rule  expression                        =>
		[qw[  assignment_element     ]],
		[qw[  assignment_expression  ]],
		;

	rule  expression_group                  =>
		[qw[  PAREN_OPEN  statement_expression  PAREN_CLOSE  ]],
		;

	rule  expression_statement              => dom => 'CSI::Language::Java::Statement::Expression',
		[qw[  statement_expression  SEMICOLON  ]],
		;

	rule  expressions                       =>
		[qw[  expression  COMMA  expressions  ]],
		[qw[  expression                      ]],
		;

	rule  field_access                      => dom => 'CSI::Language::Java::Field::Access',
		[qw[  reference  DOT  super  DOT  field_name  ]],
		[qw[                  super  DOT  field_name  ]],
		[qw[  primary_no_reference   DOT  field_name  ]],
		;

	rule  field_declaration                 => dom => 'CSI::Language::Java::Field::Declaration',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-FieldDeclaration
		[qw[  field_modifiers  variable_type  variable_declarators  SEMICOLON  ]],
		[qw[                   variable_type  variable_declarators  SEMICOLON  ]],
		;

	rule  field_modifier                    => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  private     ]],
		[qw[  protected   ]],
		[qw[  public      ]],
		[qw[  final       ]],
		[qw[  static      ]],
		[qw[  transient   ]],
		[qw[  volatile    ]],
		;

	rule  field_modifiers                   =>
		[qw[  field_modifier  field_modifiers  ]],
		[qw[  field_modifier                   ]],
		;

	rule  field_name                        => dom => 'CSI::Language::Java::Field::Name',
		[qw[  identifier  ]],
		;

	rule  for_statement                     =>
		[qw[  loop_statement  ]],
		[qw[  foreach_statement  ]],
		;

	rule  for_statement_no_short_if         =>
		[qw[  loop_statement_no_short_if  ]],
		[qw[  foreach_statement_no_short_if  ]],
		;

	rule  foreach_header                    =>
		[qw[  for  PAREN_OPEN  foreach_iterator  PAREN_CLOSE  ]],
		;

	rule  foreach_iterator                  =>
		[qw[  variable_modifiers  variable_type  variable_declarator_id  COLON  expression  ]],
		[qw[                      variable_type  variable_declarator_id  COLON  expression  ]],
		;

	rule  foreach_statement                 => dom => 'CSI::Language::Java::Statement::Foreach',
		[qw[  foreach_header  statement  ]],
		;

	rule  foreach_statement_no_short_if     => dom => 'CSI::Language::Java::Statement::Foreach',
		[qw[  foreach_header  statement_no_short_if  ]],
		;

	rule  formal_parameter                  => dom => 'CSI::Language::Java::Parameter',
		[qw[  variable_modifiers  data_type  variable_name  dims  ]],
		[qw[  variable_modifiers  data_type  variable_name        ]],
		[qw[                      data_type  variable_name  dims  ]],
		[qw[                      data_type  variable_name        ]],
		[qw[  variable_arity_parameter                            ]],
 	;

	rule  formal_parameters                 =>
		[qw[  formal_parameter                            ]],
		[qw[  formal_parameter  COMMA  formal_parameters  ]],
		;

	rule  identifier                        => dom => 'CSI::Language::Java::Identifier',
		[qw[  allowed_identifier  ]],
		;

	rule  if_prologue                       =>
		[qw[  if  condition_clause  ]],
		;

	rule  if_statement                      => dom => 'CSI::Language::Java::Statement::If',
		[qw[  if_prologue  statement_no_short_if  else  statement  ]],
		[qw[  if_prologue  statement                               ]],
		;

	rule  if_statement_no_short_if          => dom => 'CSI::Language::Java::Statement::If',
		[qw[  if_prologue  statement_no_short_if  else  statement_no_short_if  ]],
		;

	rule  import_declaration                => dom => 'CSI::Language::Java::Import::Declaration',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-7.html#jls-ImportDeclaration
		[qw[  import  static  reference  DOT  import_type  SEMICOLON  ]],
		[qw[  import  static  reference                    SEMICOLON  ]],
		[qw[  import          reference  DOT  import_type  SEMICOLON  ]],
		[qw[  import          reference                    SEMICOLON  ]],
		;

	rule  import_declarations               =>
		[qw[  import_declaration  import_declarations  ]],
		[qw[  import_declaration                       ]],
		;

	rule  import_type                       => dom => 'CSI::Language::Java::Token::Import::Type',
		[qw[  TOKEN_ASTERISK  ]],
		;

	rule  instance_creation                 => dom => 'CSI::Language::Java::Instance::Creation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ClassInstanceCreationExpression
		[qw[  primary  DOT  new  instance_reference  arguments  class_body  ]],
		[qw[  primary  DOT  new  instance_reference  arguments              ]],
		[qw[                new  instance_reference  arguments  class_body  ]],
		[qw[                new  instance_reference  arguments              ]],
		;

	rule  instance_initializer              => dom => 'CSI::Language::Java::Instance::Initializer',
		[qw[  block  ]],
		;

	rule  instance_reference                =>
		# TODO annotated reference
		[qw[  type_arguments  reference  type_arguments  ]],
		[qw[                  reference  type_arguments  ]],
		[qw[                  reference                  ]],
		;

	rule  interface_body                    => dom => 'CSI::Language::Java::Interface::Body',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-InterfaceBody
		[qw[  BRACE_OPEN  interface_member_declarations  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                 BRACE_CLOSE  ]],
		;

	rule  interface_declaration             => dom => 'CSI::Language::Java::Interface::Declaration',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-NormalInterfaceDeclaration
		[qw[  interface_modifiers  interface  type_name  type_parameters   interface_extends  interface_body  ]],
		[qw[  interface_modifiers  interface  type_name  type_parameters                      interface_body  ]],
		[qw[  interface_modifiers  interface  type_name                    interface_extends  interface_body  ]],
		[qw[  interface_modifiers  interface  type_name                                       interface_body  ]],
		[qw[                       interface  type_name  type_parameters   interface_extends  interface_body  ]],
		[qw[                       interface  type_name  type_parameters                      interface_body  ]],
		[qw[                       interface  type_name                    interface_extends  interface_body  ]],
		[qw[                       interface  type_name                                       interface_body  ]],
		;

	rule  interface_extends                 => dom => 'CSI::Language::Java::Interface::Extends',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-ExtendsInterfaces
		[qw[  extends  class_types  ]],
		;

	rule  interface_member_declaration      =>
		[qw[  constant_declaration          ]],
		[qw[  empty_declaration             ]],
		[qw[  interface_method_declaration  ]],
		[qw[  type_declaration              ]],
		;

	rule  interface_member_declarations     =>
		[qw[  interface_member_declaration  interface_member_declarations  ]],
		[qw[  interface_member_declaration                                 ]],
		;

	rule  interface_method_declaration      => dom => 'CSI::Language::Java::Method::Declaration',
		[qw[  interface_method_modifiers  method_declaration  ]],
		[qw[                              method_declaration  ]],
		;

	rule  interface_method_modifier         => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  public      ]],
		[qw[  private     ]],
		[qw[  abstract    ]],
		[qw[  default     ]],
		[qw[  static      ]],
		[qw[  strictfp    ]],
		;

	rule  interface_method_modifiers        =>
		[qw[  interface_method_modifier                              ]],
		[qw[  interface_method_modifier  interface_method_modifiers  ]],
		;

	rule  interface_modifier                => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation ]],
		[qw[  public     ]],
		[qw[  protected  ]],
		[qw[  private    ]],
		[qw[  abstract   ]],
		[qw[  static     ]],
		[qw[  strictfp   ]],
		;

	rule  interface_modifiers               =>
		[qw[  interface_modifier  interface_modifiers  ]],
		[qw[  interface_modifier                       ]],
		;

	rule  invocant                          => dom => 'CSI::Language::Java::Method::Invocant',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-MethodInvocation
		#[qw[  expression_name        ]],
		[qw[  primary                ]],
		#[qw[  type_name              ]],
		[qw[  type_name  DOT  super  ]],
		[qw[  super                  ]],
		;

	rule  label_name                        => dom => 'CSI::Language::Java::Label::Name',
		[qw[  allowed_identifier  ]],
		;

	rule  label_reference                   => dom => 'CSI::Language::Java::Label::Reference',
		[qw[  allowed_identifier  ]],
		;

	rule  labeled_statement                 => dom => 'CSI::Language::Java::Statement::Labeled',
		[qw[  label_name  COLON  statement  ]],
		;

	rule  labeled_statement_no_short_if     => dom => 'CSI::Language::Java::Statement::Labeled',
		[qw[  label_name  COLON  statement_no_short_if  ]],
		;

	rule  lambda_body                       =>
		# lambda expression is greedy
		[qw[  statement_expression  ]],
		[qw[  block                       ]],
		;

	rule  lambda_expression                 => dom => 'CSI::Language::Java::Expression::Lambda',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-LambdaExpression
		[qw[  lambda_expression_parameters  LAMBDA  lambda_body  ]],
		;

	rule  lambda_expression_parameters      => dom => 'CSI::Language::Java::Expression::Lambda::Parameters',
		[qw[  PAREN_OPEN  lambda_parameters  PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN                     PAREN_CLOSE  ]],
		[qw[  variable_name                               ]],
		;

	rule  lambda_parameter                  =>
		[qw[  variable_modifiers  variable_type  variable_declarator_id  ]],
		[qw[                      variable_type  variable_declarator_id  ]],
		[qw[                                     variable_name           ]],
		[qw[  variable_arity_parameter                                   ]],
		;

	rule  lambda_parameters                 =>
		[qw[  lambda_parameter  COMMA  lambda_parameters  ]],
		[qw[  lambda_parameter                            ]],
		;

	rule  left_hand_side                    =>
		[qw[  array_access  ]],
		[qw[  field_access  ]],
		[qw[  reference     ]],
		;

	rule  literal                           =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-15.8.1
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-IntegerLiteral
		[qw[ LITERAL_INTEGRAL_BINARY  ]],
		[qw[ LITERAL_INTEGRAL_DECIMAL ]],
		[qw[ LITERAL_INTEGRAL_HEX     ]],
		[qw[ LITERAL_INTEGRAL_OCTAL   ]],
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-HexadecimalFloatingPointLiteral
		[qw[ LITERAL_FLOAT_DECIMAL    ]],
		[qw[ LITERAL_FLOAT_HEX        ]],
		[qw[ LITERAL_CHARACTER        ]],
		[qw[ LITERAL_STRING           ]],
		[qw[ literal_boolean_false    ]],
		[qw[ literal_boolean_true     ]],
		[qw[ literal_null             ]],
		;

	rule  literal_boolean_false             => dom => 'CSI::Language::Java::Literal::Boolean::False',
		[qw[  false  ]],
		;

	rule  literal_boolean_true              => dom => 'CSI::Language::Java::Literal::Boolean::True',
		[qw[  true  ]],
		;

	rule  literal_null                      => dom => 'CSI::Language::Java::Literal::Null',
		[qw[  null  ]],
		;

	rule  logical_and_element               =>
		[qw[  binary_or_element     ]],
		[qw[  binary_or_expression  ]],
		;

	rule  logical_and_elements              =>
		[qw[  logical_and_element  LOGICAL_AND  logical_and_elements  ]],
		[qw[  logical_and_element  LOGICAL_AND  logical_and_element   ]],
		;

	rule  logical_and_expression            => dom => 'CSI::Language::Java::Expression::Logical::And',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ConditionalAndExpression
		[qw[  logical_and_elements  ]],
		;

	rule  logical_or_element                =>
		[qw[  logical_and_expression  ]],
		[qw[  logical_and_element     ]],
		;

	rule  logical_or_elements               =>
		[qw[  logical_or_element  LOGICAL_OR  logical_or_elements  ]],
		[qw[  logical_or_element  LOGICAL_OR  logical_or_element   ]],
		;

	rule  logical_or_expression             => dom => 'CSI::Language::Java::Expression::Logical::Or',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ConditionalOrExpression
		[qw[  logical_or_elements  ]],
		;

	rule  loop_condition                    => dom => 'CSI::Language::Java::Loop::Condition',
		[qw[  expression  ]],
		;

	rule  loop_header                       =>
		[qw[  for  PAREN_OPEN  loop_iterator  PAREN_CLOSE  ]],
		;

	rule  loop_init                         => dom => 'CSI::Language::Java::Loop::Init',
		[qw[  variable_declaration   ]],
		[qw[  statement_expressions  ]],
		;

	rule  loop_iterator                     =>
		[qw[  loop_init  SEMICOLON  loop_condition  SEMICOLON  loop_update  ]],
		[qw[  loop_init  SEMICOLON  loop_condition  SEMICOLON               ]],
		[qw[  loop_init  SEMICOLON                  SEMICOLON  loop_update  ]],
		[qw[  loop_init  SEMICOLON                  SEMICOLON               ]],
		[qw[             SEMICOLON  loop_condition  SEMICOLON  loop_update  ]],
		[qw[             SEMICOLON  loop_condition  SEMICOLON               ]],
		[qw[             SEMICOLON                  SEMICOLON  loop_update  ]],
		[qw[             SEMICOLON                  SEMICOLON               ]],
		;

	rule  loop_statement                    => dom => 'CSI::Language::Java::Statement::Loop',
		[qw[  loop_header  statement  ]],
		;

	rule  loop_statement_no_short_if        => dom => 'CSI::Language::Java::Statement::Loop',
		[qw[  loop_header  statement_no_short_if  ]],
		;

	rule  loop_update                       => dom => 'CSI::Language::Java::Loop::Update',
		[qw[  statement_expressions  ]],
		;

	rule  marker_annotation                 =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-MarkerAnnotation
		[qw[  ANNOTATION  type_reference  ]],
		;

	rule  method_body                       => dom => 'CSI::Language::Java::Method::Body',
		[qw[      block  ]],
		[qw[  SEMICOLON  ]],
		;

	rule  method_declaration                =>
		[qw[  method_declarator  throws_clause  method_body  ]],
		[qw[  method_declarator                 method_body  ]],
		;

	rule  method_declarator                 =>
		[qw[  type_parameters  annotations  method_result  method_name  parameters  ]],
		[qw[  type_parameters               method_result  method_name  parameters  ]],
		[qw[                                method_result  method_name  parameters  ]],
		;

	rule  method_invocation                 => dom => 'CSI::Language::Java::Method::Invocation',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-MethodInvocation
		[qw[  invocant  DOT  type_arguments  method_name  arguments  ]],
		[qw[  invocant  DOT                  method_name  arguments  ]],
		[qw[                                 method_name  arguments  ]],
		;

	rule  method_modifier                   => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation    ]],
		[qw[  private       ]],
		[qw[  protected     ]],
		[qw[  public        ]],
		[qw[  abstract      ]],
		[qw[  final         ]],
		[qw[  native        ]],
		[qw[  static        ]],
		[qw[  strictfp      ]],
		[qw[  synchronized  ]],
		;

	rule  method_modifiers                  =>
		[qw[  method_modifier  method_modifiers  ]],
		[qw[  method_modifier                    ]],
		;

	rule  method_name                       => dom => 'CSI::Language::Java::Method::Name',
		[qw[  identifier  ]],
		;

	rule  method_reference                  => dom => 'CSI::Language::Java::Method::Reference',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-MethodReference
		[qw[  primary_no_reference    DOUBLE_COLON  type_arguments  method_name  ]],
		[qw[  primary_no_reference    DOUBLE_COLON                  method_name  ]],
		[qw[  class_type              DOUBLE_COLON  type_arguments  method_name  ]],
		[qw[  class_type              DOUBLE_COLON                  method_name  ]],
		[qw[  class_type  DOT  super  DOUBLE_COLON  type_arguments  method_name  ]],
		[qw[  class_type  DOT  super  DOUBLE_COLON                  method_name  ]],
		[qw[                   super  DOUBLE_COLON  type_arguments  method_name  ]],
		[qw[                   super  DOUBLE_COLON                  method_name  ]],
		[qw[  class_type              DOUBLE_COLON  type_arguments  new          ]],
		[qw[  class_type              DOUBLE_COLON                  new          ]],
		[qw[  array_type              DOUBLE_COLON                  new          ]],
		;

	rule  method_result                     => dom => 'CSI::Language::Java::Method::Result',
		[qw[  data_type  ]],
		[qw[       void  ]],
		;

	rule  modular_compilation_unit          =>
		[qw[  import_declarations  module_declaration  ]],
		[qw[                       module_declaration  ]],
		;

	rule  module_declaration                => dom => 'CSI::Language::Java::Module::Declaration',
		[qw[  annotations  open  module  module_name  BRACE_OPEN  module_directives  BRACE_CLOSE  ]],
		[qw[  annotations  open  module  module_name  BRACE_OPEN                     BRACE_CLOSE  ]],
		[qw[  annotations        module  module_name  BRACE_OPEN  module_directives  BRACE_CLOSE  ]],
		[qw[  annotations        module  module_name  BRACE_OPEN                     BRACE_CLOSE  ]],
		[qw[               open  module  module_name  BRACE_OPEN  module_directives  BRACE_CLOSE  ]],
		[qw[               open  module  module_name  BRACE_OPEN                     BRACE_CLOSE  ]],
		[qw[                     module  module_name  BRACE_OPEN  module_directives  BRACE_CLOSE  ]],
		[qw[                     module  module_name  BRACE_OPEN                     BRACE_CLOSE  ]],
		;

	rule  module_directive                  => dom => 'CSI::Language::Java::Module::Directive',
		[qw[  requires  requires_modifiers  module_name  SEMICOLON  ]],
		[qw[  requires                      module_name  SEMICOLON  ]],
		[qw[  exports   package_name  to module_names    SEMICOLON  ]],
		[qw[  exports   package_name                     SEMICOLON  ]],
		[qw[  opens     package_name  to module_names    SEMICOLON  ]],
		[qw[  opens     package_name                     SEMICOLON  ]],
		[qw[  uses      type_name                        SEMICOLON  ]],
		[qw[  provides  type_name with type_names        SEMICOLON  ]],
		;

	rule  module_directives                 =>
		[qw[  module_directive  module_directives  ]],
		[qw[  module_directive                     ]],
		;

	rule  module_name                       => dom => 'CSI::Language::Java::Module::Name',
		[qw[ qualified_identifier ]],
		;

	rule  module_names                      =>
		[qw[  module_name  COMMA  module_names  ]],
		[qw[  module_name                       ]],
		;

	rule  multiplicative_element            =>
		[qw[  prefix_element     ]],
		[qw[  prefix_expression  ]],
		;

	rule  multiplicative_elements           =>
		# TODO: list of rules in form "DIVISION element", "MODULUS element", "MULTIPLICATION element"
		# TODO: so it can be addressed by behaviour
		[qw[  multiplicative_element  multiplicative_operator  multiplicative_elements  ]],
		[qw[  multiplicative_element  multiplicative_operator  multiplicative_element   ]],
		;

	rule  multiplicative_expression         => dom => 'CSI::Language::Java::Expression::Multiplicative',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-MultiplicativeExpression
		# TODO [  'multiplicative_element',  list( multiplicative_operand ) ]
		[qw[  multiplicative_elements  ]],
		;

	rule  multiplicative_operator           =>
		[qw[  DIVISION        ]],
		[qw[  MODULUS         ]],
		[qw[  MULTIPLICATION  ]],
		;

	rule  normal_annotation                 =>
		[qw[  ANNOTATION  reference  PAREN_OPEN  element_value_pairs  PAREN_CLOSE  ]],
		[qw[  ANNOTATION  reference  PAREN_OPEN                       PAREN_CLOSE  ]],
		;

	rule  ordinary_compilation_unit         =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-7.html#jls-OrdinaryCompilationUnit
		[qw[  package_declaration  import_declarations  type_declarations  ]],
		[qw[  package_declaration  import_declarations                     ]],
		[qw[  package_declaration                       type_declarations  ]],
		[qw[  package_declaration                                          ]],
		[qw[                       import_declarations  type_declarations  ]],
		[qw[                       import_declarations                     ]],
		[qw[                                            type_declarations  ]],
		;

	rule  package_declaration               => dom => 'CSI::Language::Java::Package::Declaration',
		[qw[  package_modifiers  package  package_name  SEMICOLON  ]],
		[qw[                     package  package_name  SEMICOLON  ]],
		;

	rule  package_modifier                  => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		;

	rule  package_modifiers                 =>
		[qw[  package_modifier  package_modifiers  ]],
		[qw[  package_modifier                     ]],
		;

	rule  package_name                      => dom => 'CSI::Language::Java::Package::Name',
		[qw[  qualified_identifier  ]],
		;

	rule  parameters                        => dom => 'CSI::Language::Java::List::Parameters',
		[qw[  PAREN_OPEN  receiver_parameter  COMMA  formal_parameters  PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN  receiver_parameter  COMMA                     PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN                             formal_parameters  PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN                                                PAREN_CLOSE  ]],
		;

	rule  postfix_element                   =>
		[qw[  primary  ]],
		;

	rule  postfix_expression                => dom => 'CSI::Language::Java::Expression::Postfix',
		[qw[  postfix_element     postfix_operators  ]],
		;

	rule  postfix_operator                  =>
		[qw[  DECREMENT  ]],
		[qw[  INCREMENT  ]],
		;

	rule  postfix_operators                 =>
		[qw[  postfix_operator  postfix_operators  ]],
		[qw[  postfix_operator                     ]],
		;

	rule  prefix_element                    =>
		[qw[  cast_expression            ]],
		[qw[  postfix_element            ]],
		[qw[  postfix_expression         ]],
		;

	rule  prefix_expression                 => dom => 'CSI::Language::Java::Expression::Prefix',
		[qw[  prefix_operators  prefix_element  ]],
		;

	rule  prefix_operator                   =>
		[qw[  BINARY_COMPLEMENT   ]],
		[qw[  INCREMENT           ]],
		[qw[  DECREMENT           ]],
		[qw[  LOGICAL_COMPLEMENT  ]],
		[qw[  UNARY_MINUS         ]],
		[qw[  UNARY_PLUS          ]],
		;

	rule  prefix_operators                  =>
		[qw[  prefix_operator  prefix_operators  ]],
		[qw[  prefix_operator                    ]],
		;

	rule  primary                           =>
		[qw[  array_creation_expression  ]],
		[qw[  primary_no_new_array       ]],
		;

	rule  primary_no_new_array              =>
		[qw[  primary_no_reference  ]],
		[qw[  reference             ]],
		;

	rule  primary_no_reference              =>
		[qw[  array_access       ]],
		[qw[  class_literal      ]],
		[qw[  expression_group   ]],
		[qw[  field_access       ]],
		[qw[  instance_creation  ]],
		[qw[  literal            ]],
		[qw[  method_invocation  ]],
		[qw[  method_reference   ]],
		[qw[  qualified_this     ]],
		;

	rule  primitive_type                    => dom => 'CSI::Language::Java::Type::Primitive',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannPrimitiveType
		[qw[  boolean       ]],
		[qw[  byte          ]],
		[qw[  char          ]],
		[qw[  double        ]],
		[qw[  float         ]],
		[qw[  int           ]],
		[qw[  long          ]],
		[qw[  short         ]],
		;

	rule  qualified_identifier              =>
		[qw[  identifier  DOT  qualified_identifier  ]],
		[qw[  identifier                             ]],
		;

	rule  qualified_this                    => dom => 'CSI::Language::Java::Expression::This',
		[qw[  qualified_identifier  DOT  this  ]],
		[qw[                             this  ]],
		;

	rule  qualified_type_identifier         =>
		[qw[  qualified_identifier  DOT  type_identifier  ]],
		[qw[                             type_identifier  ]],
		;

	rule  receiver_parameter                => dom => 'CSI::Language::Java::Parameter::Receiver',
		[qw[   annotations  type_name  class_reference  DOT  this  ]],
		[qw[                type_name  class_reference  DOT  this  ]],
		[qw[   annotations  type_name                        this  ]],
		[qw[                type_name                        this  ]],
		;

	rule  reference                         => dom => 'CSI::Language::Java::Reference',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-AmbiguousName
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-ExpressionName
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-ModuleName
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-PackageName
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-PackageOrTypeName
		[qw[  qualified_identifier  ]],
		;

	rule  reference_type                    =>
		[qw[  array_type       ]],
		[qw[  class_type       ]],
		;

	rule  relational_element                =>
		[qw[  binary_shift_element     ]],
		[qw[  binary_shift_expression  ]],
		;

	rule  relational_elements               =>
		# Associativity always produces compile time error
		# [qw[  relational_element  relational_operator  relational_elements  ]],
		[qw[  relational_element  relational_operator  relational_element   ]],
		[qw[  relational_element  instanceof           reference_type       ]],
		;

	rule  relational_expression             => dom => 'CSI::Language::Java::Expression::Relational',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-RelationalExpression
		[qw[  relational_elements  ]],
		;

	rule  relational_operator               =>
		[qw[  CMP_LESS_THAN              ]],
		[qw[  CMP_LESS_THAN_OR_EQUAL     ]],
		[qw[  CMP_GREATER_THAN           ]],
		[qw[  CMP_GREATER_THAN_OR_EQUAL  ]],
		;

	rule  resource                          => dom => 'CSI::Language::Java::Resource',
		[qw[  single_variable_declaration  ASSIGN expression  ]],
		[qw[  variable_access                                 ]],
		;

	rule  resource_specification            => dom => 'CSI::Language::Java::List::Resources',
		[qw[  PAREN_OPEN  resources  SEMICOLON  PAREN_CLOSE  ]],
		[qw[  PAREN_OPEN  resources             PAREN_CLOSE  ]],
		;

	rule  resources                         =>
		[qw[  resource  SEMICOLON  resources  ]],
		[qw[  resource                        ]],
		;

	rule  return_statement                  => dom => 'CSI::Language::Java::Statement::Return',
		[qw[  return  expression  SEMICOLON  ]],
		[qw[  return              SEMICOLON  ]],
		;

	rule  single_element_annotation         =>
		[qw[  ANNOTATION  reference  PAREN_OPEN  element_value  PAREN_CLOSE  ]],
		;

	rule  single_variable_declaration       =>
		[qw[  variable_modifiers  variable_type  variable_declarator_id  ]],
		[qw[                      variable_type  variable_declarator_id  ]],
		;

	rule  statement                         =>
		[qw[  for_statement                   ]],
		[qw[  if_statement                    ]],
		[qw[  labeled_statement               ]],
		[qw[  statement_without_substatement  ]],
		[qw[  while_statement                 ]],
		;

	rule  statement_expression              =>
		[qw[  instance_creation_expression        ]],
		[qw[  expression                          ]],
		;

	rule  statement_expressions             =>
		[qw[  statement_expression  COMMA  statement_expressions  ]],
		[qw[  statement_expression                                ]],
		;

	rule  statement_no_short_if             =>
		[qw[  for_statement_no_short_if       ]],
		[qw[  if_statement_no_short_if        ]],
		[qw[  labeled_statement_no_short_if   ]],
		[qw[  statement_without_substatement  ]],
		[qw[  while_statement_no_short_if     ]],
		;

	rule  statement_without_substatement    =>
		[qw[  assert_statement        ]],
		[qw[  block                   ]],
		[qw[  break_statement         ]],
		[qw[  continue_statement      ]],
		[qw[  do_statement            ]],
		[qw[  empty_statement         ]],
		[qw[  expression_statement    ]],
		[qw[  return_statement        ]],
		[qw[  switch_statement        ]],
		[qw[  synchronized_statement  ]],
		[qw[  throw_statement         ]],
		[qw[  try_statement           ]],
		;

	rule  static_initializer                => dom => 'CSI::Language::Java::Instance::Initializer::Static',
		[qw[  STATIC  block  ]],
		;

	rule  switch_block                      =>
		[qw[  BRACE_OPEN   switch_block_statement_groups  switch_labels  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                  switch_labels  BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN   switch_block_statement_groups                 BRACE_CLOSE  ]],
		[qw[  BRACE_OPEN                                                 BRACE_CLOSE  ]],
		;

	rule  switch_block_statement_group      => dom => 'CSI::Language::Java::Statement::Switch::Group',
		[qw[  switch_labels  block_statements  ]],
		;

	rule  switch_block_statement_groups     =>
		[qw[  switch_block_statement_group  switch_block_statement_groups  ]],
		[qw[  switch_block_statement_group                                 ]],
		;

	rule  switch_label                      => dom => 'CSI::Language::Java::Statement::Switch::Label',
		[qw[  case  constant_expression  COLON  ]],
		[qw[                    default  COLON  ]],
		;

	rule  switch_labels                     =>
		[qw[  switch_label  switch_labels ]],
		[qw[  switch_label                ]],
		;

	rule  switch_statement                  => dom => 'CSI::Language::Java::Statement::Switch',
		[qw[  switch  PAREN_OPEN  expression  PAREN_CLOSE  switch_block  ]],
		;

	rule  synchronized_statement            => dom => 'CSI::Language::Java::Statement::Synchronized',
		[qw[  synchronized  PAREN_OPEN  expression  PAREN_CLOSE  block  ]],
		;

	rule  ternary_element                   =>
		[qw[  logical_or_expression  ]],
		[qw[  logical_or_element     ]],
		;

	rule  ternary_expression                => dom => 'CSI::Language::Java::Expression::Ternary',
		[qw[  ternary_element  QUESTION_MARK  expression  COLON  expression  ]],
		;

	rule  throw_statement                   => dom => 'CSI::Language::Java::Statement::Throw',
		[qw[  throw  expression  SEMICOLON  ]]
		;

	rule  throws_clause                     => dom => 'CSI::Language::Java::Method::Throws',
		[qw[  throws  exception_types  ]],
		;

	rule  try_body                          =>
		[qw[  block  try_catches  try_finally  ]],
		[qw[  block  try_catches               ]],
		[qw[  block               try_finally  ]],
		;

	rule  try_catch                         => dom => 'CSI::Language::Java::Structure::Try::Catch',
		[qw[  catch  try_catch_formal_parameter  block  ]],
		;

	rule  try_catch_formal_parameter        => dom => 'CSI::Language::Java::Structure::Try::Catch::Parameter',
		[qw[   PAREN_OPEN  variable_modifiers  try_catch_type  variable_name  PAREN_CLOSE  ]],
		[qw[   PAREN_OPEN                      try_catch_type  variable_name  PAREN_CLOSE  ]],
		;

	rule  try_catch_type                    => dom => 'CSI::Language::Java::Structure::Try::Catch::Type',
		[qw[  try_catch_types  ]],
		;

	rule  try_catch_types                   =>
		[qw[  reference  BINARY_OR  try_catch_types  ]],
		[qw[  reference                              ]],
		;

	rule  try_catches                       =>
		[qw[  try_catch  try_catches  ]],
		[qw[  try_catch               ]],
		;

	rule  try_finally                       => dom => 'CSI::Language::Java::Structure::Try::Finally',
		[qw[  finally  block  ]],
		;

	rule  try_statement                     => dom => 'CSI::Language::Java::Statement::Try',
		[qw[  try  resource_specification  try_body  ]],
		[qw[  try  resource_specification  block     ]],
		[qw[  try                          try_body  ]],
		;

	rule  type_argument                     =>
		[qw[  reference_type  ]],
		[qw[  type_wildcard   ]],
		;

	rule  type_argument_list                =>
		[qw[  type_argument  COMMA  type_argument_list  ]],
		[qw[  type_argument                             ]],
		;

	rule  type_arguments                    => dom => 'CSI::Language::Java::Type::Arguments',
		# without  data type knowledge generic can be confused with relational / bitshift expression
		[qw[  TYPE_LIST_OPEN  type_argument_list  TYPE_LIST_CLOSE  PRIORITY_TOKEN  ]],
		[qw[  TYPE_LIST_OPEN                      TYPE_LIST_CLOSE  PRIORITY_TOKEN  ]],
		;

	rule  type_bound                        => dom => 'CSI::Language::Java::Type::Bound',
		[qw[  extends  annotated_class_type  additional_bound  ]],
		[qw[  extends  annotated_class_type                    ]],
		[qw[  extends  type_variable                 ]],
		;

	rule  type_declaration                  =>
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-7.html#jls-TypeDeclaration
		[qw[  annotation_declaration   ]],
		[qw[  class_declaration        ]],
		[qw[  enum_declaration         ]],
		[qw[  interface_declaration    ]],
		[qw[  SEMICOLON                ]],
		;

	rule  type_declarations                 =>
		[qw[  type_declaration                     ]],
		[qw[  type_declaration  type_declarations  ]],
		;

	rule  type_identifier                   => dom => 'CSI::Language::Java::Identifier',
		[qw[  allowed_type_identifier  ]],
		;

	rule  type_name                         => dom => 'CSI::Language::Java::Type::Name',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-TypeIdentifier
		[qw[  IDENTIFIER               ]],
		[qw[  keyword_type_identifier  ]],
		;

	rule  type_parameter                    => dom => 'CSI::Language::Java::Type::Parameter',
		[qw[  type_parameter_modifiers  type_identifier  type_bound  ]],
		[qw[                            type_identifier  type_bound  ]],
		[qw[  type_parameter_modifiers  type_identifier              ]],
		[qw[                            type_identifier              ]],
		;

	rule  type_parameter_list               =>
		[qw[  type_parameter  COMMA  type_parameter_list  ]],
		[qw[  type_parameter                              ]],
		;

	rule  type_parameter_modifier           =>
		[qw[  annotation  ]],
		;

	rule  type_parameter_modifiers          =>
		[qw[  type_parameter_modifier  type_parameter_modifiers  ]],
		[qw[  type_parameter_modifier                            ]],
		;

	rule  type_parameters                   => dom => 'CSI::Language::Java::Type::Parameters',
		[qw[  TYPE_LIST_OPEN  type_parameter_list  TYPE_LIST_CLOSE  ]],
		;

	rule  type_reference                    => dom => 'CSI::Language::Java::Reference',
		# https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-TypeName
		[qw[  qualified_type_identifier  ]],
		;

	rule  type_variable                     => dom => 'CSI::Language::Java::Type::Variable',
		[qw[  class_type  type_bound  ]],
		;

	rule  type_wildcard                     => dom => 'CSI::Language::Java::Type::Wildcard',
		[qw[  annotations  QUESTION_MARK  type_wildcard_bounds  ]],
		[qw[  annotations  QUESTION_MARK                        ]],
		[qw[               QUESTION_MARK  type_wildcard_bounds  ]],
		[qw[               QUESTION_MARK                        ]],
		;

	rule  type_wildcard_bounds              =>
		[qw[  extends  reference_type  ]],
		[qw[  super    reference_type  ]],
		;

	rule  unary_element                     =>
		[qw[  prefix_element    ]],
		[qw[  unary_expression  ]],
		[qw[  cast_expression   ]],
		;

	rule  unary_expression                  =>
		[qw[  INCREMENT    unary_element       ]],
		[qw[  DECREMENT    unary_element       ]],
		[qw[  UNARY_PLUS   unary_element       ]],
		[qw[  UNARY_MINUS  unary_element       ]],
		[qw[  unary_expression_not_plus_minus  ]],
		;

	rule  unary_expression_not_plus_minus   =>
		[qw[  BINARY_COMPLEMENT   unary_element  ]],
		[qw[  LOGICAL_COMPLEMENT  unary_element  ]],
		;

	rule  variable_arity_parameter          =>
		[qw[   variable_modifiers  data_type  annotations  ELIPSIS  variable_name  ]],
		[qw[                       data_type  annotations  ELIPSIS  variable_name  ]],
		[qw[   variable_modifiers  data_type               ELIPSIS  variable_name  ]],
		[qw[                       data_type               ELIPSIS  variable_name  ]],
		;

	rule  variable_declaration              => dom => 'CSI::Language::Java::Variable',
		[qw[  variable_modifiers  variable_type  variable_declarators  ]],
		[qw[                      variable_type  variable_declarators  ]],
		;

	rule  variable_declaration_statement    => dom => 'CSI::Language::Java::Statement::Variable',
		[qw[  variable_declaration  SEMICOLON  ]],
		;

	rule  variable_declarator               => dom => 'CSI::Language::Java::Variable::Declarator',
		[qw[  variable_declarator_id  ASSIGN  variable_initializer  ]],
		[qw[  variable_declarator_id                                ]],
		;

	rule  variable_declarator_id            => dom => 'CSI::Language::Java::Variable::ID',
		[qw[  variable_name  dims  ]],
		[qw[  variable_name        ]],
		;

	rule  variable_declarators              =>
		[qw[  variable_declarator                               ]],
		[qw[  variable_declarator  COMMA  variable_declarators  ]],
		;

	rule  variable_initializer              =>
		[qw[  array_initializer  ]],
		[qw[  expression         ]],
		;

	rule  variable_initializers             =>
		[qw[  variable_initializer  COMMA  variable_initializers  ]],
		[qw[  variable_initializer                                ]],
		;

	rule  variable_modifier                 => dom => 'CSI::Language::Java::Modifier',
		[qw[  annotation  ]],
		[qw[  final       ]],
		;

	rule  variable_modifiers                =>
		[qw[  variable_modifier  variable_modifiers  ]],
		[qw[  variable_modifier                      ]],
		;

	rule  variable_name                     => dom => 'CSI::Language::Java::Variable::Name',
		[qw[  allowed_identifier  ]],
		;

	rule  variable_type                     =>
		[qw[  data_type  ]],
		[qw[  var        ]],
		;

	rule  while_statement                   => dom => 'CSI::Language::Java::Statement::While',
		[qw[  while  condition_clause  statement  ]],
		;

	rule  while_statement_no_short_if       => dom => 'CSI::Language::Java::Statement::While',
		[qw[  while  condition_clause  statement_no_short_if  ]],
		;

	1;
};

__END__

	sub array_access                :RULE :ACTION_DEFAULT {
		[
			[qw[      expression_name BRACKET_OPEN expression BRACKET_CLOSE ]],
			[qw[ primary_no_new_array BRACKET_OPEN expression BRACKET_CLOSE ]],
		];
	}

	sub array_type                  :RULE :ACTION_DEFAULT {
		[
			[qw[          primitive_type dims ]],
			[qw[ class_or_interface_type dims ]],
			[qw[           type_variable dims ]],
		];
	}

	sub assignment_expression       :RULE :ACTION_DEFAULT {
		[
			[qw[ conditional_expression ]],
			[qw[             assignment ]],
		];
	}

	sub block_statement             :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ local_variable_declaration_statement ]],
			[qw[                    class_declaration ]],
			[qw[                            statement ]],
		];
	}

	sub block_statements            :RULE :ACTION_LIST {
		[
			[qw[ block_statement                   ]],
			[qw[ block_statement  block_statements ]],
		];
	}

	sub cast_expression             :RULE :ACTION_DEFAULT {
		[
			[qw[ PAREN_OPEN primitive_type                    PAREN_CLOSE unary_expression ]],
			[qw[ PAREN_OPEN reference_type  additional_bound  PAREN_CLOSE unary_expression_not_plus_minus ]],
			[qw[ PAREN_OPEN reference_type                    PAREN_CLOSE unary_expression_not_plus_minus ]],
			[qw[ PAREN_OPEN reference_type  additional_bound  PAREN_CLOSE lambda_expression ]],
			[qw[ PAREN_OPEN reference_type                    PAREN_CLOSE lambda_expression ]],
		];
	}

	sub class_instance_creation_expression:RULE :ACTION_DEFAULT {
		[
			[qw[                     unqualified_class_instance_creation_expression ]],
			[qw[ expression_name DOT unqualified_class_instance_creation_expression ]],
			[qw[         primary DOT unqualified_class_instance_creation_expression ]],
		];
	}

	sub class_or_interface_type     :RULE :ACTION_PASS_THROUGH {
		[
			[qw[     class_type ]],
			[qw[ interface_type ]],
		];
	}

	sub annotated_identifier        :RULE :ACTION_DEFAULT {
		[
			[qw[                 identifier ]],
			[qw[ annotation_list identifier ]],
		];
	}

	sub annotated_qualified_identifier :RULE :ACTION_LIST {
		[
			[qw[ annotated_identifier                          ]],
			[qw[ annotated_identifier DOT annotated_identifier ]],
		];
	}

	sub class_type                  :RULE :ACTION_DEFAULT {
		[
			[qw[                             annotation_list type_identifier type_arguments    ]],
			[qw[                             annotation_list type_identifier                   ]],
			[qw[                                             type_identifier type_arguments    ]],
			[qw[                                             type_identifier                   ]],
			[qw[            package_name DOT annotation_list type_identifier type_arguments    ]],
			[qw[            package_name DOT annotation_list type_identifier                   ]],
			[qw[            package_name DOT                 type_identifier type_arguments    ]],
			[qw[            package_name DOT                 type_identifier                   ]],
			[qw[ class_or_interface_type DOT annotation_list type_identifier type_arguments    ]],
			[qw[ class_or_interface_type DOT annotation_list type_identifier                   ]],
			[qw[ class_or_interface_type DOT                 type_identifier type_arguments    ]],
			[qw[ class_or_interface_type DOT                 type_identifier                   ]],
		];
	}

	sub constant_expression         :RULE :ACTION_ALIAS {
		[
			[qw[ expression ]],
		];
	}

	sub dim_expr                    :RULE :ACTION_DEFAULT {
		[
			[qw[   annotation_list  BRACKET_OPEN expression BRACKET_CLOSE ]],
			[qw[                    BRACKET_OPEN expression BRACKET_CLOSE ]],
		];
	}

	sub dim_exprs                   :RULE :ACTION_LIST {
		[
			[qw[ dim_expr            ]],
			[qw[ dim_expr  dim_exprs ]],
		];
	}

	sub element_value_pair          :RULE :ACTION_DEFAULT {
		[
			[qw[ identifier ASSIGN element_value ]],
		];
	}

	sub element_value_pair_list     :RULE :ACTION_LIST {
		[
			[qw[ element_value_pair                               ]],
			[qw[ element_value_pair COMMA element_value_pair_list ]],
		];
	}

	sub empty_statement             :RULE :ACTION_DEFAULT {
		[
			[qw[ SEMICOLON ]],
		];
	}

	sub enum_body_declarations      :RULE :ACTION_DEFAULT {
		[
			[qw[ SEMICOLON  class_body_declaration_list   ]],
			[qw[ SEMICOLON                                ]],
		];
	}

	sub exception_type              :RULE :ACTION_PASS_THROUGH {
		[
			[qw[    class_type ]],
			[qw[ type_variable ]],
		];
	}

	sub exception_type_list         :RULE :ACTION_LIST {
		[
			[qw[ exception_type                           ]],
			[qw[ exception_type COMMA exception_type_list ]],
		];
	}

	sub expression                  :RULE :ACTION_PASS_THROUGH {
		[
			[qw[     lambda_expression ]],
			[qw[ assignment_expression ]],
		];
	}

	sub expression_list             :RULE :ACTION_LIST {
		[
			[qw[ expression                        ]],
			[qw[ expression COMMA  expression_list ]],
		];
	}

	sub expression_name             :RULE :ACTION_DEFAULT {
		[
			[qw[ qualified_identifier ]],
		];
	}

	sub if_then_else_statement      :RULE :ACTION_DEFAULT {
		[
			[qw[ IF PAREN_OPEN expression PAREN_CLOSE statement_no_short_if ELSE statement ]],
		];
	}

	sub if_then_else_statement_no_short_if:RULE :ACTION_DEFAULT {
		[
			[qw[ IF PAREN_OPEN expression PAREN_CLOSE statement_no_short_if ELSE statement_no_short_if ]],
		];
	}

	sub if_then_statement           :RULE :ACTION_DEFAULT {
		[
			[qw[ IF PAREN_OPEN expression PAREN_CLOSE statement ]],
		];
	}

	sub lambda_parameter            :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  lambda_parameter_type variable_declarator_id ]],
			[qw[                           lambda_parameter_type variable_declarator_id ]],
			[qw[                                               variable_arity_parameter ]],
		];
	}

	sub lambda_parameter_list       :RULE :ACTION_LIST {
		[
			[qw[ lambda_parameter                             ]],
			[qw[ lambda_parameter COMMA lambda_parameter_list ]],
		];
	}

	sub lambda_parameter_type       :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ unann_type ]],
			[qw[        VAR ]],
		];
	}

	sub lambda_parameters           :RULE :ACTION_DEFAULT {
		[
			[qw[ PAREN_OPEN  lambda_parameter_list  PAREN_CLOSE ]],
			[qw[ PAREN_OPEN  identifier_list        PAREN_CLOSE ]],
			[qw[ PAREN_OPEN                         PAREN_CLOSE ]],
			[qw[                                     identifier ]],
		];
	}

	sub local_variable_declaration  :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  local_variable_type variable_declarator_list ]],
			[qw[                           local_variable_type variable_declarator_list ]],
		];
	}

	sub local_variable_declaration_statement:RULE :ACTION_DEFAULT {
		[
			[qw[ local_variable_declaration SEMICOLON ]],
		];
	}

	sub local_variable_type         :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ unann_type ]],
			[qw[        VAR ]],
		];
	}

	sub package_or_type_name        :RULE :ACTION_ALIAS {
		[
			[qw[ qualified_identifier ]],
		]
	}

	sub primitive_type              :RULE :ACTION_DEFAULT {
		[
			[qw[   annotation_list  numeric_type ]],
			[qw[                    numeric_type ]],
			[qw[        annotation_list  BOOLEAN ]],
			[qw[                         BOOLEAN ]],
		]
	}

	sub reference_type              :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ class_or_interface_type ]],
			[qw[           type_variable ]],
			[qw[              array_type ]],
		]
	}

	sub requires_modifier           :RULE :ACTION_DEFAULT {
		[
			[qw[ TRANSITIVE ]],
			[qw[ STATIC ]],
		]
	}

	sub requires_modifier_list      :RULE :ACTION_LIST {
		[
			[qw[ requires_modifier                        ]],
			[qw[ requires_modifier requires_modifier_list ]],
		]
	}

	sub resource                    :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  local_variable_type identifier ASSIGN expression ]],
			[qw[                           local_variable_type identifier ASSIGN expression ]],
			[qw[   variable_access                                                          ]],
		]
	}

	sub resource_list               :RULE :ACTION_LIST {
		[
			[qw[ resource                         ]],
			[qw[ resource SEMICOLON resource_list ]],
		]
	}

	sub resource_specification      :RULE :ACTION_DEFAULT {
		[
			[qw[ PAREN_OPEN resource_list  SEMICOLON  PAREN_CLOSE ]],
			[qw[ PAREN_OPEN resource_list             PAREN_CLOSE ]],
		]
	}

	sub result                      :RULE :ACTION_DEFAULT {
		[
			[qw[ unann_type ]],
			[qw[       VOID ]],
		]
	}

	sub simple_type_name            :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ type_identifier ]],
		]
	}

	sub statement                   :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ statement_without_trailing_substatement ]],
			[qw[                       labeled_statement ]],
			[qw[                       if_then_statement ]],
			[qw[                  if_then_else_statement ]],
			[qw[                         while_statement ]],
			[qw[                           for_statement ]],
		]
	}

	sub statement_expression_list   :RULE :ACTION_LIST {
		[
			[qw[ statement_expression ]],
			[qw[ statement_expression COMMA statement_expression_list  ]],
		]
	}

	sub statement_no_short_if       :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ statement_without_trailing_substatement ]],
			[qw[           labeled_statement_no_short_if ]],
			[qw[      if_then_else_statement_no_short_if ]],
			[qw[             while_statement_no_short_if ]],
			[qw[               for_statement_no_short_if ]],
		]
	}

	sub type_name                   :RULE :ACTION_ALIAS {
		[
			[qw[ qualified_identifier ]],
		];
	}

	sub type_name_list              :RULE :ACTION_LIST {
		[
			[qw[ type_name                       ]],
			[qw[ type_name COMMA  type_name_list ]],
		]
	}

	sub type_variable               :RULE :ACTION_DEFAULT {
		[
			[qw[   annotation_list  type_identifier ]],
			[qw[                    type_identifier ]],
		]
	}

	sub unann_array_type            :RULE :ACTION_DEFAULT {
		[
			[qw[          unann_primitive_type dims ]],
			[qw[ unann_class_or_interface_type dims ]],
			[qw[           unann_type_variable dims ]],
		]
	}

	sub unann_class_or_interface_type:RULE :ACTION_PASS_THROUGH {
		[
			[qw[     unann_class_type ]],
			[qw[ unann_interface_type ]],
		]
	}

	sub unann_class_type            :RULE :ACTION_DEFAULT {
		[
			[qw[                                                     type_identifier  type_arguments   ]],
			[qw[                                                     type_identifier                   ]],
			[qw[                  package_name DOT  annotation_list  type_identifier  type_arguments   ]],
			[qw[                  package_name DOT                   type_identifier  type_arguments   ]],
			[qw[                  package_name DOT  annotation_list  type_identifier                   ]],
			[qw[                  package_name DOT                   type_identifier                   ]],
			[qw[ unann_class_or_interface_type DOT  annotation_list  type_identifier  type_arguments   ]],
			[qw[ unann_class_or_interface_type DOT                   type_identifier  type_arguments   ]],
			[qw[ unann_class_or_interface_type DOT  annotation_list  type_identifier                   ]],
			[qw[ unann_class_or_interface_type DOT                   type_identifier                   ]],
		]
	}

	sub unann_interface_type        :RULE :ACTION_ALIAS {
		[
			[qw[ unann_class_type ]],
		]
	}

	sub unann_reference_type        :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ unann_class_or_interface_type ]],
			[qw[           unann_type_variable ]],
			[qw[              unann_array_type ]],
		]
	}

	sub unann_type_variable         :RULE :ACTION_PASS_THROUGH {
		[
			[qw[ type_identifier ]],
		]
	}

	sub unary_expression_not_plus_minus:RULE :ACTION_DEFAULT {
		[
			[qw[          postfix_expression ]],
			[qw[ BIT_NEGATE unary_expression ]],
			[qw[        NOT unary_expression ]],
			[qw[             cast_expression ]],
		]
	}

	sub variable_access             :RULE :ACTION_DEFAULT {
		[
			[qw[ expression_name ]],
			[qw[    field_access ]],
		]
	}

	sub variable_arity_parameter    :RULE :ACTION_DEFAULT {
		[
			[qw[   variable_modifier_list  unann_type  annotation_list  ELIPSIS identifier ]],
			[qw[                           unann_type  annotation_list  ELIPSIS identifier ]],
			[qw[   variable_modifier_list  unann_type                   ELIPSIS identifier ]],
			[qw[                           unann_type                   ELIPSIS identifier ]],
		]
	}

	sub variable_declarator         :RULE :ACTION_DEFAULT {
		[
			[qw[ variable_declarator_id  ASSIGN variable_initializer   ]],
			[qw[ variable_declarator_id                                ]],
		]
	}

	sub variable_declarator_id      :RULE :ACTION_DEFAULT {
		[
			[qw[ identifier  dims   ]],
			[qw[ identifier         ]],
		]
	}

	sub variable_declarator_list    :RULE :ACTION_LIST {
		[
			[qw[ variable_declarator                                ]],
			[qw[ variable_declarator COMMA variable_declarator_list ]],
		]
	}

	1
};

__END__
	rule  method_reference                  => action => 'default',
		# class reference is treated as field access (or vice versea)
		# TODO:
		# - token "symbol_reference" describing both
		# - type expression for use here
		[qw[             primary DOUBLE_COLON  type_arguments  method_name                  ]],
		[qw[             primary DOUBLE_COLON                  method_name                  ]],
		[qw[      reference_type DOUBLE_COLON  type_arguments  method_name  PRIORITY_TOKEN  ]],
		[qw[      reference_type DOUBLE_COLON                  method_name  PRIORITY_TOKEN  ]],
		[qw[               SUPER DOUBLE_COLON  type_arguments  method_name  PRIORITY_TOKEN  ]],
		[qw[               SUPER DOUBLE_COLON                  method_name  PRIORITY_TOKEN  ]],
		[qw[ type_name DOT SUPER DOUBLE_COLON  type_arguments  method_name  PRIORITY_TOKEN  ]],
		[qw[ type_name DOT SUPER DOUBLE_COLON                  method_name  PRIORITY_TOKEN  ]],
		[qw[          class_type DOUBLE_COLON  type_arguments  NEW                          ]],
		[qw[          class_type DOUBLE_COLON                  NEW                          ]],
		[qw[          array_type DOUBLE_COLON                  NEW                          ]],
		;


