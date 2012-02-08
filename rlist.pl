#! /usr/bin/perl -w
use strict;
use XML::Simple;
#use Data::Dumper;

my $xml_parser = XML::Simple->new();

## dump the bookmarks plist as xml
my $xml = `/usr/libexec/PlistBuddy ~/Library/Safari/Bookmarks.plist -x -c print`;

my $bmarks = $xml_parser->XMLin($xml)
  or die;

## this is obviously a hacky way to get at the desired data (strings
## and dicts all over the place) but it seems to work
my @bmark_groups = @{ $bmarks->{'dict'}->{'array'}->{'dict'} };
my @rlist=();

for my $bg (@bmark_groups)
  {
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


  
#print Dumper(@rlist);

for my $b (@rlist)
  {
    print '<a href="', $b->{'url'}, '">', $b->{'text'}, '</a><br>', "\n";
  }
