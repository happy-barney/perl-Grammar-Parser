
use v5.14;
use Syntax::Construct v1.8 qw[ package-version package-block ];

use strict;
use warnings;

package Grammar::Parser v1.0.0 {
	1;
};

__END__

=pod

=encoding utf8

=head1 NAME

Grammar::Parser - Unified grammar API

=head1 DESCRIPTION

This module started its life as part of L<< SQL::Admin >> after having
maintenance issues with L<< Parse::RecDescent >> grammars.

Basic idea is:

=over

=item support multiple backends using unified definition and access API

There are plenty of grammar parsing modules around, each one with its own callbacks,
grammar definition, features, lifecycle, performance.

Having unified API makes easier to change backends (regardless of reason).

=item support related grammars

Every SQL database has its own dialect based on one of SQL standards.
Even every version has different subset.

Maintaining their grammars and/or adding new one will be real pain without
possibility to reuse common parts.

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file is part of L<< Grammar::Parser >>.
It can be distributed and/or modified under Artistic license 2.0

=cut

