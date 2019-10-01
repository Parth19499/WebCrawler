use LWP::UserAgent;
use HTML::LinkExtor;
use URI::URL;
use LWP::Simple;
use HTTP::Request;
use HTTP::Response;
use HTML::Strip;
use HTML::DOM;
use warnings;


my $dom_tree = new HTML::DOM;

 
$url = "https://en.wikipedia.org/wiki/";  # for instance
print("\nEnter Word to be found : ");
$find = lc(<STDIN>); #word to be found
chomp $find;
if($url eq "https://en.wikipedia.org/wiki/") {
	$url .= $find;
}

print("url : ", $url);
print("\n Enter depth to be crawled : ");
$depth = <STDIN>;
chomp $depth;
$count = 0;
$linklim = 5;
$browser = LWP::UserAgent->new();
$browser->timeout(10);
$ua = LWP::UserAgent->new;
my %vlinks;
 
# Set up a callback that collect links
my @links = ();
sub callback {

   my($tag, %attr) = @_;
   #print("\nContent : ",@_," \n");
   return if $tag ne 'a';  # we only look closer at <a ...>
   push(@links, values %attr);
               
}

sub recur {
	if ($_[1] > $depth) {
		print("Depth exceeded");
		return;
	}
	if(exists $vlinks{$_[0]})
	{
		return;
	}
	else
	{
		$vlinks{$_[0]} = 1;
	}
	#find word in content
	my $request = HTTP::Request->new(GET => $_[0]);
	my $response = $browser->request($request);
	if ($response->is_error()) {printf "%s\n", $response->status_line;}
	$contents = lc($response->content());
	$dom_tree->write($contents);
	print("\nparagraphs\n");
	foreach my $x ($dom_tree->getElementsByTagName('p')) {
		# body...
		$x=$x->innerHTML;
		my $hs = HTML::Strip->new();
		my $clean_text = $hs->parse( $x );
		$hs->eof;
		if (index($clean_text, $find) != -1) {
			print("\t".$clean_text,"\n------------------------------------------\n");
		}
	}
	$dom_tree->close;
	$vlinks{$_[0]} = () = $contents =~ /$_[2]/g;  #counting all occurences
	#
	print("\n", "current link : ",$_[0], "\n");
	print("\n", "at depth : ", $_[1], "\n");
	$count = $count + 1;
	$p = HTML::LinkExtor->new(\&callback);
 
# Request document and parse it as it arrives
	$res = $ua->request(HTTP::Request->new(GET => $_[0]),
	                    sub {$p->parse($_[0])});
	# Expand all URLs to absolute ones
	my $base = $res->base;
	@links = map { $_ = url($_, $base)->abs; } @links;
	 
	# Print them out
	#print("\nLinks on page:\n");
	#print join("\n", @links), "\n";
	#print "Done";
	for (my $var = 0; $var < $linklim; $var++) {
		# body...
		print("\n", "in loop : " , $var, "\n");
		# $temp_depth = $depth - $var - 1;
		recur(@links[$var], $_[1] + 1, $find);
		print("\n", "return to depth : ",$_[1]," \n");
		print("\n", " loop ",$var, " complete \n");

	}
	# return recur($url, $depth - 1);
}

#Driver Code 
print(recur($url, 0, $find));
print("\n", "List of Visited Links : ", $count, "\n");
print "$_\n" for %vlinks;
print("End of program");
# Write to files
#	open(my $fh, '>', 'links.txt');
#	print $fh "$_\n" for @links;
#	close $fh; 
