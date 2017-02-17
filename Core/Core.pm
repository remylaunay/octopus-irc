#!/usr/bin/perl
package Core;
use strict;
use Core::mySQL;

our $_version = "2016.12";

sub checkLevel {
 my ( $uid ) = @_;
 my $sql = mySQL::connect;
 my $level = $sql->selectrow_array("SELECT level FROM members WHERE current_uid = '".$uid."'");
 return $level;
};

sub addChan{
	my ( $chan ) = @_;
	my $sql = mySQL::connect;
	my $rq = $sql->prepare("INSERT INTO chanlist VALUES('','".$chan."')");
	$rq->execute();
}

sub delChan{
	my ( $chan ) = @_;
	my $sql = mySQL::connect;
	my $rq = $sql->prepare("DELETE FROM chanlist WHERE chan = '".$chan."'");
	$rq->execute();
}

sub checkChan {
 my ( $chan ) = @_;
 my $sql = mySQL::connect;
 my $vchan = $sql->selectrow_array("SELECT id FROM chanlist WHERE chan = '".$chan."'");
 return $vchan;
}

sub checkClose {
 my ( $chan ) = @_;
 my $sql = mySQL::connect;
 my $vchan = $sql->selectrow_array("SELECT COUNT(*) FROM closelist WHERE chan LIKE '".$chan."'");
 print "VCHAN $vchan\n";
 print "Q: SELECT COUNT(*) FROM closelist WHERE chan LIKE '$chan'\n";
 return $vchan;
}


sub addClose{
	my ( $chan, $reason ) = @_;
	my $sql = mySQL::connect;
	my $rq = $sql->prepare("INSERT INTO closelist VALUES('','".$chan."','".$reason."')");
	$rq->execute();
	# $_Octopus->join($chan);
	# $_Octopus->topic($chan,$reason);
}

sub delClose{
	my ( $chan ) = @_;
	my $sql = mySQL::connect;
	my $rq = $sql->prepare("DELETE FROM closelist WHERE chan = '".$chan."'");
	$rq->execute();
	# $_Octopus->part($chan);
}

sub setOnline{
	my ( $nick, $uid, $user, $host, $vhost, $real ) = @_;
	my $sql = mySQL::connect;
	my $rq = $sql->prepare("INSERT INTO online VALUES('','".$nick."','".$uid."','".$user."','".$host."','".$vhost."','".$real."','')");
	$rq->execute()
}

sub updateOnline{
	my ( $uid, $nick ) = @_;
	my $sql = mySQL::connect;
	my $rq = $sql->prepare("UPDATE online SET nick = '".$nick."' WHERE uid = '".$uid."'");
	$rq->execute()
}

sub setOffline{
	my ( $uid ) = @_;
	my $sql = mySQL::connect;
	my $rq = $sql->prepare("DELETE FROM online WHERE uid = '".$uid."'");
	$rq->execute()
}

sub setMemberUid{
	my ( $uid, $arg ) = @_;
	my $sql = mySQL::connect;
	my $rq = $sql->prepare("UPDATE members SET current_uid = '".$uid."' WHERE login = '".$arg."'");
	$rq->execute()
}

sub getNick{
	my ( $uid ) = @_;
	my $sql = mySQL::connect;
	my $nick = $sql->selectrow_array("SELECT nick FROM online WHERE uid = '".$uid."'");
 	return $nick;
}

sub getUid{
	my ( $nick ) = @_;
	my $sql = mySQL::connect;
	my $uid = $sql->selectrow_array("SELECT uid FROM online WHERE nick = '".$nick."'");
 	return $uid;
}

sub getLogin{
	my ( $uid ) = @_;
	my $sql = mySQL::connect;
	my $login = $sql->selectrow_array("SELECT login FROM members WHERE current_uid = '".$uid."'");
 	return $login;
}

sub checkNick {
 my ( $nick ) = @_;
 my $sql = mySQL::connect;
 my $vnick = $sql->selectrow_array("SELECT id FROM nicklist WHERE nick = '".$nick."'");
 return $vnick;
}

sub refreshActions{
	my ( $_Octopus ) = @_;
	my $sql = mySQL::connect;
	my $rq = $sql->prepare("SELECT * FROM actions;");
	$rq->execute();
 	while ( my $data = $rq->fetchrow_hashref ) {
    	my $action = $data->{action};
		my @args = split(/;;00xE;;/, $data->{args});
    	$_Octopus->$action(@args);
  	}
  	$rq = $sql->prepare("TRUNCATE actions;");
	$rq->execute();
}
1;

#PENSER A DECO LES INSTANCES SQL