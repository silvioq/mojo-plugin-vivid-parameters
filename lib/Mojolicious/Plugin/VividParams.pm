package Mojolicious::Plugin::VividParams;
use Mojo::Base 'Mojolicious::Plugin';
# vi: set cin sw=2:
#
our $VERSION = "0.01";

sub mergehashes{     # Dies on circular references
  my $self = shift;
  my @hashrefs = @_;
  die "Passed a non hashref" if grep { ref $_ ne 'HASH' } @hashrefs;
  my %merged = ();

  foreach my $h (@hashrefs){
    while (my ($k,$v) = each %$h ){
      if( ref $v eq "ARRAY" ){
        push @{$merged{$k}}, @$v;
      } else {
        push @{$merged{$k}}, $v;
      }
    }
  }

  while (my ($k,$v) = each %merged){
    my @hashes = grep { ref $_ eq 'HASH' } @$v;
    $merged{$k} = $v->[0] if (@$v == 1 && !ref $v->[0]);
    $merged{$k}  = $self->mergehashes(@hashes) if @hashes;
  }

  return \%merged;
}

sub to_vivid_hash{
  my $self = shift;
  my @params = @_;
  my %params = ();

  for (my $i = 0; $i < @params; $i += 2) {
    my $name  = $params[$i];
    my $value = $params[$i + 1];
    my %to_merge = ();

    # Check for [] inclusion.
    while( $name =~ /\[([^\]]*)\]$/ ){
      my $partial_hash = $1;
      $name =~ s/\[[^\]]*\]$//;
      if( $partial_hash ){
        $value = { $partial_hash => $value };
      } else {
        # $value = [ $value ];
      }
    }
    $to_merge{$name} = $value;
    %params = %{$self->mergehashes( \%params, \%to_merge )};
  }
  return  \%params;
}



# Ooh, a sarcasm detector.  Oh, that's a *real* useful invention. 
sub  register{
  my( $self, $app ) = @_;
  $app->helper( 
    vivid => sub{
      my $self = shift;
      my $parm = shift;
      my $vivid = $self->stash("vivid.params");
      if( !$vivid ){
        $vivid = Mojolicious::Plugin::VividParams->to_vivid_hash(
          @{$self->tx->req->params->params}
        );
        $self->stash("vivid.params", $vivid);
      }

      return $vivid unless $parm;
      return $vivid->{$parm};
    }
  );
  return $self;
}

      


1;
__END__

=head1 NAME

Mojolicious::Plugin::VividParams - Vivid POST/GET Parameters Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('vivid_params');

  # Mojolicious::Lite
  plugin 'vivid_params';

=head1 DESCRIPTION

L<Mojolicious::Plugin::VividParams> treats parameters as PHP / Rails style. 
Square brakets after variable name makes it in Hash or Array.

This is a EXPERIMENTAL plugin, use under your own risk.

=head1 HELPERS

=head2 vivid
  
  # curl "http://example.com?p[foo][bar]=baz
  <%= vivid->{p}->{foo}->{bar} %>
  # Returns "baz"

  <%= vivid('p')->{foo}->{bar} %>

Returns vivid parameters, in PHP/Rails style

=head1 METHODS

L<Mojolicious::Plugin::VividParams> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 C<register>

  $plugin->register;

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
