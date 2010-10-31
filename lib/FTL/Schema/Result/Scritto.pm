package FTL::Schema::Result::Scritto;
use strict;
use warnings;
use parent "DBIx::Class::Core";
use overload q{""} => sub {
    my $self = shift;
    $self->scrit || $self->id;
}, fallback => 1;

__PACKAGE__->load_components("InflateColumn::DateTime",
                             "+FTL::Schema::Defaults");

__PACKAGE__->table("scritto");

__PACKAGE__->resultset_attributes({ order_by => "me.created DESC" });

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
  "user",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1, # FOR NOW. 321
    size => 10,
  },
  "parent",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
    size => 10,
  },
  "scrit",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 0,
    size => 16777215,
  },
  "content_type",
  {
    data_type => "TEXT",
    default_value => "text/plain",
    is_nullable => 0,
    size => 40,
  },
  "status",
  {
    data_type => "ENUM",
    default_value => "draft",
    extra => { list => ["draft", "publish", "deleted"] },
    is_nullable => 1,
    size => 8,
  },
  "type",
  {
    data_type => "INT",
    default_value => undef,
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
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

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to("user", "FTL::Schema::Result::User", { id => "user" }, {});

__PACKAGE__->belongs_to("type", "FTL::Schema::Result::Type");

#__PACKAGE__->might_have("type", "FTL::Schema::Result::Type");
#__PACKAGE__->belongs_to("type", "FTL::Schema::Result::Type");
#__PACKAGE__->belongs_to("type", "FTL::Schema::Result::Type");
#__PACKAGE__->might_have("type", "FTL::Schema::Result::Type", { id => "type" }, {});
#__PACKAGE__->has_one("type", "FTL::Schema::Result::Type", { id => "type" }, {});

__PACKAGE__->belongs_to(
  "parent",
  "FTL::Schema::Result::Scritto",
  { id => "parent" },
  { join_type => "LEFT" },
);

__PACKAGE__->has_many(
  "children",
  "FTL::Schema::Result::Scritto",
  { "foreign.parent" => "self.id" },
);

#__PACKAGE__->has_many(
#  "scritto_tags",
#  "FTL::Schema::Result::ScrittoTag",
#  { "foreign.scritto" => "self.id" },
#);

#__PACKAGE__->has_many(
#  "comment_scrittos",
#  "FTL::Schema::Result::Comment",
#  { "foreign.scritto" => "self.id" },
#);


use DateTime ();
use DBIx::Class::Exception ();

#__PACKAGE__->inflate_column( body => {
#    inflate => sub {
#        my $body = Encode::decode_utf8(+shift);
#        XHTML::Util->new(\$body)
#    },
#    deflate => sub {
#        +shift->as_string();
#    },
#                             });

sub parents {
    my ( $self, @parents ) = @_;
    my $parent = $self->parent;
    return @parents unless $parent;
    unshift @parents, $parent;
    die "Unterminating lineage loop suspected!" if @parents > 50;
    $parent->parents(@parents);
}

sub depth {
    my $self = shift;
    scalar $self->parents;
}

sub root {
    my $self = shift;
    my @parents = $self->parents;
    return $parents[0];
}

1;

__END__
