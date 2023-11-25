
use v5.14;
use warnings;

use Syntax::Construct 1.008 qw (
	package-block
	package-version
);

package CSI::AST::Token::Insignificant v1.0.0 {
	use Moo;

	BEGIN { extends q (CSI::AST::Token) };

	sub significant { 0 }

	1;
};
