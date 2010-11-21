package FTL::Schema::ResultSet::Scritto;
use strict;
use warnings;
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

=item live

Searches scrittos which match criteria to be called "live." Namely they have a status of C<publish> and have a C<golive> of now or earlier and a C<takedown> sometime in the future. Orders results by C<golive DESC>.

Accepts serach attributes other than status, takedown, and golive. Accepts any additional attributes including C<order_by> to override the default.

=item live_rs

L</live> guaranteed to return a result set.

=back

=head1 LICENSE, AUTHOR, COPYRIGHT, SEE ALSO

L<FTL::Manual>.

=cut
