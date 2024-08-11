
sub identify_directive_hash {
	my ($document) = @_;

	return unless $document;

	my $physical_line = 1;
	my $logical_significant = 0;

	# virtual token where next_token is actual first token
	my $token = $document->starting_token;

	while ($token = $token->next_token) {
		if ($token->type eq q (NEWLINE)) {
			$physical_line++;
			$logical_significant = 0;
			next;
		}

		if ($token->type eq q (NEWLINE_ESCAPE)) {
			$logical_significant++;
			next;
		}

		next if $logical_significant;
		next if $token->type eq q (WHITESPACE);
		next if $token->type eq q (COMMENT);

		bless $token, q (CSI::DOM::C::Token::Directive)
			if $token->type eq q (HASH)
			;

		$logical_significant++;
	}

	();
}

sub identify_paired {
	my ($document) = @_;

	my @stack;
	

	();
}
