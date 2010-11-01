package FTL::Schema::Result::DisplayCode;
use warnings;
use strict;
use parent 'DBIx::Class::Core';
#use overload q{""} => sub {
#    my $self = shift;
#    $self->name || $self->id;
#}, fallback => 1;

__PACKAGE__->load_components("+FTL::Schema::Defaults");

__PACKAGE__->table("display_code");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
    size => 10,
  },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "code",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => 65535,
  },
  "created",
  {
    data_type => "DATETIME",
    default_value => undef,
    is_nullable => 0,
    size => 19,
  },
  "updated",
  {
    data_type => "TIMESTAMP",
    default_value => undef,
    is_nullable => 1,
    size => 14,
  },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
  "scritti",
  "FTL::Schema::Result::Scritto",
  { "foreign.type" => "self.id" },
);

1;

__END__

