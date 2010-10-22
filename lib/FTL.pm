package FTL;
use Moose;
use namespace::autoclean;
use Catalyst::Runtime 5.80;

use Catalyst qw/
    ConfigLoader
    Static::Simple
/;

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;


__PACKAGE__->config(
    "Plugin::ConfigLoader" => {
        file => "ftl.yml", #__PACKAGE__->path_to("conf"),
        substitutions => {}
    },
);

__PACKAGE__->setup();

1;

__END__

=head1 NAME

FTL - Catalyst based application

=head1 SYNOPSIS

    script/ftl_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<FTL::Controller::Root>, L<Catalyst>

=head1 AUTHOR

apv

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
