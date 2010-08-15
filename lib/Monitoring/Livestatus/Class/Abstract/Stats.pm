package # Hide from pause 
    Monitoring::Livestatus::Class::Abstract::Stats;

use Moose;
use Carp;
extends 'Monitoring::Livestatus::Class::Base::Abstract';

use Monitoring::Livestatus::Class;
my $TRACE = Monitoring::Livestatus::Class->TRACE() || 0;

sub build_mode { return 'Stats'; };

sub build_compining_prefix { return 'Stats'; }

sub build_operators {
    my $self = shift;
    my $operators = $self->SUPER::build_operators();

    push @{ $operators }, {
        regexp  => qr/(groupby)/ix,
        handler => '_cond_op_groupby',
    };

    push @{ $operators }, {
        regexp  => qr/(sum|min|max|avg|std)/ix,
        handler => '_cond_op_simple'
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
            return ( sprintf("%s%s: %s",$self->compining_prefix, 'GroupBy', $value) );
        },
    });
    print STDERR "#OUT _cond_op_groupby $operator $value $combining_count\n" if $TRACE > 9;
    return ( $combining_count, @child_statment );
}

sub _cond_op_simple {
    my $self    = shift;
    my $operator = shift;
    my $value = shift;
    my $combining_count = shift || 0;

    print STDERR "#IN  _cond_op_simple $operator $value $combining_count\n" if $TRACE > 9;

    #handline from:  -avg               => [ 'latency', { -as => 'latency_avg' } ],
    my ( @child_statment ) = $self->_dispatch_refkind($value, {
        SCALAR  => sub {
            $combining_count++;
            return ( sprintf("%s: %s %s",$self->compining_prefix,$operator,$value) );
        },
        ARRAYREF => sub {
            $combining_count++;
            if ( scalar @$value > 2 ){
                die "More then 2 elements not supported.";
            }
            my $first_value = shift @$value;
            my $second_value = shift @$value;

            # First
            my $statment = $self->_dispatch_refkind($first_value, {
                SCALAR  => sub {
                    return sprintf("%s: %s %s",$self->compining_prefix,$operator,$first_value);
                },
            });

            # Second
            my $method = $self->_METHOD_FOR_refkind("_cond_attribute",$second_value);
            $statment .= $self->$method($second_value);
            return ( $statment );
        }
    });

    print STDERR "#OUT _cond_op_simple $operator $value $combining_count\n" if $TRACE > 9;
    return ( $combining_count, @child_statment );
}

1;
__END__
=head1 NAME

Monitoring::Livestatus::Class::Abstract::Stats - Class to generate livestatus
stats

=head2 SYNOPSIS

=head1 ATTRIBUTES

=head1 METHODS

=head2 apply

please view in L<Monitoring::Livestatus::Class::Base::Abstract>

=head1 INTERNAL METHODS

=over 4

=item build_mode

=item build_compining_prefix

=item build_operators

=back

=head1 AUTHOR

See L<Monitoring::Livestatus::Class/AUTHOR> and L<Monitoring::Livestatus::Class/CONTRIBUTORS>.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Bohne.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
