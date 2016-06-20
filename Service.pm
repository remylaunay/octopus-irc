#!/usr/bin/perl
package Service;
use strict;
use warnings;
use DBI;
use Switch;
use Digest::SHA1 qw(sha1_hex);
use IO::Socket;
use Octopus;


our $version = "2016.06";
our $build = "201715";
our %isauth;
our %level;
our %reqbanlist;
our %chost;


# Initialisation #
sub init{
	my ( $class, $serv, $pass, $addr, $port, $desc, $sid, $nick, $user, $host, $name, $chan ) = @_;
	$class = ref($class) || $class;
	my $ip = inet_ntoa(inet_aton($addr));
	my $this = {
		"serv"    => $serv,
		"pass"    => $pass,
		"addr" => $addr,
		"eaddr" => `ruby base64 $ip`,
		"port"    => $port,
		"desc"    => $desc,
		"sid"  => $sid,
		"nick"    => $nick,
		"user" => $user,
		"host"    => $host,
		"name"    => $name,
		"chan"  => $chan,
		"uid"    => $sid."AAAA01",	 	  
		"mySQL" => DBI->connect("DBI:mysql:database=octopus", "*****", "**********")
	};
	
	bless ($this, $class);

	our $state = 0;
	# Création de la socket, connexion au serveur distant #
	our $sockID = IO::Socket::INET->new(proto => 'tcp',
	                                   PeerAddr => $this->{addr},
	                                   PeerPort => $this->{port},
	                                  ) or die "Erreur de connexion\r\n";

	our $Octopus = Octopus->config($this->{sid},$this->{nick},$this->{user},$this->{host},$this->{name},$this->{chan},$this->{uid},$this->{eaddr},$sockID);

	# Procédure de Link #
	print $sockID "PASS :$this->{pass}\r\n";
	print $sockID "PROTOCTL EAUTH=octopus.khalia-dev.fr SID=$this->{sid}\r\n";
	print $sockID "PROTOCTL NOQUIT NICKv2 SJOIN SJ3 CLK TKLEXT TKLEXT2 NICKIP ESVID MLOCK EXTSWHOIS\r\n";
	print $sockID "SERVER $this->{serv} 1 :$this->{desc}\r\n";
	#EOS -> Fin de la synchronisation
	print $sockID ":$this->{sid} EOS\r\n";
	$Octopus->create();
	
	# Traitement des évènements #
	while (my $event = <$sockID>) {
  		  $SIG{USR1} = sub {
    	  print "got SIGUSR1\n";
  		};
		print "DEBUG : ".$event;
		my @args = split(/ /, $event);
		switch($args[0]) {
		        case "PING" {
		                print $sockID "PONG ".time()."\r\n";
		        }
		        case "NETINFO" {
		                $state = 1;
		        }                          
		}
		switch($args[1]) {                    
		        case "UID" {
		        		# :000 UID Pseudo HopCount Timestamps User Host UID Servicestamp Usermodes Virtualhost Cloakedhost IpConvertieEnBase64 :Realname
		        		# On retrouve l'adresse IP de l'utilisateur (parfois, seul le nom d'hôte est communiqué)
		        		my $ip = inet_ntoa(inet_aton($args[6]));
		        		#L'UID de Machin est 000AAAAA
		        		#$Octopus->$Octopus->getUid($args[2]) = $args[7];
		        		#
						#Le pseudo de 000AAAAA est Machin
		        		#$Octopus->getNick{$args[7]} = $args[2];
		        		#$chost{$args[7]} = $args[11];	
		        		#$chost{$args[2]} = $args[11];
		        		#L'utilisateur vient de se connecter, on déclare qu'il n'est pas identifié au service
		        		$isauth{$args[7]} = 0;
		        		my $realname = substr $args[13], 1;
		        		$Octopus->setOnline($args[2],$args[7],$args[5],$args[11],$args[10],$realname);
		        		if($state) {$Octopus->msg($this->{chan},"Connection : ".$Octopus->getNick($args[7])." (".$ip.")\r\n");}

		        }
		        case "NICK" {
		        		# :000AAAAA NICK <newnick> TIMESTAMP
		        		my $vuid = substr $args[0], 1;
		        		#Transformer en $Octopus-setnick ? $Octopus->setuid?
		        		if($state) {$Octopus->msg($this->{chan},"Nick change : ".$Octopus->getNick($vuid)." -> ".$args[2]."\r\n");}
		        		$Octopus->$Octopus->getUid($args[2]) = $vuid;
		        		$Octopus->getNick($vuid) = $args[2];
		        		$chost{$Octopus->getNick($vuid)} = $chost{$vuid};
		        		$Octopus->updateOnline($vuid,$args[2]);
		        }
		        case "CHGHOST" {
		        		# :nick CHGHOST <nick> <vhost>
		        		$chost{$args[2]} = $args[3];
		        		$chost{$Octopus->$Octopus->getUid($args[2])} = $args[3];
		        }
		        case "SETHOST" {
		        		# :nick SETHOST <vhost>
		        		my $nick = substr $args[0], 1;
		        		$chost{$nick} = $args[2];
		        		$chost{$Octopus->getUid($nick)} = $args[2];
		        }		        		        
		        case "QUIT" {
		        		# :000AAAAA QUIT :Raison
		        		my $vuid = substr $args[0], 1;
		        		if($state) {$Octopus->msg($this->{chan},"Deconnection : ".$Octopus->getNick($vuid)."\r\n");}
						$Octopus->setOffline($vuid);
						if($isauth{$vuid}) {
		        			$Octopus->setMemberUid("",$Octopus->getLogin($vuid));
		        		}
		        }
		        case "SJOIN" {
		        		# :000 SJOIN TIMESTAMP #Canal :UID
		        		my $vuid = substr $args[4], -9;
		        	   	if($Octopus->checkClose($args[3])){
						$Octopus->join($args[3]);
		        		}
		        		if($state) {$Octopus->msg($this->{chan},"Join : ".$Octopus->getNick($vuid)." -> ".$args[3]."\r\n");}
		        }                        
		        case "PART" {
		        		# :000AAAAA PART #Canal :Raison
		        		my $vuid = substr $args[0], 1;
		        		if($state) {$Octopus->msg($this->{chan},"Leave : ".$Octopus->getNick($vuid)." -> ".$args[2]."\r\n");}
		        }
		        case "PRIVMSG" {
		        	# :000AAAAA PRIVMSG Socket :Commande Arguments
		        	my ( $vuid, $cmd, $target, $args ) = split ( / /, $event, 4 );
		        	$args = substr $args, 1;
		        	$vuid = substr $vuid, 1;
		        	my $nick = $Octopus->getNick($vuid);
		        	print "MYNICK -> $nick";
		        	if($state) {
		        		if(lc($target) eq lc($this->{nick})) {
		        			&commands($this,$sockID,$Octopus,$vuid,$nick,$args);
		        		}
		        	}
		        }
		        case "352" {
		        	if($Octopus->checkClose($args[3])){
						my $reason = $this->{mySQL}->selectrow_array("SELECT reason FROM closelist WHERE chan = '".$args[3]."'");
						$Octopus->kick($args[3],$args[7],$reason);
		        	};
		        	print "\n UIDD -> ".$Octopus->getUid($args[7]);
		        	my $login = $this->{mySQL}->selectrow_array("SELECT COUNT(*) FROM members WHERE current_uid = '".$Octopus->getUid($args[7])."'");
		        	print "LOGIN : ".$login;
		        	if($login) {
		        		$isauth{$Octopus->getUid($args[7])}++;
		        		print "\n ISAUTH OK -->".$Octopus->getUid($args[7])
		        	;}
		        }
		        case "367" {
		        	$Octopus->notice($reqbanlist{$args[3]},$args[4]);
		        }
		        case "368" {
		        	$Octopus->notice($reqbanlist{$args[3]},"Fin de la liste");
		        	undef $reqbanlist{$args[3]};
		        }
		    }
		}
	};
sub commands {
	my ($this, $sockID, $Octopus, $uid, $nick, $args) = @_;
	my $vdata = $args;
	my ($command) = ($vdata =~ m/\b(\w+)\b/);
	$args=~ s/^\S+\s*//;
	print "\n";
	print "UID : $uid\n";
	print "COMMAND : $command\n";
	print "ARGS : $args\n";
   	switch(lc($command)) {
		case "help" {
	    	$Octopus->notice($nick,"---------- 6Octopus IRC Service ----------");
	    	$Octopus->notice($nick," ");
	    	$Octopus->notice($nick,"3[Commandes3]");
	    	$Octopus->notice($nick,"help - contact - version - auth");
	    	$Octopus->notice($nick," ");
	    	if($Octopus->checkLevel($uid) >= 1) {
		    	$Octopus->notice($nick,"3[Canaux3]");
		    	$Octopus->notice($nick,"mode - kick - ban - kickban - topic - banlist");
		    	$Octopus->notice($nick," ");
	    	}
	    	if($Octopus->checkLevel($uid) >= 2) {
		    	$Octopus->notice($nick,"3[Serveur3]");
		    	$Octopus->notice($nick,"kill - zline - gline - kline - glinelist");
		    	$Octopus->notice($nick,"chanclose - delchanclose - klinelist - zlinelist");
		    	$Octopus->notice($nick," ");
	    	}
	    	if($Octopus->checkLevel($uid) >= 3) {	    	
		    	$Octopus->notice($nick,"3[Sécurité3]");
		    	$Octopus->notice($nick,"join - part - addchan - delchan");
		    	$Octopus->notice($nick," ");
		    }
		   	if($Octopus->checkLevel($uid) >= 4) {
		    	$Octopus->notice($nick,"3[Gestion des accès3]");
		    	$Octopus->notice($nick,"adduser - deluser - suspenduser");
		    	$Octopus->notice($nick," ");
	    	}
	    	if($Octopus->checkLevel($uid) >= 5) {
		    	$Octopus->notice($nick,"3[Administration3]");
		    	$Octopus->notice($nick,"join - part - addchan - delchan");
		    	$Octopus->notice($nick," ");
		    }
			$Octopus->notice($nick,"---------- 6Octopus IRC Service ----------");
		}
		case "version"{
			$Octopus->notice($nick,"Octopus IRC Service - Version 2016.06 - Rémy Launay <remylaunay\@gmail.com> - http://www.khalia-dev.fr");
		}
		case "contact"{
			#Messagerie SQL user -> admin (Mémo?)
			$Octopus->notice($nick,"Octopus IRC Service - Version 2016.06 - Rémy Launay <remylaunay\@gmail.com> - http://www.khalia-dev.fr");
		}
		case "mode" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($mode) || $mode eq "") {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} MODE <canal> <mode(s)>");return}
			print "MODEE -> ".$mode;
			$Octopus->mode($target,$mode);
		}
		case "voice" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} VOICE <canal> <pseudo(s)>");return}
			if($nicks eq "") {$Octopus->mode($target,"+v ".$nick);}
			$Octopus->mode($target,"+vvvvvvvvv ".$nicks);
		}
		case "devoice" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} DEVOICE <canal> <pseudo(s)>");return}
			if($nicks eq "") {$Octopus->mode($target,"-v ".$nick);}
			$Octopus->mode($target,"-vvvvvvvvvv ".$nicks);
		}		
		case "halfop" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} HALFOP <canal> <pseudo(s)>");return}
			if($nicks eq "") {$Octopus->mode($target,"+h ".$nick);}
			$Octopus->mode($target,"+hhhhhhhhhh ".$nicks);
		}		
		case "dehalfop" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} DEHALFOP <canal> <pseudo(s)>");return}
			if($nicks eq "") {$Octopus->mode($target,"-h ".$nick);}
			$Octopus->mode($target,"-hhhhhhhhhh ".$nicks);
		}		
		case "op" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} OP <canal> <pseudo(s)>");return}
			if($nicks eq "") {$Octopus->mode($target,"+o ".$nick);}
			$Octopus->mode($target,"+oooooooooo ".$nicks);
		}		
		case "deop" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} DEOP <canal> <pseudo(s)>");return}
			$Octopus->mode($target,"-oooooooooo ".$nicks);
			if($nicks eq "") {$Octopus->mode($target,"-o ".$nick);}
		}		
		case "protect" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} PROTECT <canal> <pseudo(s)>");return}
			if($nicks eq "") {$Octopus->mode($target,"+a ".$nick);}
			$Octopus->mode($target,"+aaaaaaaaaa ".$nicks);
		}		
		case "deprotect" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} DEPROTECT <canal> <pseudo(s)>");return}
			if($nicks eq "") {$Octopus->mode($target,"-a ".$nick);}
			$Octopus->mode($target,"-aaaaaaaaaa ".$nicks);
		}		
		case "owner" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} OWNER <canal> <pseudo(s)>");return}
			if($nicks eq "") {$Octopus->mode($target,"+q ".$nick);}
			$Octopus->mode($target,"+qqqqqqqqq ".$nicks);
		}		
		case "deowner" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(!defined($target) || !defined($nicks)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} DEOWNER <canal> <pseudo(s)>");return}
			if($nicks eq "") {$Octopus->mode($target,"-q ".$nick);}
			$Octopus->mode($target,"-qqqqqqqqq ".$nicks);
		}				
		case "ban" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s+(.+)!(.+)+@(.+)/);
			if(!defined($target) || !defined($mode)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} BAN <canal> <nick!user\@host>");return}
			$Octopus->mode($target,"+b ".$mode);
		}
		case "unban" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s+(.+)!(.+)+@(.+)/);
			if(!defined($target) || !defined($mode)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} UNBAN <canal> <nick!user\@host>");return}
			$Octopus->mode($target,"-b ".$mode);
		}
		case "kick" {								   
			my ($ctarget,$utarget,$reason) = ($args =~ /([#]\S+)\s+(\S+)\s*(.*)/);
			if(!defined($ctarget) || !defined($utarget)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} KICK <canal> <cible> (<raison>)");return}			
			$Octopus->kick($ctarget,$utarget,$reason);
		}
		case "kickban" {								   
			my ($ctarget,$utarget,$reason) = ($args =~ /([#]\S+)\s+(\S+)\s*(.*)/);
			if(!defined($ctarget) || !defined($utarget)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} KICKBAN <canal> <cible> (<raison>)");return}			
			$Octopus->kickban($ctarget,$utarget,$reason,$chost{$utarget});
		}		
		case "banlist" {								   
			my ($target) = ($args =~ /([#]\S+)/);
			if(!defined($target)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} BANLIST <#canal>");return}			
			$reqbanlist{$target} = $uid;
			$Octopus->mode($target,"+b");	    				
		}			
		case "join" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} JOIN <#canal>");return}
	    	$Octopus->join($args);
		}
		case "part" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} PART <#canal>");return}
	    	$Octopus->part($args);
		}
		case "addchan" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} ADDCHAN <#canal>");return}
	    	$Octopus->addChan($target);
	    	$Octopus->join($target);
		}
		case "delchan" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} DELCHAN <#canal>");return}
	    	$Octopus->delChan($target);
	    	$Octopus->part($target);
		}
		case "chanclose" {
			my ($target,$reason) = ($args =~ /([#]\S+)\s*(.*)/);
	    	if(!defined($target)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} CHANCLOSE <#canal>");return}
	    	if($Octopus->checkClose($target)){$Octopus->notice($nick,"Erreur : ce salon est déjà dans liste noire");return}
	    	if($Octopus->checkChan($target)){$Octopus->notice($nick,"Erreur : ce salon est un salon enregistré");return}
	    	$Octopus->addClose($target,$reason);
	    	$Octopus->join($target);
	    	$Octopus->topic($target,$reason);
		}		
		case "say" {
			my ($target,$message) = ($args =~ /(\S+)\s*(.*)/);
			if(!defined($target) || !defined($message)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} SAY <canal> <message>");return}
			$Octopus->msg($target,$message);
		}
		case "auth" {
			my ($login,$code) = ($args =~ /^(\S+)\s+(\S+)/);
			if(!defined($login) || !defined($code)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{nick} AUTH <identifiant> <code>");return}
			my $isuser = $this->{mySQL}->selectrow_array("SELECT COUNT(*) FROM members WHERE login = '".$login."' AND code = '".sha1_hex($code)."'");
			if($isauth{$uid}) {$Octopus->notice($nick,"Erreur : vous êtes déjà identifié");return}
			if(!$isuser){
				$Octopus->notice($nick,"Erreur : identifiant et/ou code incorrect(s)");
				$Octopus->msg($this->{chan},"AUTH : ".$nick." -> refusé");
				return;				
			} else {
				$isauth{$uid} = 1;
				$Octopus->setMemberUid($uid,$login);
				$Octopus->notice($nick,"AUTH : identification réussie");
				$Octopus->msg($this->{chan},"AUTH : ".$nick." -> autorisé");				
			}
		}
		case "do" {
			my ($target,$message) = ($args =~ /(\S+)\s*(.*)/);
					  print $sockID ":$this->{sid} ".$message."\r\n";
		}		
		case "reload"{
		  
		  $Octopus->notice($nick,"RELOAD : ".$nick." -> rechargement en cours...");	
		  $Octopus->msg($this->{chan},"RELOAD : ".$nick." -> rechargement en cours...");	
		  print $sockID ":$this->{uid} WHO *\r\n";
		  sleep(1);
		  $Octopus->msg($this->{chan},"================ Octopus IRC Service ================");	
		  $Octopus->msg($this->{chan},"");
		  $Octopus->msg($this->{chan},"- > Redéfinition des fonctions");	
		  print "Reloading configuration...\n";
    	  delete $INC{"Octopus.pm"};
    	  delete $INC{"Service.pm"};
    	  require "Octopus.pm";
    	  require "Service.pm";
    	  $isauth{$uid} = 0;
		  $Octopus->msg($this->{chan},"- > Redéfinition des utilisateurs");	
		  $Octopus->msg($this->{chan},"- > Version du service : ".$version);	
		  $Octopus->msg($this->{chan},"- > Build du service : ".$build);	
		  $Octopus->msg($this->{chan},"");
		  sleep(1);
		  $Octopus->msg($this->{chan},"");
		  $Octopus->msg($this->{chan},"================ Octopus IRC Service ================");	
    	  $Octopus->msg($this->{chan},"RELOAD : ".$nick." -> rechargement terminé...");	
    	  $Octopus->notice($nick,"RELOAD : ".$nick." -> rechargement terminé...");	
    	  print "Reload complete.\n";
		}
		else {
			$Octopus->notice($nick,"Erreur : commande inconnue - Pour obtenir de l'aide, saisir : /msg $this->{nick} HELP");	
		}            
	}
};

	1;
