package Test::WWW::Mechanize::Catalyst;
use strict;
use warnings;
use Test::WWW::Mechanize;
use URI;
use base qw(Test::WWW::Mechanize);
our $VERSION = "0.29";

sub _make_request {
  my($self, $request) = @_;
  my $response = Test::WWW::Mechanize::Catalyst::Aux::request($request->uri);
  $response->header('Content-Base', $request->uri);
  return $response;
}

sub import {
  Test::WWW::Mechanize::Catalyst::Aux::import(@_);
}

package Test::WWW::Mechanize::Catalyst::Aux;
sub import {
  my($class, $name) = @_;
  eval "use Catalyst::Test '$name'";
  die "Error with: use Catalyst::Test '$name': $@" if $@;
}

1;

__END__

=head1 NAME

Test::WWW::Mechanize::Catalyst - Test::WWW::Mechanize for Catalyst

=head1 SYNOPSIS

  # We're in a test script...
  # To test a Catalyst application named 'Catty':
  use Test::WWW::Mechanize::Catalyst 'Catty';

  my $m = Test::WWW::Mechanize::Catalyst->new;
  $m->get_ok("http://localhost/");
  is($m->ct, "text/html");
  $m->title_is("Root");
  $m->content_contains("This is the root page");
  $m->follow_link_ok({text => 'Hello'});
  # ... and all other Test::WWW::Mechanize methods

=head1 DESCRIPTION

Catalyst is an elegant MVC Web Application
Framework. Test::WWW::Mechanize is a subclass of WWW::Mechanize that
incorporates features for web application testing. The
Test::WWW::Mechanize::Catalyst module meshes the two to allow easy
testing of Catalyst applications.

To use this module you must pass it the name of the application. See
the SYNOPSIS above.

=head1 SEE ALSO

Related modules which may be of interest: L<Catalyst>,
L<Test::WWW::Mechanize>, L<WWW::Mechanize>.

=head1 AUTHOR

Leon Brocard <acme@astray.com>.

=head1 COPYRIGHT

Copyright (C) 2005, Leon Brocard

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
