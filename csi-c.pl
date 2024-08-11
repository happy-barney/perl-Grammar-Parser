
use v5.14;
use warnings;

use FindBin;

use lib "$FindBin::Bin/lib";

use CSI::Document;
use CSI::Language::C::Grammar;

use Carp::Always;

my $data = do { local $/; <> };

my $lexer = CSI::Language::C::Lexer::->new (
	$data,
);

my $count = 0;
while (my $token = $lexer->next_token) {
	use DDP;
	p $token, colored => 0;
	last if $count++ > 5;
}


__END__

my $document = CSI::Document->new (
	grammar => CSI::Language::C::Grammar::,
	file    => shift,
);

sub csi_dump {
	my ($node, $indent) = @_;
	$indent //= '';

	for my $child ($node->children) {
		if ($child->isa (q (CSI::AST::Node))) {
			say $indent, ref ($child);
			csi_dump ($child, $indent . q (|   ));
		} elsif ($child->significant) {
			say $indent, ref ($child), q (: ), $child->content;
		} else {
			say $indent, ref ($child);
		}
	}
}

#csi_dump ($document);

say $document->dump;
