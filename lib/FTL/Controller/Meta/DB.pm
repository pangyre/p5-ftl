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

sub backup : Local Args(0) {
    my ( $self, $c ) = @_;
    my $backup = $c->path_to("db.backup.sqlt");
    $c->model("DBIC")->storage->dbh->sqlite_backup_to_file($backup);
    $c->stash(content => "OK: " . $backup,
              title => "Database backup created",
              template => "index.tt");
}

use DBIx::Class::Fixtures;

sub dump_fixtures : Local Args(0) {
    my ( $self, $c ) = @_;

    my $fixtures = DBIx::Class::Fixtures->new({
        config_dir => $c->path_to("/etc/config"),
                                              });        

# etc/config/site.json

    $fixtures->dump({
        all => 1, # just dump everything that's in the schema
        #config => "site.json",
        schema => $c->model("DBIC")->schema,
        directory => $c->path_to("/etc/fixture"), # output directory
                    });
    $c->response->status(204);
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
        $c->request->query_params->{type} : "html";

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
