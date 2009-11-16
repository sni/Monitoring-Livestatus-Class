package # hide from pause 
    Nagios::MKLivestatus::Class::Table::Hosts;

use Moose;
extends 'Nagios::MKLivestatus::Class::Base::Table';

sub build_table_name { return 'hosts' };

1;
