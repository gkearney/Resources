#!/usr/bin/perl

use Cwd; # module for finding the current working directory
use File::Copy;
use File::Basename;

sub ScanDirectory{
    my ($workdir) = shift; 

    my ($startdir) = &cwd; # keep track of where we began

    chdir($workdir) or die "Unable to enter dir $workdir:$!\n";
    opendir(DIR, ".") or die "Unable to open $workdir:$!\n";
    my @names = readdir(DIR) or die "Unable to read $workdir:$!\n";
    closedir(DIR);

    foreach my $name (@names){
        next if ($name eq "."); 
        next if ($name eq "..");

        if (-d "$workdir/$name") {  
            # is this a directory?
            print "$workdir/$name\n";
            
            $cmd = "cp -R '/Users/gkearney/Documents/development/production tools/template.app/Contents/Resources/announcements' '$workdir/$name'";
 			print "$cmd\n";
 			`$cmd`;
 			$rm = "rm -fR '$workdir/$name/announcements/*.mp3'";
 			`$rm`;
			
            
            
           # &ScanDirectory("$workdir/$name");
            next;
        }
        

        




chdir($startdir) or 
           die "Unable to change to dir $startdir:$!\n";


}
}

&ScanDirectory("/Volumes/DAC1/D");
print "\nSCAN FINISHED\n";
