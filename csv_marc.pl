#! /usr/bin/perl

BEGIN {
        push @INC,"/opt/local/lib/perl5/site_perl/5.8.8/";
}

use Text::CSV;
use MARC::Record;

my $file = '/Users/gkearney/Dropbox/Braille_Books.csv';

    my $csv = Text::CSV->new();

    open (CSV, "<", $file) or die $!;

    while (<CSV>) {
        if ($csv->parse($_)) {
            my @columns = $csv->fields();
            #print "@columns[0]\n";
            
            #$action = $columns[0];
            #$acc = $columns[0];
            $lang = "eng";
            $language = "English";
            $title = $columns[0];
            $author = $columns[1];
            #$publisher = $columns[7];
            #$pubyear = $columns[3];
            #$edition = $columns[4];
            #$isbn10 = $columns[5];
            #$isbn13 = $columns[6];
            #$errcode = $columns[11];
        	#$errtext = $columns[12];
        	#$format = $columns[15];
        	#$media_type = $columns[16];
        	
        	$format = "BANA Braille Grade 2";
			$media_type = "Braille text file .txt";
			$summary = $columns[2];
			$summary =~ /Grades.+?\./gs;
			$grade = $&;
			if ($grade eq '') {
				$grade = "Adult";
			}
			$summary =~  / [0-9]+\.$/gs;
        	$pubyear = $&;
			
			
			print "TITLE: $title\nAUTHOR: $author\n\n";
    $record = MARC::Record->new();
	
	$marc_035 = MARC::Field->new(
   	'035','','',
   		a => "$acc",
   		);
	
	
   		
   	$marc_language = MARC::Field->new(
   	'041','1','',
   		a => "$lang",
   		);
	
	$marc_language_note = MARC::Field->new(
   	'546','1','',
   		a => "$langauge",
   		);
	
	$marc_author = MARC::Field->new(
   			'100','1','',
   			a => "$author",
   		);
	
	
if ($title =~ m/^The|^A|^An/i) {$indicator2 = '4';} else {$indicator2 = '0';}
	$marc_title = MARC::Field->new(
   	'245','1',"$indicator2",
   		a => "$title /",
   		c => "$author",
   		#h => "[$format $media_type]."
   	);
	
#	$marc_editon = MARC::Field->new(
#   			'250','','',
#   			a => "$edition",
#   		);
#   		
#   	$marc_isbn10 = MARC::Field->new(
#   			'020','','',
#   			a => "$isbn10",
#   		);
#   		
#   	$marc_isbn13 = MARC::Field->new(
#   			'020','','',
#   			a => "$isbn13",
#   		);
	
	
	$marc_500 = MARC::Field->new(
	   	'500','','',
	   		a => "$format $media_type"
	   	);
	   	
	   	
	$marc_538 = MARC::Field->new(
	   	'538','','',
	   		#a => "DAISY digital talking books can be played on DAISY hardware playback devices or with a computer using DAISY playback software."
	   		a => "Title restricted to the blind and print disabled."

	   	);
	   	
	$marc_852 = MARC::Field->new(
	   	'852','1','',
	   		a => "Washington Talking book and Braille Library (USA)"
	   	);


	if ($publisher eq "") {
		$publisher = "Washington Talking book and Braille Library (USA)";
	}
	
	if ($pubyear eq "unknown") {
		$pubyear = "";
	}
	
	$marc_260 = MARC::Field->new(
	   	'260','','',
	   		b => "$publisher",
	   		c => "$pubyear"
	   	);
	
	
	$marc_260 = MARC::Field->new(
	   	'260','','',
	   		b => "$publisher",
	   		c => "$pubyear",
			f => "Seattle : Washington Talking Book & Braille Library",
	   	);
	
	
	
	
	$marc_521 = MARC::Field->new(
		   	'521','','',
		   		a => "$grade",
		   	);
		
	$marc_535 = MARC::Field->new(
		   	'535','','',
		   		a => "Assocation for the Blind of Western Australia, Victoria Park, WA 6100, AUSTRALIA",
		   	);
		
	$marc_852 = MARC::Field->new(
		   	'852','','',
		   		a => "Assocation for the Blind of Western Australia, Victoria Park, WA 6100, AUSTRALIA",
		   	);
		
	$marc_300 = MARC::Field->new(
		   	'300','','',
		   		a => "Braille BANA Grade 2",
				b => "Electronic Braille files .dxb .brf",
		   	);
		
	$marc_520 = MARC::Field->new(
			   	'520','','',
			   		a => "$summary",
			   	);

	   	
	$record->append_fields($marc_author, $marc_title, $marc_538, $marc_852, $marc_language, $marc_035, $marc_260,$marc_521,$marc_535,$marc_852,$marc_300,$marc_520,$marc_500,$marc_538); 
	#$record->append_fields($marc_author, $marc_title, $marc_035); 
	
	
	open(OUTPUT, '>>marc.mrc') or die $!;
	print OUTPUT $record->as_usmarc();
	close(OUTPUT);
        
        
        } else {
            my $err = $csv->error_input;
           # print "Failed to parse line: $err";
        }
        print "$action $acc $title $author $publisher $pubyear\n";
    }
    close CSV;
    
    
 