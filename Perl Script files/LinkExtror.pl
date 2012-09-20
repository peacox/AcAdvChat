# This script extracts links from @AcAdvChat transcript files.  Invoke with transcript file name and direct output to new .html file.
# example: perl LinkExtror.pl AcAdvChatTranscript_03_21_11 >> links.html


use HTML::SimpleLinkExtor;					# nice CPAN module for extracting links

$filename = shift @ARGV;					# get path to filename from command line
my $extor = HTML::SimpleLinkExtor->new();
$extor->parse_file($filename);             	# --or-- $extor->parse($html);

											# $extor->parse_file($other_file);  - get more links


@all_links   = $extor->links;				# extract all of the links

foreach (@all_links) {
	if (m!http://twitter.com/.*!) {							# remove all links to tweet info
#		do nothing
	}elsif (m!http://acadvchat.posterous.com/.*!) {			# remove links to AcAdvChat blog
#		do nothing
	}elsif (m!http://wthashtag.com/.*!) {					# remove all hashtag links
#		do nothing
	}elsif (m!css/.*!) {									# remove css refs							
#		do nothing
	}elsif (m!http://tweetchat.com/room/AcAdv.*!) {			# remove link to AcAdv tweetchat room
#		do nothing
	}else {
	print "<a href=\"$_\">$_</a><br />";					#print the rest of the links, html formatted
}

}