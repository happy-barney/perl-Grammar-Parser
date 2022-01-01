
= Work In Progress

This repostory holds development of Grammar::Parser and CSI tools.

== [Grammar::Parser][tree/dev-grammar-parser]

Evolved from [SQL::Admin][../perl-SQL-Admin] aims to provide
- unified grammar, lexer, and rule actions definition
- multiple backend support (Marpa, YAPP, regex, ...)
- grammar introspection (static analysis, debugging, ...)

== CSI

CSI stands for source code investigation hinting your code is a crime scene to
be investigated.

CSI aims to be language independent, starting with Java support.

TODO
- [ ] critic (static analysis)
- [ ] tidy
- [ ] language transformation / refactoring

Similar tools:
- [Babble][https://metacpan.org/pod/Babble]
- [Code::ART][https://metacpan.org/pod/Babble]

== [CSI::Grammar][tree/dev-csi-grammar]

Inspired by raku's Grammar, provides intermediate glue between Grammar::Parser
and CSI needs.

TODOs:
- [ ] C/XS compilation
- [ ] IDE/editor language support
  - [ ] emacs / raku-mode
  - [ ] emacs / perl-mode

== [CSI::Language::Java][tree/dev-csi-java]

Proof of concept language implementation.

Why Java?
- simple grammar
- very noisy language => lot of noisy code (record holder so far: 1.1 MB java file)
- lot of noisy code suggests lot of shitty code (lot of use cases for CSI)
