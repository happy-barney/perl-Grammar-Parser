
use v5.14;
use warnings;

use Syntax::Construct 1.8 qw (
	package-block
	package-version
);

package CSI::AST::Token v1.0.0 {
	use Moo;

	BEGIN { extends q (CSI::AST::Element) };

	1;
};

