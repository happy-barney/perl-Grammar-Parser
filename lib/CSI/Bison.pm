
use v5.14;
use warnings;

package CSI::Bison {

	use CSI::Grammar::Builder (
		rules => qw [
			declaration
			declaration_code
			declaration_define_feature
			declaration_defines
			declaration_destructor
			declaration_expect
			declaration_language
			declaration_locations
			declaration_name_prefix
			declaration_nonterminal
			declaration_param
			declaration_precedence
			declaration_printer
			declaration_prologue
			declaration_pure
			declaration_start
			declaration_token
			declaration_type
			declaration_union
			document
			document_minimal
			empty
		],
		tokens => qw [
			EMPTY
			PERCENT_SIGN
		],
	);

	BEGIN {
		# Atoms
		declare atom Newline      => as pattern qr ( [\n] )x;
		declare atom Percent_Sign => as pattern qr ( [%]  )x;
		declare atom 
	}

	BEGIN {
		

	BEGIN {
		declare token IDENTIFIER => as
			pattern => qr ( \b (?! \d) [a-zA-Z_0-9]+ \b )
			;

		declare token PERCENT_SIGN => as
			pattern => qr ( [%] )x
			;

		declare  EMPTY => as IDENTIFIER [q (empty)];
	}

	BEGIN {
		declare rule q (document_minimal);
		declare rule q (section_separator);
		declare rule q (section_epilogue);

	declare rule document => as
		class   => q (CSI::DOM::Bison::Document),
		grammar => [
			[ document_minimal ],
			[ document_minimal ~~ section_separator ~~ section_epilogue ],
		];

	declare rule document_minimal as
		grammar => [
			[ section_declaration ~~ section_separator ~~ section_grammar ],
		];

	declare rule empty as
		class   => q (CSI::DOM::Bison::Empty)
		grammar => [
			[ PERCENT_SIGN >> EMPTY ],
		];

	declare rule declaration as
		grammar => declaration_code
			|  declaration_define_feature
			|  declaration_defines
			|  declaration_destructor
			|  declaration_expect
			|  declaration_language
			|  declaration_locations
			|  declaration_name_prefix
			|  declaration_nonterminal
			|  declaration_param
			|  declaration_precedence
			|  declaration_printer
			|  declaration_prologue
			|  declaration_pure
			|  declaration_start
			|  declaration_token
			|  declaration_type
			|  declaration_union
		;

	}

	1;
}
