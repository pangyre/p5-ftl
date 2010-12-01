package FTL::Model::Views;
use Moose;
use common::sense;
use namespace::autoclean;

sub lookup {
    my $self = shift;
    my $content_type = shift;
    "Plain";
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

FTL::Model::Views - To map content types to views.

=head1 REFER TO

L<FTL::Manual> and L<FTL>.

=cut
