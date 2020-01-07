
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

	1;
};

1;

