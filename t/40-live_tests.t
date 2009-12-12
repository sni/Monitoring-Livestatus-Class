#!perl -T

use strict;
use warnings;
use Test::More;

unless ( $ENV{NAGIOS_MKLIVESTATUS_CLASS_TEST_PEER} ) {
    plan skip_all => 'no NAGIOS_MKLIVESTATUS_CLASS_TEST_PEER configured';
}

plan 1;

use_ok( 'Nagios::MKLivestatus::Class' );
