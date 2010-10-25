package FTL::Controller::Scritto;
use Moose;
use namespace::autoclean;

BEGIN { extends "Catalyst::Controller::HTML::FormFu" }

__PACKAGE__->config(namespace => "s");

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        scritti => $c->model("DBIC::Scritto")->search_rs(undef,{page=>1})
               );
}

sub scritto :Chained("/") PathPart("s") CaptureArgs(1) {
    my ( $self, $c, $title ) = @_;
    $title ||= $c->request->arguments->[0]; # for forwards
    $c->stash->{scritto} = $c->model("DBIC::Scritto")->find($title)
        || $c->model("DBIC::Scritto")->new({ title => $title });
}

sub default :Path {
    my ( $self, $c ) = @_;
    my $title ||= $c->request->arguments->[0];
    $c->stash->{scritto} ||=
        $c->model("DBIC::Scritto")->new({ title => $title });
}

sub view :PathPart("") Chained("scritto") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto};
    $c->go("default") unless $scritto->in_storage;
}

sub create :Local { # PUT
    my ( $self, $c ) = @_;
    my $scritto = $c->model("DBIC::Scritto")->new($c->req->body_params);
    #$scritto->uuid(rand(1000000));
    $scritto->user(1);
    $scritto->created("now");
    $scritto->insert_or_update;
    $c->go("/index");
}

sub edit :Chained("scritto") Args(0) FormConfig {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto};

    my $form = $c->stash->{form};
    $form->constraints_from_dbic($c->model("DBIC::Scritto"));
    $form->model->default_values( $scritto );

    $form->render;

    if ( $form->submitted_and_valid )
    {
    }

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
