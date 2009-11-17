package # hide from pause 
    Nagios::MKLivestatus::Class::Table::Downtimes;

use Moose;
extends 'Nagios::MKLivestatus::Class::Base::Table';

sub build_table_name { return 'downtimes' };

1;
