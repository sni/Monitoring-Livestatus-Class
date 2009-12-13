use inc::Module::Install;

name     'Nagios-MKLivestatus-Class';
all_from 'lib/Nagios/MKLivestatus/Class.pm';
author   q{Robert Bohne <rbo@cpan.org>};
license  'perl';

requires 'Moose';
requires 'Module::Find';
requires 'Nagios::MKLivestatus' => '0.28';

build_requires 'Test::More';

auto_install;

WriteAll;

