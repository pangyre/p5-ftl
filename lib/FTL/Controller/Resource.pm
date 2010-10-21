package FTL::Controller::Resource;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => 'r');

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body("FTL");
}

sub resource :Path Args(1) {
    my ( $self, $c, $page ) = @_;
    $c->response->body("FTL");
}

sub default :Path Args(1) {
    my ( $self, $c, $page ) = @_;
}


__PACKAGE__->meta->make_immutable;

1;
