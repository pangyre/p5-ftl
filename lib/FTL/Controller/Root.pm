package FTL::Controller::Root;
use Moose;
use namespace::autoclean;
BEGIN { extends "Catalyst::Controller" }

__PACKAGE__->config(namespace => "");

sub index :Path Args(0) {
#    my ( $self, $c ) = @_;
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body("Page not found");
    $c->response->status(404);
}

sub render : ActionClass("RenderView") {}

sub end : Private {
    my ( $self, $c ) = @_;
    $c->forward("render") unless @{$c->error};
    if ( grep /no such table/, @{$c->error} )
    {
        $c->log->error("Apparently there is no database, attempting auto deployment");
        $c->model("DBIC")->schema->deploy();
        $c->clear_errors;
        $c->forward("render");
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

FTL::Controller::Root - Root Controller for FTL.

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=head1 AUTHOR

Ashley Pond V.

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
