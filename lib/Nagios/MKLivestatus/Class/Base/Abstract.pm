package # hide from pause 
    Nagios::MKLivestatus::Class::Base::Abstract;

use Moose;
use Carp;

=head1 NAME

Nagios::MKLivestatus::Class::Base::Abstract

=head2 SYNOPSIS

=head1 ATTRIBUTES

=head2 ctx

Reference to context object L<Nagios::MKLivestatus::Class>

=cut

has 'ctx' => (
    is => 'rw',
    handles => [qw/table_name backend_obj/],
);

=head1 METHODS

=head2 apply

Example usage:

    $table_obj->search( { name => 'localhost' } );
    $table_obj->search( { name => [ 'localhost', 'gateway' ] } );
    $table_obj->search( [ { name => 'localhost' }, { name => 'gateway' } ] );

Returns: @statments|\@statments

=cut
sub apply {
    my $self = shift;
    my $cond = shift;

    my ( $combining_count, @statments ) = $self->_recurse_cond($cond);

    return wantarray ? @statments : \@statments;
}

=head1 INTERNAL METHODS

=over 4

=item _execute

_execute....

=cut

sub _execute {
    my $self = shift;
    my $data = shift;

    $data = $self->_dispatch_refkind($data, {
      ARRAYREF  => sub { return $data },
      SCALAR    => sub { return [ $data ]},
      UNDEF     => sub { return [] },
    });

    my $statment = join("\n",
        sprintf("GET %s",$self->table_name),
        @{ $data }
    );

    my $return = $self->backend_obj->selectall_arrayref($statment, { slice => {} });

    return wantarray ? @{ $return }  : $return;
}

=item _recurse_cond

_recurse_cond....

=cut
sub _recurse_cond {
    my $self = shift;
    my $cond = shift;
    my $combining_count = shift || 0;
    print STDERR "#IN _recurse_cond $cond $combining_count\n" if $Nagios::MKLivestatus::Class::TRACE;
    my $method = $self->_METHOD_FOR_refkind("_cond",$cond);
    my ( $child_combining_count, @statment ) = $self->$method($cond,$combining_count);
    $combining_count = $child_combining_count;
    print STDERR "#OUT _recurse_cond $cond $combining_count ( $method )\n" if $Nagios::MKLivestatus::Class::TRACE;
    return ( $combining_count, @statment );
}

=item _cond_UNDEF

_cond_UNDEF....

=cut
sub _cond_UNDEF { return ( () ); }

=item _cond_ARRAYREF

_cond_ARRAYREF....

=cut
sub _cond_ARRAYREF {
    my $self = shift;
    my $conds = shift;
    my $combining_count = shift || 0;
    print STDERR "#IN _cond_ARRAYREF $conds $combining_count\n" if $Nagios::MKLivestatus::Class::TRACE;
    my @statment = ();

    my $child_combining_count = 0;
    my @child_statment = ();
    my @cp_conds = @{ $conds }; # work with a copy
    while ( my $cond = shift @cp_conds ){
        my ( $child_combining_count, @child_statment ) = $self->_dispatch_refkind($cond, {
            HASHREF   => sub { $self->_recurse_cond($cond, $combining_count) },
            UNDEF     => sub { croak "not supported : UNDEF in arrayref" },
            SCALAR    => sub { $self->_recurse_cond( { $cond => shift(@cp_conds) } , $combining_count ) },
        });
        push @statment, @child_statment;
        $combining_count = $child_combining_count;
    }
    print STDERR "#OUT _cond_ARRAYREF $conds $combining_count\n" if $Nagios::MKLivestatus::Class::TRACE;
    return ( $combining_count, @statment );
}

=item _cond_HASHREF

_cond_HASHREF....

=cut
sub _cond_HASHREF {
    my $self = shift;
    my $cond = shift;
    my $combining_count = shift || 0;
    print STDERR "#IN _cond_HASHREF $cond $combining_count\n" if $Nagios::MKLivestatus::Class::TRACE;

    my @all_statment = ();
    my $child_combining_count = 0;
    my @child_statment = ();

    foreach my $key ( keys %{ $cond } ){
        my $value = $cond->{$key};
        my $method ;

        if ( $key =~ /^-/ ){
            # Child key for combining filters ( -and / -or )
            ( $child_combining_count, @child_statment ) = $self->_cond_compining($key, $value, $combining_count);
            $combining_count = $child_combining_count;
        } else{
            $method = $self->_METHOD_FOR_refkind("_cond_hashpair",$value);
            ( $child_combining_count, @child_statment ) = $self->$method($key, $value, undef ,$combining_count);
            $combining_count = $child_combining_count;
        }

        push @all_statment, @child_statment;
    }
    print STDERR "#OUT _cond_HASHREF $cond $combining_count\n" if $Nagios::MKLivestatus::Class::TRACE;
    return ( $combining_count, @all_statment );
}

=item _cond_hashpair_SCALAR

_cond_hashpair_SCALAR....

=cut
sub _cond_hashpair_SCALAR {
    my $self = shift;
    my $key = shift || '';
    my $value = shift;
    my $operator = shift || '=';
    print STDERR "# _cond_hashpair_SCALAR\n" if $Nagios::MKLivestatus::Class::TRACE;

    my $combining_count = shift || 0;
    my @statment = (
        sprintf("Filter: %s %s %s",$key,$operator,$value)
    );
    $combining_count++;
    return ( $combining_count, @statment );
};

