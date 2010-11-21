package FTL::Schema::Result::Scritto;
use strict;
use warnings;
use parent "DBIx::Class::Core";
use Carp;
use overload q{""} => sub {
    my $self = shift;
    $self->scrit || $self->id;
}, fallback => 1;

__PACKAGE__->load_components( # Not using yet... "InflateColumn::DateTime",
                             "Ordered",
                             "+FTL::Schema::Defaults",
                             "+FTL::Schema::ToJson",
                            );

__PACKAGE__->table("scritto");
__PACKAGE__->position_column("position");
__PACKAGE__->grouping_column("parent");
__PACKAGE__->_initial_position_value(1);
__PACKAGE__->null_position_value(undef);

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
  "position",
  {
    data_type => "INT",
    default_value => 1,
    extra => { unsigned => 1 },
    is_foreign_key => 0,
    is_nullable => 1,
    size => 6,
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
    is_nullable => 0,
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

__PACKAGE__->belongs_to(
  "parent",
  "FTL::Schema::Result::Scritto",
  { id => "parent" },
  { join_type => "LEFT" },
);

__PACKAGE__->has_many(
  "children",
  "FTL::Schema::Result::Scritto",
  { "foreign.parent" => "self.id",
    "foreign.status" => "self.status" },
    { order_by => "position" }
);

__PACKAGE__->has_many(
  "scritto_pantags",
  "FTL::Schema::Result::ScrittoPantag",
  { "foreign.scritto" => "self.id" },
);

__PACKAGE__->many_to_many(
  "pantags",
  "FTL::Schema::Result::ScrittoTag",
  { "foreign.scritto" => "self.id" },
);

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
    return @parents unless my $parent = $self->parent;
    unshift @parents, $parent;
    my %dup;
    croak "Circular lineage ", join(", ", map { $_ ->id } @parents)
        if grep { $dup{$_->id}++ } @parents;
    $parent->parents(@parents);
}

# Potentially expensive.
sub tree {
    my $self = shift;
    if ( my $root = $self->root )
    {
        return $root, $root->descendants;
    }
    else
    {
        return $self, $self->descendants;
    }
}

sub descendants {
    my ( $self, @descendants ) = @_;
    return @descendants unless my @kids = $self->children;
    for my $kid ( @kids )
    {
        push @descendants, $kid->descendants;
    }
    push @descendants, @kids;
    @descendants;
}

sub depth {
    my $self = shift;
    scalar $self->parents;
}

sub root {
    my $self = shift;
    [ $self->parents ]->[0] || $self;
}

sub is_root {
    my $self = shift;
    ! $self->parent and $self->children_rs->count;
}

# If a pantag... have to update ->tree
#sub update {
#    my ( $self, @args ) = @_;
#    $self->next::method(@args);
#}

1;

__END__

    alter table scritto add column position INT;

    my $self = shift;
        map { $_ => $self->$_ }
        $self->result_source->->columns
    };
