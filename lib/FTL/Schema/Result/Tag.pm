package FTL::Schema::Result::Tag;

use strict;
use warnings;

use parent "DBIx::Class::Core";

__PACKAGE__->load_components(
  "+FTL::Schema::Defaults",
#  "InflateColumn::DateTime",
#  "Core",
);
__PACKAGE__->table("tag");
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
#  "uuid",
#  { data_type => "CHAR", default_value => undef, is_nullable => 0, size => 36 },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "description",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
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
  "scritto_tags",
  "FTL::Schema::Result::ScrittoTag",
  { "foreign.tag" => "self.id" },
);


1;


__END__
