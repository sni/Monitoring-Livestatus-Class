package # hide from pause 
    Nagios::MKLivestatus::Class::Table::Columns;

use Moose;
extends 'Nagios::MKLivestatus::Class::Base::Table';

sub build_table_name { return 'columns' };

1;
