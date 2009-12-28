#!perl -T

use Test::More;

use_ok('Nagios::MKLivestatus::Class::Abstract::Stats');

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
);

for ( my $i = 0 ; $i < scalar @testings ; $i++ ) {
    my $search            = $testings[$i];
    my $expected_statment = $testings[ ++$i ];
    my $filter_obj        = Nagios::MKLivestatus::Class::Abstract::Stats->new();
    my $got_statment;
    eval {
        $got_statment = $filter_obj->apply($search);
    } or  warn @_;
    is_deeply( $got_statment, $expected_statment,
        sprintf( "Test %d - %s", ( $i / 2 ) + 1 , join " ",@{ $expected_statment } ));
}

done_testing;
