#!/usr/bin/env perl

use strict;
use warnings;
# vi: set cin sw=2:


use Test::More tests => 11;

# D'oh
use Mojolicious::Lite;
use Test::Mojo;

# Load plugin
my  $vivid = plugin "vivid_params";
my  $params;


is_deeply $vivid->to_vivid_hash( qw/bar bas foo bar foo baz bar test a b/ ),
  {
  foo => ['bar', 'baz'],
  a   => 'b',
  bar => ['bas', 'test']
  },
  'right structure';
  
$params = Mojo::Parameters->new;
$params->parse( "a[foo][]=3&a[foo][]=4&a[bar]=5&b=6" );
is_deeply $vivid->to_vivid_hash( @{$params->params} ), 
  { a => { foo => [ 3, 4 ], bar => 5 }, b => 6 }, 
  "right structure";

# GET-POST /
post '/' => 'index';
get '/2/' => 'index2';
get '/3/' => 'index3';

my $t = Test::Mojo->new;

# GET-POST /
$t->post_form_ok('/', { a => "b" } )->status_is(200)->content_is("bb\n");
$t->get_ok('/2/?a[]=b&a[]=c' )->status_is(200)->content_is("bc\n");
$t->get_ok('/3/?a[bar]=baz&a[baz]=foo' )->status_is(200)->content_is("bazfoo\n");

__DATA__
@@ index.html.ep
<%= vivid->{a} %><%= vivid "a" %>
@@ index2.html.ep
<%= vivid->{a}->[0] %><%= vivid( "a" )->[1] %>
@@ index3.html.ep
<%= vivid->{a}->{bar} %><%= vivid( "a" )->{baz} %>
__END__

