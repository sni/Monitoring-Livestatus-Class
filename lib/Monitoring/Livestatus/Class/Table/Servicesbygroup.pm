package # hide from pause
    Monitoring::Livestatus::Class::Table::Servicesbygroup;

use Moose;
extends 'Monitoring::Livestatus::Class::Base::Table';

=head1 NAME

Monitoring::Livestatus::Class::Table::Servicesbygroup - Class for servicesbygroup table

=head1 METHODS

=head2 build_table_name

Returns the table name from these class.

=cut

sub build_table_name { return 'servicesbygroup' };

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
