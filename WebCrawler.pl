use LWP::UserAgent;
use HTML::LinkExtor;
use URI::URL;
use LWP::Simple;
use HTTP::Request;
use HTTP::Response;
use HTML::Strip;
use HTML::DOM;
use warnings;


my $dom_tree = new HTML::DOM; #initialise DOM tree to parse an HTML file

 
$url = "https://metacpan.org/pod/HTML::DOM";  # starting url for crawling
print("\nEnter Word to be found : ");
$find = lc(<STDIN>); #word to be found - only single word search allowed
chomp $find;
if($url eq "https://en.wikipedia.org/wiki/") { # if url is wikipedia, starting url should be url/find
	$url .= $find;
}

print("url : ", $url);
print("\n Enter depth to be crawled : "); #extent to which pages of website should be searched. (eg: if depth=3, the web crawler will only search upto link of link of link)
$depth = <STDIN>;
chomp $depth;
$count = 0; #to count number of visited links
$linklim = 5; # number of links to be searched per page
$browser = LWP::UserAgent->new();
$browser->timeout(10); #time to wait for response from a url
my %vlinks; #hashmap for visited links - stores a link and number of times the key(search word) is found in it.
 
# Set up a callback that collect links
my @links = ();
sub callback {

   my($tag, %attr) = @_;
   #print("\nContent : ",@_," \n");
   return if $tag ne 'a';  # we only look closer at <a ...>
   push(@links, values %attr);#stores all links on page in @links
               
}

#recursive function to traverse links in a page and links of those links and so on
sub recur {
	if ($_[1] > $depth) { #if depth exceeded limit return
		#print("Depth exceeded");
		return;
	}
	if(exists $vlinks{$_[0]}) #if link already present in hashmap, do not traverse, but return
	{
		return;
	}
	else
	{
		$vlinks{$_[0]} = 1; #adds link to hashmap
	}
	#find word in content
	my $request = HTTP::Request->new(GET => $_[0]);# requests html source code of link 
	my $response = $browser->request($request);# stores request response
	if ($response->is_error())# error handling
	{
		printf "%s\n", $response->status_line;
		return;
	}
	$contents = lc($response->content()); # converts to lowercase
	$dom_tree->write($contents); #stores html source code in domtree to parse html
	#print("\nParagraphs:\n");
	foreach my $x ($dom_tree->getElementsByTagName('p')) { #find all paragraphs in html code
		# body...
		$x=$x->innerHTML; #get text between <p> and </p>
		my $hs = HTML::Strip->new();
		my $clean_text = $hs->parse( $x ); #remove all html tags from text
		$hs->eof;
		if (index($clean_text, $find) != -1) { #if text has keyword, then print
			print("\t".$clean_text,"\n------------------------------------------\n");
		}
	}
	$dom_tree->close;
	$vlinks{$_[0]} = () = $contents =~ /$_[2]/g;  #counting all occurences in html source code
	#print("\n", "current link : ",$_[0], "\n"); #debugging
	#print("\n", "at depth : ", $_[1], "\n");
	$count = $count + 1; #increment number of visited links
	
	$p = HTML::LinkExtor->new(\&callback); # for callback
 
# Request document and parse it as it arrives
	$res = $browser->request(HTTP::Request->new(GET => $_[0]),
	                    sub {$p->parse($_[0])}); # call callback
	# Expand all URLs to absolute ones
	my $base = $res->base;
	@links = map { $_ = url($_, $base)->abs; } @links;
	 
	# Print them out
	#print("\nLinks on page:\n");
	#print join("\n", @links), "\n";
	#print "Done";
	for (my $var = 0; $var < $linklim; $var++) { # traverse through links in a page
		# body...
		#print("\n", "in loop : " , $var, "\n");
		# $temp_depth = $depth - $var - 1;
		recur(@links[$var], $_[1] + 1, $find); 
		#print("\n", "return to depth : ",$_[1]," \n");
		#print("\n", " loop ",$var, " complete \n");

	}
	# return recur($url, $depth - 1);
}

#Driver Code 
print(recur($url, 0, $find)); 
print("\n", "List of Visited Links : ", $count, "\n");
print "$_\n" for %vlinks; #print visited links and number of occurences of keyword per link
print("End of program");
# Write to files
#	open(my $fh, '>', 'links.txt');
#	print $fh "$_\n" for @links;
#	close $fh; 
