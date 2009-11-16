#!perl -T

use Test::More;

use_ok('Nagios::MKLivestatus::Class::Base::Table;');

*generate_search_statment = sub {
    return Nagios::MKLivestatus::Class::Base::Table::_generate_search_statment(
        Nagios::MKLivestatus::Class::Base::Table,
        @_,
        undef,
    );
};

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
    my @got_statment = generate_search_statment($search);
    is_deeply( \@got_statment , $expected_statment, sprintf( "Test %d", ( $i / 2 ) + 1 ) );
}

# warn generate_search_statment();

done_testing;
