#!/usr/bin/perl
package Octopus;
use strict;
use warnings;
use Switch;
use IO::Socket;

sub config {
	my ( $class, $sid, $nick, $user, $host, $name, $chan, $uid, $sockID ) = @_;
	$class = ref($class) || $class;

	my $this = {
	  "sid"    => $sid,
	  "nick"    => $nick,
	  "user" => $user,
	  "host"    => $host,
	  "name"    => $name,
	  "chan"  => $chan,
	  "uid"    => $uid,
	  "sockID" => $sockID,
	  "mySQL" => DBI->connect("DBI:mysql:database=octopus", "**", "***") 
	};
	
	bless ($this, $class);
	return $this;
};

sub create {
	my ( $this ) = @_;
	my $sockID = $this->{sockID}; 
	# :000 UID Pseudo HopCount Timestamps User Host UID Servicestamp Usermodes Virtualhost Cloakedhost IpConvertieEnBase64 :Realname
	print "$this->{uid}";
	print $sockID ":$this->{sid} UID $this->{nick} 1 ".time()." $this->{user} $this->{host} $this->{uid} 0 +BISqzxwos $this->{host} $this->{host} XN6pyQ== :$this->{name}\r\n";	
	print $sockID ":$this->{uid} JOIN $this->{chan}\r\n";
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
 print $sockID ":$this->{sid} MODE ".$target." ".$mode."\r\n";
};

sub topic {
 my ( $this, $target, $topic ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{sid} TOPIC ".$target." ".$topic."\r\n";
};

sub kick {
 my ( $this, $ctarget, $utarget, $reason ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{sid} KICK ".$ctarget." ".$utarget." :".$reason."\r\n";
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

sub setUid{
	my ( $this, $uid, $arg ) = @_;
	my $rq = $this->{mySQL}->prepare("UPDATE members SET current_uid = '".$uid."' WHERE login = '".$arg."'");
	$rq->execute()
}

sub getLogin{
	my ( $this, $uid ) = @_;
	my $llogin = $thi->{mySQL}->selectrow_array("SELECT login FROM members WHERE current_uid = '".$uid."'");
 	return $login;
}

1;