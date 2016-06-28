#!/usr/bin/perl
package Octopus;
use strict;
use warnings;
use DBI;
use Switch;

sub config {
	my ( $class, $sid, $nick, $user, $host, $name, $chan, $uid, $eaddr, $sockID ) = @_;
	$eaddr =~ s/\n//gs;
	$class = ref($class) || $class;
	my $this = {
	  "sid"    => $sid,
	  "eaddr" => $eaddr,
	  "nick"    => $nick,
	  "user" => $user,
	  "host"    => $host,
	  "name"    => $name,
	  "chan"  => $chan,
	  "uid"    => $uid,
	  "sockID" => $sockID,
	  "mySQL" => DBI->connect("DBI:mysql:database=octopus", "*****", "*******") 
	};
	
	bless ($this, $class);
	return $this;
};

sub create {
	my ( $this ) = @_;
	my $sockID = $this->{sockID}; 
	# :000 UID Pseudo HopCount Timestamps User Host UID Servicestamp Usermodes Virtualhost Cloakedhost IpConvertieEnBase64 :Realname
	print $sockID ":$this->{sid} UID $this->{nick} 1 ".time()." $this->{user} $this->{host} $this->{uid} 0 +BISqzxwos $this->{host} $this->{host} $this->{eaddr} :$this->{name}\r\n";	
	print $sockID ":$this->{uid} JOIN $this->{chan}\r\n";
  	my $rq = $this->{mySQL}->prepare("SELECT chan FROM chanlist;");
	$rq->execute();
 	while ( my $data = $rq->fetchrow_hashref ) {
    	print $sockID ":$this->{uid} JOIN $data->{chan}\r\n";
  	}
}

sub msg {
 my ( $this, $target, $message ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{uid} PRIVMSG ".$target." :".$message."\r\n";
};

sub notice {
 my ( $this, $target, $message ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{uid} NOTICE ".$target." :".$message."\r\n";
};

sub mode {
 my ( $this, $target, $mode ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{uid} MODE ".$target." ".$mode."\r\n";
};

sub topic {
 my ( $this, $target, $topic ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{uid} TOPIC ".$target." :".$topic."\r\n";
};

sub kick {
 my ( $this, $ctarget, $utarget, $reason ) = @_;
 my $sockID = $this->{sockID};
 if($utarget ne $this->{nick}) {print $sockID ":$this->{uid} KICK ".$ctarget." ".$utarget." :".$reason."\r\n";}
};

sub kickban {
 my ( $this, $ctarget, $utarget, $reason, $chost ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{uid} KICK ".$ctarget." ".$utarget." :".$reason."\r\n";
 print $sockID ":$this->{uid} MODE ".$ctarget." +b *!*@".$chost."\r\n";
};

sub kill {
 my ( $this, $utarget, $reason ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{uid} KILL ".$utarget." ".$reason."\r\n";
};

sub join {
 my ( $this, $target ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{uid} JOIN ".$target."\r\n";
 print $sockID ":$this->{uid} WHO ".$target."\r\n";
};

sub part {
 my ( $this, $target ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{uid} PART ".$target."\r\n";
};

sub checkLevel {
 my ( $this, $uid ) = @_;
 my $level = $this->{mySQL}->selectrow_array("SELECT level FROM members WHERE current_uid = '".$uid."'");
 return $level;
};

sub addChan{
	my ( $this, $chan ) = @_;
	my $rq = $this->{mySQL}->prepare("INSERT INTO chanlist VALUES('','".$chan."')");
	$rq->execute();
	$this->join($chan);
}

sub delChan{
	my ( $this, $chan ) = @_;
	my $rq = $this->{mySQL}->prepare("DELETE FROM chanlist WHERE chan = '".$chan."'");
	$rq->execute();
	$this->part($chan);
}

sub checkChan {
 my ( $this, $chan ) = @_;
 $chan = $this->{mySQL}->selectrow_array("SELECT id FROM chanlist WHERE chan = '".$chan."'");
 return $chan;
}

sub checkClose {
 my ( $this, $chan ) = @_;
 $chan = $this->{mySQL}->selectrow_array("SELECT id FROM closelist WHERE chan = '".$chan."'");
 return $chan;
}

sub addClose{
	my ( $this, $chan, $reason ) = @_;
	my $rq = $this->{mySQL}->prepare("INSERT INTO closelist VALUES('','".$chan."','".$reason."')");
	$rq->execute();
	$this->join($chan);
	$this->topic($chan,$reason);
}

sub delClose{
	my ( $this, $chan ) = @_;
	my $rq = $this->{mySQL}->prepare("DELETE FROM closelist WHERE chan = '".$chan."'");
	$rq->execute();
	$this->part($chan);
}

sub setOnline{
	my ( $this, $nick, $uid, $user, $host, $vhost, $real ) = @_;
	my $rq = $this->{mySQL}->prepare("INSERT INTO online VALUES('','".$nick."','".$uid."','".$user."','".$host."','".$vhost."','".$real."','')");
	$rq->execute()
}

sub updateOnline{
	my ( $this, $uid, $nick ) = @_;
	my $rq = $this->{mySQL}->prepare("UPDATE online SET nick = '".$nick."' WHERE uid = '".$uid."'");
	$rq->execute()
}

sub setOffline{
	my ( $this, $uid ) = @_;
	my $rq = $this->{mySQL}->prepare("DELETE FROM online WHERE uid = '".$uid."'");
	$rq->execute()
}

sub setMemberUid{
	my ( $this, $uid, $arg ) = @_;
	my $rq = $this->{mySQL}->prepare("UPDATE members SET current_uid = '".$uid."' WHERE login = '".$arg."'");
	$rq->execute()
}

sub getNick{
	my ( $this, $uid ) = @_;
	my $nick = $this->{mySQL}->selectrow_array("SELECT nick FROM online WHERE uid = '".$uid."'");
 	return $nick;
}

sub getUid{
	my ( $this, $nick ) = @_;
	my $uid = $this->{mySQL}->selectrow_array("SELECT uid FROM online WHERE nick = '".$nick."'");
 	return $uid;
}

sub getLogin{
	my ( $this, $uid ) = @_;
	my $login = $this->{mySQL}->selectrow_array("SELECT login FROM members WHERE current_uid = '".$uid."'");
 	return $login;
}

sub refreshActions{
	my ( $this ) = @_;
	my $rq = $this->{mySQL}->prepare("SELECT * FROM actions;");
	$rq->execute();
 	while ( my $data = $rq->fetchrow_hashref ) {
    	my $action = $data->{action};
		my @args = split(/;;00xE;;/, $data->{args});
    	$this->$action(@args);
  	}
}

1;
