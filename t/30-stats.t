#!perl

use Test::More;

use_ok('Monitoring::Livestatus::Class::Abstract::Stats');
my $now = time();
my $min1   = $now - 60;
my $min5   = $now - 300;
my $min15  = $now - 900;
my @testings = (
    { name => 'localhost' }, ["Stats: name = localhost"],
    [
        { state => [0,1,2,3] },
        { '-groupby' => 'host_name'}
    ], [
        "Stats: state = 0",
        "Stats: state = 1",
        "Stats: state = 2",
        "Stats: state = 3",
        "StatsGroupBy: host_name",
    ],
    [
        [ 'check_type' => 0, -as => 'active_sum' ],
        {
            -and => [
                'check_type'       => 0,
                'has_been_checked' => 1,
                'last_check'       => { '>=' => $min1 },
                # -as                => 'active_1_min_sum',
            ]
        },
        {
            -and => [
                'check_type'       => 0,
                'has_been_checked' => 1,
                'last_check'       => { '>=' => $min5 },
                # -as                => 'active_5_min_sum',
            ]
        },
        {
            -and => [
                'check_type'       => 0,
                'has_been_checked' => 1,
                'last_check'       => { '>=' => $min15 },
                # -as => 'active_15_min_sum',
            ]
        },
        {
            -and => [
                'check_type'       => 0,
                'has_been_checked' => 1,
                -avg               => 'latency',
                # -as                => 'latency_avg',
            ]
        }
    ],
      [
        # "Stats: check_type = 0 as active_sum",
        "Stats: check_type = 0",
        "Stats: check_type = 0",
        "Stats: has_been_checked = 1",
        # "Stats: last_check >= $min1 as active_1_min_sum",
        "Stats: last_check >= $min1",
        "StatsAnd: 3",
        "Stats: check_type = 0",
        "Stats: has_been_checked = 1",
        # "Stats: last_check >= $min5 as active_5_min_sum",
        "Stats: last_check >= $min5",
        "StatsAnd: 3",
        "Stats: check_type = 0",
        "Stats: has_been_checked = 1",
        # "Stats: last_check >= $min15 as active_15_min_sum",
        "Stats: last_check >= $min15",
        "StatsAnd: 3",
        "Stats: check_type = 0",
        "Stats: has_been_checked = 1",
        # "Stats: avg latency as latency_avg",
        "Stats: avg latency",
        "StatsAnd: 3",
      ]

);

for ( my $i = 0 ; $i < scalar @testings ; $i++ ) {
    my $search            = $testings[$i];
    my $expected_statment = $testings[ ++$i ];
    my $filter_obj        = Monitoring::Livestatus::Class::Abstract::Stats->new();
    my $got_statment;
    eval {
        $got_statment = $filter_obj->apply($search);
    } or  warn @_;
    is_deeply( $got_statment, $expected_statment,
        sprintf( "Test %d - %s", ( $i / 2 ) + 1 , join " ",@{ $expected_statment } ));
}

done_testing;
