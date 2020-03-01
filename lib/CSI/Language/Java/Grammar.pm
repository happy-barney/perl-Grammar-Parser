
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
		my $lc = lc $keyword;
		my $uc = uc $keyword;
		my $word = ucfirst $lc;
		my $re = qr/ (?> \b $lc \b ) /sx;

		token $uc => dom => "CSI::Language::Java::Token::Word::$word" => @opts, $re;
	}

	sub operator {
		my ($name, $dom, @params) = @_;

		my $code = Ref::Util::is_plain_arrayref ($params[-1])
			? \& rule
			: \& token
			;

		$code->(
			$name,
			dom => "CSI::Language::Java::Operator::$dom",
			@params,
		);
	}

	start rule TOP                          => dom => 'CSI::Document',
		[qw[  compilation_unit  ]],
		[],
		;

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

	sub Identifier_Character        :REGEX {
		qr/[_\p{Letter}\p{Letter_Number}\p{Digit}\p{Currency_Symbol}]/sx;
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
	}

	sub IDENTIFIER                  :TOKEN :ACTION_LITERAL_VALUE {
        qr/(?>
			(?!  \p{Digit} )
			(?!  (??{ 'Keyword' }) )
			(?!  (??{ 'Literal_Boolean' }) )
			(?!  (??{ 'Literal_Null' }) )
			(?<value> (??{ 'Identifier_Character' })+ )
		) /sx;
	}

	sub type_identifier             :TOKEN :ACTION_LITERAL_VALUE {
        qr/(?>
			(?!  \p{Digit} )
			(?!  (??{ 'Keyword' }) )
			(?!  (??{ 'Literal_Boolean' }) )
			(?!  (??{ 'Literal_Null' }) )
			(?!  (??{ 'VAR' }) )
			(?<value> (??{ 'Identifier_Character' })+ )
		) /sx;
	}

	sub ABSTRACT                    :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b abstract       \b ) /sx;
	}

	sub ASSERT                      :TOKEN :PROTO(Keyword) {
		qr/ (?> \b assert         \b ) /sx;
	}

	sub BOOLEAN                     :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b boolean        \b ) /sx;
	}

	sub CONTINUE                    :TOKEN :PROTO(Keyword) {
		qr/ (?> \b continue       \b ) /sx;
	}

	sub DEFAULT                     :TOKEN :PROTO(Keyword) {
		qr/ (?> \b default        \b ) /sx;
	}

	sub DO                          :TOKEN :PROTO(Keyword) {
		qr/ (?> \b do             \b ) /sx;
	}

	sub FOR                         :TOKEN :PROTO(Keyword) {
		qr/ (?> \b for            \b ) /sx;
	}

	sub GOTO                        :TOKEN :PROTO(Keyword) {
		qr/ (?> \b goto           \b ) /sx;
	}

	sub IF                          :TOKEN :PROTO(Keyword) {
		qr/ (?> \b if             \b ) /sx;
	}

	sub NEW                         :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b new            \b ) /sx;
	}

	sub PACKAGE                     :TOKEN :PROTO(Keyword) {
		qr/ (?> \b package        \b ) /sx;
	}

	sub SWITCH                      :TOKEN :PROTO(Keyword) {
		qr/ (?> \b switch         \b ) /sx;
	}

	sub SYNCHRONIZED                :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b synchronized   \b ) /sx;
	}

	sub PRIVATE                     :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b private        \b ) /sx;
	}

	sub THIS                        :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b this           \b ) /sx;
	}

	sub BREAK                       :TOKEN :PROTO(Keyword) {
		qr/ (?> \b break          \b ) /sx;
	}

	sub DOUBLE                      :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b double         \b ) /sx;
	}

	sub IMPLEMENTS                  :TOKEN :PROTO(Keyword) {
		qr/ (?> \b implements     \b ) /sx;
	}

	sub PROTECTED                   :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b protected      \b ) /sx;
	}

	sub THROW                       :TOKEN :PROTO(Keyword) {
		qr/ (?> \b throw          \b ) /sx;
	}

	sub BYTE                        :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b byte           \b ) /sx;
	}

	sub ELSE                        :TOKEN :PROTO(Keyword) {
		qr/ (?> \b else           \b ) /sx;
	}

	sub IMPORT                      :TOKEN :PROTO(Keyword) {
		qr/ (?> \b import         \b ) /sx;
	}

	sub PUBLIC                      :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b public         \b ) /sx;
	}

	sub THROWS                      :TOKEN :PROTO(Keyword) {
		qr/ (?> \b throws         \b ) /sx;
	}

	sub CASE                        :TOKEN :PROTO(Keyword) {
		qr/ (?> \b case           \b ) /sx;
	}

	sub ENUM                        :TOKEN :PROTO(Keyword) {
		qr/ (?> \b enum           \b ) /sx;
	}

	sub INSTANCEOF                  :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b instanceof     \b ) /sx;
	}

	sub RETURN                      :TOKEN :PROTO(Keyword) {
		qr/ (?> \b return         \b ) /sx;
	}

	sub TRANSIENT                   :TOKEN :PROTO(Keyword) {
		qr/ (?> \b transient      \b ) /sx;
	}

	sub TRANSITIVE                  :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b transient      \b ) /sx;
	}

	sub CATCH                       :TOKEN :PROTO(Keyword) {
		qr/ (?> \b catch          \b ) /sx;
	}

	sub EXTENDS                     :TOKEN :PROTO(Keyword) {
		qr/ (?> \b extends        \b ) /sx;
	}

	sub INT                         :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b int            \b ) /sx;
	}

	sub SHORT                       :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b short          \b ) /sx;
	}

	sub TRY                         :TOKEN :PROTO(Keyword) {
		qr/ (?> \b try            \b ) /sx;
	}

	sub CHAR                        :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b char           \b ) /sx;
	}

	sub FINAL                       :TOKEN :PROTO(Keyword) {
		qr/ (?> \b final          \b ) /sx;
	}

	sub INTERFACE                   :TOKEN :PROTO(Keyword) {
		qr/ (?> \b interface      \b ) /sx;
	}

	sub STATIC                      :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b static         \b ) /sx;
	}

	sub VOID                        :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b void           \b ) /sx;
	}

	sub CLASS                       :TOKEN :PROTO(Keyword) {
		qr/ (?> \b class          \b ) /sx;
	}

	sub FINALLY                     :TOKEN :PROTO(Keyword) {
		qr/ (?> \b finally        \b ) /sx;
	}

	sub LONG                        :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b long           \b ) /sx;
	}

	sub STRICTFP                    :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b strictfp       \b ) /sx;
	}

	sub VOLATILE                    :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b volatile       \b ) /sx;
	}

	sub CONST                       :TOKEN :PROTO(Keyword) {
		qr/ (?> \b const          \b ) /sx;
	}

	sub FLOAT                       :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b float          \b ) /sx;
	}

	sub NATIVE                      :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b native         \b ) /sx;
	}

	sub SUPER                       :TOKEN :PROTO(Keyword) :ACTION_SYMBOL {
		qr/ (?> \b super          \b ) /sx;
	}

	sub WHILE                       :TOKEN :PROTO(Keyword) {
		qr/ (?> \b while          \b ) /sx;
	}

	sub EXPORTS                     :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b exports \b ) /sx;
	}

	sub REQUIRES                    :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b requires \b ) /sx;
	}

	sub PROVIDES                    :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b provides \b ) /sx;
	}

	sub USES                        :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b uses \b ) /sx;
	}

	sub WITH                        :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b with \b ) /sx;
	}

	sub TO                          :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b to \b ) /sx;
	}

	sub MODULE                      :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b module \b ) /sx;
	}

	sub OPENS                       :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b opens \b ) /sx;
	}

	sub OPEN                        :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b open \b ) /sx;
	}

	sub VAR                         :TOKEN :ACTION_SYMBOL {
		qr/ (?> \b var            \b ) /sx;
	}

	sub underline                   :TOKEN :PROTO(Keyword) {
		qr/ (?> \b _              \b ) /sx;
	}

	sub TRUE                        :TOKEN :PROTO(Literal_Boolean) :ACTION_SYMBOL {
		qr/ (?> \b true           \b ) /sx;
	}

	sub FALSE                       :TOKEN :PROTO(Literal_Boolean) :ACTION_SYMBOL {
		qr/ (?> \b false          \b ) /sx;
	}

	sub NULL                        :TOKEN :PROTO(Literal_Null) :ACTION_SYMBOL {
		qr/ (?> \b null           \b ) /sx;
	}

	sub SEMICOLON                   :TOKEN {
		';'
	}

	sub DOT                         :TOKEN {
		'.'
	}

	sub BRACE_OPEN                  :TOKEN {
		'{'
	}

	sub BRACE_CLOSE                 :TOKEN {
		'}'
	}

	sub PAREN_OPEN                  :TOKEN {
		'('
	}

	sub PAREN_CLOSE                 :TOKEN {
		')'
	}

	sub BRACKET_OPEN                :TOKEN {
		'['
	}

	sub BRACKET_CLOSE               :TOKEN {
		']'
	}

	sub COMMA                       :TOKEN {
		','
	}

	sub AT                          :TOKEN {
		'@'
	}

	sub TYPE_PARAMETER_LIST_OPEN    :TOKEN {
		'<'
	}

	sub TYPE_PARAMETER_LIST_CLOSE   :TOKEN {
		'>'
	}

	sub DOUBLE_COLON                :TOKEN {
		'::'
	}

	sub LAMBDA                      :TOKEN {
		'->'
	}

	sub ELIPSIS                     :TOKEN {
		'...'
	}

	sub COLON                       :TOKEN {
		':'
	}

	sub QUESTION_MARK               :TOKEN {
		'?'
	}

	sub AND                         :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'&';
	}

	sub ASSIGN                      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'=';
	}

	sub ASSIGN_ADD                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'+=';
	}

	sub ASSIGN_AND                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'&=';
	}

	sub ASSIGN_DIVIDE               :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'/=';
	}

	sub ASSIGN_LEFT_SHIFT           :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'<<=';
	}

	sub ASSIGN_MULTIPLY             :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'*=';
	}

	sub ASSIGN_MODULO               :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'%=';
	}

	sub ASSIGN_OR                   :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'|=';
	}

	sub ASSIGN_RIGHT_SHIFT          :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>>=';
	}

	sub ASSIGN_SUB                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'-=';
	}

	sub ASSIGN_UNSIGNED_RIGHT_SHIFT :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>>>=';
	}

	sub ASSIGN_XOR                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'^=';
	}

	sub DECREMENT                   :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'--';
	}

	sub DIVIDE                      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'/';
	}

	sub EQUALS                      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'==';
	}

	sub GREATER_THAN                :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>';
	}

	sub GREATER_THAN_OR_EQUALS      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>=';
	}

	sub INCREMENT                   :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'++';
	}

	sub LESS_THAN                   :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'<';
	}

	sub LESS_THAN_OR_EQUALS         :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'<=';
	}

	sub LOGICAL_OR                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'||';
	}

	sub LOGICAL_AND                 :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'&&';
	}

	sub MINUS                       :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'-';
	}

	sub NOT                         :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'!';
	}

	sub NOT_EQUALS                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'!=';
	}

	sub OR                          :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'|';
	}

	sub PLUS                        :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'+';
	}

	sub RIGHT_SHIFT                 :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>>';
	}

	sub MULTIPLY                    :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'*'
	}

	sub MODULO                      :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'%'
	}

	sub LEFT_SHIFT                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'<<'
	}

	sub UNSIGNED_RIGHT_SHIFT        :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'>>>'
	}

	sub XOR                         :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'^'
	}

	sub BIT_NEGATE                  :TOKEN :PROTO(Operator) :ACTION_SYMBOL {
		'~'
	}

	1;
};

1;

