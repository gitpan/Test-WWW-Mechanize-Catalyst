package ExternalCatty::Controller::Root;
use strict;
use warnings;

use base qw/ Catalyst::Controller /;

__PACKAGE__->config( namespace => '' );

sub default : Private {
    my ( $self, $c ) = @_;
    $c->response->content_type('text/html; charset=utf-8');
    $c->response->output( html( 'Root', 'Hello, test ☺!' ) );
}

# redirect to a redirect
sub hello: Global {
    my ( $self, $context ) = @_;
    my $where = $context->uri_for('/');
    $context->response->redirect($where);
    return;
}

sub html {
    my ( $title, $body ) = @_;
    return qq[
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>$title</title>
</head>
<body>$body</body>
</html>
];
}

1;

