package FTL::View::JSON;
use strict;
use parent "Catalyst::View::JSON";

__PACKAGE__->config(
    expose_stash => 'json',
    );

1;

__END__
