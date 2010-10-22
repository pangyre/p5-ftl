package FTL::Model::DBIC;
use strict;
use parent "Catalyst::Model::DBIC::Schema";

__PACKAGE__->config(
    schema_class => "FTL::Schema",
    );

1;

__END__

=head1 NAME

FTL::Model::DBIC - Catalyst DBIC Schema Model using L<FTL::Schema> as its C<schema_class>.

=head1 REFER TO

L<FTL::Manual> and L<FTL>.

=cut
