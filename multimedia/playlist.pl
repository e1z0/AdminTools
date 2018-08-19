#!/usr/bin/perl -w
# VLC Playlist generator
# v0.1 (c) 2011 \dev\null

# this script requires media info and its dependencies from http://mediainfo.sourceforge.net/

use strict;
use warnings;
use File::Find;

my $version = "0.1";
my $debug = 1;
my $mediainfo = "/usr/bin/mediainfo";
my $media;
my $length;
my $ext;
my $modified;
my ($med, $fl, $lg, $ex, $mod);
my $count;
my $exist;
sub find_file
{
$media = $File::Find::name;
my $filename = $_;
$length = `$mediainfo -f \"$media\"|grep Duration|head -n1|awk '{print \$3}'`; 
$ext = `$mediainfo -f \"$media\"|grep \"File extension\"|awk '{print \$4}'`;
$modified = `$mediainfo -f \"$media\"|grep \"File last modification date (loc\"| awk '{print \$7 \" \" \$8}'`;
chop($length);
chop($ext);
chop($modified);
print "Adding file: $media Filename: $filename Length: $length ext: $ext modified: $modified\n" if ($debug > 0);
print EXP $media."::".$filename."::".$ext."::".$length."::".$modified."\n";
$count++;
}

sub try_find {
find( sub {find_file("$File::Find::name\n") if (/(.avi|.mpeg)$/i)},$ARGV[1]);
}

sub try_find2 {
find( sub {update_files("$File::Find::name\n") if (/(.avi|.mpeg)$/i)},$ARGV[1]);
}

sub update_plist {
exit unless @ARGV and -d $ARGV[1];
exit unless $ARGV[2];
exit unless (-e $ARGV[2]);
open(EXP,">>".$ARGV[2]);
print "Fetching media... Please wait a little bit :-)\n";
try_find2;
close(EXP);
print "Results fetched: $count\n";
print "Done.\n";
}

sub html_header {
my $header = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n
	      <html xmlns=\"http://www.w3.org/1999/xhtml\">\n
	      <html>\n
              <head>\n
              <title>VLC Playlist Generator: $version</title>\n
	      <meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\">\n
              <meta name=\"robots\" content=\"index,nofollow\">\n
	      <style type=\"text/css\">\n
              tr.normal:hover { background: #ccc; }\n
	 	table
		{
	        margin: 0.5em 0;
	        border-collapse: collapse;
		}
		td
		{
	        padding: 0.25em;
	        border: 1pt solid #C1B496;
		font-family:verdana;
		font-size:10px;
		}

		td p {
		        margin: 0;
		        padding: 0;
			}
		
              </style>\n
	      </head>\n
              <body>\n";
return $header;
}

sub html_footer {
my $footer = "<center><p>VLC Playlist Generator v".$version.". Copyright &copy 2011 \\dev\\null</p></center>\n
		</body>\n
              </html>\n";
return $footer;
}

sub export_plist {
my $record;
exit unless @ARGV and -f $ARGV[1];
exit unless $ARGV[2];
print "Exporting data to HTML...\n";
open(HTML,">".$ARGV[2]);
print HTML html_header;
print HTML "<table cellpadding=\"1\" cellspacing=\"1\" border=\"0\" width=\"98%\"><tr style=\"background-color: #d9bb7a\" ><th>Path</th><th>Filename</th><th>Extension</th><th>Length</th><th>Last modified</th></tr>";
open (IMPORT, $ARGV[1]);
while ($record = <IMPORT>) {
chop($record);
my ($filename, $file, $extension, $length, $last) = split("::", $record);
$extension = "<font color=\"red\">broken</font>" if ($extension eq "");
$length = "0" if ($length eq "");
$last = "<font color=\"red\">broken</font>" if ($last eq "");
print HTML "<tr class=\"normal\"><td>".$filename."</td><td>".$file."</td><td>".$extension."</td><td>".$length."</td><td>".$last."</td></tr>";
$count++;
}
close(IMPORT);
print HTML "</table>";
print HTML html_footer;
close(HTML);
print "Done.\n";
}

sub create_plist {
exit unless @ARGV and -d $ARGV[1];
exit unless $ARGV[2];
open(EXP,">".$ARGV[2]);
print "Fetching media... Please wait a little bit :-)\n";
try_find;
close(EXP);
print "Results fetched: $count\n";
print "Done.\n";
}

sub stats {
print "Not implemented yet!";
}


sub show_help {
# help prompt
print "Help options:\n";
print "  $0 --stats <directory> - stats for files\n";
print "  $0 --create <directory> <export file> - create playlist\n";
print "  $0 --update <directory> <export file> - update playlist\n";
print "  $0 --export <playlist file> <html file> - export playlist to html\n";
}

# Program init!
print "Playlist exporter for VLC\n";
print "Version $version by \\dev\\null\n\n";
print "Starting in debugging mode...\n" unless ($debug == 0);
show_help,exit unless defined $ARGV[0];
for ($ARGV[0]) {
                if    (/--stats/)  { stats; }
                elsif (/--create/)       { create_plist; }
                elsif (/--update/)     { update_plist; }
                elsif (/--export/)	{ export_plist; }
                else                { show_help; }
        }
