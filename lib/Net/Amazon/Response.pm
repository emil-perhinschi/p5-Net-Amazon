######################################################################
package Net::Amazon::Response;
######################################################################
use base qw(Net::Amazon);

use Text::Wrap qw($columns wrap);

##################################################
sub new {
##################################################
    my($class, %options) = @_;

    my $self = {
        status  => "",
        message => "",
        items   => [],
        xmlref  => {},
    };

    $class->SUPER::make_accessor("status");
    $class->SUPER::make_accessor("message");
    $class->SUPER::make_accessor("items");
    $class->SUPER::make_accessor("xmlref");

    bless $self, $class;
}

###########################################
sub is_success {
###########################################
    my($self) = @_;

    return $self->{status} ? 1 : "";
}

###########################################
sub is_error {
###########################################
    my($self) = @_;

    return !$self->is_success();
}

###########################################
sub push_item {
###########################################
    my($self, $item) = @_;

    push @{$self->{items}}, $item;
}

###########################################
sub as_string {
###########################################
    my($self) = @_;

    return Data::Dumper::Dumper($self);
}

###########################################
sub list_as_string {
###########################################
    my($self, @properties) = @_;

    my $full = "";

        # Column with
    $columns   = 60;
    my $bullet = 1;

    foreach my $property (@properties) {
        $full .= "\n" if $full;
        my $bullet_string = sprintf("[%d]%s", 
                                    $bullet, (" " x (3-length($bullet))));
        $full .= wrap("", "     ", $bullet_string . $property->as_string());
        $bullet++;
    }

    return $full;
}

##################################################
sub properties {
##################################################
    my($self) = @_;

    my @properties = ();

    if($self->is_success && ref($self->{xmlref}->{Details}) eq 'ARRAY') {
        foreach my $xmlref (@{$self->{xmlref}->{Details}}) {
            my $property = Net::Amazon::Property::factory(xmlref => $xmlref);
            push @properties, $property;
        }
    }

    return (@properties);
}

1;

__END__

=head1 NAME

Net::Amazon::Response - Baseclass for responses from Amazon's web service

=head1 SYNOPSIS

    $resp = $ua->request($request);

    if($resp->is_success()) { 
        print $resp->as_string();
    }

    if($resp->is_error()) {
        print $resp->message();
    }
 
    if($resp->is_success()) { 
        for my $property ($resp->properties) {
            print $property->as_string(), "\n";
        }
    }

=head1 DESCRIPTION

C<Net::Amazon::Response> is the baseclass for responses coming back 
from the useragent's C<request> method. Responses are typically
not of type C<Net::Amazon::Response> but one of its subclasses
C<Net::Amazon::Response::*>. However, for basic error handling and
dumping content, C<Net::Amazon::Response>'s methods are typically used,
because we typically don't know what type of object we're 
actually dealing with.

=head2 METHODS

=over 4

=item is_success()

Returns true if the request was successful. This doesn't mean any objects
have been found, it just indicates a successful roundtrip.

=item is_error()

Returns true if an error occurred. Use C<message()> to determine what 
kind of error.

=item properties()

Returns the list of C<Net::Amazon::Property> objects which were found
by the query.

=item as_string()

Dumps the content of the response.

=back

=head1 SEE ALSO

=head1 AUTHOR

Mike Schilli, E<lt>m@perlmeister.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Mike Schilli E<lt>m@perlmeister.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut