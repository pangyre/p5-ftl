package FTL::View::TT;
use strict;
use warnings;
use parent "Catalyst::View::TT";

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

1;

__END__


=head1 NAME

FTL::View::TT - TT View for FTL

=head1 DESCRIPTION

TT View for FTL.

=head1 SEE ALSO

L<FTL>.

=cut
