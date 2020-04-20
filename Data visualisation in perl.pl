#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV_XS;
use Switch;
use GD::Graph::bars;
use GD::Graph::colour;
use GD::Graph::Data;
use GD::Graph::pie;
use GD::Graph::lines;
use GD::Graph::points;


sub attendance_line()
{
	my @date=();  #array to store match dates
	my @attendance=(); #array to store attendence in the stadium
	my $first=1;
	my $csv = Text::CSV_XS->new({ sep_char => ', ' });  
	my $File = "match.csv" ;
	open(my $data_file,'<',$File) or die; 
	while (my $line = <$data_file>)  
	{
		if($first)
		{
			$first=0;
		}
		else
		{
			chomp $line;
			# Parsing the line
			if ($csv->parse($line))
			{
				# Extracting elements
				my @words = $csv->fields();
				push(@date,$words[1]);
				push(@attendance,$words[3]);
			}
			else
			{
				# Warning to be displayed
				warn "Line could not be parsed: $line\n";
			}
		}
	}
	close($File);
	my $d=\@date;
	my $att=\@attendance;
	my $data = ([$d,$att]);
	my $mygraph = GD::Graph::lines->new(600, 300); #fixing the size of the graph
	$mygraph->set(
	x_label     => 'Matches',
	y_label     => 'Attendance',
	title       => 'Attendance of the tournament',
	x_labels_vertical => 1,
	# Draw datasets in 'solid', 'dashed' and 'dotted-dashed' lines
	line_types  => [1],
	# Set the thickness of line
	line_width  => 5,
	# Set colors for datasets
	dclrs       => ['black'],
	) or warn $mygraph->error;
	
	my $myimage = $mygraph->plot($data) or die $mygraph->error;

	my $file = 'line_atnd.jpeg';
	open(my $out, '>', $file) or die "Cannot open '$file' for write: $!";
	binmode $out;
	print $out $mygraph->gd->jpeg;
	close $out;
	system("C:\\Perl64\\line_atnd.jpeg"); #opening the image from the local drive

}

sub position_pie()
{
	my @position=(); #array for the playing position
	my @goal=(); #array for the total goals
	
	my $tot_sum=0;	
	my $first=1;

	my $csv = Text::CSV_XS->new({ sep_char => ', ' });  
	my $File = "players.csv" ;
	open(my $data_file,'<',$File) or die;
	while (my $line = <$data_file>)  
	{
		if($first)
		{
			$first=0;
		}
		else
		{
			chomp $line;
	
			# Parsing the line
			if ($csv->parse($line))
			{
				# Extracting elements
				my @words = $csv->fields();
				$tot_sum=$tot_sum+$words[13];
				my $j=0;
				my $f=0;
				while($j<@position)
				{
					if($words[4]eq$position[$j])
					{
						$f=1;
						$goal[$j]=$goal[$j]+$words[13];
					}
					$j++;
				}
			
				if($f==0)
				{
					push(@position,$words[4]);
					push(@goal,$words[13]);
				}
			}
	
			else
			{
				# Warning to be displayed
				warn "Line could not be parsed: $line\n";
			}
		}
	}

	for(my $i=0;$i<@goal;$i++)
	{
		$goal[$i]=($goal[$i]*100)/$tot_sum;
	}

	my $mygraph = GD::Graph::pie->new(400,400);
	$mygraph->set(
	title       => 'Position wise Goal scorers',
	'3d'        => 1,
	bgclr => 'black',
	textclr => 'white',
	axislabelclr => 'black',
	axislabel_vertical => 1,
	transparent     => 1,
	pie_height => 30,
	) ;

	my $nm = \@position;
	my $gl = \@goal;

	my $data = GD::Graph::Data->new([$nm,$gl]);

	$mygraph->set_value_font(GD::gdMediumBoldFont);
	my $myimage = $mygraph->plot($data);

	my $file = 'pies_pos.jpeg';
	open(my $out, '>', $file);
	binmode $out;
	print $out $mygraph->gd->jpeg;
	close $out;
	system("C:\\Perl64\\pies_pos.jpeg");   #opening the image from the local drive

}

