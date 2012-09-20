#! /usr/bin/perl -w

# This script grabs tweets from Twitter Search API, pulls relevant information from atom format and prints info
# with formatting html tags.  As Twitter search returns tweets with most recent at top of page, pages are 
# written to file which is then reversed with File::ReadBackwards so transcript is properly formatted.
 
# Can / should beginning and ending html be printed here, or added after, as htlm file has to be edited for question
# titles anyway?


use LWP::Simple;
use lib '/usr/local/lib/perl5/site_perl/5.12.3/';   ## needed for OS 10.8, as it uses other lib locations
use XML::FeedPP;
use Time::Piece;
use IO::File;
use File::ReadBackwards ;

# Filehandle for (reverse-order) tweets from search api, removed after reverse-order file is written
my $fh = IO::File->new('chat_html', 'w') or die
#$fh = IO::File->new_tmpfile or die
	"Cannot open chat.html: $!";

# main loop to grab search results - Since API allows only 100 results per page, need to fetch multiple
# pages.  Setting i<5 grabs 4 pages, which is usually enough.	
for ($i = 1; $i < 5; $i++) {
	my $url = "http://search.twitter.com/search.atom?q=%23acadv&rpp=100&page=" . $i;
#	my $url = "http://search.twitter.com/search.atom?q=%23NACADAR8&rpp=100&page=" . $i;
	print "Fetching page $i \n";
	my $source = get($url);
	# my $source = get("http://search.twitter.com/search.atom?q=%23acadv&since=2011-04-11&until=2011-04-07&rpp=100&page=4");
	die "Couldn't get page!" unless defined $source;
	my $feed = XML::FeedPP->new( $source );

	# loop to parse atom feed and write results to file with $fh print function
	foreach my $item ( $feed->get_item() ) {
		$fh->print ("<tr><td valign=\"top\" width=\"55px\">");
		# Get GMT pub time from atom feed, pass to convert_time sub to convert to local (CST) time
		my $local_time = &convert_time($item->pubDate());
		# print out html for local time of tweet, time linked to tweet
		$fh->print ("<a href=\"", $link = $item->link(), "\" title=\"View original tweet\">". $local_time, "</a>");
		$fh->print ("</td>");
		# get poster (author) name and use regex to capture twitter username only, truncating real name with regex
		my $_ = $item->author();
		/(\w+)/; 
		# print username with link to profile page
		$fh->print ("<td valign=\"top\" align=\"right\">"); 
		$fh->print ("<b><a href=\"http://twitter.com/#!/", $1, "\" title=\"View this user's profile\" target=\"_blank\">", $1, "</a>:</b>");
		$fh->print ("</td>");
		# print contents of tweet
		$fh->print ("<td valign=\"top\">");
		$fh->print ($item->description());
		$fh->print ("</td>");
		$fh->print ("</tr>");
		# newline needed so File::ReadBackwards knows where each line is terminated, and can properly reverse order 
		$fh->print("\n");
		}
}

# Reverse order of file containing tweets, write to new file, and remove original file.
$bw = File::ReadBackwards->new( 'chat_html' ) or
	die "can't read 'chat_html': $!" ;
my $fh2 = IO::File->new('chatTranscript_html', 'w') or die
		"Cannot open chatTranscript: $!";
while( defined( $chat_html = $bw->readline ) ) {
	$fh2->print ($chat_html) ;
	}
$fh->close;
$fh2->close;

unlink "chat_html" or warn
	"File not deleted: $!";

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