#!perl -T
use strict;
use warnings;
use lib 'lib';
use Test::More tests => 9;
use lib 't/lib';
use Test::WWW::Mechanize::Catalyst 'Catty';

my $root = "http://localhost";

my $m = Test::WWW::Mechanize::Catalyst->new;
$m->get_ok("$root/");
is($m->ct, "text/html");
$m->title_is("Root");
$m->content_contains("This is the root page");

$m->follow_link_ok({text => 'Hello'});
is($m->base, "http://localhost/hello/");
is($m->ct, "text/html");
$m->title_is("Hello");
$m->content_contains("Hi there");
