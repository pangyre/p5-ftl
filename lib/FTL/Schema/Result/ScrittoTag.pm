package FTL::Schema::Result::ScrittoTag;
use strict;
use warnings;
use parent 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("scritto_tag");

__PACKAGE__->add_columns(
  "scritto",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
  },
  "tag",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
    size => 10,
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
__PACKAGE__->set_primary_key("tag", "scritto");

__PACKAGE__->belongs_to("tag", "FTL::Schema::Result::Tag", { id => "tag" }, {});

__PACKAGE__->belongs_to(
  "scritto",
  "FTL::Schema::Result::Scritto",
  { id => "scritto" },
  {},
);

1;

__END__
