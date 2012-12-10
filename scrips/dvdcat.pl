#!/usr/bin/perl

use Cwd; # module for finding the current working directory

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
            
            
            open (MYFILE, ">>/diskcat.csv");
				print MYFILE "\"\",\"$workdir\",\"$name\"\n";
			close (MYFILE);

            &ScanDirectory("$workdir/$name");
            next;
        }
                
    chdir($startdir) or 
           die "Unable to change to dir $startdir:$!\n";
    }

}

&ScanDirectory("/Volumes/libravox2");