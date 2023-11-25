
use v5.14;
use warnings;

use Syntax::Construct 1.008 qw (
	package-block
	package-version
);

package CSI::AST::Token::Comment v1.0.0 {
	use Moo;

	BEGIN { extends q (CSI::AST::Token::Insignificant) };

	1;
};
