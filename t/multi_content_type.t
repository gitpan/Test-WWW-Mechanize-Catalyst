#!perl
use strict;
use warnings;
use lib qw(lib t/lib);

my $PORT;

BEGIN {
    $PORT = $ENV{TWMC_TEST_PORT} || 7357;
    $ENV{CATALYST_SERVER} ||= "http://localhost:$PORT";
}

use Test::More tests => 6;
use Test::Exception;

BEGIN {
    diag(
        "\n###################################################################\n",
        "Starting an external Catalyst HTTP server on port $PORT\n",
        "To change the port, please set the TWMC_TEST_PORT env variable.\n",
        "(The server will be automatically shut-down right after the tests).\n",
        "###################################################################\n"
    );
}

# Let's catch interrupts to force the END block execution.
$SIG{INT} = sub { warn "INT:$$"; exit };

use_ok 'ExternalCatty';
my $pid = ExternalCatty->background($PORT);

use Test::WWW::Mechanize::Catalyst;
my $m = Test::WWW::Mechanize::Catalyst->new;

lives_ok { $m->get_ok( '/', 'Get a multi Content-Type response' ) }
'Survive to a multi Content-Type sting';

is( $m->ct, 'text/html', 'Multi Content-Type Content-Type' );
$m->title_is( 'Root', 'Multi Content-Type title' );
$m->content_contains( "Hello, test \x{263A}!", 'Multi Content-Type body' );

END {
    if ( $pid > 0 ) {
        kill 9, $pid;
    }
}

1;

