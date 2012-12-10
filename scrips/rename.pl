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
            
            
 
			open FILE, "$workdir/$name/ncc.html" or die $!;
            
            while (my $line = <FILE>) {
				if ($line =~ m/<meta name="dc:title" content="(.+)" \/>/i) {
				$title = $1;
				#$title =~ s/scheme=.+|"//gi;
				
			} 
			
            }
            
            close(FILE);
            print "TITLE: $title\n\n";
            
            
            $old_name = "$workdir/$name";
			$new_name = "$workdir/$title";
			$new_name =~ s/\s/_/g;

			if ($old_name ne $new_name) {
				rename($old_name, $new_name) or die "Could not rename $old_name to $new_name: $!";
				print "Renamed '$old_name' to '$new_name'.\n";
			}   

		}
            
            
           # &ScanDirectory("$workdir/$name");
            next;
        }
        

        




chdir($startdir) or 
           die "Unable to change to dir $startdir:$!\n";


}

&ScanDirectory("/Volumes/Daisy");
print "\nSCAN FINISHED\n";
