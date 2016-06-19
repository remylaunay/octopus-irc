#!/usr/bin/perl
package Service;
use strict;
use warnings;
use DBI;
use Switch;
use Digest::SHA1 qw(sha1_hex);
use IO::Socket;
use Octopus;

my %uid;
my %nickname;
my %isauth;
my %level;

# Initialisation #
sub init{
	my ( $class, $serv, $pass, $addr, $port, $desc, $sid, $nick, $user, $host, $name, $chan ) = @_;
	$class = ref($class) || $class;
	my $this = {
		"serv"    => $serv,
		"pass"    => $pass,
		"addr" => $addr,
		"port"    => $port,
		"desc"    => $desc,
		"sid"  => $sid,
		"nick"    => $nick,
		"user" => $user,
		"host"    => $host,
		"name"    => $name,
		"chan"  => $chan,
		"uid"    => $sid."AAAA01",	 	  
		"mySQL" => DBI->connect("DBI:mysql:database=octopus", "***", "***")
	};
	
	bless ($this, $class);

	our $state = 0;
	# Création de la socket, connexion au serveur distant #
	our $sockID = IO::Socket::INET->new(proto => 'tcp',
	                                   PeerAddr => $this->{addr},
	                                   PeerPort => $this->{port},
	                                  ) or die "Erreur de connexion\r\n";

	our $Octopus = Octopus->config($this->{sid},$this->{nick},$this->{user},$this->{host},$this->{name},$this->{chan},$this->{uid},$sockID);

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
		        		$uid{$args[2]} = $args[7];
						#Le pseudo de 000AAAAA est Machin
		        		$nickname{$args[7]} = $args[2];
		        		#L'utilisateur vient de se connecter, on déclare qu'il n'est pas identifié au service
		        		$isauth{$args[7]} = 0;
		        		if($state) {$Octopus->msg($this->{chan},"Connection : ".$nickname{$args[7]}." (".$ip.")\r\n");}
		        }
		        case "NICK" {
		        		# :000AAAAA NICK <newnick> TIMESTAMP
		        		my $vuid = substr $args[0], 1;
		        		#Transformer en $Octopus-setnick ? $Octopus->setuid?
		        		$uid{$args[2]} = $vuid;
		        		$nickname{$vuid} = $args[2];		        		
		        		if($state) {$Octopus->msg($this->{chan},"Nick change : ".$nickname{$vuid}." -> ".$args[2]."\r\n");}
		        }
		        case "QUIT" {
		        		# :000AAAAA QUIT :Raison
		        		my $uid = substr $args[0], 1;
		        		if($state) {$Octopus->msg($this->{chan},"Deconnection : ".$nickname{$uid}."\r\n");}
						if($isauth{$uid}) {
		        			$Octopus->setUid("",$Octopus->getLogin($uid));
		        		}
		        }
		        case "SJOIN" {
		        		# :000 SJOIN TIMESTAMP #Canal :UID
		        		my $uid = substr $args[4], 1;
		        		if($state) {$Octopus->msg($this->{chan},"Join : ".$nickname{$uid}." -> ".$args[3]."\r\n");}
		        }                        
		        case "PART" {
		        		# :000AAAAA PART #Canal :Raison
		        		my $uid = substr $args[0], 1;
		        		if($state) {$Octopus->msg($this->{chan},"Leave : ".$nickname{$uid}." -> ".$args[2]."\r\n");}
		        }
		        case "PRIVMSG" {
		        	# :000AAAAA PRIVMSG Socket :Commande Arguments
		        	my ( $uid, $cmd, $target, $args ) = split ( / /, $event, 4 );
		        	$args = substr $args, 1;
		        	$uid = substr $uid, 1;
		        	my $nick = $nickname{$uid};
		        	if($state) {
		        		if($target eq $this->{nick}) {
		        			&commands($this,$Octopus,$uid,$nick,$args);
		        		}
		        	}
		        }    
			}
		}
	};

sub commands {
	my ($this, $Octopus, $uid, $nick, $args) = @_;
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
		    	$Octopus->notice($nick,"mode - kick - ban - kickban - topic");
		    	$Octopus->notice($nick," ");
	    	}
	    	if($Octopus->checkLevel($uid) >= 2) {
		    	$Octopus->notice($nick,"3[Serveur3]");
		    	$Octopus->notice($nick,"shun - kill - zline - gline - kline - glinelist");
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
			if(!defined($target) || !defined($mode)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{$nick} MODE <canal> <mode(s)>");return}
			$Octopus->mode($target,$mode);
		}
		case "ban" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s+(.+)!(.+)+@(.+)/);
			if(!defined($target) || !defined($mode)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{$nick} BAN <canal> <nick!user\@host>");return}
			$Octopus->mode($target,"+b ".$mode);
		}
		case "unban" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s+(.+)!(.+)+@(.+)/);
			if(!defined($target) || !defined($mode)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{$nick} UNBAN <canal> <nick!user\@host>");return}
			$Octopus->mode($target,"-b ".$mode);
		}
		case "kick" {								   
			my ($ctarget,$utarget,$reason) = ($args =~ /([#]\S+)\s+(\S+)\s*(.*)/);
			if(!defined($ctarget) || !defined($utarget)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{$nick} KICK <canal> <cible> (<raison>)");return}			
			$Octopus->kick($ctarget,$utarget,$reason);
		}
		case "join" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{$nick} JOIN #<canal>");return}
	    	$Octopus->join($args);
		}
		case "part" {
			my ($target) = ($args =~ /([#])(\S+)/);
	    	if(!defined($target)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{$nick} PART #<canal>");return}
	    	$Octopus->part($args);
		}
		case "say" {
			my ($target,$message) = ($args =~ /(\S+)\s*(.*)/);
			if(!defined($target) || !defined($message)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{$nick} SAY <canal> <message>");return}
			$Octopus->msg($target,$message);
		}
		case "auth" {
			my ($login,$code) = ($args =~ /^(\S+)\s+(\S+)/);
			if(!defined($login) || !defined($code)) {$Octopus->notice($nick,"Erreur de syntaxe : /msg $this->{$nick} AUTH <identifiant> <code>");return}
			my $isuser = $this->{mySQL}->selectrow_array("SELECT COUNT(*) FROM members WHERE login = '".$login."' AND code = '".sha1_hex($code)."'");
			if($isauth{$uid}) {$Octopus->notice($nick,"Erreur : vous êtes déjà identifié");return}
			if(!$isuser){
				$Octopus->notice($nick,"Erreur : identifiant et/ou code incorrect(s)");
				$Octopus->msg($this->{chan},"AUTH : ".$nick." -> refusé");
				return;				
			} else {
				$isauth{$uid} = 1;
				$Octopus->setUid($uid,$login);
				$Octopus->notice($nick,"AUTH : identification réussie");
				$Octopus->msg($this->{chan},"AUTH : ".$nick." -> autorisé");				
			}
		}
		else {
			$Octopus->notice($nick,"Erreur : commande inconnue - Pour obtenir de l'aide, saisir : /msg $this->{$nick} HELP");	
		}            
	}
};

	1;