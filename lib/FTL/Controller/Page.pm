package FTL::Controller::Page;
use Moose;
use namespace::autoclean;
use Encode;

BEGIN { extends "Catalyst::Controller" }

sub page :Path {
    my ( $self, $c, @path ) = @_;
    @path or die 404;
    $c->stash( include => join("/", @path) . ".tt" )
}

__PACKAGE__->meta->make_immutable;

1;

__END__


