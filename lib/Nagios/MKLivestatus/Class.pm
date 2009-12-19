package Nagios::MKLivestatus::Class;

use Moose;
use Module::Find;

our $VERSION = '0.01';


our $TRACE = $ENV{'NAGIOS_MKLIVESTATUS_CLASS_TRACE'} || 0;


has 'peer' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'backend_obj' => (
    is       => 'ro',
);

has 'table_sources' => (
    is      => 'ro',
    # isa     => 'ArrayRef',
    builder  => '_build_table_sources',
);

sub _build_table_sources {
    my $self = shift;
    my @found = useall Nagios::MKLivestatus::Class::Table;
    return \@found;
}

sub BUILD {
    my $self = shift;

    my $backend = sprintf 'Nagios::MKLivestatus';
    Class::MOP::load_class($backend);
    $self->{backend_obj} = $backend->new( peer => $self->{peer} );
}



sub table {
    my $self = shift;
    my $table = ucfirst(lc(shift));
    my $class = sprintf("Nagios::MKLivestatus::Class::Table::%s",$table);
    return $class->new( ctx => $self );
}

1;
__END__

=head1 NAME

Nagios::MKLivestatus::Class - Object-Oriented inteface for Nagios:: MKLivestatus

=head1 SYNOPSIS

    use Nagios::MKLivestatus::Class;

    my $class = Nagios::MKLivestatus::Class->new(
        peer => '/var/lib/nagios3/rw/livestatus.sock'
    );

    my $hosts = $class->table('hosts');
    my @data = $hosts->columns('display_name')->filter(
        { display_name => { '-or' => [qw/test_host_47 test_router_3/] } }
    )->hashref_array();
    print Dumper \@data;

=head1 ATTRIBUTES

=head2 peer

Connection point to the status check_mk livestatus Nagios addon. This can be a socket or a TCP connection.

=head3 Socket

    my $class = Nagios::MKLivestatus::Class->new( peer => '/var/lib/nagios3/rw/livestatus.sock' );

=head3 TCP Connection

    my $class = Nagios::MKLivestatus::Class->new( peer => '192.168.1.1:2134');

=head1 METHODS

=head2 table_sources

Get a list of all table class names.

Arguments: none

Returns: @list

=head2 table

Get table object from ....

Arguments: $scalar

Returns: $table_object

=head1 ENVIRONMENT VARIABLES

=head2 NAGIOS_MKLIVESTATUS_CLASS_TEST_PEER

=head2 NAGIOS_MKLIVESTATUS_CLASS_TRACE

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
