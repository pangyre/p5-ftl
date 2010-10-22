package FTL::Controller::Scritto;
use Moose;
use namespace::autoclean;

BEGIN { extends "Catalyst::Controller::HTML::FormFu" }

__PACKAGE__->config(namespace => "s");

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
}

sub scritto :Chained("/") PathPart("s") CaptureArgs(1) {
    my ( $self, $c, $title ) = @_;
    $title ||= $c->request->arguments->[0]; # for forwards
    $c->stash->{scritto} = $c->model("Scritto")->find($title)
        || $c->model("Scritto")->new({ title => $title });
}

sub default :Path {

}

sub view :PathPart("") Chained("scritto") Args(0) {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto};
    $c->go("default") unless $scritto->in_storage;
}

sub edit :Chained("scritto") Args(0) FormConfig {
    my ( $self, $c ) = @_;
    my $scritto = $c->stash->{scritto};

    my $form = $c->stash->{form};
    $form->constraints_from_dbic($c->model("Scritto"));
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
