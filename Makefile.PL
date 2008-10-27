#!perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Test::WWW::Mechanize::Catalyst',
    'VERSION_FROM' => 'lib/Test/WWW/Mechanize/Catalyst.pm',
    'AUTHOR'       => 'Leon Brocard <acme@astray.com>',
    'ABSTRACT'     => 'Test::WWW::Mechanize for Catalyst',
    'LICENSE'      => 'perl',
    'PREREQ_PM'    => {
        'Catalyst'                                 => '5.00',
        'Catalyst::Plugin::Session::State::Cookie' => '0',
        'Catalyst::Plugin::Session::Store::Dummy'  => '0',
        'LWP'                                      => '5.816',
        'Test::Exception'                          => '0',
        'Test::More'                               => '0',
        'Test::WWW::Mechanize'                     => '1.14',
        'WWW::Mechanize'                           => '1.50',
    },
);

