package Nagios::MKLivestatus::Class;

use Moose;
use Module::Find;

=head1 NAME

Nagios::MKLivestatus::Class - The great new Nagios::MKLivestatus::Class!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


our $TRACE = $ENV{'NAGIOS_MKLIVESTATUS_CLASS_TRACE'} ? 1 : 0;

=head1 SYNOPSIS



Perhaps a little code snippet.

    use Nagios::MKLivestatus::Class;

    my $foo = Nagios::MKLivestatus::Class->new(
        backend => 'INET',
        socket => '10.211.55.140:6557',
    );

=cut

=head1 ATTRIBUTES

=head2 socket

Path to unix socket or host:port

=cut
has 'socket' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

=head2 backend

=head3 Values:

=over 4

=item Socket

=item INET

=back

=cut
has 'backend' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);


has 'backend_obj' => (
    is       => 'ro',
);

=head1 METHODS

=head2 BUILD

BUILD Method

=cut

sub BUILD {
    my $self = shift;

    # Load all Modules 
    useall Nagios::MKLivestatus::Class::Table;

    my $backend = sprintf 'Nagios::MKLivestatus::%s', $self->{backend};
    Class::MOP::load_class($backend);
    $self->{backend_obj} = $backend->new( $self->{socket} );
}


=head2 table

Get table object from ....

Arguments: $scalar

Returns: $table_object

=cut
sub table {
    my $self = shift;
    my $table = ucfirst(lc(shift));
    my $class = sprintf("Nagios::MKLivestatus::Class::Table::%s",$table);
    return $class->new( ctx => $self );
}


=head1 AUTHOR

Robert Bohne, C<< <rbo at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-nagios-mklivestatus-class at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Nagios-MKLivestatus-Class>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Nagios::MKLivestatus::Class


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Nagios-MKLivestatus-Class>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Nagios-MKLivestatus-Class>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Nagios-MKLivestatus-Class>

=item * Search CPAN

L<http://search.cpan.org/dist/Nagios-MKLivestatus-Class/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Bohne.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Nagios::MKLivestatus::Class
