#!/usr/bin/perl

use Getopt::Long;

my $region = '';
my $target = '';
my $verbose;
my $debug;
my $help;

$result = GetOptions ("region=s"   => \$region,  # pick the region to search
                      "target=s"  => \$target,         # string
                      "verbose"  => \$verbose,   # flag
                      "help"  => \$help);        # flag

# date date/time of run

$date = `date`;
chomp($date);


@get_top = `curl -Ss https://www.leagueofgraphs.com/tft/summoners/na`;

foreach $top_line (@get_top) {
   chomp($top_line); 
   #print "top_line is $top_line\n";


   # get top na player name
   ($top_name) = ($top_line =~ /\<span class=\"name\"\>(.*)\<\/span\>/);

   # get top na player LP
   ($top_lp) = ($top_line =~ /\<div class=\"leaguePoints\"\>\<i\>LP:\s+(\d+)\<\/i\>\<\/div\>/);

   # get player URL
   ($top_url) = ($top_line =~ /href=\"\/tft\/summoner\/na\/(\S+)\"/);

   # if rank tag found, get numerical rank
   if ($rank_bol == 1) {
      ($rank_na) = ($top_line =~ /(\d+)\./);
      print "rank_na is $rank_na\n" if($verbose);
      $rank_bol = 0;
   }

   # look for rank tag
   if ($top_line =~ /<td class="text-right hide-for-small-down">/) {
      #print "top_line is $top_line\n";
      $rank_bol = 1;
      print "rank_bol is $rank_bol\n" if($verbose);
   } 

   # add data to hashes

   if ($rank_na) {
      print "rank_na is $rank_na\n" if($debug);
   }

   if ($top_name) {
      $top_name{$rank_na} = $top_name;
      print "top_name is $top_name{$rank_na}\n" if($verbose);
   }

   if ($top_lp) {
      $top_lp{$rank_na} = $top_lp;
      print "top_lp is $top_lp{$rank_na}\n" if($verbose);
   }

   if ($top_url) {
      $top_url{$rank_na} = $top_url;
      print "hash top_url is $top_url{$rank_na}\n" if($verbose);
   }
}


#print "list all records in csv format\n";
#print "rank,name,LP,url\n";

$rank_count = 1;

while ($rank_count < 101) {
   print "$date,$rank_count,$top_name{$rank_count},$top_lp{$rank_count},https://www.leagueofgraphs.com/tft/summoner/na/$top_url{$rank_count}\n";
   $rank_count += 1;
}



