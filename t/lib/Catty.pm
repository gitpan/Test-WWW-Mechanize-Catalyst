package Catty;

use strict;
use Catalyst;
#use Catalyst qw/-Debug/;
use Cwd;

our $VERSION = '0.01';

Catty->config(
    name => 'Catty',
    root => cwd . '/t/root',
);

Catty->action(
  '!default' => sub {
    my($self, $c) = @_;
    my $html = html("Root", "This is the root page");
    $c->res->output($html);
  },
  'hello' => sub {
    my($self, $c) = @_;
    my $html = html("Hello", "Hi there!");
    $c->res->output($html);
  },
);

sub html {
  my($title, $body) = @_;
  return qq{
<html>
<head><title>$title</title></head>
<body>
$body
<a href="/hello/">Hello</a>.
</body></html>
};
}

1;
