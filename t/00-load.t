#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Monitoring::Livestatus::Class' );
}

diag( "Testing Monitoring::Livestatus::Class $Monitoring::Livestatus::Class::VERSION, Perl $], $^X" );
