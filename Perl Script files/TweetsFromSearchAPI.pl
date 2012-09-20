#! /usr/bin/perl -w

# This script grabs tweets from Twitter Search API, pulls relevant information from atom format and prints info with formatting html tags.
# As Twitter search returns tweets with most recent at top of page, each page has to be reversed with 'TwitReverseLines' for transcript to
# appear properly formatted.

use LWP::Simple;
use XML::FeedPP;
use Time::Piece;

my $source = get("http://search.twitter.com/search.atom?q=%23acadv&since=2011-04-10&rpp=100&page=5");
# my $source = get("http://search.twitter.com/search.atom?q=%23acadv&since=2011-04-04&until=2011-04-07&rpp=100&page=4");
die "Couldn't get page!" unless defined $source;
my $feed = XML::FeedPP->new( $source );

foreach my $item ( $feed->get_item() ) {
		print "<tr><td valign=\"top\" width=\"55px\">";
		# Get GMT pub time from atom feed, pass to convert_time sub to convert to local (CST) time
		my $local_time = &convert_time($item->pubDate());
		# print out html for local time of tweet, time linked to tweet
		print "<a href=\"", $link = $item->link(), "\" title=\"View original tweet\">". $local_time, "</a>";
		print "</td>";
		# get poster (author) name and use regex to capture twitter username only, truncating real name
		my $_ = $item->author();
		/(\w+)/; 
		# print username with link to profile page
		print "<td valign=\"top\" align=\"right\">"; 
		print "<b><a href=\"http://twitter.com/#!/", $1, "\" title=\"View this user's profile\" target=\"_blank\">", $1, "</a>:</b>";
		print "</td>";
		# print contents of tweet
		print "<td valign=\"top\">";
		print $item->description();
		print "</td>";
		print "</tr>";
#		print "<br /><br />";
		print "\n";
}

# Twtter search API provides GMT timestamp.  This subroutine converts to CST.
sub convert_time {	
		# assign pubDate to $date as passed paramter
		my $date = @_[0];
		
		# Parse the date using strptime(), which uses strftime() formats.
		my $time = Time::Piece->strptime($date, "%Y-%m-%dT%H:%M:%SZ");

		# Get your local time zone offset and add it to the time.
		$time += $time->localtime->tzoffset;

		# And here it is localized.
		return $time->hms;
}