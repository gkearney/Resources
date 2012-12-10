#!/usr/bin/perl

BEGIN {
        push @INC,"/opt/local/lib/perl5/site_perl/5.8.8/";
}

use Cwd; # module for finding the current working directory
use File::Copy;
use File::Basename;

$mypath = "/Volumes/DAISY_MASTER/Books/BS/tmp";

&ScanDirectory("$mypath");

sub ScanDirectory{
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
		next if ($name eq ".DS_Store");
		
		
		
		if (-d "$workdir/$name") { 
			print "Working in: $name\n";
			
			
			
			
			&ScanDirectory("$workdir/$name");
			next;
		}
		
		if ($name =~ m/\.xml/gi) {
			print "XML file: $workdir/$name\n";

#			$new = "$workdir/temp.xml";
#			$old = "$workdir/$name";
#
#
#			open(OLD, "< $old")         or die "can't open $old: $!";
#			open(NEW, "> $new")         or die "can't open $new: $!";
#			while (<OLD>) {
#				$wholexml .= $_;
#
#			}
#
#
#			$wholexml =~ s/<level1 id="bookshare_note">.+?<\/level1>//sm;
#
#			print NEW $wholexml            or die "can't write $new: $!";
#
#
#			close(OLD)                  or die "can't close $old: $!";
#			close(NEW)                  or die "can't close $new: $!";
#			rename($old, "$old.orig")   or die "can't rename $old to $old.orig: $!";
#
#			rename($new, $old)          or die "can't rename $new to $old: $!";










			($file,$dir,$ext) = fileparse($name, qr/\.\D.*/);
			print "The new name will be: $file.rtf\n\n";
			$cmd = "/usr/local/bin/pipeline/pipeline.sh /usr/local/bin/pipeline/scripts/create_distribute/text/DtbookToRtf.taskScript --input='$workdir/$name' --inclTOC='false' --output='$workdir/$file.rtf' --inclPagenum='true'";
			
			
			
			print "\Working in $workdir/$name\n";
			`$cmd`;
			#print $cmd;
			print "\tFinished $workdir/$name\n";
			#`perl -pi -e "s/This material was downloaded by .+ and is digitally fingerprinted in the manner described above\.//gi" "$workdir/$file.rtf"`;
			
			#`textutil -convert odt "$workdir/$file.rtf"`;

		} else {
			print "removing $workdir/$name\n\n";
			unlink("$workdir/$name");
		}
		
		
	}
	chdir($startdir) or  die "Unable to change to dir $startdir:$!\n";
}
			