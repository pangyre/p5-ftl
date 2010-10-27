package FTL::Controller::Search;
use Moose;
use namespace::autoclean;
BEGIN { extends "Catalyst::Controller" }

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
    my $q = $c->req->param("q") || $c->detach;

    my $rs = $c->model("DBIC::Scritto")->search(undef,
                                                # { prefetch => [qw/ user /], }
        );

    my $primary = $rs->search({ scrit => $q });
    my $secondary = $rs->search({
        -or => [
             scrit => { LIKE => '%'.$q.'%' },
            ],
                                },
                                 {
                                     page => 1,
                                     rows => 50
                                 },
        );

    $secondary = $secondary->search({id => { "NOT IN" => [ map { $_->id } $primary->all ] },})
        if $primary->count;

    unless ( $primary->count || $secondary->count )
    {
        $c->go("/s/default", [$q]);
    }
    else
    {
        $c->stash( primary => $primary,
                   secondary => $secondary );
    }
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

FTL::Controller::Search - Search Controller for FTL

=head1 DESCRIPTION

[enter your description here]

=cut

