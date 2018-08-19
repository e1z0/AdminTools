#!/usr/bin/perl -w
#  2009-2016 (c) justinas@eofnet.lt, EofNET LAB06 
# pre: apt install libcurses-perl

my $banner = "Server realtime monitoring";

# tcp port services to monitor
my %tcps = (
    "Nginx httpd"  => "80",
    "Nginx httpd (ssl)" => "443",
    "SSH"  => "22",
);

# process names to monitor
my %procs = (
  "Nginx httpd" => "nginx",
  "PHP-FPM 7.1" => "7.1/etc/php-fpm",
  "MySQL" => "mysqld",
  "Glusterfs" => "glusterfsd",
  "SuperVisor" => "supervisord",
  "Linux HA" => "keepalived",
  "Zabbix Agent" => "zabbix_agentd",
  "Redis" => "redis-server",
  "Munin Node" => "munin-node",
);


## Code
use strict;
use warnings;
use Socket;
use Curses;
use POSIX ":sys_wait_h";
#$SIG{INT}  = sub { $toexit = 1; };
#$SIG{TERM} = sub { $toexit = 1; };
$SIG{ALRM} = "IGNORE";
$ENV{TERM} = "xterm-vt220" if ($ENV{TERM} eq 'xterm');

sub check_port {
my ($port) = @_;
   my $timeout = 30;
    my $proto = getprotobyname('tcp');
    my $iaddr = inet_aton('localhost');
    my $paddr = sockaddr_in($port, $iaddr);
    socket(SOCKET, PF_INET, SOCK_STREAM, $proto) || warn "socket: $!";
    eval {
      local $SIG{ALRM} = sub { die "timeout" };
      alarm($timeout);
      connect(SOCKET, $paddr) || error();
      alarm(0);
    };
    if ($@) {
      close SOCKET || warn "close: $!";
      return 0;
    }
    else {
      close SOCKET || warn "close: $!";
      return 1;
    }
}

sub check_proc {
my ($proc) = @_;
if(`ps -aef | grep -v grep|grep \"$proc\"`) {
    return 1;
}
return 0
}

my $mwh = new Curses;
start_color; # spalvos
init_pair(1, COLOR_RED, A_NORMAL); # raudonas ant normalaus fono
init_pair(2, COLOR_BLUE, A_NORMAL); # banerio spalvos, melyna ant normalaus fono
$mwh->attrset(A_BOLD | A_UNDERLINE | COLOR_PAIR(2));
$mwh->addstr(1, $LINES+10, $banner);
$mwh->attrset(A_NORMAL);

while (1) {
my $ln = 5; # patraukiam 5 eilutes nuo virsaus
  $mwh->refresh(); # refreshas
$mwh->addstr($ln,$LINES-2, "---- PORTS MONITORING ----");
foreach my $name(sort {$a cmp $b} keys %tcps) {
 $ln++;
 my $port = $tcps{$name};
 my $pstat = "Okay";
    $pstat = "Fail" if !(check_port($port));
    (check_port($port)) ? $mwh->attrset(A_NORMAL) : $mwh->attrset(A_BOLD | A_BLINK | COLOR_PAIR(1));
    $mwh->addstr($ln, $LINES-2, sprintf("%15s","Service: $name ($port) is: $pstat"));
}
$mwh->addstr($ln+1, $LINES-2, "---- PROCESSES MONITORING ----");
$ln++;
foreach my $name(sort {$a cmp $b} keys %procs) {
    $ln++; # line countas
    my $proc = $procs{$name};
    my $pps = "Okay";
    $pps = "Fail" if !(check_proc($proc));
    (check_proc($proc)) ? $mwh->attrset(A_NORMAL) : $mwh->attrset(A_BOLD | A_BLINK | COLOR_PAIR(1));
    $mwh->addstr($ln, $LINES-2, "Process: $name is: $pps");    
}
  sleep 2; # refreshas
}

END
{
  endwin(); # clean curses
}