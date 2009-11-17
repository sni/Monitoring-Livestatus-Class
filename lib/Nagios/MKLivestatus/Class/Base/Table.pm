package Nagios::MKLivestatus::Class::Base::Table;

use Moose;
use Carp;

has 'ctx' => (
    is => 'rw',
    isa => 'Nagios::MKLivestatus::Class',
    handles => [qw/backend_obj/],
);

has 'table_name' => (
    is => 'ro',
    isa => 'Str',
    builder  => 'build_table_name',
);


=head1 METHODS

=head2 build_table_name

=cut

sub build_table_name {
    die "build_table_name must be implemented in " . ref(shift)
}

=head2 columns

Return a list of all columns.

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

=cut

sub search {
    my $self = shift;
    my $cond = shift;

    my ( @statments ) = $self->_recurse_cond($cond,"AND");

    return $self->_execute(@statments);
}


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



sub _generate_search_statment {
    my $self = shift;
    my $cond = shift;
    my $logic = shift || "AND";

    my ( @statment ) = $self->_recurse_cond($cond,$logic);

    return @statment;
}

sub _recurse_cond {
    my $self = shift;
    my $cond = shift;
    my $logic = shift || 'and';

    my $method = $self->_METHOD_FOR_refkind("_cond",$cond);
    my ( @statment ) = $self->$method($cond,$logic);

    return ( @statment );
}

sub _cond_UNDEF { return ( () ); }

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

sub _cond_hashpair_SCALAR {
    my $self = shift;
    my $key = shift || '';
    my $value = shift || '';
    my @statment = (
        sprintf("Filter: %s = %s",$key,$value)
    );
    return ( @statment );
};

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

sub _dispatch_refkind {
    my $self = shift;
    my $value = shift;
    my $dispatch_table = shift;

    my $type = $self->_refkind($value);
    my $coderef = $dispatch_table->{$type};
    return $coderef->();
}

sub _METHOD_FOR_refkind {
    my $self = shift;
    my $prefix = shift || '';
    my $value = shift;
    my $type = $self->_refkind( $value );
    my $method = sprintf("%s_%s",$prefix,$type);
    return $method;
}

1; # End of Nagios::MKLivestatus::Class
