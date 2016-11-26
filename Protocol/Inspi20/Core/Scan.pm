#!/usr/bin/perl
package Scan;
use strict;
use Switch;
use IO::Socket;
use Core::mySQL;
use Geo::IP::PurePerl;

sub init {
	my ( $_Octopus,$uid,$nick,$ident,$gecos,$ip,$host ) = @_;
	my %_port_thr;
	my %_nick_thr;
	my %_ident_thr;
	my %_gecos_thr;
	my %_hostip_thr;
	print "Start scanning : ".Core::getNick($uid)."\n";
	# $_Octopus->msg($_Octopus->{chan},"\002[SIGN ON]");
 #  	$_Octopus->msg($_Octopus->{chan},"....\002\0033[Nickname]\002\0037 $nick\0031");
 #  	$_Octopus->msg($_Octopus->{chan},"....\002\0033[Ident]\002\0037 $ident\0031");
 #  	$_Octopus->msg($_Octopus->{chan},"....\002\0033[Gecos]\002\0037 $real\0031");
 #  	$_Octopus->msg($_Octopus->{chan},"....\002\0033[Hostname]\002\0037 $host\0031");
 #  	$_Octopus->msg($_Octopus->{chan},"....\002\0033[IP]\002\0037 $ip\0031");
	$_nick_thr{$nick} = threads->create(\&scanNick,$_Octopus,$nick);
  	$_nick_thr{$nick}->detach;	

	$_ident_thr{$nick} = threads->create(\&scanIdent,$_Octopus,$nick,$ident);
  	$_ident_thr{$nick}->detach;	

	$_gecos_thr{$nick} = threads->create(\&scanGecos,$_Octopus,$nick,$gecos);
  	$_gecos_thr{$nick}->detach;	

	# $_ident_thr{$ident} = threads->create(\&scanIdent,$ident);
 # 	$_ident_thr{$ident}->detach;	

	# $_real_thr{$real} = threads->create(\&scanReal,$real);
 # 	$_real_thr{$real}->detach;	

	$_hostip_thr{$nick} = threads->create(\&scanHostIp,$_Octopus,$nick,$ip,$host);
  	$_hostip_thr{$nick}->detach;	

	# $_port_thr{$ip} = threads->create(\&scanPort,$_Octopus,$nick,$ip);
 # 	$_port_thr{$ip}->detach;	
  	my $gi = Geo::IP::PurePerl->new(GEOIP_STANDARD);
	my $country = $gi->country_name_by_addr($ip);
  	# $_Octopus->msg($_Octopus->{chan},"....\002\0033[Geo-localization]\002 \0037$country\0031");
  	# $_Octopus->msg($_Octopus->{chan},"\002[END]");
};

# sub scanPort{
# 	my ( $_Octopus, $nick, $hostip ) = @_;
# 	my @ports=("21","22","25","80","110","443","993","995","1080","8080","8081");
# 	my @opens;
# 	my $thid = threads->tid();
# 	foreach my $port (@ports)  {
# 	  my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $port, Proto => 'tcp', Timeout => 4);
# 	  if ($scansock) {
# 	    push (@opens, $port);
# 	    $scansock->close;
# 	  }
# 	}
# 	if (@opens) {
# 	 $_Octopus->msg($_Octopus->{chan},"\002[Scanner]\002 \002\0034[Port]\002\0031 - \0037$nick ($hostip) \0031:\0033 \002@opens\002");
# 	}
# 	threads->exit();
# }

sub scanNick{
 	my ( $_Octopus, $nick) = @_;
 	my $sql = mySQL::connect;	
 	my $badnick = $sql->selectrow_array("SELECT id FROM nicklist WHERE nick = '".$nick."'");
 	$sql->disconnect();
 	if($badnick){
 		$_Octopus->msg($_Octopus->{chan},"\002[Scanner]\002 \002\0034[Bad nickname] \0037$nick :\002\0033 $nick is a forbidden nickname. (Listed in database)\002");
		$_Octopus->kill($nick,"Forbidden nickname !");
 	}
 	threads->exit();
}


