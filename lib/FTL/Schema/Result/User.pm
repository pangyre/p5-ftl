package FTL::Schema::Result::User;

use strict;
use warnings;

use parent 'DBIx::Class';

__PACKAGE__->load_components(
  "InflateColumn::DateTime",
  "Core",
);
__PACKAGE__->table("user");
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
  "uuid",
  { data_type => "CHAR", default_value => undef, is_nullable => 0, size => 36 },
  "username",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "password",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "email",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 100,
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
__PACKAGE__->add_unique_constraint("email", ["email"]);
__PACKAGE__->add_unique_constraint("username", ["username"]);
__PACKAGE__->has_many(
  "scritti",
  "FTL::Schema::Result::Scritto",
  { "foreign.user" => "self.id" },
);
#__PACKAGE__->has_many(
#  "comments",
#  "FTL::Schema::Result::Comment",
#  { "foreign.user" => "self.id" },
#);

1;

__END__



use List::Util "first";
use Scalar::Util "blessed";

BEGIN { use parent "DBIx::Class";
        __PACKAGE__->load_components("EncodedColumn",
                                     "InflateColumn::DateTime",
                                    );
             }



__PACKAGE__->add_columns(
                         created => { data_type => 'datetime' },
                         updated => { data_type => 'datetime' },
                         );

__PACKAGE__->add_columns(
    password => {
        encode_column => 1,
        encoded_column => 1,
        data_type => "VARCHAR",
        is_nullable => 0,
        size        => 60,
        encode_class  => "Crypt::Eksblowfish::Bcrypt",
        encode_args   => { key_nul => 1,
                           cost => 10 },
        encode_check_method => "check_password",
    }); 

sub can_preview_scritto {
    my $self = shift;
    my $scritto = shift;
    return 1 if $scritto->user->id eq $self->id;
    # Next check roles? Levels?
    return;
}

sub has_site_role : method {
    my $self = shift;
    my $role = shift || return;

    if ( blessed $role )
    {
        return first { $role->id == $_->id } $self->site_roles;
    }
    elsif ( $role =~ /\A\d+\z/ )
    {
        return first { $role == $_->id } $self->site_roles;
    }
    else
    {
        return first { $role eq $_->name } $self->site_roles;
    }
    return;
}

1;

__END__

=head1 NAME

FTL:: - 

=head1 METHODS

=over 4

=item has_site_role

Takes a role object, an id, or a name.

=item 321

=back

=head1 LICENSE, AUTHOR, COPYRIGHT, SEE ALSO

L<FTL::Manual> and L<FTL>.

=cut


  sub _role_to_id {
    my ($self, $role) = @_;
    return blessed($role) ? $role->id : $role;
}
sub with_any_role {
    my ( $self, @roles ) = @_;
    $self->search({
        'role_links.role_id' => {
          -in => [
            map { $self->_role_to_id($_) } @roles
          ]
        }
      },
      { join => 'role_links' }
    );
  }
----


