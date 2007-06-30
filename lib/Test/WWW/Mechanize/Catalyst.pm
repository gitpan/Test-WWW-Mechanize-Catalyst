package Test::WWW::Mechanize::Catalyst;
use strict;
use warnings;
use Encode qw();
use HTML::Entities;
use Test::WWW::Mechanize;
use base qw(Test::WWW::Mechanize);
our $VERSION = "0.38";
my $Test = Test::Builder->new();

# the reason for the auxiliary package is that both WWW::Mechanize and
# Catalyst::Test have a subroutine named 'request'

sub _make_request {
    my ( $self, $request ) = @_;
    $self->cookie_jar->add_cookie_header($request) if $self->cookie_jar;

    $request->authorization_basic(
        LWP::UserAgent->get_basic_credentials(
            undef, "Basic", $request->uri
        )
        )
        if LWP::UserAgent->get_basic_credentials( undef, "Basic",
        $request->uri );

    my $response = Test::WWW::Mechanize::Catalyst::Aux::request($request);
    $response->header( 'Content-Base', $request->uri );
    $response->request($request);
    $self->cookie_jar->extract_cookies($response) if $self->cookie_jar;

    # fail tests under the Catalyst debug screen
    if (   !$self->{catalyst_debug}
        && $response->code == 500
        && $response->content =~ /on Catalyst \d+\.\d+/ )
    {
        my ($error)
            = ( $response->content =~ /<code class="error">(.*?)<\/code>/s );
        $error ||= "unknown error";
        decode_entities($error);
        $Test->diag("Catalyst error screen: $error");
        $response->content('');
        $response->content_type('');
    }

    # check if that was a redirect
    if (   $response->header('Location')
        && $self->redirect_ok( $request, $response ) )
    {

        # remember the old response
        my $old_response = $response;

        # *where* do they want us to redirect to?
        my $location = $old_response->header('Location');

        # no-one *should* be returning non-absolute URLs, but if they
        # are then we'd better cope with it.  Let's create a new URI, using
        # our request as the base.
        my $uri = URI->new_abs( $location, $request->uri )->as_string;

        # make a new response, and save the old response in it
        $response = $self->_make_request( HTTP::Request->new( GET => $uri ) );
        my $end_of_chain = $response;
        while ( $end_of_chain->previous )    # keep going till the end
        {
            $end_of_chain = $end_of_chain->previous;
        }                                          #   of the chain...
        $end_of_chain->previous($old_response);    # ...and add us to it
    } else {
        $response->{_raw_content} = $response->content;
        if (   $response->header('Content-Type')
            && $response->header('Content-Type') =~ m/charset=(\S+)/xms )
        {
            $response->content( Encode::decode( $1, $response->content ) );
        }
    }

    return $response;
}

sub import {
    Test::WWW::Mechanize::Catalyst::Aux::import(@_);
}

package Test::WWW::Mechanize::Catalyst::Aux;

sub import {
    my ( $class, $name ) = @_;
    eval "use Catalyst::Test '$name'";
    warn $@ if $@;
}

1;

__END__

=head1 NAME

Test::WWW::Mechanize::Catalyst - Test::WWW::Mechanize for Catalyst

=head1 SYNOPSIS

  # We're in a t/*.t test script...
  # To test a Catalyst application named 'Catty':
  use Test::WWW::Mechanize::Catalyst 'Catty';

  my $mech = Test::WWW::Mechanize::Catalyst->new;
  $mech->get_ok("/"); # no hostname needed
  is($mech->ct, "text/html");
  $mech->title_is("Root", "On the root page");
  $mech->content_contains("This is the root page", "Correct content");
  $mech->follow_link_ok({text => 'Hello'}, "Click on Hello");
  # ... and all other Test::WWW::Mechanize methods

=head1 DESCRIPTION

L<Catalyst> is an elegant MVC Web Application
Framework. L<Test::WWW::Mechanize> is a subclass of L<WWW::Mechanize> that
incorporates features for web application testing. The
L<Test::WWW::Mechanize::Catalyst> module meshes the two to allow easy
testing of L<Catalyst> applications without starting up a web server.

Testing web applications has always been a bit tricky, normally
starting a web server for your application and making real HTTP
requests to it. This module allows you to test L<Catalyst> web
applications but does not start a server or issue HTTP
requests. Instead, it passes the HTTP request object directly to
L<Catalyst>. Thus you do not need to use a real hostname:
"http://localhost/" will do. However, this is optional. The following
two lines of code do exactly the same thing:

  $mech->get_ok('/action');
  $mech->get_ok('http://localhost/action');

You can also test a remote server by setting the environment variable
CATALYST_SERVER, for example:

  $ CATALYST_SERVER=http://example.com/myapp prove -l t

will run the same tests on the application running at
http://example.com/myapp regardless of whether or not you specify
http:://localhost for Test::WWW::Mechanize::Catalyst.    
    
This makes testing fast and easy. L<Test::WWW::Mechanize> provides
functions for common web testing scenarios. For example:

  $mech->get_ok( $page );
  $mech->title_is( "Invoice Status", "Make sure we're on the invoice page" );
  $mech->content_contains( "Andy Lester", "My name somewhere" );
  $mech->content_like( qr/(cpan|perl)\.org/, "Link to perl.org or CPAN" );

This module supports cookies automatically.

To use this module you must pass it the name of the application. See
the SYNOPSIS above.

Note that Catalyst has a special developing feature: the debug
screen. By default this module will treat responses which are the
debug screen as failures. If you actually want to test debug screens,
please use:

  $m->{catalyst_debug} = 1;

