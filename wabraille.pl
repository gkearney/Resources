#!/usr/bin/perl

BEGIN {
        push @INC,"/opt/local/lib/perl5/site_perl/5.8.8/";
}
use POSIX qw(strftime);
use Cwd; # module for finding the current working directory
use File::Copy;
use File::Basename;
use MARC::Record;
use File::Path qw(make_path remove_tree);
#use Net::Twitter;
#use Net::Twitter::Lite;
use XML::Simple;
#use Data::Dumper;
use Net::FTP;
use Proc::Daemon;



$mypath = "/Users/gkearney/Dropbox/braille/washington/index.html";

open FILE, "$mypath" or die $!; #open the ncc.html file
{
        local $/;
        $content = <FILE>;
}
    close(FILE);


$ref = XMLin($content,ForceArray => 0, KeyAttr => 'name');
$title = $ref->{body}->{'i'}->{content};
print "TITLE: $title\n";
