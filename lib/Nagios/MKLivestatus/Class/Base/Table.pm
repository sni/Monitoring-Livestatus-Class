package # hide from pause 
    Nagios::MKLivestatus::Class::Base::Table;

use Moose;
use Carp;

=head1 NAME

Nagios::MKLivestatus::Class::Base::Table - Base class for all table objects.

=head1 ATTRIBUTES

=head2 ctx

Reference to context object L<Nagios::MKLivestatus::Class>

=cut

has 'ctx' => (
    is => 'rw',
    isa => 'Nagios::MKLivestatus::Class',
    handles => [qw/backend_obj/],
);

=head2 table_name

Containts the table name.

=cut

has 'table_name' => (
    is => 'ro',
    isa => 'Str',
    builder  => 'build_table_name',
);

=head2 statments

Containts the all statments.

=cut
has 'statments' => (
    is => 'rw',
    isa => 'ArrayRef',
);

=head1 METHODS

=head2 build_table_name

=cut

sub build_table_name {
    die "build_table_name must be implemented in " . ref(shift)
}

=head2 columns

Return a list of all columns.

Arguments: none

Returns: @cols|\@cols

=cut
sub columns{
    my $self = shift;

    my $statment = sprintf("GET %s\nLimit: 1",$self->table_name);
    my ( $hash_ref ) = @{ $self->backend_obj->selectall_arrayref($statment,{ slice => 1}) };
    my @cols = keys %$hash_ref;
    return wantarray ? @cols : \@cols;
}

=head2 search

search...

Arguments: $search

Returns: @cols|\@cols

=cut
sub search {
    my $self = shift;
    my $cond = shift;

    my ( @statments ) = $self->_recurse_cond($cond,"AND");

    my @tmp = @{ $self->statments || [] };
    push @tmp, @statments;
    $self->statments(\@tmp);
    return $self;
}

=head2 hashref_array

search...

Arguments: none

Returns: @data|\@data

=cut
sub hashref_array {
    my $self = shift;
    my @data =  $self->_execute(@{ $self->statments });
    return wantarray ? @data : \@data;
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
    my $logic = shift || 'and';

    my $method = $self->_METHOD_FOR_refkind("_cond",$cond);
    my ( @statment ) = $self->$method($cond,$logic);

    return ( @statment );
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
    my $logic = shift;
    my ( @all_statment );

    foreach my $cond ( @{ $conds } ){
        my ( @statment ) = $self->_dispatch_refkind($cond, {
          HASHREF   => sub { $self->_recurse_cond($cond, 'and') },
          UNDEF     => sub { croak "not supported : UNDEF in arrayref" },
        });
        push @all_statment, @statment;
    }

    return ( @all_statment );
}

=item _cond_HASHREF

_cond_HASHREF....

=cut
sub _cond_HASHREF {
    my $self = shift;
    my $cond = shift;
    my $logic = shift;
    my ( @all_statment );
    foreach my $key ( keys %{ $cond } ){
        my $value = $cond->{$key};
        my ( @statment );
        if ( $key =~ /^(-.+)/ ){
            # Do operations stuff -and / -or
        }else{
            my $method = $self->_METHOD_FOR_refkind("_cond_hashpair",$value);
            ( @statment ) = $self->$method($key, $value);
        }
        push @all_statment, @statment;
    }

    return ( @all_statment );
}

=item _cond_hashpair_SCALAR

_cond_hashpair_SCALAR....

=cut
sub _cond_hashpair_SCALAR {
    my $self = shift;
    my $key = shift || '';
    my $value = shift || '';
    my @statment = (
        sprintf("Filter: %s = %s",$key,$value)
    );
    return ( @statment );
};

=item _cond_hashpair_ARRAYREF

_cond_hashpair_ARRAYREF....

=cut
sub _cond_hashpair_ARRAYREF {
    my $self = shift;
    my $key = shift || '';
    my $values = shift || [];
    my @statment = ();
    foreach my $value ( @{ $values }){
        push @statment, sprintf("Filter: %s = %s",$key,$value)
    }
    return ( @statment );
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

1; # End of Nagios::MKLivestatus::Class
