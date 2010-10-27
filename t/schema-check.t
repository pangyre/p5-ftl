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

ok( ! exception {  $schema->deploy(); },
    "Deployment lives" );

my $fixture = YAML::Load(join "", <DATA>);

for my $row ( @{ $fixture } )
{
    $row->{created} = \q{ datetime('now') };
    $row->{user} ||= 1;
    $schema->resultset("Scritto")->create($row)->update;
}

done_testing();


__END__
- scrit: "Something something something"
  user: 1
- scrit: "O HAI"
  user: 1
- scrit: "…"
  user: 1
