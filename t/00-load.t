#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Nagios::MKLivestatus::Class' );
}

diag( "Testing Nagios::MKLivestatus::Class $Nagios::MKLivestatus::Class::VERSION, Perl $], $^X" );
