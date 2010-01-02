package # Hide from pause 
    Nagios::MKLivestatus::Class::Abstract::Stats;

use Moose;
use Carp;
extends 'Nagios::MKLivestatus::Class::Base::Abstract';

my $TRACE = $Nagios::MKLivestatus::Class::TRACE || 0;

sub build_mode { return 'Stats'; };

sub build_compining_prefix { return 'Stats'; }

sub build_operators {
    my $self = shift;
    my $operators = $self->SUPER::build_operators();

    push @{ $operators }, {
        regexp   => qr/(groupby)/ix,
        handler => '_cond_op_groupby',
    };

    return $operators;
}

sub _cond_op_groupby {
    my $self    = shift;
    my $operator = shift;
    my $value = shift;
    my $combining_count = shift || 0;

    print STDERR "#IN  _cond_op_groupby $operator $value $combining_count\n" if $TRACE > 9;

    my ( @child_statment ) = $self->_dispatch_refkind($value, {
        SCALAR  => sub {
            return ( sprintf("%s%s: %s",$self->compining_prefix,$operator,$value) );
        },
    });

    print STDERR "#OUT _cond_op_groupby $operator $value $combining_count\n" if $TRACE > 9;
    return ( $combining_count, @child_statment );
}

1;
__END__
=head1 NAME

Nagios::MKLivestatus::Class::Abstract::Stats - Class to generate livestatus stats

=head2 SYNOPSIS

=head1 ATTRIBUTES

=head1 METHODS

=head2 apply

please view in L<Nagios::MKLivestatus::Class::Base::Abstract>

=head1 INTERNAL METHODS

=over 4

=item build_mode

=item build_compining_prefix

=item build_operators

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