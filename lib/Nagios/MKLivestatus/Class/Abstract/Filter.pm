package # Hide from pause 
    Nagios::MKLivestatus::Class::Abstract::Filter;

use Moose;
use Carp;
extends 'Nagios::MKLivestatus::Class::Base::Abstract';

sub build_mode { return 'Filter'; };


1;
__END__
=head1 NAME

Nagios::MKLivestatus::Class::Abstract::Filter - Class to generate livestatus filters

=head2 SYNOPSIS

=head1 ATTRIBUTES

=head1 METHODS

=head2 apply

please view in L<Nagios::MKLivestatus::Class::Base::Abstract>

=head1 INTERNAL METHODS

=over 4

=item build_mode

=back

=head1 AUTHOR

Robert Bohne, C<< <rbo at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Bohne.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut