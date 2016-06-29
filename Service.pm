#!/usr/bin/perl
package Service;
use strict;
use warnings;
use DBI;
use Switch;
use Digest::SHA1 qw(sha1_hex);
use IO::Socket;
use Octopus;


our $_version = "2016.06";
our %_isauth;
our %_reqbanlist;
our %_chost;
our ( $_botuid, $_serv, $_pass, $_addr, $_port, $_desc, $_sid, $_botnick, $_botuser, $_bothost, $_botname, $_botchan, $_sqlhost, $_sqlport, $_sqllogin, $_sqlpass, $_sqldb,  $_mySQL );

# Initialisation #
sub init{
	( $_serv, $_pass, $_addr, $_port, $_desc, $_sid, $_botnick, $_botuser, $_bothost, $_botname, $_botchan, $_sqlhost, $_sqlport, $_sqllogin, $_sqlpass, $_sqldb ) = @_;
	our $_ip = inet_ntoa(inet_aton($_addr));
	our $_state = 0;
	our $_eaddr = `ruby base64 $_ip`;
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
	our $_mySQL = DBI->connect("DBI:mysql:database=$_sqldb;host=$_sqlhost;port=$_sqlport", $_sqllogin, $_sqlpass);
	our $_Octopus = Octopus->config();

	print $_sockID "PASS :$_pass\r\n";
	print $_sockID "PROTOCTL EAUTH=$_serv SID=$_sid\r\n";
	print $_sockID "PROTOCTL NOQUIT NICKv2 SJOIN SJ3 CLK TKLEXT TKLEXT2 NICKIP ESVID MLOCK EXTSWHOIS\r\n";
	print $_sockID "SERVER $_serv 1 :$_desc\r\n";
	print $_sockID ":$_sid EOS\r\n";
	$_Octopus->create();

	while (my $event = <$_sockID>) {
  		  $SIG{USR1} = sub {
    	  print "got SIGUSR1\n";
    	  $_Octopus->refreshActions();
  		};
		print "DEBUG : ".$event;
		my @args = split(/ /, $event);
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
		        		my $ip = inet_ntoa(inet_aton($args[6]));
		        		$_isauth{$args[7]} = 0;
		        		my $realname = substr $args[13], 1;
		        		$_Octopus->setOnline($args[2],$args[7],$args[5],$args[11],$args[10],$realname);

		        }
		        case "NICK" {
		        		# :000AAAAA NICK <newnick> TIMESTAMP
		        		my $vuid = substr $args[0], 1;
		        		$_Octopus->getUid($args[2]) = $vuid;
		        		$_Octopus->getNick($vuid) = $args[2];
		        		$_chost{$_Octopus->getNick($vuid)} = $_chost{$vuid};
		        		$_Octopus->updateOnline($vuid,$args[2]);
		        }
		        case "CHGHOST" {
		        		# :nick CHGHOST <nick> <vhost>
		        		$_chost{$args[2]} = $args[3];
		        		$_chost{$_Octopus->$_Octopus->getUid($args[2])} = $args[3];
		        }
		        case "SETHOST" {
		        		# :nick SETHOST <vhost>
		        		my $nick = substr $args[0], 1;
		        		$_chost{$nick} = $args[2];
		        		$_chost{$_Octopus->getUid($nick)} = $args[2];
		        }		        		        
		        case "QUIT" {
		        		# :000AAAAA QUIT :Raison
		        		my $vuid = substr $args[0], 1;
						$_Octopus->setOffline($vuid);
						if($_isauth{$vuid}) {
		        			$_Octopus->setMemberUid("",$_Octopus->getLogin($vuid));
		        		}
		        }
		        case "SJOIN" {
		        		# :000 SJOIN TIMESTAMP #Canal :UID
		        		my $vuid = substr $args[4], -9;
		        	   	if($_Octopus->checkClose($args[3])){
						$_Octopus->join($args[3]);
		        		}
		        }                        
		        case "PART" {
		        		# :000AAAAA PART #Canal :Raison
		        		my $vuid = substr $args[0], 1;
		        }
		        case "PRIVMSG" {
		        	# :000AAAAA PRIVMSG Socket :Commande Arguments
		        	my ( $vuid, $cmd, $target, $args ) = split ( / /, $event, 4 );
		        	$args = substr $args, 1;
		        	$vuid = substr $vuid, 1;
		        	my $nick = $_Octopus->getNick($vuid);
		        	if($_state) {
		        		if(lc($target) eq lc($_botnick)) {
		        			&commands($_sockID,$_Octopus,$vuid,$nick,$args);
		        		}
		        	}
		        }
		        case "352" {
		        	if($_Octopus->checkClose($args[3])){
						my $reason = $_mySQL->selectrow_array("SELECT reason FROM closelist WHERE chan = '".$args[3]."'");
						$_Octopus->kick($args[3],$args[7],$reason);
		        	};
		        	my $login = $_mySQL->selectrow_array("SELECT COUNT(*) FROM members WHERE current_uid = '".$_Octopus->getUid($args[7])."'");
		        	if($login) {
		        		$_isauth{$_Octopus->getUid($args[7])}++;
		        	}
		        }
		        case "367" {
		        	$_Octopus->notice($_reqbanlist{$args[3]},$args[4]);
		        }
		        case "368" {
		        	$_Octopus->notice($_reqbanlist{$args[3]},"Fin de la liste");
		        	undef $_reqbanlist{$args[3]};
		        }
		    }
		}
	};

