package FTL::View::NoOp;
use warnings;
use strict;
use parent "Catalyst::Component"; # The View pieces aren't used.

sub process {
    my ( $self, $c ) = @_;
    $c->response->body("");
    $c->response->content_length(0);
    $c->response->status(204);
}

1;

__END__


=head1 NAME

FTL::View::TT - TT View for FTL

=head1 DESCRIPTION

TT View for FTL.

=head1 SEE ALSO

L<FTL>.

=cut
