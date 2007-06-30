package Catty;

use strict;

#use Catalyst;
use Catalyst qw/-Debug/;
use Cwd;
use MIME::Base64;

our $VERSION = '0.01';

Catty->config(
    name => 'Catty',
    root => cwd . '/t/root',
);

Catty->setup();

sub default : Private {
    my ( $self, $context ) = @_;
    my $html = html( "Root", "This is the root page" );
    $context->response->content_type("text/html");
    $context->response->output($html);
}

sub hello : Global {
    my ( $self, $context ) = @_;
    my $html = html( "Hello", "Hi there! ☺" );
    $context->response->content_type("text/html; charset=utf-8");
    $context->response->output($html);
}

# absolute redirect
sub hi : Global {
    my ( $self, $context ) = @_;
    my $where = $context->uri_for('hello');
    $context->response->redirect($where);
    return;
}

# partial (relative) redirect
sub greetings : Global {
    my ( $self, $context ) = @_;
    $context->response->redirect("hello");
    return;
}

# redirect to a redirect
sub bonjour : Global {
    my ( $self, $context ) = @_;
    my $where = $context->uri_for('hi');
    $context->response->redirect($where);
    return;
}

sub check_auth_basic : Global {
    my ( $self, $context ) = @_;

    my $auth = $context->req->headers->authorization;
    ($auth) = $auth =~ /Basic\s(.*)/i;
    $auth = decode_base64($auth);

    if ( $auth eq "user:pass" ) {
        my $html = html( "Auth", "This is the auth page" );
        $context->response->content_type("text/html");
        $context->response->output($html);
        return $context;
    } else {
        my $html = html( "Auth", "Auth Failed!" );
        $context->response->content_type("text/html");
        $context->response->output($html);
        $context->response->status("401");
        return $context;
    }
}

sub die : Global {
    my ( $self, $context ) = @_;
    my $html = html( "Die", "This is the die page" );
    $context->response->content_type("text/html");
    $context->response->output($html);
    die "erk!";
}

sub html {
    my ( $title, $body ) = @_;
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

