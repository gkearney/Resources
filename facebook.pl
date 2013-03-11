#!/usr/bin/perl

BEGIN {
        push @INC,"/opt/local/lib/perl5/site_perl/5.8.8/";
}

$fb_api_key = "604676607";
$fb_secret = "AAACEdEose0cBAHi6D7ZC4yZA4HeWNjLp5FWaaQcTKq46VmiOnIOWUwZBMu49Dt0GSpOKiAbUNwLAU07tMuRQMzdblXtwe2l7K3TnrzZAPAZDZD";

use WWW::Facebook::API;
my $facebook = WWW::Facebook::API->new(
    desktop => 0,
    api_key => $fb_api_key,
    secret => $fb_secret,
 session_key => $query->cookie($fb_api_key.'_session_key'),
 session_expires => $query->cookie($fb_api_key.'_expires'),
 session_uid => $query->cookie($fb_api_key.'_user')
);

my $response = $facebook->stream->publish(
 message => qq|Test status message|,
);