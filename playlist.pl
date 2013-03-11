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

$mypath = "/Volumes/DAISY_MASTER/tmp";
$movetodir = "/Volumes/Daisy/Daisy_Master_Backup/"; #Where the book gets moved to.
$movetodir_bu = "/Volumes/DAISY_MASTER/ABWA"; #Where the book gets moved to. a backup if the primary path above is not found


&ScanDirectory("$mypath");
&MoveDirectory("$mypath");


$dirname  = dirname($0);

sub MoveDirectory{
	my ($workdir) = shift; 

    my ($startdir) = &cwd; # keep track of where we began

    chdir($workdir) or die "Unable to enter dir $workdir:$!\n";
    opendir(DIR, ".") or die "Unable to open $workdir:$!\n";
    my @names = readdir(DIR) or die "Unable to read $workdir:$!\n";
    closedir(DIR);

    foreach my $name (@names){
    	next if ($name eq "."); 
        next if ($name eq "..");

		$new_name = $name;
		$new_name =~ s/\s+/_/g; #check for space
		$new_name =~ s/\x27//g; #check for space
		
        
        if (-d "$workdir/$name") {
    	
    	
    	&ScanDirectory("$workdir");
        next;
        
		chdir($startdir) #or  die "Unable to change to dir $startdir:$!\n";
    
    }


}
}



