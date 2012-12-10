#!/usr/bin/perl

use Cwd; # module for finding the current working directory
use File::Copy;
use File::Basename;

$dirname  = dirname($0);
 
$filetobecopied = "$dirname/AutoRun.exe";


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
            &ScanDirectory("$workdir/$name");
            next;
        }
        
        foreach my $name (@names){
        next if ($name eq "."); 
        next if ($name eq "..");

        
        
        if ($name =~ m<\.wpl>gi) {          # is this a file named "core"?
            	
            	if ($name ne "playlist.wpl") {
            		print "Making copy of playlist in $workdir\n";
            		copy("$workdir/$name", "$workdir/playlist.wpl")  or die "File cannot be copied.";
            	}
            	
                open (MYFILE, ">$workdir/autorun.inf");
				print MYFILE "[autorun]\r\nopen=AutoRun.exe playlist.wpl";
				close (MYFILE);
				unlink "$workdir/AutoRun.exe.";
				$newfile = "$workdir/AutoRun.exe";
				copy($filetobecopied, $newfile) or die "File cannot be copied.";
				
        } else {
        	
        	
        	
        	$cmd = "$dirname/pipeline/pipeline.sh $dirname/pipeline/scripts/modify_improve/multiformat/AudioTagger.taskScript --audioTaggerInputFile='$workdir/ncc.html' --audioTaggerOutputPath='$workdir'";
        	print "$name\n";
        }
        	
        }
}
        
        
        
        
        
        
        chdir($startdir) or 
           die "Unable to change to dir $startdir:$!\n";
    }
}

&ScanDirectory("/Volumes/Daisy/ABWA/Inkheart");

