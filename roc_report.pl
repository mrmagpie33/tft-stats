#!/usr/bin/perl

use Getopt::Long;

my $region = '';
my $name = '';
my $verbose;
my $debug;
my $help;

$result = GetOptions ("region=s"   => \$region,  # pick the region to search
                      "name=s"  => \$name,         # string
                      "verbose"  => \$verbose,   # flag
                      "debug"  => \$debug,   # flag
                      "help"  => \$help);        # flag

# date date/time of run
$date = `date`;
chomp($date);

# open source file for player stats
open(STATS, "/Users/wmehl/Documents/tft_stats/lol_stats.csv") or die "File '$filename' can't be opened"; 
@stats = (<STATS>); 

# read in stats data
foreach $stats_line (@stats) {
   chomp($stats_line); 
   if ($stats_line  !~ /WinRate,TOP4/) {
       #print "stats_line is $stats_line\n";
       ($date, $Rank, $Tier, $Name, $LP, $WinRate, $TOP4, $Played, $Wins, $TOP4, $url) = split /,/, $stats_line;
       #print "Name is $Name\n";
       #push @name_list, $Name;
       $name_list{$Name} = $Name;
    }
}

while (($key, $name) = each (%name_list)) {
   @stats_by_name = ();
   chomp($name); 
   #print "name_list - name is $name\n";

   foreach $stats_line (@stats) {
      #print "stats_line is $stats_line\n";
      if ($stats_line =~ /$name/) {
          #`print "stats_line is $stats_line\n";
          push @stats_by_name, $stats_line;
      }
   }


   #print "stats_by_name 0 is $stats_by_name[-1]\n";
   #print "stats_by_name 1 is $stats_by_name[-2]\n";
   #print "stats_by_name 2 is $stats_by_name[-3]\n";
   #print "stats_by_name 3 is $stats_by_name[-4]\n";

   ($date, $Rank_1, $Tier, $Name_1, $LP_current, $WinRate, $TOP4, $Played, $Wins, $TOP4, $url) = split /,/, $stats_by_name[-1];
   #print "LP_current is $LP_current\n";
   ($date, $Rank_3, $Tier, $Name_3, $LP_previous, $WinRate, $TOP4, $Played, $Wins, $TOP4, $url) = split /,/, $stats_by_name[-4];
   #print "LP_previous is $LP_previous\n";

   #$roc = ($LP_current / $LP_previous -1 ) * 100;
   $roc = ($LP_current - $LP_previous);

   $roc_list{$name} = $roc;
   #print "roc name is $name\n";
   #print "roc is $roc\n";

}


while (($name, $roc) = each (%roc_list)) {
  if ($roc > 100) {
     print "name is $name and roc is $roc\n";
  }
}




