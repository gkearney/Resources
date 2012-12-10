#!/usr/bin/perl


use Net::LDAP;

$ldap = Net::LDAP->new( 'bookserver-mac' ) or die "$@";

 $mesg = $ldap->bind ;    # an anonymous bind

 $mesg = $ldap->search( # perform a search
                        base   => "cn=users,dc=bookserver-mac,dc=local",
                        filter => "(&(description=Player*))"
                      );

 $mesg->code && die $mesg->error;

 foreach $entry ($mesg->entries) { 
 
 print $entry->dump; 
 $userdata =  $entry->get_value ( 'sn' ) . " " . $entry->get_value ( 'givenName' );
 #print $ref;
 `say "This drive belongs to $userdata"`;
 
 
 }

 $mesg = $ldap->unbind;   # take down session