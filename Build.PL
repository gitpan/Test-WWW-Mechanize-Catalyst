use Module::Build;
use strict;

my $build = Module::Build->new(
  create_makefile_pl => 'traditional',
  license            => 'perl',
  module_name        => 'Test::WWW::Mechanize::Catalyst',
  requires           => {
    'Test::More' => '0',
    'Catalyst'   => '4.30',
    'Test::WWW::Mechanize' => '0',
  },
);
$build->create_build_script;
