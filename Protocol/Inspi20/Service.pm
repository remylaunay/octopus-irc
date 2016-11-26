#!/usr/bin/perl
package Service;
use strict;
use DBI;
use Switch;
use IO::Socket;
use threads;


use Core::Scan;
use Core::Reload;
use Core::Core;
use Core::mySQL;
use Protocol::Inspi20::Commands;
use Protocol::Inspi20::Bot;

our %_isauth;
our %_reqbanlist;
our %_chost;
our ( $_botuid, $_serv, $_pass, $_addr, $_port, $_desc, $_sid, $_botnick, $_botuser, $_bothost, $_botname, $_botchan, $_sqlhost, $_sqlport, $_sqllogin, $_sqlpass, $_sqldb,  $_mySQL );
our $_Octopus;
# Initialisation #

sub init{
	( $_serv, $_pass, $_addr, $_port, $_desc, $_sid, $_botnick, $_botuser, $_bothost, $_botname, $_botchan, $_sqlhost, $_sqlport, $_sqllogin, $_sqlpass, $_sqldb ) = @_;
	our $_ip = inet_ntoa(inet_aton($_addr));
	our $_state = 0;
	our $_eaddr = `ruby src/base64 $_ip`;
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
	# SERVER services-dev.chatspike.net password 0 666 :Description here
	print $_sockID "CAPAB START 1202\r\n";
	print $_sockID "CAPAB CAPABILITIES PROTOCOL=1201\r\n";
  	print $_sockID "CAPAB END\r\n";
	print $_sockID "SERVER $_serv $_pass 0 $_sid :$_desc\r\n";
	print $_sockID ":$_sid BURST\r\n";
	print $_sockID ":$_sid VERSION :Octopus IRC Service ($Core::_version)\r\n";
	$_Octopus->create();
	print $_sockID ":$_sid ENDBURST\r\n";
	while (my $event = <$_sockID>) {
		my @args = split(/ /, $event);
		print "DEBUG >> $event\n";
		if($args[1] =~ "ENDBURST"){$_state = 1;}
		switch($args[1]) {
				case "PING" {
					print "PING ? PONG !\r\n";
					print $_sockID ":$_sid PONG $_sid ".$args[2]."\r\n";
				}
				# case "ENDBURST" {
				# 	print "READY kk\r\n";
				# 	# $_state = 1;
				# }
		        case "UID" {
		        		# :000 UID Pseudo HopCount Timestamps User Host UID Servicestamp Usermodes Virtualhost Cloakedhost IpConvertieEnBase64 :Realname
						my $nick = $args[4];
						my $ident = $args[7];
						my $host = $args[5];
						my $ip = $args[8];
						my $uid = $args[2];
						my $vhost = $args[6];
						my $chost = $args[6];
		        		my $realname = substr $args[12], 1;
		        		$_chost{&Core::getNick($uid)} = $chost;
		        		$_isauth{$uid} = 0;
		        		&Core::setOnline($nick,$uid,$ident,$vhost,$chost,$realname);
						&Scan::init($_Octopus,$uid,$nick,$ident,$realname,$ip,$host);
				}
		        case "NICK" {
		        		# :000AAAAA NICK <newnick> TIMESTAMP
		        		my $vuid = substr $args[0], 1;
		        		$_chost{&Core::getNick($vuid)} = $_chost{$vuid};
		        		&Core::updateOnline($vuid,$args[2]);
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
		        case "FJOIN" {
		        		# :000 SJOIN TIMESTAMP #channel :UID
		        		my $vuid = substr $args[5], -12;
		        		print "VUID : $vuid";
		        		my $vtarget = Core::getNick($vuid);
		        		print "VNICK : $vtarget";
		        	   	if(&Core::checkClose($args[2])){
							$_Octopus->join($args[2]);
        					$_Octopus->kick($args[2],$vuid,"Closed channel !");	
		        		}
		        }                        
		        case "PART" {
		        		# :000AAAAA PART #channel :Raison
		        		my $vuid = substr $args[0], 1;
		        }
		        case "FMODE" {
		        		#:21D FMODE #Central 1480131480 +bb *!d@ f!*@*
		        		my ($sid, $command, $target, $time, $mode, @vargs) = @args;
		        		if($mode =~ "b"){
		        			our %bans;
		        			my $ban;
		        			if($mode =~ /^\+/){		        				
			        			foreach $ban (@vargs){
			        			 	push @{ $bans{$target} }, $ban;
			        			}		
		        			} else {
					   			my $tban;
					   			my $index = 0;
					   			my $unban;
					   			my %vbans;
					   			my %valid;
					   			$vbans{$target} = $bans{$target};
					   			undef $bans{$target};
					   			foreach $unban (@vargs){
									foreach $tban ( @{ $vbans{$target} } ) {
										$valid{$index} = 1;
									 	if($unban =~ /^\Q$tban/i) {
									 		$valid{$index} = 0;
									 	}
									 	if($valid{$index}){push @{ $bans{$target} }, $tban}
									 	$index++;    
									}
								}
								undef %vbans;
		        			}
		        		}
		        } 
		        case "PRIVMSG" {
		        	# :000AAAAA PRIVMSG Socket :Commande Arguments
		        	my ( $vuid, $cmd, $target, $args ) = split ( / /, $event, 4 );
		        	$args = substr $args, 1;
		        	$vuid = substr $vuid, 1;
		        	my $nick = &Core::getNick($vuid);
		        	if($_state) {
		        		if($target =~ $_botuid) {
		        			print "GOT MSG\n";
		        			&Commands::commands($_sockID,$_Octopus,$vuid,$nick,$args);
		        		}
		        	}
		        }
		    }
		}
	};



	1;