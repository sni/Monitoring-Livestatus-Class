#!perl -T

use Test::More;

use_ok('Nagios::MKLivestatus::Class::Table::Hosts');

my @testings = (
    { name => 'localhost' }, ["Filter: name = localhost"],
    { name => 'localhost', service => 'ping' }, [ "Filter: name = localhost", "Filter: service = ping" ],
    { name => [qw/localhost router/] }, [ "Filter: name = localhost", "Filter: name = router" ],
    [
        { name => 'localhost' },
        { name => 'router' },
    ], [ "Filter: name = localhost", "Filter: name = router" ],
    # not supported at the moment
    { name => { '-or' => [ qw/localhost router/] } },[ "Filter: name = localhost", "Filter: name = router", "Or: 2" ],
    { '-or' => [
            scheduled_downtime_depth => { '>' => '0' },
            host_scheduled_downtime_depth => { '>' => '0'},
        ]
    },['Filter: scheduled_downtime_depth > 0','Filter: host_scheduled_downtime_depth > 0','Or: 2'],
    {
        '-or' => {
            '-and' => { state => '2', acknowledged => '1', },
            state => '0',
        }
    },['Filter: acknowledged = 1', 'Filter: state = 2', 'And: 2', 'Filter: state = 0', 'Or: 2'],
    {
        '-or' => [
            { host_has_been_checked => 0, },
            {
                '-and' => {
                    host_state            => 1,
                    host_has_been_checked => 1,
                }
            },
            {
                '-and' => {
                    host_state            => 2,
                    host_has_been_checked => 1,
                }
            },
        ]
    },['Filter: host_has_been_checked = 0','Filter: host_state = 1','Filter: host_has_been_checked = 1','And: 2','Filter: host_state = 2','Filter: host_has_been_checked = 1','And: 2','Or: 3',],
    # Simple operator tests
    { name => { '=' => [ qw/localhost router/] } },[ "Filter: name = localhost", "Filter: name = router" ],
    { name => { '~' => [ qw/localhost router/] } },[ "Filter: name ~ localhost", "Filter: name ~ router" ],
    { name => { '~=' => [ qw/localhost router/] } },[ "Filter: name ~= localhost", "Filter: name ~= router" ],
    { name => { '~~' => [ qw/localhost router/] } },[ "Filter: name ~~ localhost", "Filter: name ~~ router" ],
    { name => { '<' => [ qw/localhost router/] } },[ "Filter: name < localhost", "Filter: name < router" ],
    { name => { '>' => [ qw/localhost router/] } },[ "Filter: name > localhost", "Filter: name > router" ],
    { name => { '<=' => [ qw/localhost router/] } },[ "Filter: name <= localhost", "Filter: name <= router" ],
    { name => { '>=' => [ qw/localhost router/] } },[ "Filter: name >= localhost", "Filter: name >= router" ],
    { host_scheduled_downtime_depth => { '>' => 0 } },[ "Filter: host_scheduled_downtime_depth > 0" ],
);

for ( my $i = 0 ; $i < scalar @testings ; $i++ ) {
    my $search            = $testings[$i];
    my $expected_statment = $testings[ ++$i ];
    my $hosts_obj         = Nagios::MKLivestatus::Class::Table::Hosts->new();
    my $got_statment;
    eval {
        $got_statment = $hosts_obj->search($search)->statments;
    } or  warn @_;
    is_deeply( $got_statment, $expected_statment,
        sprintf( "Test %d - %s", ( $i / 2 ) + 1 , join " ",@{ $expected_statment } ));
}

done_testing;
