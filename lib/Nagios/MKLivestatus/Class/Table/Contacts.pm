package # hide from pause 
    Nagios::MKLivestatus::Class::Table::Contats;

use Moose;
extends 'Nagios::MKLivestatus::Class::Base::Table';

sub build_table_name { return 'contacts' };

1;
