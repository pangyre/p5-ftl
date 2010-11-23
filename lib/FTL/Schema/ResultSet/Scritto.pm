package FTL::Schema::ResultSet::Scritto;
use warnings;
use strict;
use parent "DBIx::Class::ResultSet::HashRef";

sub root {
    my $self = shift;
    $self->search({parent => ['',undef]});
}

sub root_rs {
    scalar +shift->root;
}

sub non_root {
    my $self = shift;
    $self->search({parent => { "!=" => "" } });
}

sub non_root_rs {
    scalar +shift->non_root;
}

sub deleted {
    +shift->search({status => "deleted"},{where => undef});
}

sub deleted_rs {
    scalar +shift->deleted;
}

sub newest {
    +shift->search({},{order_by => "created DESC"});
}

sub newest_rs {
    scalar +shift->newest;
}

1;

__END__

=head1 NAME

FTL::Schema::ResultSet::Scritto - extensions to using L<FTL::Schema::Result::Resource>.

=head1 METHODS

=over 4

=item 321

=back

=head1 LICENSE, AUTHOR, COPYRIGHT, SEE ALSO

L<FTL::Manual>.

=cut