sub goal_all_point()
{
	my @name=();
	my @tot_goal=();
	my @home_goal=();
	my @away_goal=();

	my $first=1;

	my $csv = Text::CSV_XS->new({ sep_char => ', ' });  
	my $File = "teams.csv" ;
	open(my $data_file,'<',$File) or die;
	while (my $line = <$data_file>)  
	{
		if($first)
		{
			$first=0;
		}
		else
		{
			chomp $line;

			# Parsing the line
			if ($csv->parse($line))
			{
				# Extracting elements
				my @words = $csv->fields();
				push(@name,$words[0]);
				push(@tot_goal,$words[24]);
				push(@home_goal,$words[30]);
				push(@away_goal,$words[31]);

			}	
			else
			{
				# Warning to be displayed
				warn "Line could not be parsed: $line\n";
			}
		}
	}

	my $nm = \@name;
	my $t_gl = \@tot_goal;
	my $h_gl = \@home_goal;
	my $a_gl = \@away_goal;
	
	my $data = GD::Graph::Data->new([$nm,$t_gl,$h_gl,$a_gl]);
	my $mygraph = GD::Graph::points->new(600, 300);
	$mygraph->set(
		x_label => 'COUNTRIES',
		y_label => 'GOALS',
		x_labels_vertical => 1,
		title => 'Points Graph',
		y_max_value => 40,
		y_tick_number => 8,
		y_label_skip => 2,
		legend_placement => 'RC',
		long_ticks => 1,
		marker_size => 2,
		markers => [ 1, 7, 5 ],
		transparent => 0,
    );  
	$mygraph->set_legend('Total', 'Home','Away');
	my $myimage = $mygraph->plot($data) or die $mygraph->error;
	my $file = 'points.jpeg';
	open(my $out, '>', $file) or die "Cannot open '$file' for write: $!";
	binmode $out;
	print $out $mygraph->gd->jpeg;
	close $out;
	system("C:\\Perl64\\points.jpeg");
	
}

sub display_teams()
{
	my $sno = 0 ;
	my $csv = Text::CSV_XS->new({ sep_char => ', ' });
	my $file_to_be_read = "teams.csv" ;
	open(my $data_file, '<', $file_to_be_read) or die;	
	while (my $line = <$data_file>)
	{
		chomp $line;
		# Parsing the line
		if ($csv->parse($line))
		{
			# Extracting elements
			my @words = $csv->fields();
			if( $sno >= 1)
			{
				print "\t$sno . $words[3]\n";
			}
		}
		else
		{
			# Warning to be displayed
			warn "Line could not be parsed: $line\n";
		}
		$sno = $sno + 1 ;
	}
}

sub squad
{
	my ($c) =  @_ ;
	my $csv = Text::CSV_XS->new({ sep_char => ', ' });
	my $file_to_be_read = "players.csv" ;
	open(my $data_file, '<', $file_to_be_read) or die;
	while (my $line = <$data_file>)
	{
		chomp $line;
		# Parsing the line
		if ($csv->parse($line))
		{
			# Extracting elements
			my @words = $csv->fields();
			if( $words[5] eq $c)
			{
				printf("\t %-40s \t %-15s\n",$words[0],$words[4]);
			}
		}
		else
		{
			# Warning to be displayed
			warn "Line could not be parsed: $line\n";
		}
	}
}

