package Nagios::MKLivestatus::Class::Abstract::Stats;

use Moose;
use Carp;
extends 'Nagios::MKLivestatus::Class::Base::Abstract';

sub build_mode { return 'Stats'; };

sub build_compining_prefix { return 'Stats'; }

1;
__END__
=head1 NAME

Nagios::MKLivestatus::Class::Base::Abstract

=head2 SYNOPSIS

=head1 ATTRIBUTES

=head1 METHODS

=head2 build_mode

=head2 build_compining_prefix

=head1 AUTHOR

Robert Bohne, C<< <rbo at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Bohne.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut