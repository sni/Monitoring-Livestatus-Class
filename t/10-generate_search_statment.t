#!perl -T

use Test::More;

use_ok('Nagios::MKLivestatus::Class::Table::Hosts');

my @testings = (
    { name => 'localhost' }, [ "Filter: name = localhost" ],
    { name => 'localhost', service => 'ping' }, [ "Filter: name = localhost", "Filter: service = ping" ],
    { name => [qw/localhost router/] }, [ "Filter: name = localhost", "Filter: name = router" ],
    [
        { name => 'localhost' },
        { name => 'router' },
    ], [ "Filter: name = localhost", "Filter: name = router" ],

);

for ( my $i = 0 ; $i < scalar @testings ; $i++ ) {
    my $search   = $testings[ $i ];
    my $expected_statment = $testings[ ++$i ];
    my $hosts_obj = Nagios::MKLivestatus::Class::Table::Hosts->new();
    my $got_statment = $hosts_obj->search($search)->statments;
    is_deeply( $got_statment , $expected_statment, sprintf( "Test %d", ( $i / 2 ) + 1 ) );
}

done_testing;
