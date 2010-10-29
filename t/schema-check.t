use warnings;
use strict;
use Test::More;
use Test::Fatal;
use utf8;
use YAML;

BEGIN { use_ok "FTL::Schema" }

my $db = "dummy.sqlt";
unlink $db if -e $db;

ok( my $schema = FTL::Schema->connect("dbi:SQLite:$db"),
    "Connecting to an SQLite dummy" );

ok( ! exception { $schema->deploy(); },
    "Deployment lives" );

my $fixture = YAML::Load(join "", <DATA>);

for my $source ( keys %{ $fixture } )
{
    for my $rec ( @{ $fixture->{$source} } )
    {
        $schema->resultset($source)->create($rec);
    }
}

done_testing();

__END__
Scritto:
  - scrit: "Something something something"
    user: 1
  - scrit: "…"
    user: 1
Type:
  - name: "book"
  - name: "section"
  - name: "chapter"
  - name: "prose"
  - name: "dialog"
  - name: "note"
  - name: "notebook"
  - name: "character"
  - name: "character study"
  - name: "stanza"
  - name: "poem"
  - name: "project"
  - name: "scene"
  - name: "collection"
  - name: "chapbook"
  - name: "magazine"
  - name: "article"
