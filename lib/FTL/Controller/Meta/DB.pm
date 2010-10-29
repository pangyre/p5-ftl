package FTL::Controller::Meta::DB;
use Moose;
use namespace::autoclean;
BEGIN { extends "Catalyst::Controller" }

use DBIx::Class::Fixtures;
use SQL::Translator;

sub index :Path Args(0) {
    my ( $self, $c ) = @_;
    $c->go("schema");
}

sub populate : Local Args(0) {
    my ( $self, $c ) = @_;

}

sub dump : Local Args(0) {

}

sub schema : Local Args(0) {
    my ( $self, $c ) = @_;
    my %options = ( html => { mime => "text/html",
                              producer => "HTML",
                          },
                    mysql => { mime => "text/plain",
                               producer => "MySQL",
                           },
                    sqlite => { mime => "text/plain",
                                producer => "SQLite",
                           },
                    pg => { mime => "text/plain",
                               producer => "PostgreSQL",
                           },
                    );

    my $type = $options{$c->request->query_params->{type}} ?
        $c->request->query_params->{type} : 'html';

    my $choice = $options{$type};

    my $translator = SQL::Translator->new(
          parser        => "SQL::Translator::Parser::DBIx::Class",
          data          => $c->model("DBIC")->schema,
          producer      => $choice->{producer},
          producer_args => {
#              output_type => 'png',
#              title       => 'MyApp Schema',
          },
                                          ) or die SQL::Translator->error;

    $c->res->content_type($choice->{mime});

    my $body = $translator->translate;
    $body =~ s{\A.+?<body[^>]*>|</body>.+}{}sg;
    $c->stash( content => $body );
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

=cut