sub scanHostIp{
	my ( $_Octopus, $nick, $ip, $host ) = @_;;
	my $scoreip = 0;
	my $scorehost = 0;
	my $filename = "db/ips.db";
	open (my $fh, '<', $filename) or die "Error: couldn't read '$filename'";
	while (my $line = <$fh>)
	{

	    if($line =~ $ip){
	    	$scoreip++;
	    } elsif($line =~ $host) {
	    	$scorehost++;
	    } else {
	    	1;
	    }

	}
	close $fh;
	if($scoreip>0){
		$_Octopus->msg($_Octopus->{chan},"\002[Scanner]\002 \002\0034[Bad IP address] \0037$nick :\002\0033 $ip is a forbidden address. (Listed in auto-generated database)\002");
		$_Octopus->kill($nick,"Forbidden IP address !");
	} elsif($scorehost>0) {
		$_Octopus->msg($_Octopus->{chan},"\002[Scanner]\002 \002\0034[Bad hostname] \0037$nick :\002\0033 $host is a forbidden address. (Listed in auto-generated database)\002");
		$_Octopus->kill($nick,"Forbidden hostname !");
	} else {
	 	my $sql = mySQL::connect;	
	 	my $badip = $sql->selectrow_array("SELECT id FROM iphostlist WHERE address = '".$ip."'");
	 	my $badhost = $sql->selectrow_array("SELECT id FROM iphostlist WHERE address = '".$host."'");
	 	$sql->disconnect();
	 	if($badip){
	 		$_Octopus->msg($_Octopus->{chan},"\002[Scanner]\002 \002\0034[Bad IP address] \0037$nick :\002\0033 $ip is a forbidden address. (Listed in database)\002");
	 		$_Octopus->kill($nick,"Forbidden IP address !");
	 	} elsif ($badhost) {
			$_Octopus->msg($_Octopus->{chan},"\002[Scanner]\002 \002\0034[Bad hostname] \0037$nick :\002\0033 $host is a forbidden address. (Listed in database)\002"); 		
			$_Octopus->kill($nick,"Forbidden hostname !");
	 	} else {
	 		1;
	 	}
 	}

	threads->exit();
}

sub scanIdent{
 	my ( $_Octopus, $nick, $ident ) = @_;
 	my $recordident;
 	my $scoreident = 0;
 	my $sql = mySQL::connect;	
	my $rq = $sql->prepare("SELECT ident FROM identlist;");
	$rq->execute();
	while ( my $data = $rq->fetchrow_hashref ) {
	 	$scoreident++ if $ident =~ /$data->{ident}/;
	 	$recordident = $data->{ident};
	}
 	$sql->disconnect();
 	if($scoreident>0){
 		$_Octopus->msg($_Octopus->{chan},"\002[Scanner]\002 \002\0034[Bad username] \0037$nick :\002\0033 $ident is a forbidden username. (Listed in database : [\0034$recordident\0033])\002");
		$_Octopus->kill($nick,"Forbidden ident !");
 	}
 	threads->exit();
}

sub scanGecos{
 	my ( $_Octopus, $nick, $gecos ) = @_;
 	my $recordgecos;
 	my $scoregecos = 0;
 	my $sql = mySQL::connect;	
	my $rq = $sql->prepare("SELECT gecos FROM gecoslist;");
	$rq->execute();
	while ( my $data = $rq->fetchrow_hashref ) {
	 	$scoregecos++ if $gecos =~ /$data->{gecos}/;
	 	$recordgecos = $data->{gecos};
	}
 	$sql->disconnect();
 	if($scoregecos>0){
 		$_Octopus->msg($_Octopus->{chan},"\002[Scanner]\002 \002\0034[Bad gecos] \0037$nick :\002\0033 have got a forbidden realname. (Listed in database : [\0034$recordgecos\0033]) :: $gecos\002");
		$_Octopus->kill($nick,"Forbidden gecos !");
 	}
 	threads->exit();
}




1;