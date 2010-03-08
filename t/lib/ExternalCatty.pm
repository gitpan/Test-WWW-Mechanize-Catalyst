package ExternalCatty;
use strict;
use warnings;
use Catalyst qw/-Engine=HTTP/;

__PACKAGE__->config( name => 'ExternalCatty' );
__PACKAGE__->setup;

# The Cat HTTP server background option is useless here :-(
# Thus we have to provide our own background method.
sub background {
    my $self  = shift;
    my $port  = shift;
    my $child = fork;
    die "Can't fork Cat HTTP server: $!" unless defined $child;
    return $child if $child;

    if ( $^O !~ /MSWin32/ ) {
        require POSIX;
        POSIX::setsid() or die "Can't start a new session: $!";
    }

    $self->run($port);
}

1;

