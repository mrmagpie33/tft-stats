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

# get data for the top 300 players in NA
#@top_page_list = ("https://lolchess.gg/leaderboards?region=na&page=2", "https://lolchess.gg/leaderboards?region=na&page=2", "https://lolchess.gg/leaderboards?region=na&page=3");
@top_page_list = ("https://lolchess.gg/leaderboards?region=na\\&page=1", "https://lolchess.gg/leaderboards?region=na\\&page=2", "https://lolchess.gg/leaderboards?region=na\\&page=3", "https://lolchess.gg/leaderboards?region=na\\&page=4", "https://lolchess.gg/leaderboards?region=na\\&page=5");


foreach $top_page (@top_page_list) {

chomp($top_page);
print "top_page is $top_page\n" if($verbose);


# run curl to pul web page data
@get_top = `curl -Ss $top_page`;

# read each line of the web page
foreach $top_line (@get_top) {
   chomp($top_line);
   # if line is the rank line, start capture of player data
   if ($top_line =~ /<td class="rank">/) {
      print "top_line is $top_line\n" if($debug);
      # get rank of player
      ($top_rank) = ($top_line =~ /<td class="rank">(\d+)<\/td>/);
      print "\ntop_rank is $top_rank\n" if($verbose);
      # start capture of player data
      $keep_line = 1;
   }

   if ($keep_line == 1) {
       # check for player url, start capture of player url and IGN
       if ($top_line =~ /<a href="https:\/\/lolchess.gg\/profile\/na\/\S+">/) {
         # get player url
         ($top_url) = ($top_line =~ /<a href="(https:\/\/lolchess.gg\/profile\/na\/\S+)">/);
         print "top_url is $top_url\n" if($verbose);
         $top_url{$top_rank} = $top_url;
         # set flag to capture IGN in following line
         $start_ign = 1;
         print "start_ign is $start_ign\n" if($debug);
        }
        # capture ign
        if (($top_line =~ /\s+(.*)/) && ($start_ign == 1) && ($top_line !~ /<i class="far fa-link"><\/i>/) && ($top_line !~ /<a href="https:\/\/lolchess.gg\/profile\/na\/\S+">/)) {
           # get IGN
           print "get IGN string...\n" if($debug);
           ($top_ign) = ($top_line =~ /\s+(.*)/);
           #$top_ign = $top_line; # debug line if regex breaks
           print "top_ign is $top_ign\n" if($verbose);
           $top_ign{$top_rank} = $top_ign;
        }
        # close IGN capture
        if ($top_line =~ /<i class="far fa-link"><\/i>/) {
           # set flag to capture IGN to false
           print "set flag to capture IGN to false\n" if($debug);
           $start_ign = 0;
        }

        # get player LP
        if ($top_line =~ /<td class="lp active">/) {
           print "top_line is $top_line\n" if($debug);
           $start_lp = 1;
           print "open start_lp is $start_lp\n" if($debug);
        } 

        if (($start_lp) && ($top_line !~ /<td class="lp active">/)) {
           print "top_line is $top_line\n" if($debug);
           ($top_lp) = ($top_line =~ /\s+(\d+)\s+LP/);
           print "top_lp is $top_lp\n" if($verbose);
           $top_lp{$top_rank} = $top_lp;
           $start_lp = 0;
           print "close start_lp is $start_lp\n" if($debug);
        }

        # get player winrate
        if ($top_line =~ /<td class="winrate">/) {
           print "top_line is $top_line\n" if($debug);
           $start_winrate = 1;
           print "open start_winrate is $start_winrate\n" if($debug);
        }

        if (($start_winrate) && ($top_line !~ /<td class="winrate">/)) {
           print "top_line is $top_line\n" if($debug);
           ($top_winrate) = ($top_line =~ /\s+(\S+)/);
           print "top_winrate is $top_winrate\n" if($verbose);
           $top_winrate{$top_rank} = $top_winrate;
           $start_winrate = 0;
           print "close start_winrate is $start_winrate\n" if($debug);
        }

        # get player top4 rate
        if ($top_line =~ /<td class="toprate">/) {
           print "top_line is $top_line\n" if($debug);
           $start_top4rate = 1;
           print "open start_top4rate is $start_top4rate\n" if($debug);
        }

        if (($start_top4rate) && ($top_line !~ /<td class="toprate">/)) {
           print "top_line is $top_line\n" if($debug);
           ($top_top4rate) = ($top_line =~ /\s+(\S+)/);
           print "top_top4rate is $top_top4rate\n" if($verbose);
           $top_top4rate{$top_rank} = $top_top4rate;
           $start_top4rate = 0;
           print "close start_top4rate is $start_top4rate\n" if($debug);
        }

        # get games played
        if ($top_line =~ /<td class="played">\d+<\/td>/) {
           ($top_played) = ($top_line =~ /<td class="played">(\d+)<\/td>/);
           print "top_played is $top_played\n" if($verbose);
           $top_played{$top_rank} = $top_played;
        }

        # get wins
        if ($top_line =~ /<td class="wins">\d+<\/td>/) {
           ($top_wins) = ($top_line =~ /<td class="wins">(\d+)<\/td>/);
           print "top_wins is $top_wins\n" if($verbose);
           $top_wins{$top_rank} = $top_wins;
        }

        # get tier
        if ($top_line =~ /class="tier-name-sm">(.*)<\/span>/) {
           ($top_tier) = ($top_line =~ /class="tier-name-sm">(.*)<\/span>/);
           print "top_tier is $top_tier\n" if($verbose);
           $top_tier{$top_rank} = $top_tier;
        }



   }


   # if line is tops line, stop capture of player data
   if ($top_line =~ /<td class="tops">/) {
      print "top_line is $top_line\n" if($debug);
      # get number of top 4 wins
      ($top_tops) = ($top_line =~ /<td class="tops">(\d+)<\/td>/);
      print "top_tops is $top_tops\n" if($verbose);
      $top_tops{$top_rank} = $top_tops;
      # end capture of player data
      $keep_line = 0;
   }
}

}

# csv format for header line
#date,Name,LP,WinRate,TOP4 %,Played,Wins,TOP4,url

$rank_count = 1;

while ($rank_count < 501) {
   print "$date,$rank_count,$top_tier{$rank_count},$top_ign{$rank_count},$top_lp{$rank_count},$top_winrate{$rank_count},$top_top4rate{$rank_count},$top_played{$rank_count},$top_wins{$rank_count},$top_tops{$rank_count},$top_url{$rank_count}\n";
   $rank_count += 1;
}




