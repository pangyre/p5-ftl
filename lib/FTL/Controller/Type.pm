package FTL::Controller::Type;
use Moose;
use namespace::autoclean;
BEGIN { extends "Catalyst::Controller" }
use feature ":5.10";
sub index :Path Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( types => $c->model("DBIC::Type")->search_rs );
}

sub load :Chained("/") PathPart("type") CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $id ||= $c->request->arguments->[0]; # for forwards
    $c->stash->{type} ||= $c->model("DBIC::Type")->find($id);
}

sub rest :PathPart("") Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $type = $c->stash->{type};
    given ( $c->request->method )
    {
        when ( "GET" )    { $c->forward("view") }
        when ( "POST" )   { $c->forward("edit") }
        when ( "PUT" )    { $c->forward("create") }
        when ( "DELETE" ) { $c->forward("delete") }
    }
}

sub create :Private { # PUT
    my ( $self, $c ) = @_;
    my $type = $c->stash->{type};
    my $params = $c->req->body_params;
    my $type = $c->model("DBIC::Type")->new($params);
    $type->insert_or_update;
    $c->response->redirect( $c->uri_for_action("/type/view",[$type->id]) );
}

sub edit :Private { # POST
    my ( $self, $c ) = @_;
    my $type = $c->stash->{type};
}

sub autocomplete :Local {
    my ( $self, $c ) = @_;
    my $q = $c->req->param("term") || $c->detach;

    my $rs = $c->model("DBIC::Type")->search({
           -or => [
            name => { LIKE => '%'.$q.'%' },
                    description => { LIKE => '%'.$q.'%' },
               ],
                                   },
                                    {
                                        columns => [qw/ id name /],
                                        rows => 25
                                    },
           );
           
           $c->stash(json => [ $rs->hashref_array ] );
$c->detach($c->view("JSON"));
}

__PACKAGE__->meta->make_immutable;

1;

__END__


=head1 NAME

FTL::Controller::Root - Root Controller for FTL

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=head1 AUTHOR

apv

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut