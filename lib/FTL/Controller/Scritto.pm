package FTL::Controller::Scritto;
use Moose;
use namespace::autoclean;

BEGIN { extends "Catalyst::Controller::HTML::FormFu" }

__PACKAGE__->config(namespace => "s");

has "rows" =>
    is => "ro",
    default => 50,
    ;

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        scritti => $c->model("DBIC::Scritto")->search_rs(undef,{page=>1,rows=>$self->rows})
               );
}

sub scritto :Chained("/") PathPart("s") CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $id ||= $c->request->arguments->[0]; # for forwards
    $c->stash->{scritto} ||= $c->model("DBIC::Scritto")->find($id);
    $c->stash->{scritto}->id || die "404: $id";
}

sub view :PathPart("") Chained("scritto") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto};
    $c->go("default") unless $scritto->in_storage;
}

sub create :Local { # PUT
    my ( $self, $c, $scrit, $more ) = @_; # No id...?
    die if defined $more;

    if (  $c->request->method =~ /\A(POST|PUT)\z/ )
    {
        my $params = $c->req->body_params;
        delete $params->{x};
        my $scritto = $c->model("DBIC::Scritto")->new($params);
        #$scritto->uuid(rand(1000000));
        $scritto->user(1);
        $scritto->created("now");
        $scritto->insert_or_update;
        $c->response->redirect( $c->uri_for_action("/s/view",[$scritto->id]) );
        # $c->go("index"); # 321 redirect I think.
    }
    else
    {
        $c->stash(scritto => $c->model("DBIC::Scritto")->new({ scrit => $scrit }) );
        $c->go("edit");
    }
}

sub edit :Chained("scritto") Args(0) FormConfig {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto} ||= $c->model("DBIC::Scritto")->new({});
    my $form = $c->stash->{form};
    $form->constraints_from_dbic($c->model("DBIC::Scritto"));
    $form->model->default_values($scritto);

    $form->render;

    if ( $form->submitted_and_valid )
    {
        $scritto->user(1);
        $scritto->created(\q{datetime('now')});
        $form->model->update($scritto);
        $c->response->redirect( $c->uri_for_action("/s/view",[$scritto->id]) );
    }
}

sub ajax_edit :Chained("scritto") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto} or die "No scritto...";# ||= $c->model("DBIC::Scritto")->new({});
    # $scritto->$_($c->req->param($_)) for $scritto->columns;
    $scritto->scrit($c->req->param("value"));
    $scritto->update();
    $c->response->body($scritto);
}

sub default :Path  {
    my ( $self, $c ) = @_;
    my $scrit = $c->request->arguments->[0];
    $c->stash->{scritto} ||=
        $c->model("DBIC::Scritto")->new({ scrit => $scrit });
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