sub goal_bar
{
	my ($c) =@_;
	my @players = ();
	my @goals = ();
	my $csv = Text::CSV_XS->new({ sep_char => ', ' });
	my $file_to_be_read = "players.csv" ;
	open(my $data_file, '<', $file_to_be_read) or die;
	while (my $line = <$data_file>)
	{
		chomp $line;
		# Parsing the line
		if ($csv->parse($line))
		{
			# Extracting elements
			my @words = $csv->fields();
			if( ($words[5] eq $c) and ($words[13] >= 1) )
			{
				push(@players,$words[0]);
				push(@goals,$words[13]);
			}
		}
		else
		{
			# Warning to be displayed
			warn "Line could not be parsed: $line\n";
		}
	}

	my $pl = \@players;
	my $gl = \@goals;

	my $data = GD::Graph::Data->new([$pl,$gl]) or die GD::Graph::Data->error;
 
 
	my $graph = GD::Graph::bars->new(500,500);
	
	$graph->set(
	x_label         => 'NAMES',
	y_label         => 'GOALS',
	title           => 'GOAL SCORERS',
	x_labels_vertical => 1,
	fgclr => 'lyellow' ,
	dclrs => ['red', 'lyellow'],
	bgclr => 'black',
	textclr => 'white',
	labelclr=> 'white',
	axislabelclr=>'white',
	legendclr=> 'white',
	valuesclr=> 'white',
	x_labels_vertical => 1,
 
	bar_spacing     => 10,
	shadow_depth    => 4,
	#shadowclr       => 'dred',
 
	#transparent     => 0,
	) or die $graph->error;
 
	$graph->plot($data) or die $graph->error;
 
	my $file = 'goals.jpeg';
	
	open(my $out, '>', $file) or die "Cannot open '$file' for write: $!";
	binmode $out;
	print $out $graph->gd->jpeg;
	close $out;
	system("C:\\Perl64\\goals.jpeg");
}

sub age_pie
{
	my ($c) =@_;
	my @players_count = (0,0,0,0);
	my @age = ("< 22","22 - 25","25 - 30","30+");
	my $csv = Text::CSV_XS->new({ sep_char => ', ' });
	my $file_to_be_read = "players.csv" ;
	open(my $data_file, '<', $file_to_be_read) or die;
	while (my $line = <$data_file>)
	{
		chomp $line;
		# Parsing the line
		if ($csv->parse($line))
		{
			# Extracting elements
			my @words = $csv->fields();
			if( ($words[5] eq $c) )
			{
				if($words[1]<=22)
				{
					$players_count[0]=$players_count[0]+1;
				}
				if($words[1]>22 and $words[1]<=25)
				{
					$players_count[1]=$players_count[1]+1;
				}

				if($words[1]>25 and $words[1]<=30)
				{
					$players_count[2]=$players_count[2]+1;
				}

				if($words[1]>30)
				{
					$players_count[3]=$players_count[3]+1;
				}

			}
		}
		else
		{
			# Warning to be displayed
			warn "Line could not be parsed: $line\n";
		}
	}

	my $pc = \@players_count;
	my $ages = \@age;
	
	my $data = ([$ages,$pc]);
	
	my $mygraph = GD::Graph::pie->new(400,400);
	$mygraph->set(
	title       => 'AGE COMPOSITION',
	'3d'        => 1,
	bgclr => 'black',
	textclr => 'white',
	axislabelclr => 'black',
    pie_height => 30,
	) or warn $mygraph->error;

	$mygraph->set_value_font(GD::gdMediumBoldFont);
	my $myimage = $mygraph->plot($data) or die $mygraph->error;
	
	my $file = 'age.jpeg';
	open(my $out, '>', $file) or die "Cannot open '$file' for write: $!";
	binmode $out;
	print $out $mygraph->gd->jpeg;
	close $out;
	system("C:\\Perl64\\age.jpeg");

}

