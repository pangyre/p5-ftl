package FTL::View::JSON;
use common::sense;
use parent "Catalyst::View::JSON";
use JSON::XS ();

__PACKAGE__->config(
    expose_stash => "json",
    );

sub encode_json {
    my ( $self, $c, $data ) = @_;
    state $encoder = JSON::XS->new
        ->utf8
        ->pretty
        ->allow_blessed
        ->convert_blessed;
    $encoder->encode($data);
}

1;

__END__
