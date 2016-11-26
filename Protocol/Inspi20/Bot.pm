#!/usr/bin/perl
package Bot;
use strict;
use Switch;
use IO::Socket;
use Core::mySQL;

sub config {
	my ( $class ) = @_;
	$Service::_eaddr =~ s/\n//gs;
	$class = ref($class) || $class;
	my $this = {
	  "sid"    => $Service::_sid,
	  "addr" => $Service::_ip,
	  "nick"    => $Service::_botnick,
	  "user" => $Service::_botuser,
	  "host"    => $Service::_bothost,
	  "name"    => $Service::_botname,
	  "chan"  => $Service::_botchan,
	  "uid"    => $Service::_botuid,
	  "sockID" => $Service::_sockID
	};
	bless ($this, $class);
  	my $sql = mySQL::connect;
  	my $rq = $sql->prepare("TRUNCATE online;");
	$rq->execute();
	return $this;
};

sub create {
	my ( $this ) = @_;
	my $sql = mySQL::connect;
	my $sockID = $this->{sockID}; 
	# :000 UID Pseudo HopCount Timestamps User Host UID Servicestamp Usermodes Virtualhost Cloakedhost IpConvertieEnBase64 :Realname
	print $sockID ":$this->{sid} UID $this->{uid} ".time()." $this->{nick} $this->{host} $this->{host} $this->{user} $this->{addr} ".time()." +BSiosw +ABCKNOQcdfgklnoqtx :$this->{name}\r\n";	
	print $sockID ":$this->{uid} JOIN $this->{chan}\r\n";
	print $sockID ":$this->{sid} MODE $this->{chan} +oha $this->{nick} $this->{nick} $this->{nick}\r\n";
  	my $rq = $sql->prepare("SELECT chan FROM chanlist;");
	$rq->execute();
 	while ( my $data = $rq->fetchrow_hashref ) {
    	print $sockID ":$this->{uid} JOIN $data->{chan}\r\n";
  	}
  	&Core::refreshActions();
}

sub msg {
 my ( $this, $target, $message ) = @_;
 my $sockID = $this->{sockID};
 if($Service::_state) {print $sockID ":$this->{uid} PRIVMSG ".$target." :".$message."\r\n";}
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
 print $sockID ":$this->{nick} WHO ".$target."\r\n";
};

sub part {
 my ( $this, $target ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{uid} PART ".$target."\r\n";
};

sub svsnick {
 my ( $this, $target, $newnick ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{sid} SVSNICK ".$target." ".$newnick." :".time()."\r\n";
};

sub svsjoin {
 my ( $this, $target, $chan ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{sid} SVSJOIN ".$target." ".$chan."\r\n";
};

sub svspart {
 my ( $this, $target, $chan ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{sid} SVSPART ".$target." ".$chan."\r\n";
};

sub chgident {
 my ( $this, $target, $ident ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{sid} CHGIDENT ".$target." ".$ident."\r\n";
};

sub chgname {
 my ( $this, $target, $gecos ) = @_;
 my $sockID = $this->{sockID};
 print $sockID ":$this->{sid} CHGNAME ".$target." ".$gecos."\r\n";
};

1;