sub ScanDirectory{
	$movetodir = "/Volumes/Daisy/Daisy_Master_Backup/";
	$record = '';
	$xml = '';
	$brlnote ='';
	$dirname  = dirname($0);
    my ($workdir) = shift; 

    my ($startdir) = &cwd; # keep track of where we began

    chdir($workdir) or die "Unable to enter dir $workdir:$!\n";
    opendir(DIR, ".") or die "Unable to open $workdir:$!\n";
    my @names = readdir(DIR) or die "Unable to read $workdir:$!\n";
    closedir(DIR);

    foreach my $name (@names){
        next if ($name eq "."); 
        next if ($name eq "..");

		my $d = "$workdir/$name";
		
		if (-d $d) {
			print "Checkng pathname of $d\n";
			$old= $d;
			$old =~ s/ +/_/gi;
			$old =~ s/'//gi;
			$old =~ s/\.//gi;
			print "$d $old\n";
			rename($d,$old);
		}
	}



	chdir($workdir) or die "Unable to enter dir $workdir:$!\n";
    opendir(DIR, ".") or die "Unable to open $workdir:$!\n";
    my @names = readdir(DIR) or die "Unable to read $workdir:$!\n";
    closedir(DIR);



    foreach my $name (@names){
        next if ($name eq "."); 
        next if ($name eq "..");

		my $d = "$workdir/$name";
		if (-d $d) {
			my @files = <$d/*>;
			my $countfiles = @files;
			print "Count of files in $name is: $countfiles\n";
			next if ($countfiles < 2); 
		}
		
		#if ($name eq "Daisy_master") {
        	#print "removing $workdir/$name\n";
        	#remove_tree("$workdir/$name") or die "Could not unlink $workdir/$name $!";
        	#next;
        #}
        
        #This is here to remove the BackUp directory created by MyStudioPC.
		 if ($name eq "BackUp") {
        	print "removing $workdir/$name\n";
        	remove_tree("$workdir/$name") or die "Could not unlink $workdir/$name $!\n";
        	next;
        }

        #This is here to remove the z3986 directory if it is found.
		 if ($name eq "z3986") {
        	print "removing $workdir/$name\n";
        	remove_tree("$workdir/$name") or die "Could not unlink $workdir/$name $!\n";
        	next;
        }

		if ($name eq "tmp") {
        	print "removing $workdir/$name\n";
        	remove_tree("$workdir/$name") or die "Could not unlink $workdir/$name $!\n";
        	next;
        }
		#Make sure we retain the images directory if there is one.
		if ($name eq "images") {
      	      		next;
      	}

        if (-d "$workdir/$name") { 
        	#removeing old files.
        	print "$workdir/$name\n";
        	# $chmod = "chmod -Rv 775 $workdir/$name"; 
        	#`$chmod`;
        	
            # is this a directory?
            if (!-e "$workdir/$name/*.wpl") {
            if (-e "$workdir/$name/AutoRun.exe") { unlink("$workdir/$name/AutoRun.exe"); }
        	if (-e "$workdir/$name/autorun.inf") { unlink("$workdir/$name/autorun.inf"); }
            
				if (-e "$workdir/$name/content.html") {
				$brfcmd = "java -jar /Applications/BrailleBlaster/brailleblaster.jar -nogui translate  -f /Applications/BrailleBlaster/programData/liblouisutdml/lbu_files/preferences.cfg '$workdir/$name/content.html' '$workdir/$name/content.brf'";
#				$brfcmd = "/usr/local/bin/xml2brl '$workdir/$name/content.html' '$workdir/$name/content.brf'";
				$braille_note = " and UEBC Braille";
				print "Creating Braille file. $brfcmd \n";
				`$brfcmd`;} else {$braille_note = "";}
				

				
				
				
				
            if (-e "$workdir/$name/ncc.html") {
            	$cmd = "/usr/local/bin/pipeline/pipeline.sh /usr/local/bin/pipeline/scripts/modify_improve/multiformat/AudioTagger.taskScript --audioTaggerInputFile='$workdir/$name/ncc.html' --audioTaggerOutputPath='$workdir/$name'";


        		print "Working in $workdir/$name\n";
        		`$cmd`;
        		print "\tFinished $workdir/$name\n";
				
				print "Making MARC record from  $workdir/$name/ncc.html\n";



open FILE, "$workdir/$name/ncc.html" or die $!; #open the ncc.html file
			
$find = "dc:|ncc:"; #find only the lines with the meta data we need.
@line = <FILE>;
close FILE;

#loop through the file finding only lines with the meta data
for (@line) {
    if ($_ =~ /$find/) {
        $xml .= $_;
    }
}

if ($xml =~ m/<\/head>/gi) {
	$xml_head = "<head>\n$xml"; #put head tags around it for XML::Simple
} else {
	$xml_head = "<head>\n$xml</head>"; #put head tags around it for XML::Simple
}



#build the hash $ref key on the meta data name
$ref = XMLin($xml_head,ForceArray => 0, KeyAttr => 'name');


#Map the meta data into variables for the MARC record
#Map the meta data into variables for the MARC record
$title = $ref->{meta}->{'dc:title'}->{content};
$creator = $ref->{meta}->{'dc:creator'}->{content};
$date = $ref->{meta}->{'dc:date'}->{content};
$format = $ref->{meta}->{'dc:format'}->{content};
$uid = $ref->{meta}->{'dc:identifier'}->{content};
$language = $ref->{meta}->{'dc:language'}->{content};
$publisher = $ref->{meta}->{'dc:publisher'}->{content};
$totaltime = $ref->{meta}->{'ncc:totalTime'}->{content};
$subject = $ref->{meta}->{'dc:subject'}->{content};
$sourcepublisher = $ref->{meta}->{'ncc:SourcePublisher'}->{content};
$narrator = $ref->{meta}->{'ncc:narrator'}->{content};
$sourcedate = $ref->{meta}->{'ncc:SourceDate'}->{content};
$isbn = $ref->{meta}->{'dc:source'}->{content};



print "The format is: $format, The date is: $date\n";
				

close(FILE);


  
$record = '';
# create MARC object
$record = MARC::Record->new();

$marc_035 = MARC::Field->new(
   	'035','1','',
   		a => "$uid",
   		);

$marc_language = MARC::Field->new(
   	'041','1','',
   		a => "$language",
   		);

$marc_isbn = MARC::Field->new(
   	'020','1','',
   		a => "$isbn"
   		);
   		
$marc_author = MARC::Field->new(
   			'100','1','',
   			a => "$creator"
   			);

$marc_title = MARC::Field->new(
   	'245','1','4',
   		a => "$title",
   		c => "$creator"
   	);
   	

$marc_300 = MARC::Field->new(
   	'300','1','',
   		a => "$totaltime",
   		b => "$format mono"
   	);

$marc_500 = MARC::Field->new(
   	'500','1','',
   		a => "DAISY digital talking book ($format)"
   	);
   	
$marc_511 = MARC::Field->new(
   	'511','1','',
   		a => "$narrator"
   	);
   	
$marc_538 = MARC::Field->new(
   	'538','1','',
   		a => "DAISY digital talking books can be played on DAISY hardware playback devices or with a computer using DAISY playback software."
   	);
   	
#$marc_650 = MARC::Field->new(
 #  	'650','1','0',
#   		a => "$subject"
#   		);
   		
$marc_700 = MARC::Field->new(
   	'700','1','',
   		a => "$narrator",
   		e => "narrator"
   	);
   	
$marc_852 = MARC::Field->new(
   	'852','1','',
   		a => "$publisher"
   	);

$marc_260 = MARC::Field->new(
   	'260','1','',
   		a => "$publisher",
   		c => "$date"
   	);

$record->append_fields($marc_author, $marc_title, $marc_500, $marc_538, $marc_852, $marc_isbn, $marc_language, $marc_035, $marc_260, $marc_700, $marc_511, $marc_300) or print "Error creating MARC record\n"; 


open(OUTPUT, ">>$workdir/$name/daisy.mrc") or die $!;
print OUTPUT $record->as_usmarc();
close(OUTPUT);
$record = '';
print "\tFinished making MARC record from  $workdir/$name/ncc.html\n\n";



#Rename all the playlist files to the book title:


$newname = basename "$workdir/$name";
opendir DIR, "$workdir/$name";
@files = grep /playlist\.*/, readdir DIR;
closedir DIR;
 
foreach (@files) {
    
    $new = $_;
    $new =~ s/playlist\.(.+)/$newname.$1/;
    print "rename $_ $new\n";
    rename "$workdir/$name/$_", "$workdir/$name/$new";
}

rename "$workdir/$name/daisy.mrc", "$workdir/$name/$newname.mrc";
rename "$workdir/$name/content.brf", "$workdir/$name/$newname.brf";
				
				
            }
            }
            
            &ScanDirectory("$workdir/$name");
            next;
        }
        

        


        	
        }
        
