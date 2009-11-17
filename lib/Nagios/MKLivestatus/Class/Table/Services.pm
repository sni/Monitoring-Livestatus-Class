package # hide from pause 
    Nagios::MKLivestatus::Class::Table::Services;

use Moose;
extends 'Nagios::MKLivestatus::Class::Base::Table';

sub build_table_name { return 'services' };

1;
