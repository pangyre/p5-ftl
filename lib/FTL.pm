package FTL;
use Moose;
use common::sense; # Test flight. Modern::Perl's mro fucks with Moose/Cat.
use namespace::autoclean;
use Catalyst::Runtime 5.80;
use URI;

use Catalyst qw/
                Unicode::Encoding
                ConfigLoader
                Static::Simple
               /;

extends 'Catalyst';

our $VERSION = '0.01';
our $AUTHORITY = "cpan:ASHLEY";

__PACKAGE__->config(
    "Plugin::ConfigLoader" => {
        file => "ftl.yml", #__PACKAGE__->path_to("conf"),
        substitutions => {},
    },
    static => {
        debug => 1,
        #dirs => [ "static" ],
        include_path => [ __PACKAGE__->path_to('root/static'), ],
        ignore_extensions => [],
    },
);

has "repository" =>
    is => "ro",
    isa => "URI",
    lazy => 1,
    default => sub { URI->new("http://github.com/pangyre/p5-ftl") };

has [qw( name logo )] =>
    is => "ro",
    isa => "Str",
    required => 1,
    ;

sub version { $VERSION }

__PACKAGE__->setup();

__PACKAGE__->meta->make_immutable;

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