sub shots
{
	my ($c) =@_;
	my @shotc = ();
	my @shot = ("GOAL(H)","GOAL(A)","ON TARGET(H)","ON TARGET(A)","OFF TARGET(H)","OFF TARGET(A)");
	my $csv = Text::CSV_XS->new({ sep_char => ', ' });
	my $file_to_be_read = "teams.csv" ;
	open(my $data_file, '<', $file_to_be_read) or die;
	while (my $line = <$data_file>)
	{
		chomp $line;
		# Parsing the line
		if ($csv->parse($line))
		{
			# Extracting elements
			my @words = $csv->fields();
			if( ($words[1] eq $c) )
			{
				push(@shotc,$words[28]);
				push(@shotc,$words[29]);
				push(@shotc, ($words[67]-$words[28]));
				push(@shotc, ($words[68]-$words[29]));
				push(@shotc,$words[70]);
				push(@shotc,$words[71]);
			}
		}

		else
		{
			# Warning to be displayed
			warn "Line could not be parsed: $line\n";
		}

	}

	my $shtc = \@shotc;
	my $s = \@shot;
	
	my $data = ([$s,$shtc]);

	my $mygraph = GD::Graph::pie->new(600, 600);
	$mygraph->set(
	title       => 'SHOTS',
	'3d'	    => 1,
	bgclr => 'black',
	textclr => 'white',
	axislabelclr => 'black',
	pie_height => 30,

	) or warn $mygraph->error;

	$mygraph->set_value_font(GD::gdMediumBoldFont);
	my $myimage = $mygraph->plot($data) or die $mygraph->error;
	
	my $file = 'shots.jpeg';
	open(my $out, '>', $file) or die "Cannot open '$file' for write: $!";
	binmode $out;
	print $out $mygraph->gd->jpeg;
	close $out;
	system("C:\\Perl64\\shots.jpeg");


}

sub gd_line
{
	my ($c) =@_;
	my $cnt = 0;
	my @match = ();
	my @gd = ();
	my $csv = Text::CSV_XS->new({ sep_char => ', ' });
	my $file_to_be_read = "match.csv" ;
	open(my $data_file, '<', $file_to_be_read) or die;
	while (my $line = <$data_file>)
	{
		chomp $line;
		# Parsing the line
		if ($csv->parse($line))
		{
			# Extracting elements
			my @words = $csv->fields();
			if($words[4] eq $c)
			{
				$cnt = $cnt + 1;
				push(@match,$cnt);
				push(@gd,($words[10]-$words[11]));
			}

			if($words[5] eq $c)
			{
				$cnt = $cnt + 1;
				push(@match,$cnt);
				push(@gd,($words[11]-$words[10]));
			}


		}
		else
		{
			# Warning to be displayed
			warn "Line could not be parsed: $line\n";
		}
	}

	my $mtch = \@match;
	my $gdf = \@gd;

	my $data = ([$mtch,$gdf]);

	my $mygraph = GD::Graph::lines->new(600, 300);
	$mygraph->set(
	x_label     => 'Matches',
	y_label     => 'Goal Difference',
	title       => 'GD of the tournament',
	# Draw datasets in 'solid', 'dashed' and 'dotted-dashed' lines
	line_types  => [1],
	# Set the thickness of line
	line_width  => 2,
	# Set colors for datasets
	dclrs       => ['black'],
	) or warn $mygraph->error;

	$mygraph->set_legend_font(GD::gdMediumBoldFont);
	$mygraph->set_legend('GD');
	my $myimage = $mygraph->plot($data) or die $mygraph->error;

	my $file = 'gd.jpeg';
	open(my $out, '>', $file) or die "Cannot open '$file' for write: $!";
	binmode $out;
	print $out $mygraph->gd->jpeg;
	close $out;
	system("C:\\Perl64\\gd.jpeg");

}


while(1)
{

	print "\n\n\t\tFIFA WORLD CUP 2018 ANALYSIS\n\n";
	print "\t 1 . Team wise analysis\n\n";
	print "\t 2 . Overall analysis\n\n";
	print "\t 3 . Exit\n\n";
	print "\tEnter your choice : ";
	my $number = <>; #getting input
	#convert to integer
	$number = $number*1;

	system("cls");

	switch($number)
	{
		case 1
		{
			print "\n\n\t\tTEAM WISE ANALYSIS\n\n";
			display_teams();
			print "\n\nEnter the team name to see the report : ";
			my $country = <>;
			chomp $country;
			system("cls");
			my $cname = uc($country);
			print "\n\n\t\t\t\t\t$cname\n\n\n";
			print "\t\tSQUAD\n\n";
			squad($country);
			goal_bar($country);
			age_pie($country);
			shots($country);
			gd_line($country);
		}
		case 2
		{
			goal_all_point();
			position_pie();
			attendance_line();
		}

		case 3
		{
			exit;
		}
	
		else
		{
			print "\nNot a valid option\n";
		}
	}
}