$name = basename $workdir;


if ($name eq 'tmp') {
	print "No futher books to process\n";
	exit;
}

print "Creating the zip file for $workdir/$name\n";
$cmd = "cd $mypath; /usr/bin/zip -r -0 $name $name > /dev/null ";
`$cmd`;
sleep 3;

#test the zip file to see if it is OK
$result = `unzip -t $workdir.zip`;

if ($result =~ m/No errors detected/) {
	print "ZIP file OK\n\n";
} else {
	die "Error in ZIP file $workdir.zip\n\n";
}

$filesize = -s "$workdir.zip";

#Create the new directory on Bookserver-mac
@values = split('_',$name);

$dirnumber = @values[-1];




if ($dirnumber =~ /G.+/){
	$the_dir = "pd";
	$brlnote = '';
} else {
	$the_dir = "restricted";
	$brlnote = '';
}

if ($dirnumber =~ /^B.+/) {
	$the_dir = "restricted/braille";
	$brlnote = "braille";
} else {
	$the_dir = "restricted";
	$brlnote = '';
}



if ($dirnumber =~ /[0-9]+/) {


if (!-d "/Volumes/books/$the_dir/$dirnumber") {
	print "Making directory /Volumes/books/$the_dir/$dirnumber\n";
	make_path("/Volumes/books/$the_dir/$dirnumber", {verbose => 1});
} else {
	#die "No Directory test failed: /Volumes/books/$the_dir/$dirnumber\n";
	$rmcmd = "rm /Volumes/books/$the_dir/$dirnumber/*.*";
	`$rmcmd`;
}


# move the zipfile to the bookserver.
if (-d "/Volumes/books/$the_dir/$dirnumber") {
$zmcmd = "mv -f $workdir.zip /Volumes/books/$the_dir/$dirnumber/$name.zip";
$zipmove = `$zmcmd`;
print "$zmcmd\n$zipmove\n";
$zipfile = "/Volumes/books/$the_dir/$dirnumber/$name.zip";	
} else {
	die "No Directory /Volumes/books/$the_dir/$dirnumber\n";
}


#lookup the book's bibliographic information

use DBI;

my $db = 'DB_library';
my $host = 'bookserver-mac';
my $user = 'greg';
my $pass = 'cucat';

#DBI->trace(1);
print "Start of lookup\n";

$dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=3306",$user, $pass);

# PREPARE THE QUERY
$query = "SELECT b.title, b.`author` ,  bf.bibid, bfd.`field_data` FROM `biblio_field_data` bfd,`biblio_field` bf, `biblio` b 
WHERE ( bf.`tag`=035 AND bf.`subfield_cd`='a')
AND bfd.field_data = \"$dirnumber\"
AND bf.`fieldid`=bfd.`fieldid` 
AND b.`bibid`=bf.bibid";

$query_handle = $dbh->prepare($query);

# EXECUTE THE QUERY
$query_handle->execute();

# BIND TABLE COLUMNS TO VARIABLES
$query_handle->bind_columns(undef, \$title, \$author, \$bibid, \$field_data);

# LOOP THROUGH RESULTS
while($query_handle->fetch()) {
	
	print "Creating biblio_copy entry for $bibid $title\n\n";
	
	if ($braille_note eq "") {
		$copy_des = "Daisy 2.02 Audio Only";
		$contentid = "1";
	} else {
		$copy_des = "Daisy 2.02 Full Text, Full Audio";
		$contentid = "3";
	}
	
	if ($brlnote eq "braille") {
		$copy_des = "Braille";
		$contentid = "8";
		
	}
	

		$create_dt = strftime "%Y-%m-%d %H:%M:%S ", localtime;
		$file_path = "$the_dir/$dirnumber/$name.zip";
	 
	
	$insert_sql ="INSERT INTO biblio_copy (bibid, formatid, contentid, create_dt, copy_desc, file_path) VALUES(\"$bibid\", \"1\", \"$contentid\", \"$create_dt\", \"$copy_des\", \"$file_path\")";
	
	
   #print "$title $author $bibid\n";
}




$query = "SELECT CONCAT(bf.`tag`, bf.`subfield_cd`) AS 'tag' , bfd.`field_data` AS 'data' 
FROM `biblio_field` bf, `biblio_field_data` bfd 
WHERE bf.`fieldid`=bfd.`fieldid`AND bf.bibid = $bibid;";

$query_handle = $dbh->prepare($query);

# EXECUTE THE QUERY
$query_handle->execute();

# BIND TABLE COLUMNS TO VARIABLES
$query_handle->bind_columns(undef, \$tag, \$data);

undef ($Synopsis);
undef ($isbn);
undef ($format);
undef ($language);
undef ($agelevel);
undef ($language);
undef ($restriction);
undef ($warning_V);
undef ($warning_S);
undef ($wipo_test);
undef ($publisher);
undef ($public_note);

# LOOP THROUGH RESULTS
while($query_handle->fetch()) {
	if ($tag eq '520a') {
		$Synopsis = $data;
		$Synopsis =~ s/,//g;
	} 
	
	if ($tag eq '020a') {
			$isbn_marc = $data;
		}
		if ($isbn eq '') {
			$isbn_marc = "##########";
		}
	
	if ($tag eq '300a') {
			$format = $data;
		}
		if ($format eq '') {
			$format = "Daisy 2.02 audio";
		}
		
	if ($tag eq '041a') {
			$language = $data;
		}
		if ($language eq '') {
			$language = "eng";
		}
	if ($tag eq '041a') {
			$agelevel = $data;
	}
	if ($agelevel eq '') {
		$agelevel = "Adult";
	}
	if ($tag eq '020c') {
		$restriction = $data;
	}
	if ($restriction eq '') {
		$restriction = "";
	}
	if ($tag eq '599s') {
			$warning_S = "Sexual content";
		}
		if ($warning_S eq '') {
					$warning_S = "";
		}
	if ($tag eq '599v') {
				$warning_V = "Violent content";
			}
			if ($warning_V eq '') {
				$warning_V = "";
			}
			
	if ($tag eq '599t') {
					$wipo_test = "$data";
				}
				if ($wipo_test eq '') {
					$wipo_test = "N";
				}
				
	if ($tag eq '534c') {
						$publisher = "$data";
					}
					if ($publisher eq '' or $the_dir eq "pd") {
						$publisher = "Association for the Blind of Western Australia";
					}	
}

print "$Synopsis\n";
print "$isbn\n";
print "$format\n";
print "$language\n";
print "$agelevel\n";
print "$wipo_test\n";
print "$publisher\n";


$query_handle = $dbh->prepare($insert_sql);

# EXECUTE THE QUERY
$query_handle->execute();


$query_handle->finish();
$dbh->disconnect();

print "DONE with lookup\n";

# Use it in the fields below:

if ($the_dir eq "pd" or $wipo_test eq "Y"){
	print "Sending the book to WIPO/TIGAR\n";
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900; ## $year contains no. of years since 1900, to add 1900 to make Y2K compliant
	my @month_abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
	
	$tigar_req_date = "$mday/$mon/$year";
	
	$message = "Below is given the comma seperated values for $title by $creator\n\r\n\r,,\"ABWA\",\"AU\",\"$tigar_req_date\",\"$dirnumber\",,\"$name.zip\",\"$creator\",\"$title\",\"$subject\",\"$language\",\"$publisher\",\"$isbn_marc\",\"$restriction\",\"$agelevel\",\"$warning_S $warning_V\",\"$Synopsis\",\"$format\",\"$public_note\"\n";
	$message2 = ",,\"ABWA\",\"AU\",\"$tigar_req_date\",\"$dirnumber\",,\"$name.zip\",\"$creator\",\"$title\",\"$subject\",\"$language\",\"$publisher\",\"$isbn_marc\",\"$restriction\",\"$agelevel\",\"$warning_S $warning_V\",\"$Synopsis\",\"$format\",\"$public_note\"\n";
	$copyright_message = "The title $title has been converted by the Association for the Blind of Western Australia to an alternative format under the provisions of the Copyright Act. for more information please contact:\n\r
	Gregory Kearney\n\r
	Manager - Accessible Media\n\r
	Association for the Blind of Western Australia\n\r
	61 Kitchener Avenue, PO Box 101\n\r
	Victoria Park 6979, WA Australia\n\r
\n\r
	Telephone: +61 (08) 9311 8246\n\r
	Fax: +61 (08) 9361 8696\n\r
	Toll free: 1800 658 388 (Australia only)\n\r
	Email: gkearney@gmail.com\n\r
\n\r	
	comma seperated values for $title by $creator\n\r\n\r
	\"$tigar_req_date\",\"1\",\"DAISY\",\"$isbn_marc\",,\"$title\",,\"$creator\",,\"$publisher\",,,,,,,\n";

	# Send the email about the book to Copyright Agency
			$to='gkearney@gmail.com';
			$from= 'gkearney@gmail.com';
			$subject="Information for $title by $creator from ABWA Perth";
			 
			open(MAIL, "|/usr/sbin/sendmail -t");
			 
			## Mail Header
			print MAIL "To: $to\n";
			print MAIL "From: $from\n";
			print MAIL "Subject: $subject\n\n";
			## Mail Body
			print MAIL "$copyright_message";
			 
			close(MAIL);

# Send the email about the book to WIPO TIGAR
		$to='gkearney@gmail.com, hturneredit@gmail.com';
		$from= 'gkearney@gmail.com';
		$subject="TIGAR information for $title by $creator from ABWA Perth";
		 
		open(MAIL, "|/usr/sbin/sendmail -t");
		 
		## Mail Header
		print MAIL "To: $to\n";
		print MAIL "From: $from\n";
		print MAIL "Subject: $subject\n\n";
		## Mail Body
		print MAIL "$message";
		 
		close(MAIL);
		
		
	

# Sending the zip file to WIPO TIGAR
		$host = "tigarftp.wipo.int";
		$user = "ABWA-upd";
		$password = "-069-bm056df";
		
		$f = Net::FTP->new($host) or die "Can't open $host\n";
		$f->login($user, $password) or die "Can't log $user in\n";
		
#		$dir = "/";
#
#		$f->cwd($dir) or die "Can't cwd to $dir\n";
#		
#		$f->binary();
#		$file_to_put = "$workdir.zip";
#		print "Sending $workdir.zip to WIPO TIGAR\n\n";
#		$f->put($file_to_put) or die "Can't put $file_to_put into $dir\n";
		
		$f->ascii();
			$dir = "/";
			$f->cwd($dir) or die "Can't cwd to $dir\n";
			$dir = "metadata";
			$f->cwd($dir) or die "Can't cwd to $dir\n";
			
				open (MYFILE, '>/tmp/wipotmp');
			 	print MYFILE "$message2";
			 	close (MYFILE); 
			
			$f->append("/tmp/wipotmp","ABWA-metadata.txt") or die "Can't append to file";
			
			
		
		
		
# if the work is in the public domain send it to the WIPO/TIGAR FTP server.		
if ($the_dir eq "pd") {	
		print "Started sending $workdir.zip to WIPO TIGAR\n\n";	
		# build ftp daemon command
		    my $cmd = $this->{Location}{BinDir} . "/Resources/wipoftp.pl $zipfile";
		    my $daemon = Proc::Daemon->new(
		        work_dir     => $this->{Location}{BinDir},
		        child_STDOUT => $this->{DaemonDir} . '/tmp/stdout.txt',
		        child_STDERR => $this->{DaemonDir} . '/tmp/stderr.txt',
		        pid_file     => $this->{DaemonDir} . '/tmp/pid.txt',
		        exec_command => $cmd,
		    );
		    # fork ftp daemon process
		    my $pid = $daemon->Init();
}		
		
		undef ($Synopsis);
		undef ($isbn);
		undef ($format);
		undef ($language);
		undef ($agelevel);
		undef ($language);
		undef ($restriction);
		undef ($warning_V);
		undef ($warning_S);
		undef ($wipo_test);
		undef ($publisher);
		undef ($public_note);
	
}










$first = uc(substr($name, 0, 1));
if ($first =~ m/[0-9]/gi) {
	$movetodir = $movetodir."0-9/";
	} else {
	$movetodir = "$movetodir$first";
}


#if (-d $movetodir) {
#if ($filesize > 100) {
#
#if (!-d "$movetodir/$name") {
#	#`mv -f $workdir $movetodir`;
#	#print "Moving $workdir to $movetodir\n";
#	#my $mv_result = system("mv -f $workdir $movetodir > /dev/null");
#	#move($workdir, $movetodir);
#	
#
#} else {
#	# added move to a holding directory.
#	#print "$movetodir/$name exists. Moving to _hold directory.\n\n";
#	#`mv -f $workdir "/Volumes/books/_hold > /dev/null"`;
#	
#	#move($workdir, "/Volumes/books/_hold");	
#}
#
#}
#
#} else {
#	print "Moving $workdir/$name to $movetodir_bu\n";
#	#`mv -f $workdir $movetodir_bu > /dev/null`;
#	
#
#}



#Send the book to twitter.
print "Sending the book information to Twitter.\n";
if ($creator eq '') {
	$author = "";
} else {
	$author = " by $creator";
}

if ($isbn) {
	$isbn_number = " ISBN: $isbn";
} else {
	$isbn_number = "";
}


#`/Users/gkearney/github/marc/playlist.pl/twitter.sh "$title$author$isbn_number has been converted to DAISY$braille_note."`;

 use Net::Twitter;
  use Scalar::Util 'blessed';
	$unixtime = time;

	$consumer_key = "YFhiuQoaER4I6gXkWj4e2g";
	$consumer_secret = "DGUGa3H4GJsugJbAPJHC5c0bj5CeqknJuj6Pjzl8vY";
	$token = "41378378-PE6Y1yQisIwRPZ2mOMEQJUHVlrx2xl0JM34kHIN4j";
	$token_secret = "YxozLo0RNzh1UktihTJET217eKNpcYXJqhV565tOPk";

  # When no authentication is required:
  my $nt = Net::Twitter->new(legacy => 0);

  # As of 13-Aug-2010, Twitter requires OAuth for authenticated requests
  my $nt = Net::Twitter->new(
      traits   => [qw/OAuth API::REST/],
      consumer_key        => $consumer_key,
      consumer_secret     => $consumer_secret,
      access_token        => $token,
      access_token_secret => $token_secret,
  );
print "Braille Note: $brlnote\n\n";
if ($brlnote eq "braille") {
	print "in braille\n";
	my $thetweet = "$title$author$isbn_number in Braille has been added to the ABWA library. #newbraillebook ($unixtime)";
	my $myLength = length($thetweet);
	print "$thetweet $myLength\n\n";
	
	if ($myLength < 140) {

	  my $result = $nt->update({status => "$thetweet"});


	  if ( my $err = $@ ) {
	      #die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

	      warn "HTTP Response Code: ", $err->code, "\n",
	           "HTTP Message......: ", $err->message, "\n",
	           "Twitter error.....: ", $err->error, "\n";
	  }

	}
} else {
	print "in DAISY\n";
	my $thetweet = "$title$author$isbn_number has been converted to DAISY$braille_note #newdaisybook ($unixtime)";
	my $myLength = length($thetweet);
	print "$thetweet $myLength\n\n";
	
	if ($myLength < 140) {

	  my $result = $nt->update({status => "$thetweet"});


	  if ( my $err = $@ ) {
	      #die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

	      warn "HTTP Response Code: ", $err->code, "\n",
	           "HTTP Message......: ", $err->message, "\n",
	           "Twitter error.....: ", $err->error, "\n";
	  }

	}
}

	
	
	


}




#if (-d "$movetodir/$name" or -d "/Volumes/books/_hold/$name") {
print "Removing $workdir\n\n";
#		unlink $workdir;
my $result = system("rm -rf $workdir");
#	}



chdir($startdir) or  die "Unable to change to dir $startdir:$!\n";
#`mv  $workdir/$name /Volumes/DaisyMasters/ABWA`;



  
  

}
        
        
      




print "\nSCAN FINISHED\n";