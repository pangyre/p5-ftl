package FTL::Controller::Search;
use Moose;
use namespace::autoclean;
BEGIN { extends "Catalyst::Controller" }

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
    my $q = $c->req->param("q") || $c->detach;

    my $rs = $c->model("DBIC::Scritto")->search(undef,
                                                { prefetch => [qw/ user /], });
    my $primary = $rs->search({ title => $q });
    my $secondary => $rs->search({ -or => [
                                        title => { LIKE => '%'.$q.'%' },
                                        body => { LIKE => '%'.$q.'%' },
                                       ]
                                 },
                                 { page => 1,
                                   rows => 50 },
        );

#    unless ( $primary->count || $secondary->count )
    unless ( $primary->count )
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
