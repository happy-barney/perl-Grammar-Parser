# NAME

Grammar::Parser - Unified grammar API

# VERSION

version 1.0.0

# DESCRIPTION

This module started its life as part of [SQL::Admin](https://metacpan.org/pod/SQL%3A%3AAdmin) after having
maintenance issues with [Parse::RecDescent](https://metacpan.org/pod/Parse%3A%3ARecDescent) grammars.

- it should support multiple backends using unified definition

    There are plenty of grammar parsing modules around, each one with its own callbacks,
    grammar definition, features, lifecycle, performance, ...

    Having unified API makes easier to change backends (regardless of reason).

- support related grammars / grammar inheritance

    Every SQL database has its own dialect based on one of SQL standards.
    Even every version of same product has different subset.

    Maintaining their grammars and/or adding new one will be real pain without
    possibility to reuse common parts.

# AUTHOR

Branislav Zahradník <barney@cpan.org>

# COPYRIGHT AND LICENCE

This file is part of [Grammar::Parser](https://metacpan.org/pod/Grammar%3A%3AParser) distribution.
It can be distributed and/or modified under Artistic license 2.0