sub commands {
	my ($_sockID, $_Octopus, $uid, $nick, $args) = @_;
	my $vdata = $args;
	my ($command) = ($vdata =~ m/\b(\w+)\b/);
	$args=~ s/^\S+\s*//;
	print "\n";
	print "UID : $uid\n";
	print "COMMAND : $command\n";
	print "ARGS : $args\n";
   	switch(lc($command)) {
		case "help" {
	    	$_Octopus->notice($nick,"---------- 6Octopus IRC Service ----------");
	    	$_Octopus->notice($nick," ");
	    	$_Octopus->notice($nick,"3[Commandes3]");
	    	$_Octopus->notice($nick,"help - contact - version - auth");
	    	$_Octopus->notice($nick," ");
	    	if($_Octopus->checkLevel($uid) >= 1) {
		    	$_Octopus->notice($nick,"3[Canaux3]");
		    	$_Octopus->notice($nick,"mode - kick - ban - kickban - topic - banlist");
		    	$_Octopus->notice($nick," ");
	    	}
	    	if($_Octopus->checkLevel($uid) >= 2) {
		    	$_Octopus->notice($nick,"3[Serveur3]");
		    	$_Octopus->notice($nick,"kill - zline - gline - kline - glinelist");
		    	$_Octopus->notice($nick,"chanclose - delchanclose - klinelist - zlinelist");
		    	$_Octopus->notice($nick," ");
	    	}
	    	if($_Octopus->checkLevel($uid) >= 3) {	    	
		    	$_Octopus->notice($nick,"3[Sécurité3]");
		    	$_Octopus->notice($nick,"join - part - addchan - delchan");
		    	$_Octopus->notice($nick," ");
		    }
		   	if($_Octopus->checkLevel($uid) >= 4) {
		    	$_Octopus->notice($nick,"3[Gestion des accès3]");
		    	$_Octopus->notice($nick,"adduser - deluser - suspenduser");
		    	$_Octopus->notice($nick," ");
	    	}
	    	if($_Octopus->checkLevel($uid) >= 5) {
		    	$_Octopus->notice($nick,"3[Administration3]");
		    	$_Octopus->notice($nick,"join - part - addchan - delchan");
		    	$_Octopus->notice($nick," ");
		    }
			$_Octopus->notice($nick,"---------- 6Octopus IRC Service ----------");
		}
		case "version"{
			$_Octopus->notice($nick,"Octopus IRC Service - Version 2016.06 - Rémy Launay <remylaunay\@gmail.com> - http://www.khalia-dev.fr");
		}
		case "contact"{
			#Messagerie SQL user -> admin (Mémo?)
			$_Octopus->notice($nick,"Octopus IRC Service - Version 2016.06 - Rémy Launay <remylaunay\@gmail.com> - http://www.khalia-dev.fr");
		}
		case "mode" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($mode) || $mode eq "") {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} MODE <canal> <mode(s)>");return}
			print "MODEE -> ".$mode;
			$_Octopus->mode($target,$mode);
		}
		case "voice" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} VOICE <canal> <pseudo(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+v ".$nick);}
			$_Octopus->mode($target,"+vvvvvvvvv ".$nicks);
		}
		case "devoice" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} DEVOICE <canal> <pseudo(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"-v ".$nick);}
			$_Octopus->mode($target,"-vvvvvvvvvv ".$nicks);
		}		
		case "halfop" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} HALFOP <canal> <pseudo(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+h ".$nick);}
			$_Octopus->mode($target,"+hhhhhhhhhh ".$nicks);
		}		
		case "dehalfop" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} DEHALFOP <canal> <pseudo(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"-h ".$nick);}
			$_Octopus->mode($target,"-hhhhhhhhhh ".$nicks);
		}		
		case "op" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} OP <canal> <pseudo(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+o ".$nick);}
			$_Octopus->mode($target,"+oooooooooo ".$nicks);
		}		
		case "deop" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} DEOP <canal> <pseudo(s)>");return}
			$_Octopus->mode($target,"-oooooooooo ".$nicks);
			if($nicks eq "") {$_Octopus->mode($target,"-o ".$nick);}
		}		
		case "protect" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} PROTECT <canal> <pseudo(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+a ".$nick);}
			$_Octopus->mode($target,"+aaaaaaaaaa ".$nicks);
		}		
		case "deprotect" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} DEPROTECT <canal> <pseudo(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"-a ".$nick);}
			$_Octopus->mode($target,"-aaaaaaaaaa ".$nicks);
		}		
		case "owner" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} OWNER <canal> <pseudo(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+q ".$nick);}
			$_Octopus->mode($target,"+qqqqqqqqq ".$nicks);
		}		
		case "deowner" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} DEOWNER <canal> <pseudo(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"-q ".$nick);}
			$_Octopus->mode($target,"-qqqqqqqqq ".$nicks);
		}				
		case "ban" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s+(.+)!(.+)+@(.+)/);
			if(!defined($target) || !defined($mode)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} BAN <canal> <nick!user\@host>");return}
			$_Octopus->mode($target,"+b ".$mode);
		}
		case "unban" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s+(.+)!(.+)+@(.+)/);
			if(!defined($target) || !defined($mode)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} UNBAN <canal> <nick!user\@host>");return}
			$_Octopus->mode($target,"-b ".$mode);
		}
		case "kick" {								   
			my ($ctarget,$utarget,$reason) = ($args =~ /([#]\S+)\s+(\S+)\s*(.*)/);
			if(!defined($ctarget) || !defined($utarget)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} KICK <canal> <cible> (<raison>)");return}			
			$_Octopus->kick($ctarget,$utarget,$reason);
		}
		case "kickban" {								   
			my ($ctarget,$utarget,$reason) = ($args =~ /([#]\S+)\s+(\S+)\s*(.*)/);
			if(!defined($ctarget) || !defined($utarget)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} KICKBAN <canal> <cible> (<raison>)");return}			
			$_Octopus->kickban($ctarget,$utarget,$reason,$_chost{$utarget});
		}		
		case "banlist" {								   
			my ($target) = ($args =~ /([#]\S+)/);
			if(!defined($target)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} BANLIST <#canal>");return}			
			$_reqbanlist{$target} = $uid;
			$_Octopus->mode($target,"+b");	    				
		}			
		case "join" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} JOIN <#canal>");return}
	    	$_Octopus->join($args);
		}
		case "part" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} PART <#canal>");return}
	    	$_Octopus->part($args);
		}
		case "addchan" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} ADDCHAN <#canal>");return}
	    	$_Octopus->addChan($args);
	    	#$_Octopus->join($args);
		}
		case "delchan" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} DELCHAN <#canal>");return}
	    	$_Octopus->delChan($args);
	    	#$_Octopus->part($args);
		}
		case "chanclose" {
			my ($target,$reason) = ($args =~ /([#]\S+)\s*(.*)/);
	    	if(!defined($target)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} CHANCLOSE <#canal>");return}
	    	if($_Octopus->checkClose($target)){$_Octopus->notice($nick,"Erreur : ce salon est déjà dans liste noire");return}
	    	if($_Octopus->checkChan($target)){$_Octopus->notice($nick,"Erreur : ce salon est un salon enregistré");return}
	    	$_Octopus->addClose($target,$reason);
		}		
		case "say" {
			my ($target,$message) = ($args =~ /(\S+)\s*(.*)/);
			if(!defined($target) || !defined($message)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} SAY <canal> <message>");return}
			$_Octopus->msg($target,$message);
		}
		case "auth" {
			my ($login,$code) = ($args =~ /^(\S+)\s+(\S+)/);
			if(!defined($login) || !defined($code)) {$_Octopus->notice($nick,"Erreur de syntaxe : /msg $_Octopus->{nick} AUTH <identifiant> <code>");return}
			my $isuser = $_mySQL->selectrow_array("SELECT COUNT(*) FROM members WHERE login = '".$login."' AND code = '".sha1_hex($code)."'");
			if($_isauth{$uid}) {$_Octopus->notice($nick,"Erreur : vous êtes déjà identifié");return}
			if(!$isuser){
				$_Octopus->notice($nick,"Erreur : identifiant et/ou code incorrect(s)");
				$_Octopus->msg($_botchan,"AUTH : ".$nick." -> refusé");
				return;				
			} else {
				$_isauth{$uid} = 1;
				$_Octopus->setMemberUid($uid,$login);
				$_Octopus->notice($nick,"AUTH : identification réussie");
				$_Octopus->msg($_botchan,"AUTH : ".$nick." -> autorisé");				
			}
		}
		case "do" {
			my ($target,$message) = ($args =~ /(\S+)\s*(.*)/);
					  print $_sockID ":$_sid ".$message."\r\n";
		}		
		case "reload"{
		  
		  $_Octopus->notice($nick,"RELOAD : ".$nick." -> rechargement en cours...");	
		  $_Octopus->msg($_botchan,"RELOAD : ".$nick." -> rechargement en cours...");	
		  print $_sockID ":$_botuid WHO *\r\n";
		  sleep(1);
		  $_Octopus->msg($_botchan,"================ Octopus IRC Service ================");	
		  $_Octopus->msg($_botchan,"");
		  $_Octopus->msg($_botchan,"- > Redéfinition des fonctions");	
		  print "Reloading configuration...\n";
    	  delete $INC{"Octopus.pm"};
    	  delete $INC{"Service.pm"};
    	  require "Octopus.pm";
    	  require "Service.pm";
    	  $_isauth{$uid} = 0;
		  $_Octopus->msg($_botchan,"- > Redéfinition des utilisateurs");	
		  $_Octopus->msg($_botchan,"- > Version du service : ".$_version);	
		  $_Octopus->msg($_botchan,"");
		  sleep(1);
		  $_Octopus->msg($_botchan,"");
		  $_Octopus->msg($_botchan,"================ Octopus IRC Service ================");	
    	  $_Octopus->msg($_botchan,"RELOAD : ".$nick." -> rechargement terminé...");	
    	  $_Octopus->notice($nick,"RELOAD : ".$nick." -> rechargement terminé...");	
    	  print "Reload complete.\n";
		}
		else {
			$_Octopus->notice($nick,"Erreur : commande inconnue - Pour obtenir de l'aide, saisir : /msg $_Octopus->{nick} HELP");	
		}            
	}
};

	1;
