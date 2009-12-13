use strict;
use warnings;
use Test::More;
use Data::Dumper;
unless ( $ENV{NAGIOS_MKLIVESTATUS_CLASS_TEST_PEER} ) {
    plan skip_all => 'no NAGIOS_MKLIVESTATUS_CLASS_TEST_PEER configured';
}

use_ok('Nagios::MKLivestatus::Class');
use Nagios::MKLivestatus::Class;
my $class = Nagios::MKLivestatus::Class->new(
    peer => $ENV{NAGIOS_MKLIVESTATUS_CLASS_TEST_PEER},
);
my $hosts = $class->table('hosts');

my $got_statment =
  $hosts->columns('display_name')->filter( { display_name => { '-or' => [qw/test_host_47 test_router_3/] } } )
  ->hashref_array();

my $expected_statment = [ { 'display_name' => 'test_host_47' }, { 'display_name' => 'test_router_3' } ];

is_deeply( $got_statment, $expected_statment, "" );

done_testing(2);
