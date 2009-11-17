package # hide from pause 
    Nagios::MKLivestatus::Class::Table::Hostgroups;

use Moose;
extends 'Nagios::MKLivestatus::Class::Base::Table';

sub build_table_name { return 'hostgroups' };

1;
