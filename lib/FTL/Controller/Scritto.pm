package FTL::Controller::Resource;
use Moose;
use namespace::autoclean;

BEGIN { extends "Catalyst::Controller::HTML::FormFu" }

__PACKAGE__->config(namespace => "r");

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
}

sub load :Chained("/") PathPart("r") CaptureArgs(1) {
    my ( $self, $c, $name ) = @_;
    $name ||= $c->request->arguments->[0]; # for forwards
    $c->stash->{resource} = $c->model("DBIC::Resource")->find($name)
        || $c->model("DBIC::Resource")->new({ name => $name });
}

sub view :PathPart("") Chained("load") Args(0) {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{resource};
    $c->detach("default") unless $resource->in_storage;
}

sub edit :Chained("load") Args(0) FormConfig {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{resource};

    my $form = $c->stash->{form};
    $form->constraints_from_dbic($c->model("DBIC::Resource"));
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
