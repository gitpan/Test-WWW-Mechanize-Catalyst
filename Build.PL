#!perl
use Module::Build;
use strict;
use warnings;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Test::WWW::Mechanize::Catalyst',
    requires           => {
        'Test::More'           => '0',
        'Catalyst'             => '5.00',
        'Test::WWW::Mechanize' => '1.14',
        'WWW::Mechanize'       => '1.30',
    },
);
$build->create_build_script;

