#! /usr/bin/perl -w
use strict;
use Carp;
use XML::Simple;
use File::Temp;

# handy for kludging your way through XML!
#use Data::Dumper;


sub get_reading_list() {
  my $xml_parser = XML::Simple->new();

  ## dump the bookmarks plist as xml
  my $xml = `/usr/libexec/PlistBuddy ~/Library/Safari/Bookmarks.plist -x -c print`;

  my $bmarks = $xml_parser->XMLin($xml)
    or carp;


  ## this is obviously a hacky way to get at the desired data (strings
  ## and dicts all over the place) but it seems to work
  my @bmark_groups = @{ $bmarks->{'dict'}->{'array'}->{'dict'} };
  my @rlist=();

  for my $bg (@bmark_groups) {
    # pick the group with the right label
    next unless grep /com\.apple\.ReadingList/, @{ $bg->{'string'} };


    # extract the url and link text from each
    for my $item (@{ $bg->{'array'}->{'dict'} }) {
      my $url = ${ $item->{'string'} }[0];
      my $text;

      for my $choice (@{ $item->{'dict'}}) {
	if ($choice->{'key'} eq 'title') {
	  $text = $choice->{'string'};
	  last;
	}
      }

      #      print "**$text** -> \"$url\"\n";
      push @rlist, {'url' => $url, 'text' => $text};
    }
  }

  return @rlist;
}
  
  
#print Dumper(@rlist);

## print contents to a temporary html file
my $fh = File::Temp->new( UNLINK=>0, SUFFIX => '.html' );

# if i wanted to have perl clean up the tmp file for me...
# my $fh = File::Temp->new( SUFFIX => '.html' );

print $fh '<html><title>Safari Reading List</title><body><ol>';
for my $b (get_reading_list()) {
  print $fh '<li><a href="', $b->{'url'}, '">', $b->{'text'}, '</a></li>', "\n";
}
print $fh '</ol></body>';

$fh->close();



# open in system-configured browser
system("open $fh");
  
# # sleep for a little bit, so that tmp file can get deleted
# sleep 3;
