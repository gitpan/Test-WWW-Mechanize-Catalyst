#!perl
use inc::Module::Install 0.77;

use strict;
use warnings;

name 'Test-WWW-Mechanize-Catalyst';
all_from 'lib/Test/WWW/Mechanize/Catalyst.pm';

requires 'Catalyst'                                 => '5.00';
requires 'LWP'                                      => '5.816';
requires 'Test::WWW::Mechanize'                     => '1.14';
requires 'WWW::Mechanize'                           => '1.50';
requires 'Moose'                                    => '0.67';
requires 'namespace::clean'                         => '0.09';

test_requires 'Catalyst::Plugin::Session::State::Cookie' => '0';
test_requires 'Catalyst::Plugin::Session::Store::Dummy'  => '0';
test_requires 'Test::Exception'                          => '0';
test_requires 'Test::More'                               => '0';

if ($Module::Install::AUTHOR) {
  system('pod2text lib/Test/WWW/Mechanize/Catalyst.pm > README');
}


WriteAll;
