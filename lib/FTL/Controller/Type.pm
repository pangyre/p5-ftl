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

sub rest :Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $type = $c->stash->{type};
    given ( $c->request->method )
    {
        when ( "GET" )    { $c->go("view") }
        when ( "POST" )   { $c->forward("edit") }
        when ( "PUT" )    { die "undefined behavior..."; $c->forward("edit") }
        when ( "DELETE" ) { $c->forward("delete") }
    }
}

sub view :Private {
    my ( $self, $c ) = @_;
}

sub raw :Chained("load") Args(1) {
    my ( $self, $c, $field ) = @_;
    my $type = $c->stash->{type} or die 404;
    die 404 unless $type->has_column($field);
    $c->response->content_type("text/plain");
    $c->response->body($type->$field);
    $c->detach($c->view("NoOp"));
}

sub delete :Private {
    my ( $self, $c ) = @_;
    my $type = $c->stash->{type};
    if ( $type->scritti_rs->count )
    {
        $c->res->status(406);
        $c->res->body('Type "' . $type->name . '" has associated scritti');
        $c->detach;
    }
    $type->delete;
    $c->response->status(204);
}

sub create :Private { # PUT
    my ( $self, $c ) = @_;
    my $type = $c->stash->{type};
    my $params = $c->req->body_params;
    $type = $c->model("DBIC::Type")->new($params);
    $type->insert;
    $c->response->redirect( $c->uri_for_action("/type/view",[$type->id]) );
}

sub edit :Private { # POST
    my ( $self, $c ) = @_;
    my $type = $c->stash->{type} ||= $c->model("DBIC::Type")->new({});
    $type->insert unless $type->in_storage;
    delete $c->request->body_params->{id}; # wtf?
    $type->update($c->request->body_params);
    $c->response->status(204);
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
