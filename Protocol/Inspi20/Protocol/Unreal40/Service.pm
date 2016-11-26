#!/usr/bin/perl
package Service;
use strict;
use DBI;
use Switch;
use IO::Socket;
use threads;
use MIME::Base64;
use Core::Scan;
use Core::Reload;
use Core::Core;
use Core::mySQL;
use Protocol::Unreal40::Commands;
use Protocol::Unreal40::Bot;

our %_isauth;
our %_reqbanlist;
our %_countbanlist;
our %_chost;
our ( $_botuid, $_serv, $_pass, $_addr, $_port, $_desc, $_sid, $_botnick, $_botuser, $_bothost, $_botname, $_botchan, $_sqlhost, $_sqlport, $_sqllogin, $_sqlpass, $_sqldb,  $_mySQL );
our $_Octopus;
# Initialisation #

sub init{
	( $_serv, $_pass, $_addr, $_port, $_desc, $_sid, $_botnick, $_botuser, $_bothost, $_botname, $_botchan, $_sqlhost, $_sqlport, $_sqllogin, $_sqlpass, $_sqldb ) = @_;
	our $_ip = inet_ntoa(inet_aton($_addr));
	our $_state = 0;
	my @part = split(/\./, $_ip);
	my $res = pack("C*",@part);
	our $_eaddr = encode_base64($res);
	# Création de la socket, connexion au serveur distant #
	our $_sockID = IO::Socket::INET->new(proto => 'tcp',
	                                   PeerAddr => $_addr,
	                                   PeerPort => $_port,
	                                  ) or die "Erreur de connexion\r\n";

	
	my @_letters=('A'..'Z');
	my @_figures=('0'..'9');
	$_botuid .= $_letters[rand($#_letters)] for (1..4);
	$_botuid .= $_figures[rand($#_figures)] for (1..2);

	$_botuid = $_sid.$_botuid;
	$_mySQL = DBI->connect("DBI:mysql:database=$_sqldb;host=$_sqlhost;port=$_sqlport", $_sqllogin, $_sqlpass);
	$_Octopus = Bot->config();  
	my $thr0 = threads->new(\&Reload::init,$_Octopus);
 	$thr0->detach;
	print $_sockID "PASS :$_pass\r\n";
	print $_sockID "PROTOCTL EAUTH=$_serv SID=$_sid\r\n";
	print $_sockID "PROTOCTL NOQUIT NICKv2 SJOIN SJ3 CLK TKLEXT TKLEXT2 NICKIP ESVID MLOCK EXTSWHOIS\r\n";
	print $_sockID "SERVER $_serv 1 :$_desc\r\n";
	print $_sockID ":$_sid EOS\r\n";
	$_Octopus->create();

	while (my $event = <$_sockID>) {
		my @args = split(/ /, $event);
		print "DEBUG >> $event\n";
		switch($args[0]) {
		        case "PING" {
		                print $_sockID "PONG ".time()."\r\n";
		        }           
		        case "NETINFO" {
		        	$_state = 1;
		        }     		        
		}
		switch($args[1]) {                    
		        case "UID" {
		        		# :000 UID Pseudo HopCount Timestamps User Host UID Servicestamp Usermodes Virtualhost Cloakedhost IpConvertieEnBase64 :Realname
						my $nick = $args[2];
						my $ident = $args[5];
						my $host = $args[6];
						my $ip = inet_ntoa(inet_aton($args[6]));
						my $uid = $args[7];
						my $vhost = $args[10];
						my $chost = $args[11];
		        		my $realname = substr $args[13], 1;
		        		$_isauth{$uid} = 0;
		        		&Core::setOnline($nick,$uid,$ident,$vhost,$chost,$realname);
						&Scan::init($_Octopus,$uid,$nick,$ident,$realname,$ip,$host);
				}
		        case "NICK" {
		        		# :000AAAAA NICK <newnick> TIMESTAMP
		        		my $vuid = substr $args[0], 1;
		        		$_chost{&Core::getNick($vuid)} = $_chost{$vuid};
		        		$_Octopus->updateOnline($vuid,$args[2]);
		        }
		        case "CHGHOST" {
		        		# :nick CHGHOST <nick> <vhost>
		        		$_chost{$args[2]} = $args[3];
		        		$_chost{&Core::getUid($args[2])} = $args[3];
		        }
		        case "SETHOST" {
		        		# :nick SETHOST <vhost>
		        		my $nick = substr $args[0], 1;
		        		$_chost{$nick} = $args[2];
		        		$_chost{&Core::getUid($nick)} = $args[2];
		        }		        		        
		        case "QUIT" {
		        		# :000AAAAA QUIT :Raison
		        		my $vuid = substr $args[0], 1;
						&Core::setOffline($vuid);
						if($_isauth{$vuid}) {
		        			&Core::setMemberUid("",$_Octopus->getLogin($vuid));
		        		}
		        }
		        case "SJOIN" {
		        		# :000 SJOIN TIMESTAMP #channel :UID
		        		my $vuid = substr $args[4], -9;
		        	   	if(&Core::checkClose($args[3])){
						$_Octopus->join($args[3]);
		        		}
		        }                        
		        case "PART" {
		        		# :000AAAAA PART #channel :Raison
		        		my $vuid = substr $args[0], 1;
		        }
		        case "PRIVMSG" {
		        	# :000AAAAA PRIVMSG Socket :Commande Arguments
		        	my ( $vuid, $cmd, $target, $args ) = split ( / /, $event, 4 );
		        	$args = substr $args, 1;
		        	$vuid = substr $vuid, 1;
		        	my $nick = &Core::getNick($vuid);
		        	if($_state) {
		        		if(lc($target) eq lc($_botnick)) {
		        			&Commands::commands($_sockID,$_Octopus,$vuid,$nick,$args);
		        		}
		        	}
		        }
		        case "352" {
		        	if(&Core::checkClose($args[3])){
						my $reason = $_mySQL->selectrow_array("SELECT reason FROM closelist WHERE chan = '".$args[3]."'");
						$_Octopus->kick($args[3],$args[7],$reason);
		        	};
		        	my $login = $_mySQL->selectrow_array("SELECT COUNT(*) FROM members WHERE current_uid = '".&Core::getUid($args[7])."'");
		        	if($login) {
		        		$_isauth{&Core::getUid($args[7])}++;
		        	}
		        }
		        case "367" {
		        	if(!defined($_countbanlist{$args[3]})) {$_countbanlist{$args[3]} = 0;};
		        	$_Octopus->notice($Commands::_reqbanlist{$args[3]},$args[4]);
		        	$_countbanlist{$args[3]}++;
		        }
		        case "368" {
		        	if($_countbanlist{$args[3]}<1){$_Octopus->notice($Commands::_reqbanlist{$args[3]},"no records");}
		        	$_Octopus->notice($Commands::_reqbanlist{$args[3]},"\002End of list\002");
		        	undef $_countbanlist{$args[3]};
		        	undef $_reqbanlist{$args[3]};
		        }
		    }
		}
	};



	1;