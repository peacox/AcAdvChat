# Since Twitter Search API returns tweets with most recent on top of page, order needs to be reversed to make transcript read from
# beginning to end.  File::ReadBackwards does all the heavy lifting here.


use File::ReadBackwards ;

$bw = File::ReadBackwards->new( 'revised.html' ) or
                    die "can't read 'log_file': $!" ;

while( defined( $reversed_line = $bw->readline ) ) {
				            print $reversed_line ;
				    }
