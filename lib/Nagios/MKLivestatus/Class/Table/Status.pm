package # hide from pause 
    Nagios::MKLivestatus::Class::Table::Status;

use Moose;
extends 'Nagios::MKLivestatus::Class::Base::Table';
=head1 NAME

Nagios::MKLivestatus::Class::Table::Columns - Class for status table

=head1 METHODS

=head2 build_table_name

Returns the table name from these class.

=cut

sub build_table_name { return 'status' };

=head1 AUTHOR

Robert Bohne, C<< <rbo at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Bohne.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
1;
