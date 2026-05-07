
use v5.24;
use warnings;

package CSI::Language::Postgresql::Tokenizer v1.0.0 {

	# Insignificants
	sub _part_WHITESPACE              { qr/ [^\S\n]+            /x }
	sub _part_NEW_LINE                { qr/ \n                  /x }
	sub _part_COMMENT_SQL             { qr/ --                  /x }
	sub _part_COMMENT_C               { qr/ \/\*                /x }

	# Significant tokens
	sub _part_IDENTIFIER_SQL          { qr/ (?! \p{Digit}) [_\p{Letter}\p{Letter_Number}\p{Digit}\p{Currency_Symbol}]+ /x }
	sub _part_QUOTATION_MARK          { qr/  "                  /x }
	sub _part_APOSTROPHE              { qr/  '                  /x }
	sub _part_COMMA                   { qr/  ,                  /x }
	sub _part_DOT                     { qr/ \.                  /x }
	sub _part_VERTICAL_LINE           { qr/ \|                  /x }
	sub _part_EQUALS_SIGN             { qr/  =                  /x }
	sub _part_LESS_THAN               { qr/  <                  /x }
	sub _part_GREATER_THAN            { qr/  >                  /x }
	sub _part_PAREN_LEFT              { qr/ \(                  /x }
	sub _part_PAREN_RIGHT             { qr/ \)                  /x }
	sub _part_SOLIDUS                 { qr/ \/                  /x }
	sub _part_ASTERISK                { qr/ \*                  /x }
	sub _part_PERCENT_SIGN            { qr/  %                  /x }
	sub _part_SEMICOLON               { qr/  ;                  /x }
	sub _part_MINUS_SIGN              { qr/  -                  /x }
	sub _part_PLUS_SIGN               { qr/ \+                  /x }

	# mode QCONTENT_APOSTROPHE
	sub _part_ESCAPE_APOSTROPHE       { qr/ ''                  /x }
	sub _part_QCONTENT_APOSTROPHE     { qr/ [^\n\\']+           /x }

	# mode QCONTENT_QUOTATION_MARK
	sub _part_ESCAPE_QUOTATION_MARK   { qr/ ""                  /x }
	sub _part_QCONTENT_QUOTATION_MARK { qr/ [^\n\\"]+           /x }

	# mode COMMENT_C
	sub _part_COMMENT_C_CONTENT       { qr/ (?: [^\n*]+ | (?: \* (?! \/ )) )+ /x }
	sub _part_COMMENT_C_END           { qr/ \*\/ /x }

	# mode COMMENT_LINE
	sub _part_COMMENT_LINE_CONTENT    { qr/ [^\n]+ /x }

	my $initial_mode = 'INITIAL';

	my @modes = (
		#'COMMENT_C',
		#'COMMENT_SINGLE',
		'INITIAL',
		#'QCONTENT_QUOTATION_MARK',
		#'QCONTENT_APOSTROPHE',
	);

	my %mode_action    = _build_mode_map action    => @modes;
	my %mode_regex     = _build_mode_map regex     => @modes;
	my %mode_value_map = _build_mode_map value_map => @modes;

	sub _build_regex {
		my $parts = join "\n|", map {
			die "$_ not defined" unless exists $parts{$_};
			"(?<$_> $parts{$_})"
		} @_;

		return qr/$parts(?(DEFINE)$parts{__DEFINE__})/x;
	}

	sub _build_value_map {
		return +{ reverse @_ };
	}

	sub _build_mode_map {
		my ($type, @modes) = @_;

		map {
			my $builder = "_mode_${_}_${type}";
			my $method  = __PACKAGE__->can ($builder);

			die "Undefined function $builder"
				unless $builder;

			+($_ => $builder->())
		} @modes;
	}

    sub _lookup_value_tranformation {
		my ($self, $value) = @_;

		lc $value;
	}

	sub _mode_INITIAL_action {
		+{
			APOSTROPHE      =>	[
				[ 'push_token',  'QCONTENT_STRING', '' ],
				[ 'change_type', 'QCONTENT_DELIMITER' ],
			],
			QUOTATION_MARK  => [
				[ 'push_token',  'QCONTENT_IDENTIFIER', '' ],
				[ 'change_type', 'QCONTENT_DELIMITER' ],
			],
			COMMENT_SQL     => [
				[ 'push_mode', 'COMMENT_SINGLE' ],
			],
			COMMENT_C       => [
				[ 'push_mode', 'COMMENT_C' ],
			],
		},
	}

	sub _mode_INITIAL_parts {
		qw(
			APOSTROPHE
			ASTERISK
			COMMA
			COMMENT_C
			COMMENT_SQL
			DOT
			EQUALS_SIGN
			GREATER_THAN
			IDENTIFIER
			LESS_THAN
			MINUS_SIGN
			NEW_LINE
			PAREN_LEFT
			PAREN_RIGHT
			PERCENT_SIGN
			PLUS_SIGN
			QUOTATION_MARK
			SEMICOLON
			SOLIDUS
			VERTICAL_LINE
			WHITESPACE
		);
	}

	sub _mode_INITIAL_value_mapping {
		return +{
			IDENTIFIER_SQL => _keyword_mapping,
		},
	}

	sub _mode_COMMENT_C_action {
		+{
			COMMENT_C_CONTENT => [
				[ 'change_type', 'COMMENT_CONTENT' ],
			],
			COMMENT_C_END     => [
				[ 'change_type', 'COMMENT_END' ],
				[ 'pop_mode' ],
			],
		}
	}

	sub _mode_COMMENT_C_regex {
		_build_regex qw[
			COMMENT_C_CONTENT
			COMMENT_C_END
			NEW_LINE
		];
	}

	sub _mode_COMMENT_C_value_mapping {
		return +{},
	}

	sub _mode_COMMENT_LINE_action {
		+{
			COMMENT_LINE_CONTENT => [ [ 'change_type', 'COMMENT_CONTENT' ] ],
			NEW_LINE        => [
				[ 'push_token', 'COMMENT_END' ],
				[ 'pop_mode' ],
			],
		}
	}

	sub _mode_COMMENT_LINE_regex {
		_build_regex qw[
			COMMENT_CPP_CONTENT
			NEW_LINE
		];
	}

	sub _mode_COMMENT_LINE_value_mapping {
		return +{},
	}

	sub _mode_FAVOUR_VALUE_action {
		+{
			%{ _mode_COMMON_action () },
			SOLIDUS         => [ [ 'push_mode', 'REGEX' ] ],
			SOLIDUS_CONT    => [ [ 'push_mode', 'REGEX' ] ],
		}
	}

	sub _mode_FAVOUR_VALUE_parts {
		_mode_COMMON_parts ();
	}

	sub _mode_FAVOUR_VALUE_regex {
		_build_regex _mode_FAVOUR_VALUE_parts ();
	}

	sub _mode_FAVOUR_OPERATOR_action {
		+{
			%{ _mode_COMMON_action () },
		}
	}

	sub _mode_FAVOUR_OPERATOR_regex {
		_mode_FAVOUR_VALUE_regex;
	}

	sub _mode_REGEX_regex {
		_build_regex qw[
			BRACKET_LEFT
			ESCAPE_SEQUENCE
			REGEX_CONTENT
			SOLIDUS
		];
	}

	sub _mode_REGEX_GROUP_regex {
		_build_regex qw[
			BRACE_RIGHT
			ESCAPE_SEQUENCE
			REGEX_GROUP_CONTENT
		];
	}

	sub _mode_QCONTENT_APOSTROPHE_action {
		+{
			APOSTROPHE      => [
				[ 'pop_mode' ],
				[ 'change_type', 'QCONTENT_END' ],
			],
			QCONTENT_APOSTROPHE => [
				[ 'change_type', 'QCONTENT_DATA' ],
			],
		}
	}

	sub _mode_QCONTENT_APOSTROPHE_regex {
		_build_regex qw[
			APOSTROPHE
			NEW_LINE
			ESCAPE_SEQUENCE
			QCONTENT_APOSTROPHE
		];
	}

	sub _mode_QCONTENT_QUOTATION_MARK_regex {
		_build_regex qw[
			QUOTATION_MARK
			NEW_LINE
			ESCAPE_SEQUENCE
			QCONTENT_QUOTATION_MARK
		];
	}

	sub _mode_QCONTENT_QUOTATION_MARK_action {
		+{
			QUOTATION_MARK  => [
				[ 'pop_mode' ],
				[ 'change_type', 'QCONTENT_END' ],
			],
			QCONTENT_QUOTATION_MARK => [
				[ 'change_type', 'QCONTENT_DATA' ],
			],
		}
	}

	sub _mode_QCONTENT_TEMPLATE_regex {
		_build_regex qw[
			GRAVE_ACCENT
			NEW_LINE
			ESCAPE_SEQUENCE
			QCONTENT_INTERPOLATION
			QCONTENT_TEMPLATE
		];
	}

	sub _mode_QCONTENT_TEMPLATE_action {
		+{
			GRAVE_ACCENT  => [
				[ 'pop_mode' ],
				[ 'change_type', 'QCONTENT_END' ],
			],
			QCONTENT_INTERPOLATION => [
				[ 'push_mode', 'FAVOUR_VALUE' ],
			],
			QCONTENT_TEMPLATE => [
				[ 'change_type', 'QCONTENT_DATA' ],
			],
		}
	}

	sub _value_map_keyword {
		_build_value_map (
			map { uc "KEYWORD_$_" => lc $_ } qw(
				A
				ABORT
				ABS
				ABSENT
				ABSOLUTE
				ACCESS
				ACCORDING
				ACOS
				ACTION
				ADA
				ADD
				ADMIN
				AFTER
				AGGREGATE
				ALL
				ALLOCATE
				ALSO
				ALTER
				ALWAYS
				ANALYSE
				ANALYZE
				AND
				ANY
				ARE
				ARRAY
				ARRAY_AGG
				ARRAY_​MAX_​CARDINALITY
				AS
				ASC
				ASENSITIVE
				ASIN
				ASSERTION
				ASSIGNMENT
				ASYMMETRIC
				AT
				ATAN
				ATOMIC
				ATTACH
				ATTRIBUTE
				ATTRIBUTES
				AUTHORIZATION
				AVG
				BACKWARD
				BASE64
				BEFORE
				BEGIN
				BEGIN_FRAME
				BEGIN_PARTITION
				BERNOULLI
				BETWEEN
				BIGINT
				BINARY
				BIT
				BIT_LENGTH
				BLOB
				BLOCKED
				BOM
				BOOLEAN
				BOTH
				BREADTH
				BY
				C
				CACHE
				CALL
				CALLED
				CARDINALITY
				CASCADE
				CASCADED
				CASE
				CAST
				CATALOG
				CATALOG_NAME
				CEIL
				CEILING
				CHAIN
				CHAINING
				CHAR
				CHARACTER
				CHARACTERISTICS
				CHARACTERS
				CHARACTER_LENGTH
				CHARACTER_​SET_​CATALOG
				CHARACTER_SET_NAME
				CHARACTER_SET_SCHEMA
				CHAR_LENGTH
				CHECK
				CHECKPOINT
				CLASS
				CLASSIFIER
				CLASS_ORIGIN
				CLOB
				CLOSE
				CLUSTER
				COALESCE
				COBOL
				COLLATE
				COLLATION
				COLLATION_CATALOG
				COLLATION_NAME
				COLLATION_SCHEMA
				COLLECT
				COLUMN
				COLUMNS
				COLUMN_NAME
				COMMAND_FUNCTION
				COMMAND_​FUNCTION_​CODE
				COMMENT
				COMMENTS
				COMMIT
				COMMITTED
				COMPRESSION
				CONCURRENTLY
				CONDITION
				CONDITIONAL
				CONDITION_NUMBER
				CONFIGURATION
				CONFLICT
				CONNECT
				CONNECTION
				CONNECTION_NAME
				CONSTRAINT
				CONSTRAINTS
				CONSTRAINT_CATALOG
				CONSTRAINT_NAME
				CONSTRAINT_SCHEMA
				CONSTRUCTOR
				CONTAINS
				CONTENT
				CONTINUE
				CONTROL
				CONVERSION
				CONVERT
				COPY
				CORR
				CORRESPONDING
				COS
				COSH
				COST
				COUNT
				COVAR_POP
				COVAR_SAMP
				CREATE
				CROSS
				CSV
				CUBE
				CUME_DIST
				CURRENT
				CURRENT_CATALOG
				CURRENT_DATE
				CURRENT_​DEFAULT_​TRANSFORM_​GROUP
				CURRENT_PATH
				CURRENT_ROLE
				CURRENT_ROW
				CURRENT_SCHEMA
				CURRENT_TIME
				CURRENT_TIMESTAMP
				CURRENT_​TRANSFORM_​GROUP_​FOR_​TYPE
				CURRENT_USER
				CURSOR
				CURSOR_NAME
				CYCLE
				DATA
				DATABASE
				DATALINK
				DATE
				DATETIME_​INTERVAL_​CODE
				DATETIME_​INTERVAL_​PRECISION
				DAY
				DB
				DEALLOCATE
				DEC
				DECFLOAT
				DECIMAL
				DECLARE
				DEFAULT
				DEFAULTS
				DEFERRABLE
				DEFERRED
				DEFINE
				DEFINED
				DEFINER
				DEGREE
				DELETE
				DELIMITER
				DELIMITERS
				DENSE_RANK
				DEPENDS
				DEPTH
				DEREF
				DERIVED
				DESC
				DESCRIBE
				DESCRIPTOR
				DETACH
				DETERMINISTIC
				DIAGNOSTICS
				DICTIONARY
				DISABLE
				DISCARD
				DISCONNECT
				DISPATCH
				DISTINCT
				DLNEWCOPY
				DLPREVIOUSCOPY
				DLURLCOMPLETE
				DLURLCOMPLETEONLY
				DLURLCOMPLETEWRITE
				DLURLPATH
				DLURLPATHONLY
				DLURLPATHWRITE
				DLURLSCHEME
				DLURLSERVER
				DLVALUE
				DO
				DOCUMENT
				DOMAIN
				DOUBLE
				DROP
				DYNAMIC
				DYNAMIC_FUNCTION
				DYNAMIC_​FUNCTION_​CODE
				EACH
				ELEMENT
				ELSE
				EMPTY
				ENABLE
				ENCODING
				ENCRYPTED
				END
				END-EXEC
				END_FRAME
				END_PARTITION
				ENFORCED
				ENUM
				EQUALS
				ERROR
				ESCAPE
				EVENT
				EVERY
				EXCEPT
				EXCEPTION
				EXCLUDE
				EXCLUDING
				EXCLUSIVE
				EXEC
				EXECUTE
				EXISTS
				EXP
				EXPLAIN
				EXPRESSION
				EXTENSION
				EXTERNAL
				EXTRACT
				FALSE
				FAMILY
				FETCH
				FILE
				FILTER
				FINAL
				FINALIZE
				FINISH
				FIRST
				FIRST_VALUE
				FLAG
				FLOAT
				FLOOR
				FOLLOWING
				FOR
				FORCE
				FOREIGN
				FORMAT
				FORTRAN
				FORWARD
				FOUND
				FRAME_ROW
				FREE
				FREEZE
				FROM
				FS
				FULFILL
				FULL
				FUNCTION
				FUNCTIONS
				FUSION
				G
				GENERAL
				GENERATED
				GET
				GLOBAL
				GO
				GOTO
				GRANT
				GRANTED
				GREATEST
				GROUP
				GROUPING
				GROUPS
				HANDLER
				HAVING
				HEADER
				HEX
				HIERARCHY
				HOLD
				HOUR
				ID
				IDENTITY
				IF
				IGNORE
				ILIKE
				IMMEDIATE
				IMMEDIATELY
				IMMUTABLE
				IMPLEMENTATION
				IMPLICIT
				IMPORT
				IN
				INCLUDE
				INCLUDING
				INCREMENT
				INDENT
				INDEX
				INDEXES
				INDICATOR
				INHERIT
				INHERITS
				INITIAL
				INITIALLY
				INLINE
				INNER
				INOUT
				INPUT
				INSENSITIVE
				INSERT
				INSTANCE
				INSTANTIABLE
				INSTEAD
				INT
				INTEGER
				INTEGRITY
				INTERSECT
				INTERSECTION
				INTERVAL
				INTO
				INVOKER
				IS
				ISNULL
				ISOLATION
				JOIN
				JSON
				JSON_ARRAY
				JSON_ARRAYAGG
				JSON_EXISTS
				JSON_OBJECT
				JSON_OBJECTAGG
				JSON_QUERY
				JSON_TABLE
				JSON_TABLE_PRIMITIVE
				JSON_VALUE
				K
				KEEP
				KEY
				KEYS
				KEY_MEMBER
				KEY_TYPE
				LABEL
				LAG
				LANGUAGE
				LARGE
				LAST
				LAST_VALUE
				LATERAL
				LEAD
				LEADING
				LEAKPROOF
				LEAST
				LEFT
				LENGTH
				LEVEL
				LIBRARY
				LIKE
				LIKE_REGEX
				LIMIT
				LINK
				LISTAGG
				LISTEN
				LN
				LOAD
				LOCAL
				LOCALTIME
				LOCALTIMESTAMP
				LOCATION
				LOCATOR
				LOCK
				LOCKED
				LOG
				LOG10
				LOGGED
				LOWER
				M
				MAP
				MAPPING
				MATCH
				MATCHED
				MATCHES
				MATCH_NUMBER
				MATCH_RECOGNIZE
				MATERIALIZED
				MAX
				MAXVALUE
				MEASURES
				MEMBER
				MERGE
				MESSAGE_LENGTH
				MESSAGE_OCTET_LENGTH
				MESSAGE_TEXT
				METHOD
				MIN
				MINUTE
				MINVALUE
				MOD
				MODE
				MODIFIES
				MODULE
				MONTH
				MORE
				MOVE
				MULTISET
				MUMPS
				NAME
				NAMES
				NAMESPACE
				NATIONAL
				NATURAL
				NCHAR
				NCLOB
				NESTED
				NESTING
				NEW
				NEXT
				NFC
				NFD
				NFKC
				NFKD
				NIL
				NO
				NONE
				NORMALIZE
				NORMALIZED
				NOT
				NOTHING
				NOTIFY
				NOTNULL
				NOWAIT
				NTH_VALUE
				NTILE
				NULL
				NULLABLE
				NULLIF
				NULLS
				NUMBER
				NUMERIC
				OBJECT
				OCCURRENCES_REGEX
				OCTETS
				OCTET_LENGTH
				OF
				OFF
				OFFSET
				OIDS
				OLD
				OMIT
				ON
				ONE
				ONLY
				OPEN
				OPERATOR
				OPTION
				OPTIONS
				OR
				ORDER
				ORDERING
				ORDINALITY
				OTHERS
				OUT
				OUTER
				OUTPUT
				OVER
				OVERFLOW
				OVERLAPS
				OVERLAY
				OVERRIDING
				OWNED
				OWNER
				P
				PAD
				PARALLEL
				PARAMETER
				PARAMETER_MODE
				PARAMETER_NAME
				PARAMETER_​ORDINAL_​POSITION
				PARAMETER_​SPECIFIC_​CATALOG
				PARAMETER_​SPECIFIC_​NAME
				PARAMETER_​SPECIFIC_​SCHEMA
				PARSER
				PARTIAL
				PARTITION
				PASCAL
				PASS
				PASSING
				PASSTHROUGH
				PASSWORD
				PAST
				PATH
				PATTERN
				PER
				PERCENT
				PERCENTILE_CONT
				PERCENTILE_DISC
				PERCENT_RANK
				PERIOD
				PERMISSION
				PERMUTE
				PLACING
				PLAN
				PLANS
				PLI
				POLICY
				PORTION
				POSITION
				POSITION_REGEX
				POWER
				PRECEDES
				PRECEDING
				PRECISION
				PREPARE
				PREPARED
				PRESERVE
				PRIMARY
				PRIOR
				PRIVATE
				PRIVILEGES
				PROCEDURAL
				PROCEDURE
				PROCEDURES
				PROGRAM
				PRUNE
				PTF
				PUBLIC
				PUBLICATION
				QUOTE
				QUOTES
				RANGE
				RANK
				READ
				READS
				REAL
				REASSIGN
				RECHECK
				RECOVERY
				RECURSIVE
				REF
				REFERENCES
				REFERENCING
				REFRESH
				REGR_AVGX
				REGR_AVGY
				REGR_COUNT
				REGR_INTERCEPT
				REGR_R2
				REGR_SLOPE
				REGR_SXX
				REGR_SXY
				REGR_SYY
				REINDEX
				RELATIVE
				RELEASE
				RENAME
				REPEATABLE
				REPLACE
				REPLICA
				REQUIRING
				RESET
				RESPECT
				RESTART
				RESTORE
				RESTRICT
				RESULT
				RETURN
				RETURNED_CARDINALITY
				RETURNED_LENGTH
				RETURNED_​OCTET_​LENGTH
				RETURNED_SQLSTATE
				RETURNING
				RETURNS
				REVOKE
				RIGHT
				ROLE
				ROLLBACK
				ROLLUP
				ROUTINE
				ROUTINES
				ROUTINE_CATALOG
				ROUTINE_NAME
				ROUTINE_SCHEMA
				ROW
				ROWS
				ROW_COUNT
				ROW_NUMBER
				RULE
				RUNNING
				SAVEPOINT
				SCALAR
				SCALE
				SCHEMA
				SCHEMAS
				SCHEMA_NAME
				SCOPE
				SCOPE_CATALOG
				SCOPE_NAME
				SCOPE_SCHEMA
				SCROLL
				SEARCH
				SECOND
				SECTION
				SECURITY
				SEEK
				SELECT
				SELECTIVE
				SELF
				SENSITIVE
				SEQUENCE
				SEQUENCES
				SERIALIZABLE
				SERVER
				SERVER_NAME
				SESSION
				SESSION_USER
				SET
				SETOF
				SETS
				SHARE
				SHOW
				SIMILAR
				SIMPLE
				SIN
				SINH
				SIZE
				SKIP
				SMALLINT
				SNAPSHOT
				SOME
				SOURCE
				SPACE
				SPECIFIC
				SPECIFICTYPE
				SPECIFIC_NAME
				SQL
				SQLCODE
				SQLERROR
				SQLEXCEPTION
				SQLSTATE
				SQLWARNING
				SQRT
				STABLE
				STANDALONE
				START
				STATE
				STATEMENT
				STATIC
				STATISTICS
				STDDEV_POP
				STDDEV_SAMP
				STDIN
				STDOUT
				STORAGE
				STORED
				STRICT
				STRING
				STRIP
				STRUCTURE
				STYLE
				SUBCLASS_ORIGIN
				SUBMULTISET
				SUBSCRIPTION
				SUBSET
				SUBSTRING
				SUBSTRING_REGEX
				SUCCEEDS
				SUM
				SUPPORT
				SYMMETRIC
				SYSID
				SYSTEM
				SYSTEM_TIME
				SYSTEM_USER
				T
				TABLE
				TABLES
				TABLESAMPLE
				TABLESPACE
				TABLE_NAME
				TAN
				TANH
				TEMP
				TEMPLATE
				TEMPORARY
				TEXT
				THEN
				THROUGH
				TIES
				TIME
				TIMESTAMP
				TIMEZONE_HOUR
				TIMEZONE_MINUTE
				TO
				TOKEN
				TOP_LEVEL_COUNT
				TRAILING
				TRANSACTION
				TRANSACTIONS_​COMMITTED
				TRANSACTIONS_​ROLLED_​BACK
				TRANSACTION_ACTIVE
				TRANSFORM
				TRANSFORMS
				TRANSLATE
				TRANSLATE_REGEX
				TRANSLATION
				TREAT
				TRIGGER
				TRIGGER_CATALOG
				TRIGGER_NAME
				TRIGGER_SCHEMA
				TRIM
				TRIM_ARRAY
				TRUE
				TRUNCATE
				TRUSTED
				TYPE
				TYPES
				UESCAPE
				UNBOUNDED
				UNCOMMITTED
				UNCONDITIONAL
				UNDER
				UNENCRYPTED
				UNION
				UNIQUE
				UNKNOWN
				UNLINK
				UNLISTEN
				UNLOGGED
				UNMATCHED
				UNNAMED
				UNNEST
				UNTIL
				UNTYPED
				UPDATE
				UPPER
				URI
				USAGE
				USER
				USER_​DEFINED_​TYPE_​CATALOG
				USER_​DEFINED_​TYPE_​CODE
				USER_​DEFINED_​TYPE_​NAME
				USER_​DEFINED_​TYPE_​SCHEMA
				USING
				UTF16
				UTF32
				UTF8
				VACUUM
				VALID
				VALIDATE
				VALIDATOR
				VALUE
				VALUES
				VALUE_OF
				VARBINARY
				VARCHAR
				VARIADIC
				VARYING
				VAR_POP
				VAR_SAMP
				VERBOSE
				VERSION
				VERSIONING
				VIEW
				VIEWS
				VOLATILE
				WHEN
				WHENEVER
				WHERE
				WHITESPACE
				WIDTH_BUCKET
				WINDOW
				WITH
				WITHIN
				WITHOUT
				WORK
				WRAPPER
				WRITE
				XML
				XMLAGG
				XMLATTRIBUTES
				XMLBINARY
				XMLCAST
				XMLCOMMENT
				XMLCONCAT
				XMLDECLARATION
				XMLDOCUMENT
				XMLELEMENT
				XMLEXISTS
				XMLFOREST
				XMLITERATE
				XMLNAMESPACES
				XMLPARSE
				XMLPI
				XMLQUERY
				XMLROOT
				XMLSCHEMA
				XMLSERIALIZE
				XMLTABLE
				XMLTEXT
				XMLVALIDATE
				YEAR
				YES
				ZONE
			)
		);
	}


		QCONTENT_APOSTROPHE => _build_value_map (
			APOSTROPHE => 'QCONTENT_END',
			QCONTENT_APOSTROPHE => 'QCONTENT_DATA',
		),
		QCONTENT_QUOTATION_MARK => _build_value_map (
			QCONTENT_QUOTATION_MARK => 'QCONTENT_DATA',
		),
	);

	our @mode_stack;
	our @token_queue;
	our $str;

	sub _run_action {
		my ($token) = @_;
		my $mode_map = $mode_map{$mode_stack[-1]};

		my $spec = undef
			// $mode_map->{$token->{type}}
			// $mode_map->{''}
			;

		return unless $spec;

		LOOP:
		for my $entry (@$spec) {
			my ($action, @params) = @$entry;

			next unless $action;

			goto uc $action;

			CHANGE_TYPE: {
				$token->{type} = $params[0];
				next LOOP;
			}

			PUSH_MODE: {
				push @mode_stack, @params;
				next LOOP;
			}

			PUSH_TOKEN: {
				push @token_queue, { type => $params[0], value => $params[1] // '' };
				next LOOP;
			}

			POP_MODE: {
				pop @mode_stack;
				next LOOP;
			}
		}

		return;
	}

	sub tokenize {
		my ($self, $string) = @_;

		local @mode_stack = ($initial_mode);
		local $str = $string;

		$self->_tokenize_string;
	}

	sub _tokenize_string {
		my ($self) = @_;
		local @token_queue;
		my ($line, $column) = (1, 1);

		while (1) {
			my $lookup_regex = $mode_regex{$mode_stack[-1]};
			my $current_mapping  = $mapping{$mode_stack[-1]};

			last
				unless $str =~ m/\G $lookup_regex /xgcm;

			my ($match, $value) = %+;

			if (length $value) {
				if ($match eq 'New_Line') {
					$line++;
					$column = 1;
				} else {
					$column += length $value;
				}
			}

			my $token = {
				type => $current_mapping->{$match}{$value} // $match,
				value => $value,
			};

			next
				if _run_action ($token);

			# implicit action
			push @token_queue, $token;
		}

		unless ($str =~ m/\G \Z/xgcm) {
			my $pos = pos $str;
			my $sub = substr $str, $pos, 16;
			say "oops, unmatch at $line:$column: '$sub'";
			say "mode: ${\ join ' ', @mode_stack }";
			exit;
		}

		return @token_queue;
	}


	1;
};

__END__
my %mode_regex = (
	INITIAL => qr/
	/x,
	FAVOUR_VALUE => qr/
		(?<IDENTIFIER> (?!      \pN) [\$_\pL\pN]+   )
		| (?<NEW_LINE>          \n                  )
		| (?<WHITESPACE>        [^\S\n]+            )
		| (?<DIGITS>            [0-9]+              )
		| (?<COMMENT_C>         \/\*                )
		| (?<COMMENT_CPP>       \/\/                )

		| (?<REGEXP>            \/                  )

		| (?<AMPERSAND>         &                   )
		| (?<APOSTROPHE>        '                   )
		| (?<ASTERISK>          \*                  )
		| (?<BRACE_LEFT>        \{                  )
		| (?<BRACE_RIGHT>       \}                  )
		| (?<BRACKET_LEFT>      \[                  )
		| (?<BRACKET_RIGHT>     \]                  )
		| (?<CIRCUMFLEX_ACCENT> \^                  )
		| (?<COLON>             :                   )
		| (?<COMERCIAL_AT>      @                   )
		| (?<COMMA>             ,                   )
		| (?<DOT>               \.                  )
		| (?<EQUALS_SIGN>       =                   )
		| (?<EXCLAMATION_MARK>  !                   )
		| (?<GRAVE_ACCENT>      \`                  )
		| (?<GREATER_THAN>      >                   )
		| (?<LESS_THAN>         <                   )
		| (?<MINUS_SIGN>        -                   )
		| (?<NUMBER_SIGN>       \#                  )
		| (?<PAREN_LEFT>        \(                  )
		| (?<PAREN_RIGHT>       \)                  )
		| (?<PERCENT_SIGN>      %                   )
		| (?<PLUS_SIGN>         \+                  )
		| (?<QUESTION_MARK>     \?                  )
		| (?<QUOTATION_MARK>    "                   )
		| (?<REVERSE_SOLIDUS>   \\                  )
		| (?<SEMICOLON>         ;                   )
		| (?<VERTICAL_LINE>     \|                  )
	/x,
	COMMENT_CPP => qr/
		(?<NEW_LINE>            \n                  )
		| (?<COMMENT_PART>      .+                  )
	/x,
	COMMENT_C => qr/
		(?<COMMENT_C_END>       \*\/                )
		| (?<NEW_LINE>          \n                  )
		| (?<COMMENT_PART>      (?: [^\n*]* (?: \* (?! \/ ))* )* )
	/x,
	TEMPLATE_STRING => qr/
		(?<INTERPOLATION>       \$\{                )
		| (?<NEW_LINE>          \n                  )
		| (?<GRAVE_ACCENT>      \`                  )
		| (?<QCONTENT>          (?: [^\n\\\`\$]* (?: \\ .)* (?: \$ (?! \{ ))* )* )
	/x,
	REGEXP => qr/
		(?<NEW_LINE>            \n                  )
		| (?<SOLIDUS>           \/                  )
		| (?<QCONTENT>          [^\n\\\/]+          )
		| (?<ESCAPE>            (?: \\ .)           )
	/x,
);

my %mode_map = (
	INITIAL => {
		COMMENT_C       => 'COMMENT_C',
		COMMENT_CPP     => 'COMMENT_CPP',
		GRAVE_ACCENT    => 'TEMPLATE_STRING',
		PAREN_LEFT      => 'FAVOUR_VALUE',
		BRACE_LEFT      => 'FAVOUR_VALUE',
		BRACKET_LEFT    => 'FAVOUR_VALUE',
		EQUALS_SIGN     => 'FAVOUR_VALUE',
		PAREN_RIGHT     => undef,
		BRACE_RIGHT     => undef,
		BRACKET_RIGHT   => undef,
	},
	FAVOUR_VALUE => {
		COMMENT_C       => 'COMMENT_C',
		COMMENT_CPP     => 'COMMENT_CPP',
		GRAVE_ACCENT    => 'TEMPLATE_STRING',
		PAREN_LEFT      => '',
		BRACE_LEFT      => '',
		BRACKET_LEFT    => '',
		EQUALS_SIGN     => '',
		REGEXP          => 'REGEXP',
		WHITESPACE      => '',
		NEW_LINE        => '',
		''              => undef,
	},
	REGEXP => {
		SOLIDUS         => undef,
	},
	COMMENT_CPP => {
		NEW_LINE        => undef,
	},
	COMMENT_C => {
		COMMENT_C_END   => undef,
	},
	TEMPLATE_STRING => {
		INTERPOLATION   => 'FAVOUR_VALUE',
		GRAVE_ACCENT    => undef,
	},
);

	1;
};

__END__

	my $regex = qw/
		(?<Identifier>           \b (?!= \p{N} ) [\$_\p{L}\p{N}]+ \b )
		| (?
		)
	/x;

	my %value_table = (
		any          => 'ANY',
		boolean      => 'BOOLEAN',
		number       => 'NUMBER',
	);

	my @tranformations = (
		[ 'IDENTIFIER', 'IDENTIFIER'           ] => 'IDENTIFIER',
		[ 'IDENTIFIER', 'DOT',  \ 'IDENTIFIER' ] => 'MODULE_NAME',
		[ 'MODULE_NAME', 'DOT', \ 'IDENTIFIER' ] => 'MODULE_NAME',
		[ 'MODULE_NAME', 'IDENTIFIER'          ] => 'MODULE_NAME',
	);
	

	my %tranform_table = (
		Identifier => {
			Identifier => [ merge => 'Identifier' ],
			Dot        => [ merge => 'Qualification' ],
		},
		Qualification => {
			Identifier => [ merge => 'Qualification' ],
		},
		Forward_Slash => {
			Forward_Slash => [ merge => 'Comment_Cpp' ],
			Asterisk      => [ merge => 'Comment_C' ],
		},
		Comment_Cpp => {
			New_Line       => [ 'submit' ],
			''             => [ 'merge' ],
		},
		Comment_C   => {
			Asterisk       => [ merge => 'Comment_C_Tail' ],
			''             => [ 'merge' ],
		},
		Comment_C_Tail => {
		}
	);

	sub _next_token {
		my $token = $self->pop_token;

		while (my $tranformation = $tranform_table{ $token->{type} }) {
			my $lookup = $self->lookup_token;

			my ($action, @args) = @{ $tranformation->{$lookup->{type}} // $tranformation->{''} // [] };

			last unless $action;

			goto $action;

			merge:
			my $new_type = @args ? $args[0] : $token->{type};
			$token = build_logical_token ($new_type, $token, $self->pop_token);
			next;

			submit:
			last;
		}

		if ($self->

		given ($token->{token}) {
			when { 
	}
	
