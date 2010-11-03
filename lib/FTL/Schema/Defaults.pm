package FTL::Schema::Defaults;
use strict;
use warnings;
use parent "DBIx::Class::Core";
use Carp;

sub new {
    my $self = +shift->next::method(@_);
    $self->created(\q{datetime('now')}) unless $self->created;
    $self;
}

sub insert {
    my ( $self, @args ) = @_;

    $self->updated(\q{datetime('now')}) unless $self->updated;

    if ( $self->result_source->has_column("parent") and $self->parent )
    {
        $self->result_source->resultset->find($self->parent)
            or croak "Parent ", $self->parent, " was not found";
        my $guard = $self->result_source->schema->txn_scope_guard;
        $self->next::method(@args);
        $self->parents; # Fatal if circular. Not efficient...
        $guard->commit;
    }
    return $self;
}

sub update {
    my ( $self, @args ) = @_;

    $self->updated(\q{datetime('now')});
    if ( $self->result_source->has_column("parent") and $self->parent )
    {
        $self->result_source->resultset->find($self->parent)
            or croak "Parent ", $self->parent, " was not found";
        my $guard = $self->result_source->schema->txn_scope_guard;
        $self->next::method(@args);
        $self->parents; # Fatal if circular. Not efficient...
        $guard->commit;
    }
    $self;
}

#sub delete {
#    my $self = shift;
#    # Do stuff with $self.
#    return $self->next::method(@_);
#}

1;

__END__


    $self->schema->storage->

last_insert_id


  $h->last_insert_id($catalog, $schema, $table_name, $field_name [, \%attr ])

        my $max = $self->result_source
            ->resultset
            ->search->get_column('id')->max();

    my $txn = sub {
        $self->next::method(@_);
        DBIx::Class::Exception->throw("...");
    };

    my $rs = $self->result_source
        ->schema
        ->txn_do($txn);

    die "RS: ", $rs;

