package FTL::Controller::Type;
use Moose;
use namespace::autoclean;
BEGIN { extends "Catalyst::Controller" }

#sub index :Path Args(0) {
#    my ( $self, $c ) = @_;
#}

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
