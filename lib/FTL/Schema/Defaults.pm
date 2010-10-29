package FTL::Schema::Defaults;
use strict;
use warnings;
use parent "DBIx::Class::Core";

sub new {
    my $self = +shift->next::method(@_);
    $self->created(\q{datetime('now')}) unless $self->created;
    $self;
}

sub insert {
    my $self = shift;
    $self->updated(\q{datetime('now')}) unless $self->updated;
    return $self->next::method(@_);
}

sub update {
    my $self = shift;
    $self->updated(\q{datetime('now')}) unless $self->updated;
    return $self->next::method(@_);
}

#sub delete {
#    my $self = shift;
#    # Do stuff with $self.
#    return $self->next::method(@_);
#}

1;

__END__
