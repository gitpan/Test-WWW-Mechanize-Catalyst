#!perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Test::WWW::Mechanize::Catalyst',
    'VERSION_FROM' => 'lib/Test/WWW/Mechanize/Catalyst.pm',
    'AUTHOR'       => 'Leon Brocard <acme@astray.com>',
    'PREREQ_PM'    => {
        'Test::More'           => '0',
        'WWW::Mechanize'       => '1.30',
        'Catalyst'             => '5.00',
        'Test::WWW::Mechanize' => '1.14'
    },
);