=item _cond_hashpair_ARRAYREF

_cond_hashpair_ARRAYREF....

=cut
sub _cond_hashpair_ARRAYREF {
    my $self = shift;
    my $key = shift || '';
    my $values = shift || [];
    my $operator = shift || '=';
    my $combining_count = shift || 0;
    print STDERR "#IN _cond_hashpair_ARRAYREF $combining_count\n" if $Nagios::MKLivestatus::Class::TRACE;

    my @statment = ();
    foreach my $value ( @{ $values }){
        push @statment, sprintf("Filter: %s %s %s",$key,$operator,$value);
        $combining_count++;
    }
    print STDERR "#OUT _cond_hashpair_ARRAYREF $combining_count\n" if $Nagios::MKLivestatus::Class::TRACE;
    return ( $combining_count, @statment );
}

=item _cond_hashpair_HASHREF

_cond_hashpair_HASHREF....

=cut
sub _cond_hashpair_HASHREF {
    my $self = shift;
    my $key = shift || '';
    my $values = shift || {};
    my $combining = shift || undef;
    my $combining_count = shift || 0;
    print STDERR "# _cond_hashpair_HASHREF $combining_count\n" if $Nagios::MKLivestatus::Class::TRACE;

    my @statment = ();

    foreach my $child_key ( keys %{ $values } ){
        my $child_value = $values->{ $child_key };

        if ( $child_key =~ /^-/ ){
            # Child key for combining filters ( -and / -or )
            my ( $child_combining_count, @child_statment ) = $self->_dispatch_refkind($child_value, {
                ARRAYREF  => sub { $self->_cond_compining($child_key, { $key => $child_value } , 0) },
                UNDEF     => sub { croak "not supported : UNDEF in arrayref" },
            });
            $combining_count += $child_combining_count;
            push @statment, @child_statment;
        } elsif ( $child_key =~ /^[!<>=~]/ ){
            # Child key is a operator like:
            # =     equality
            # ~     match regular expression (substring match)
            # =~    equality ignoring case
            # ~~    regular expression ignoring case
            # <     less than
            # >     greater than
            # <=    less or equal
            # >=    greater or equal
            my $method = $self->_METHOD_FOR_refkind("_cond_hashpair",$child_value);
            my ( $child_combining_count, @child_statment ) = $self->$method($key, $child_value,$child_key);
            $combining_count += $child_combining_count;
            push @statment, @child_statment;
        } else {
            my $method = $self->_METHOD_FOR_refkind("_cond_hashpair",$child_value);
            my ( $child_combining_count, @child_statment ) = $self->$method($key, $child_value);
            $combining_count += $child_combining_count;
            push @statment, @child_statment;
        }
    }

    return ( $combining_count, @statment );
}

sub _cond_compining {
    my $self = shift;
    my $combining = shift;
    my $value = shift;
    my $combining_count = shift || 0;
    print STDERR "#IN _cond_compining $combining $combining_count\n" if $Nagios::MKLivestatus::Class::TRACE;
    $combining_count++;
    my @statment = ();

    if ( defined $combining and $combining =~ /^-/ ){
        $combining =~ s/^-//; # remove -
        $combining =~ s/^\s+|\s+$//g; # remove leading/trailing space
        $combining = ucfirst( $combining );
    }
    my ( $child_combining_count, @child_statment )= $self->_recurse_cond($value, 0 );
    push @statment, @child_statment;
    push @statment, sprintf("%s: %d",$combining,$child_combining_count) if ( defined $combining );
    print STDERR "#OUT _cond_compining $combining $combining_count \n" if $Nagios::MKLivestatus::Class::TRACE;
    return ( $combining_count, @statment );
}

=item _refkind

_refkind....

=cut
sub _refkind {
  my ($self, $data) = @_;
  my $suffix = '';
  my $ref;
  my $n_steps = 0;

  while (1) {
    # blessed objects are treated like scalars
    $ref = (blessed $data) ? '' : ref $data;
    $n_steps += 1 if $ref;
    last          if $ref ne 'REF';
    $data = $$data;
  }

  my $base = $ref || (defined $data ? 'SCALAR' : 'UNDEF');


  return $base . ('REF' x $n_steps);
}

=item _dispatch_refkind

_dispatch_refkind....

=cut
sub _dispatch_refkind {
    my $self = shift;
    my $value = shift;
    my $dispatch_table = shift;

    my $type = $self->_refkind($value);
    my $coderef = $dispatch_table->{$type};
    die sprintf("No coderef for %s ( %s ) found!",$value, $type)
        unless ( ref $coderef eq 'CODE' );
    return $coderef->();
}

=item _METHOD_FOR_refkind

_METHOD_FOR_refkind....

=back

=cut
sub _METHOD_FOR_refkind {
    my $self = shift;
    my $prefix = shift || '';
    my $value = shift;
    my $type = $self->_refkind( $value );
    my $method = sprintf("%s_%s",$prefix,$type);
    return $method;
}


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