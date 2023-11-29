
use strict;
use warnings;

package CSI::Common::Sense;
use parent q (Import::Base);

# Syntax::Construct also says which perl version provides required construct
use Syntax::Construct v1.8 qw (
	package-block
	package-version
);

our @IMPORT_MODULES = (
	q (strict),
	q (warnings),
	q (feature) => [ qw (:5.14) ],

	q (mro)     => [ qw (c3) ],

	q (utf8),
);

1;
