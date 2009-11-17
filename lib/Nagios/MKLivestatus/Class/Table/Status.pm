package # hide from pause 
    Nagios::MKLivestatus::Class::Table::Status;

use Moose;
extends 'Nagios::MKLivestatus::Class::Base::Table';

sub build_table_name { return 'status' };

1;
