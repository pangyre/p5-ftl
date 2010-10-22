use warnings;
use strict;
use Test::More;
use Test::Exception;

BEGIN { use_ok "FTL::Schema" }

my $db = "dummy.sqlt";
unlink $db if -e $db;

ok( my $schema = FTL::Schema->connect("dbi:SQLite:$db"),
    "Connecting to an SQLite dummy" );

lives_ok( sub { $schema->deploy() },
          "Deployment lives" );


done_testing();
