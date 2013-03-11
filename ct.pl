#!/usr/bin/perl

BEGIN {
        push @INC,"/opt/local/lib/perl5/site_perl/5.8.8/";
}


use POSIX qw(strftime);
my $date = strftime("%Y-%m-%dT%H:%M:%SZ\n", gmtime(time));
chop $date;
 

my $agency = "Association for the Blind of Western Australia";
my $head  = '<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:dcterms="http://purl.org/dc/terms" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:opds="http://opds-spec.org/2010/catalog">
<title>ABWA Library</title>
<id>abwa:catalog</id>
<author>
	<name>Greg Kearney</name>
	<uri>http://www.guidedogswa.org</uri>
	<email>gkearney@gmail.com</email>
</author>'."
<updated>$date</updated>";

print $head;