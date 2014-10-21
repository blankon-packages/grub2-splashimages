#!/usr/bin/perl

#
# grub2-commons2tga.pl by Krzysztof Burghardt <krzysztof@burghardt.pl>
#
# I, the copyright holder of this work, hereby release it into the
# public domain. This applies worldwide.
#
# In case this is not legally possible:
# I grant anyone the right to use this work for any purpose, without
# any conditions, unless such conditions are required by law.
#

use LWP::UserAgent;
use Image::Magick;

if ($#ARGV != 0) {
    print "Usage: grub2-commons2tga commons_image_name.ext\n";
    exit -1;
}

$ua = LWP::UserAgent->new;
$req = HTTP::Request->new(GET => "http://commons.wikimedia.org/wiki/Image:$ARGV[0]");
$req->header("Accept" => "text/html");

$res = $ua->request($req);

if ($res->is_success) {
    $res = $res->content;
} else {
    print "error: " . $res->status_line . "\n";
    exit -1;
}

if ($res =~ /class="fullImageLink" id="file"><a href="([^"]*)"><img/si) {
    $res = $1;
} else {
    print "error: requested file not found on server\n";
    exit -1;
}

$req = HTTP::Request->new(GET => $res);
$res = $ua->request($req);

if ($res->is_success) {
    $res = $res->content;
} else {
    print "error: " . $res->status_line . "\n";
    exit -1;
}

$image = Image::Magick->new();
$image->BlobToImage($res);
$image->Scale(geometry => "640x480");

if ($ARGV[0] =~ /([^.]*)/g) {
    $filename = "$1.tga";
    $filename =~ s/ /_/g;
} else {
    print "error: cannot determine target file name";
    exit -1;
}

$image->Write(filename => $filename);
