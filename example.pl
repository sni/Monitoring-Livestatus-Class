#!/usr/bin/env perl

use warnings;
use strict;

use Data::Dumper;

use lib '/Users/rbo/Development/Private/Nagios-MKLivestatus/lib/';
use Nagios::MKLivestatus::INET;

use lib 'lib/';
use Nagios::MKLivestatus::Class;

my $livestatus = Nagios::MKLivestatus::INET->new( '10.211.55.140:6557' );
printf "%s\n", $livestatus->selectall_arrayref("GET hosts");

my $class = Nagios::MKLivestatus::Class->new(
    backend => 'INET',
    socket => '10.211.55.140:6557',
);

my $hosts = $class->table('services');

my @headers = $hosts->columns();
my @data = $hosts->search->hashref_array();
print Dumper \@data;




