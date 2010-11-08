package FTL::Schema::Result::ScrittoPantag;
use warnings;
use strict;
use parent "DBIx::Class::Core";

__PACKAGE__->load_components(
  "+FTL::Schema::Defaults",
);

__PACKAGE__->table("scritto_pantag");

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
  "pantag",
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
);

__PACKAGE__->set_primary_key("pantag", "scritto");

__PACKAGE__->belongs_to("pantag",
                        "FTL::Schema::Result::PanTag",
                        { id => "pantag" },
                        {});

__PACKAGE__->belongs_to("scritto",
                        "FTL::Schema::Result::Scritto",
                        { id => "scritto" },
                        {});

1;

__END__
