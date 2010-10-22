package FTL::Schema;
use strict;
use warnings;
use parent "DBIx::Class::Schema";

__PACKAGE__->load_namespaces(
    result_namespace => 'Result',
);

our $VERSION = "0.001";

1;

__END__
