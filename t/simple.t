#!perl -T
use strict;
use warnings;
use lib 'lib';
use Test::More tests => 19;
use lib 't/lib';
use Test::WWW::Mechanize::Catalyst 'Catty';

my $root = "http://localhost";

my $m = Test::WWW::Mechanize::Catalyst->new;
$m->get_ok("$root/");
is( $m->ct, "text/html" );
$m->title_is("Root");
$m->content_contains("This is the root page");

$m->follow_link_ok( { text => 'Hello' } );
is( $m->base, "http://localhost/hello/" );
is( $m->ct,   "text/html" );
$m->title_is("Hello");
$m->content_contains("Hi there");

$m->get("$root/die/");
is( $m->status, 500 );
is( $m->ct,     "" );
$m->title_is(undef);
$m->content_is("");

$m->{catalyst_debug} = 1;
$m->get("$root/die/");
is( $m->status, 500 );
is( $m->ct,     "text/html" );
$m->title_like(qr/Catty on Catalyst/);
$m->content_like(qr/Caught exception in Catty/);
$m->content_like(qr/erk/);
$m->content_like(qr/This is the die page/);
