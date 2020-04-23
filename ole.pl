#!/usr/bin/env perl 

use strict;
use warnings;
use feature qw(say switch :5.10);
use Carp qw(croak carp);
use utf8;
use Encode;
use open 'locale';
use WWW::Mechanize;
use LWP::Simple;

my @links = ();
my $url   = 'http://leer-comics.blogspot.com/2019/02/coleccion-ole.html?m=1';

my $mech = WWW::Mechanize->new();
$mech->get("$url");

foreach my $link ( $mech->links ) {
    my $url  = $link->url;
    my $text = $link->text;
    if ($text) {
        {
            push @links, $link->url if ( $text =~ /^Colección.*/ );
        }
    }
}

for my $link (@links) {
    say $link;
    my @nombre = split( /\//, $link );
    my ( $nombre, undef ) = split( /\./, $nombre[-1] );
    $nombre =~ s/-/ /g;
    $nombre = uc($nombre);
    $nombre =~ s/.*OLE /$`/o;
    $nombre =~ s/^\d+/$& -/o;

    $mech->get($link);
    
    my @links = $mech->find_all_links(
        tag       => "a",
        url_regex => qr/\d+\.jpg$/i
    );

    say "¿Quiere descargar el tebeo \"$nombre\"? [s/n/x]";
    
    while ( my $sn = <> ) {
        chomp $sn;
        exit if $sn eq 'x';
        last if ( $sn eq 'n' );
        &descargar( \@links, $nombre ) if ( $sn eq 's' );
        last;
    }
}

sub descargar {
    my ( $links, $nombre ) = @_;
    mkdir("/tmp/$nombre");
    say "Creando directorio /tmp/$nombre";
    for my $l (@$links) {
        my @archivo = split( /\//, $l->url );
        say "Descargando " . $l->url . " en\n\t" . "/tmp/$nombre/$archivo[-1]";
        getstore( $l->url, "/tmp/$nombre/$archivo[-1]" );
    }
    return;
}
