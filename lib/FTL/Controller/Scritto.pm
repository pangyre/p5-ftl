package FTL::Controller::Scritto;
use Moose;
use namespace::autoclean;
use Encode;
use feature ":5.10";

BEGIN { extends "Catalyst::Controller::HTML::FormFu" }

__PACKAGE__->config(namespace => "s");

has "rows" =>
    is => "ro",
    isa => "Int",
    default => 50,
    ;

has "placeholder" =>
    is => "rw",
    isa => "Str",
    default => "[\x{2026}]", # ellipsis.
    ;

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        scritti => $c->model("DBIC::Scritto")->root_rs
               );
}

sub deleted :Local Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        scritti => $c->model("DBIC::Scritto")->deleted_rs
               );
}

sub load :Chained("/") PathPart("s") CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $id ||= $c->request->arguments->[0]; # for forwards
    $c->stash->{scritto} ||= $c->model("DBIC::Scritto")->find($id);
}


sub rest :Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    given ( $c->request->method )
    {
        when ( "GET" )    { $c->go("view") }
        when ( "POST" )   { $c->go("ajax_edit") }
#        when ( "PUT" )    { die "undefined behavior..."; $c->forward("edit") }
        when ( "DELETE" ) { $c->go("delete") }
    }
}

sub delete :Private {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto}
        or die 404;

    if ( $scritto->children_rs->count )
    {
        $c->res->status(406);
        $c->res->body('Scritto id(' . $scritto->id . ') has associated scritti');
        $c->detach;
    }

    if ( $scritto->status eq "deleted" # It's "deleted" already. Make it real.
         or
         $scritto->scrit eq $self->placeholder ) # It's a "dummy."
    {
            $scritto->delete;
    }
    else
    {
        $scritto->status("deleted");
        $scritto->update;
    }
    $c->response->status(204);
}

sub view :PathPart("") Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto};
    $c->go("default") unless $scritto and $scritto->in_storage;
    $c->stash( title => $scritto->root->scrit );
}

sub publish :Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto} || die 404;
    my $view = $c->model("Views")->lookup($scritto->content_type);
    # Probably we should catch it with render here and serve it as file-disposed content, yes?
    $c->forward($c->view($view));
}

sub search :Local Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( json => [] );
    $c->detach($c->view("JSON"))
        unless my $q = $c->request->param("q");

    my @fields = $c->request->param("field");
    push @fields, "scrit" unless @fields;

    my %fields = map { $_ => { LIKE => '%'.$q.'%' } }
         @fields;

    my @cols = $c->request->param("col");

    my $rs = $c->model("DBIC::Scritto")
        ->search(\%fields, { ( columns => \@cols ) x!! @cols })
        ->hashref_rs;

    $c->stash( json => [ $rs->all ] );
    $c->detach($c->view("JSON"));
}

sub search_path :Local Args(1) {
    my ( $self, $c ) = @_;
    die 503;
}

sub raw :Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto} or die 404;
    # die 404 unless $scritto->has_column($field);
    $c->response->content_type( $scritto->content_type || "text/plain" );
    $c->response->body($scritto->scrit);
}

sub rendered :Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto};
    $c->res->status(503);
    $c->response->content_type("text/plain");
    $c->response->body("NOT IMPLEMENTED\n");
}

sub create :Local { # PUT
    my ( $self, $c, $scrit, $more ) = @_; # No id...?
    die if defined $more;

    if (  $c->request->method =~ /\A(POST|PUT)\z/ )
    {
        my $params = $c->req->body_params;
        delete $params->{x};
        $params->{scrit} ||= $self->placeholder;
        # Pass 'duplicate' to allow such.
        my $scritto = delete $params->{duplicate} ?
            $c->model("DBIC::Scritto")->create($params)
            :
            $c->model("DBIC::Scritto")->find_or_create($params);

        $scritto->user(1);
        $scritto->insert;
        $c->response->redirect( $c->uri_for_action("/s/view",[$scritto->id]) );
    }
    else
    {
        $c->stash(scritto => $c->model("DBIC::Scritto")->new({ scrit => $scrit }) );
        $c->go("edit");
    }
}

sub edit :Chained("load") Args(0) FormConfig {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto} ||= $c->model("DBIC::Scritto")->new({});
    my $form = $c->stash->{form};
    $form->model->default_values($scritto);
    $form->constraints_from_dbic($c->model("DBIC::Scritto"));
    $form->render;

    if ( $form->submitted_and_valid )
    {
        $scritto->user(1);
        $form->model->update($scritto);
        $c->response->redirect( $c->uri_for_action("/s/view",[$scritto->id]) );
    }
    else
    {

    }
}

sub position :Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto} || die 404;
    my $position = delete $c->request->params->{position};
    die 406, "bad argument list, only send position"
        if %{ $c->request->params };
    $c->response->status(204);
#    unless ( $scritto->position == $position )
#    {
        $scritto->move_to($position);
        $scritto->update;
#    }
}

sub ajax_edit :Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto} or die 404;
    delete $c->request->params->{id};
    $scritto->update($c->request->params);
    $scritto->discard_changes; # Get non-ref dates back out.
    #use YAML; die YAML::Dump( { $scritto->get_columns } );
    $c->stash( json => { $scritto->get_columns } );
    $c->detach($c->view("JSON"));
}

sub type_edit :Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto} or die "No scritto...";
    my $name = $c->req->param("type");
    die "No name" unless $name;
    my $type = $c->model("DBIC::Type")->find_or_create({name => $name});
    $scritto->type($type);
    $scritto->update();
    $c->response->body("OK");
}

sub default :Path  {
    my ( $self, $c ) = @_;
    my $scrit = $c->request->arguments->[0];
    $c->stash->{scritto} ||=
        $c->model("DBIC::Scritto")->new({ scrit => $scrit });
}

sub json : Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto};
    $c->stash( json => $scritto );
    $c->detach($c->view("JSON"));
}

__PACKAGE__->meta->make_immutable;

1;

__END__

sub preview :Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $article = $c->stash->{article};
    die "RC_404" unless $c->user_exists;
    unless ( $c->user->can_preview_article($article) )
    {
        die "RC_403";
    }

