#!/usr/bin/perl -w
# apt install libnet-sftp-foreign-perl
##########################################################################################################################################
# SSH To the servers and read the remote file in tail mode v2.0 (c) 2018 Justinas K. justinas@eofnet.lt
##########################################################################################################################################

my $file = "/var/log/mail.log";
my $version = "2.0";
use strict;
use warnings;
use Getopt::Long;
use Net::SFTP::Foreign;
use Fcntl qw(SEEK_END);

# const variables
my $max_tries = 15; # max tries to connect to the ssh server
my $parse_with_delay = 0;
my $host;
my $username = 'root';
my $password;
my $port = 22;
my $sftp;

my %opt = (
                "help" => 1,
        );

# Gather the options from the command line
GetOptions(\%opt,
                'host=s' => \$host,
                'user=s' => \$username,
                'pass=s' => \$password,
                'port=i' => \$port,
                'help',
        );


# write log function
sub write_log {
 my ($text) = @_;
 # one trully method, that actually works!
 use File::Basename;
 my $script_dir = undef;
  if(-l __FILE__) {
    $script_dir = dirname(readlink(__FILE__));
  }
  else {
    $script_dir = dirname(__FILE__);
  }
 my $logas = $script_dir."/ssher.log";
 use Time::localtime;
 my $t = localtime;
 open(my $fh, '>>', $logas);
 printf $fh ("%04d.%02d.%02d %02d:%02d:%02d -> [%s]: %s\n", $t->year + 1900, $t->mon + 1, $t->mday, $t->hour, $t->min, $t->sec, $host, $text);
 close $fh;
}


my %args = (
  user      => $username,
  password  => $password,
  port      => $port,
  autodie   => 0,
  timeout   => 10,
  autoflush => 1,
);

sub usage {
        # Shown with --help option passed
        print "\n".
                "   ssher.pl $version - Remote log reader\n".
                "   Bug reports, feature requests\n".
                "   Created by Justinas K. (justinas\@eofnet.lt)\n".
                "\n".
                "   Options\n".
                "      --host       Remote machine host\n".
                "      --user       Remote machine ssh username\n".
                "      --pass       Remote machine ssh password\n".
                "      --port       Remote machine port (Default 22)\n".
                "\n";
        exit;
}




if (defined($host)&&defined($username)&&defined($password)&&defined($port)) {

my $retry_count = 0;
# we shall avoid stupid, non stable ssh connections...
while (1) {
    eval {
      $sftp = do {
        local $SIG{TERM} = 'IGNORE';  # used to avoid the message "Killed by signal 15".
        $sftp = Net::SFTP::Foreign->new($host, %args,more => [-o => 'StrictHostKeyChecking no']); };
     };

   if ($sftp->error) {
   if ($retry_count >= $max_tries) {
            print "Opening connection to the server $host failed, maximum retry reached !\n";
            write_log("Opening connection to the server $host failed, maximum retry reached !");
            exit 2;
            }
         print "Connecting to $host server (retry $retry_count/$max_tries)...\n";
         write_log("Connecting to $host server (retry $retry_count/$max_tries)...");
         sleep 2;
         $retry_count++;
       } else {
         print "Connection established to $host!\n";
         last;
       }
}

my $fh = $sftp->open($file) or die "Unable to open file $file: ".$sftp->error."\n";
seek($fh, 0, SEEK_END);

my $sleep = 1;
while (1) {
    while (<$fh>) {
        print;
        $sleep = 1;
    }
    sleep $sleep if ($parse_with_delay > 0);
    $sleep++ unless $sleep > 5;
}

} else {
if (defined $opt{'help'} && $opt{'help'} == 1) { usage(); }
}
