package FTL::View::Plain;
use strict;
use warnings;
use parent "Catalyst::View::TT";

__PACKAGE__->config(
    ENCODING => "utf8",
    TEMPLATE_EXTENSION => '.txt',
    # PRE_PROCESS => 'lib/macros.tt',
    RECURSION => 1,
    render_die => 1,
);

sub process {
    my ( $self, $c, @args ) = @_;
    $c->response->content_type("text/plain");
    $self->SUPER::process($c, @args);
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