An alternative to this module is L<Catalyst::Test>.

=head1 CONSTRUCTOR

=head2 new

Behaves like, and calls, L<WWW::Mechanize>'s C<new> method.  Any parms
passed in get passed to WWW::Mechanize's constructor. Note that we
need to pass the name of the Catalyst application to the "use":

  use Test::WWW::Mechanize::Catalyst 'Catty';
  my $mech = Test::WWW::Mechanize::Catalyst->new;

=head1 METHODS

=head2 $mech->get_ok($url, [ \%LWP_options ,] $desc)

A wrapper around WWW::Mechanize's get(), with similar options, except the
second argument needs to be a hash reference, not a hash. Returns true or 
false.

=head2 $mech->title_is( $str [, $desc ] )

Tells if the title of the page is the given string.

    $mech->title_is( "Invoice Summary" );

=head2 $mech->title_like( $regex [, $desc ] )

Tells if the title of the page matches the given regex.

    $mech->title_like( qr/Invoices for (.+)/

=head2 $mech->title_unlike( $regex [, $desc ] )

Tells if the title of the page matches the given regex.

    $mech->title_unlike( qr/Invoices for (.+)/

=head2 $mech->content_is( $str [, $desc ] )

Tells if the content of the page matches the given string

=head2 $mech->content_contains( $str [, $desc ] )

Tells if the content of the page contains I<$str>.

=head2 $mech->content_lacks( $str [, $desc ] )

Tells if the content of the page lacks I<$str>.

=head2 $mech->content_like( $regex [, $desc ] )

Tells if the content of the page matches I<$regex>.

=head2 $mech->content_unlike( $regex [, $desc ] )

Tells if the content of the page does NOT match I<$regex>.

=head2 $mech->page_links_ok( [ $desc ] )

Follow all links on the current page and test for HTTP status 200

    $mech->page_links_ok('Check all links');

=head2 $mech->page_links_content_like( $regex,[ $desc ] )

Follow all links on the current page and test their contents for I<$regex>.

    $mech->page_links_content_like( qr/foo/,
      'Check all links contain "foo"' );

=head2 $mech->page_links_content_unlike( $regex,[ $desc ] )

Follow all links on the current page and test their contents do not
contain the specified regex.

    $mech->page_links_content_unlike(qr/Restricted/,
      'Check all links do not contain Restricted');

=head2 $mech->links_ok( $links [, $desc ] )

Check the current page for specified links and test for HTTP status
200.  The links may be specified as a reference to an array containing
L<WWW::Mechanize::Link> objects, an array of URLs, or a scalar URL
name.

    my @links = $mech->find_all_links( url_regex => qr/cnn\.com$/ );
    $mech->links_ok( \@links, 'Check all links for cnn.com' );

    my @links = qw( index.html search.html about.html );
    $mech->links_ok( \@links, 'Check main links' );

    $mech->links_ok( 'index.html', 'Check link to index' );

=head2 $mech->link_status_is( $links, $status [, $desc ] )

Check the current page for specified links and test for HTTP status
passed.  The links may be specified as a reference to an array
containing L<WWW::Mechanize::Link> objects, an array of URLs, or a
scalar URL name.

    my @links = $mech->links();
    $mech->link_status_is( \@links, 403,
      'Check all links are restricted' );

=head2 $mech->link_status_isnt( $links, $status [, $desc ] )

Check the current page for specified links and test for HTTP status
passed.  The links may be specified as a reference to an array
containing L<WWW::Mechanize::Link> objects, an array of URLs, or a
scalar URL name.

    my @links = $mech->links();
    $mech->link_status_isnt( \@links, 404,
      'Check all links are not 404' );

=head2 $mech->link_content_like( $links, $regex [, $desc ] )

Check the current page for specified links and test the content of
each against I<$regex>.  The links may be specified as a reference to
an array containing L<WWW::Mechanize::Link> objects, an array of URLs,
or a scalar URL name.

    my @links = $mech->links();
    $mech->link_content_like( \@links, qr/Restricted/,
        'Check all links are restricted' );

=head2 $mech->link_content_unlike( $links, $regex [, $desc ] )

Check the current page for specified links and test the content of each
does not match I<$regex>.  The links may be specified as a reference to
an array containing L<WWW::Mechanize::Link> objects, an array of URLs,
or a scalar URL name.

    my @links = $mech->links();
    $mech->link_content_like( \@links, qr/Restricted/,
      'Check all links are restricted' );

=head2 follow_link_ok( \%parms [, $comment] )

Makes a C<follow_link()> call and executes tests on the results.
The link must be found, and then followed successfully.  Otherwise,
this test fails.

I<%parms> is a hashref containing the parms to pass to C<follow_link()>.
Note that the parms to C<follow_link()> are a hash whereas the parms to
this function are a hashref.  You have to call this function like:

    $agent->follow_like_ok( {n=>3}, "looking for 3rd link" );

As with other test functions, C<$comment> is optional.  If it is supplied
then it will display when running the test harness in verbose mode.

Returns true value if the specified link was found and followed
successfully.  The HTTP::Response object returned by follow_link()
is not available.

=head1 SEE ALSO

Related modules which may be of interest: L<Catalyst>,
L<Test::WWW::Mechanize>, L<WWW::Mechanize>.

=head1 AUTHOR

Leon Brocard, C<< <acme@astray.com> >>

=head1 COPYRIGHT

Copyright (C) 2005, Leon Brocard

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

