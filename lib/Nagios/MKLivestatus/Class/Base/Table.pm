package # hide from pause 
    Nagios::MKLivestatus::Class::Base::Table;

use Moose;
use Carp;

use Nagios::MKLivestatus::Class::Abstract::Filter;
use Nagios::MKLivestatus::Class::Abstract::Stats;

has 'ctx' => (
    is => 'rw',
    isa => 'Nagios::MKLivestatus::Class',
    handles => [qw/backend_obj/],
);

# 
#  Filter Stuff
#  
has 'filter_obj' => (
    is => 'ro',
    isa => 'Nagios::MKLivestatus::Class::Abstract::Filter',
    builder => '_build_filter',
    handles => { apply_filer => 'apply' },
);

sub _build_filter { return Nagios::MKLivestatus::Class::Abstract::Filter->new( ctx => shift ); };

sub filter {
    my $self = shift;
    my $cond = shift;

    my @statments = $self->apply_filer($cond);
    my @tmp = @{ $self->statments || [] };
    push @tmp, @statments;
    $self->_statments(\@tmp);
    return $self;
}

# 
#  Stats Stuff
# 
has 'stats_obj' => (
    is => 'ro',
    isa => 'Nagios::MKLivestatus::Class::Abstract::Stats',
    builder => '_build_stats',
    handles => { apply_stats => 'apply' },
);

sub _build_stats { return Nagios::MKLivestatus::Class::Abstract::Stats->new( ctx => shift ); };

sub stats {
    my $self = shift;
    my $cond = shift;

    my @statments = $self->apply_stats($cond);
    my @tmp = @{ $self->statments || [] };
    push @tmp, @statments;
    $self->_statments(\@tmp);
    return $self;
}




has 'table_name' => (
    is => 'ro',
    isa => 'Str',
    builder  => 'build_table_name',
);

sub build_table_name { die "build_table_name must be implemented in " . ref(shift) };

has '_statments' => (
    is => 'rw',
    reader => 'statments',
    isa => 'ArrayRef',
    default => sub { return []; }
);


has '_columns' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { return []; }
);

sub columns {
    my $self = shift;
    my @columns = @_ ;
    $self->_columns( \@columns );
    return $self;
}

sub headers{
    my $self = shift;

    my $statment = sprintf("GET %s\nLimit: 1",$self->table_name);
    my ( $hash_ref ) = @{ $self->backend_obj->selectall_arrayref($statment,{ slice => 1}) };
    my @cols = keys %$hash_ref;
    return wantarray ? @cols : \@cols;
}

sub hashref_array {
    my $self = shift;

    my @statments = ();
    if ( scalar @{ $self->_columns } > 0 ){
        push @statments, sprintf('Columns: %s',join(' ',@{  $self->_columns  }));
    }
    push @statments, @{ $self->statments };

    my @data =  $self->_execute( @statments );
    return wantarray ? @data : \@data;
}

sub _execute {
    my $self = shift;
    my @data = @_;

    my @statments = ();
    push @statments, sprintf("GET %s",$self->table_name);
    push @statments, @data;

    printf STDERR "EXECUTE: %s\n", join("\nEXECUTE: ",@statments)
        if $Nagios::MKLivestatus::Class::TRACE >= 1;

    my $statment = join("\n",@statments);

    my $return = $self->backend_obj->selectall_arrayref($statment, { slice => {} });

    return wantarray ? @{ $return }  : $return;
}

1;
__END__
=head1 NAME

Nagios::MKLivestatus::Class::Base::Table - Base class for all table objects.

=head2 SYNOPSIS

    my $class = Nagios::MKLivestatus::Class->new(
        backend => 'INET',
        socket => '10.211.55.140:6557',
    );

    my $table_obj = $class->table('services');

    my $data = $table_obj->search( {} )->hashref_array();

=head1 ATTRIBUTES

=head2 ctx

Reference to context object L<Nagios::MKLivestatus::Class>

=head2 filter

Reference to filter object L<Nagios::MKLivestatus::Class>

=head2 stats

Reference to filter object L<Nagios::MKLivestatus::Class>

=head2 table_name

Containts the table name.

=head2 statments

Containts the all statments.

=head1 METHODS

=head2 columns

Arguments: $colA, $colB, ...

Return: $self

Set columns...

=head2 headers

Returns a array or reference to array, depending on the calling context, of all header columns.

=head2 filter

Example usage:

    $table_obj->search( { name => 'localhost' } );
    $table_obj->search( { name => [ 'localhost', 'gateway' ] } );
    $table_obj->search( [ { name => 'localhost' }, { name => 'gateway' } ] );

Returns: $self

=head2 hashref_array

Returns a array or reference to array, depending on the calling context.

Example usage:

    my $hashref_array = $table_obj->search( { } )->hashref_array;
    print Dumper $hashref_array;


=head2 build_table_name

=head1 AUTHOR

Robert Bohne, C<< <rbo at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Bohne.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut