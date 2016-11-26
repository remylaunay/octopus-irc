package Commands;

use Digest::SHA1 qw(sha1_hex);
use Switch;

sub commands {
	my ($_sockID, $_Octopus, $uid, $nick, $args) = @_;
	my $vdata = $args;
	my ($command) = ($vdata =~ m/\b(\w+)\b/);
	$args=~ s/^\S+\s*//;
	print "\n";
	print "UID : $uid\n";
	print "NICK : $nick\n";
	print "COMMAND : $command\n";
	print "ARGS : $args\n";
   	switch(lc($command)) {
		case "help" {
	    	$_Octopus->notice($nick,"\002---------- \0036Octopus IRC Service (Unreal)\003 ----------\002");
	    	$_Octopus->notice($nick," ");
	    	$_Octopus->notice($nick,"\002\0033[\003Commands\0033]\002\003");
	    	$_Octopus->notice($nick,"help - contact - version - auth");
	    	$_Octopus->notice($nick," ");
	    	if(Core::checkLevel($uid) >= 1) {
		    	$_Octopus->notice($nick,"\002\0033[\003Channels\0033]\002\003");
		    	$_Octopus->notice($nick,"mode - kick - ban - kickban - topic - banlist");
		    	$_Octopus->notice($nick," ");
	    	}
	    	if(Core::checkLevel($uid) >= 2) {
		    	$_Octopus->notice($nick,"\002\0033[\003Server\0033]\002\003");
		    	$_Octopus->notice($nick,"kill - zline - gline - kline - glinelist");
		    	$_Octopus->notice($nick,"chanclose - delchanclose - klinelist - zlinelist");
		    	$_Octopus->notice($nick," ");
	    	}
	    	if(Core::checkLevel($uid) >= 3) {	    	
		    	$_Octopus->notice($nick,"\002\0033[\003Security\0033]\002\003");
		    	$_Octopus->notice($nick,"addblacklist - delblacklist");
		    	$_Octopus->notice($nick," ");
		    }
		   	if(Core::checkLevel($uid) >= 4) {
		    	$_Octopus->notice($nick,"\002\0033[\003Access\0033]\002\003");
		    	$_Octopus->notice($nick,"adduser - deluser - suspenduser");
		    	$_Octopus->notice($nick," ");
	    	}
	    	if(Core::checkLevel($uid) >= 5) {
		    	$_Octopus->notice($nick,"\002\0033[\003Administration\0033]\002\003");
		    	$_Octopus->notice($nick,"join - part - addchan - delchan");
		    	$_Octopus->notice($nick," ");
		    }
			$_Octopus->notice($nick,"\002---------- \0036Octopus IRC Service\003 ----------\002");
			$_Octopus->msg($_Octopus->{chan},"\002HELP :\002 ".$nick);
		}
		case "version"{
			$_Octopus->notice($nick,"Octopus IRC Service - Version ".$Service::_version." - Diogene <remylaunay\@gmail.com> - http://www.khalia-dev.fr");
			$_Octopus->msg($_Octopus->{chan},"\002VERSION :\002 ".$nick);
		}
		case "contact"{
			#Messagerie SQL user -> admin (Mémo?)
			$_Octopus->notice($nick,"Octopus IRC Service - Version ".$_version."  - Diogene <remylaunay\@gmail.com> - http://www.khalia-dev.fr");
			$_Octopus->msg($_Octopus->{chan},"\002CONTACT :\002 ".$nick);
		}
		case "mode" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002MODE : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($mode) || $mode eq "") {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} MODE <channel> <mode(s)>");return}			
			$_Octopus->mode($target,$mode);
			$_Octopus->msg($_Octopus->{chan},"\002MODE :\002 ".$nick);
		}
		case "voice" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002VOICE : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} VOICE <channel> <nickname(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+v ".$nick);}
			$_Octopus->mode($target,"+vvvvvvvvv ".$nicks);
			$_Octopus->msg($_Octopus->{chan},"\002VOICE :\002 ".$nick);
		}
		case "devoice" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002DEVOICE : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} DEVOICE <channel> <nickname(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"-v ".$nick);}
			$_Octopus->mode($target,"-vvvvvvvvvv ".$nicks);
			$_Octopus->msg($_Octopus->{chan},"\002DEVOICE :\002 ".$nick);
		}		
		case "halfop" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002HALFOP : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} HALFOP <channel> <nickname(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+h ".$nick);}
			$_Octopus->mode($target,"+hhhhhhhhhh ".$nicks);
			$_Octopus->msg($_Octopus->{chan},"\002HALFOP :\002 ".$nick);
		}		
		case "dehalfop" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002DEHALFOP : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} DEHALFOP <channel> <nickname(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"-h ".$nick);}
			$_Octopus->mode($target,"-hhhhhhhhhh ".$nicks);
			$_Octopus->msg($_Octopus->{chan},"\002DEHALFOP :\002 ".$nick);
		}		
		case "op" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002OP : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} OP <channel> <nickname(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+o ".$nick);}
			$_Octopus->mode($target,"+oooooooooo ".$nicks);
			$_Octopus->msg($_Octopus->{chan},"\002OP :\002 ".$nick);
		}		
		case "deop" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002DEOP : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} DEOP <channel> <nickname(s)>");return}
			$_Octopus->mode($target,"-oooooooooo ".$nicks);
			if($nicks eq "") {$_Octopus->mode($target,"-o ".$nick);}
			$_Octopus->msg($_Octopus->{chan},"\002DEOP :\002 ".$nick);
		}		
		case "protect" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002PROTECT : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} PROTECT <channel> <nickname(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+a ".$nick);}
			$_Octopus->mode($target,"+aaaaaaaaaa ".$nicks);
			$_Octopus->msg($_Octopus->{chan},"\002PROTECT :\002 ".$nick);
		}		
		case "deprotect" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002DEPROTECT : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} DEPROTECT <channel> <nickname(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"-a ".$nick);}
			$_Octopus->mode($target,"-aaaaaaaaaa ".$nicks);
			$_Octopus->msg($_Octopus->{chan},"\002DEPROTECT :\002 ".$nick);
		}		
		case "owner" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002OWNER : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} OWNER <channel> <nickname(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"+q ".$nick);}
			$_Octopus->mode($target,"+qqqqqqqqq ".$nicks);
			$_Octopus->msg($_Octopus->{chan},"\002OWNER :\002 ".$nick);
		}		
		case "deowner" {
			my ($target,$nicks) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002DEOWNER : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($nicks)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} DEOWNER <channel> <nickname(s)>");return}
			if($nicks eq "") {$_Octopus->mode($target,"-q ".$nick);}
			$_Octopus->mode($target,"-qqqqqqqqq ".$nicks);
			$_Octopus->msg($_Octopus->{chan},"\002DEOWNER :\002 ".$nick);
		}				
		case "ban" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s+(.+)!(.+)+@(.+)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002BAN : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($mode)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} BAN <channel> <nick!user\@host>");return}
			$_Octopus->mode($target,"+b ".$mode);
			$_Octopus->msg($_Octopus->{chan},"\002BAN :\002 ".$nick);
		}
		case "unban" {
			my ($target,$mode) = ($args =~ /([#]\S+)\s+(.+)!(.+)+@(.+)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002UNBAN : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($mode)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} UNBAN <channel> <nick!user\@host>");return}
			$_Octopus->mode($target,"-b ".$mode);
			$_Octopus->msg($_Octopus->{chan},"\002UNBAN :\002 ".$nick);
		}
		case "kick" {								   
			my ($ctarget,$utarget,$reason) = ($args =~ /([#]\S+)\s+(\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002KICK : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($ctarget) || !defined($utarget)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} KICK <channel> <target> (<reason>)");return}			
			$_Octopus->kick($ctarget,$utarget,$reason);
			$_Octopus->msg($_Octopus->{chan},"\002KICK :\002 ".$nick);
		}
		case "kickban" {								   
			my ($ctarget,$utarget,$reason) = ($args =~ /([#]\S+)\s+(\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002KICKBAN : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($ctarget) || !defined($utarget)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} KICKBAN <channel> <target> (<reason>)");return}			
			$_Octopus->kickban($ctarget,$utarget,$reason,$_chost{$utarget});
			$_Octopus->msg($_Octopus->{chan},"\002KICKBAN :\002 ".$nick);
		}		
		case "banlist" {								   
			my ($target) = ($args =~ /([#]\S+)/);
			if(Core::checkLevel($uid) < 1) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002BANLIST : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} BANLIST <#channel>");return}			
			$_reqbanlist{$target} = $uid;			
			$_Octopus->notice($nick,"\002Channel : $target\002");		
			$_Octopus->mode($target,"+b");	    	
			$_Octopus->msg($_Octopus->{chan},"\002BANLIST :\002 ".$nick);			
		}			
		case "join" {
			my ($target) = ($args =~ /([#])(\S+)/);
			if(Core::checkLevel($uid) < 5) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002JOIN : \002\0034".$nick."\0031 -> denied");return}
	    	if(!defined($target)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} JOIN <#channel>");return}
	    	$_Octopus->join($args);
	    	$_Octopus->msg($_Octopus->{chan},"\002JOIN :\002 ".$nick);
		}
		case "part" {
			my ($target) = ($args =~ /([#])(\S+)/);
			if(Core::checkLevel($uid) < 5) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002PART : \002\0034".$nick."\0031 -> denied");return}
	    	if(!defined($target)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} PART <#channel>");return}
	    	$_Octopus->part($args);
	    	$_Octopus->msg($_Octopus->{chan},"\002PART :\002 ".$nick);
		}
		case "addchan" {
			my ($target) = ($args =~ /([#])(\S+)/);
			if(Core::checkLevel($uid) < 5) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002ADDCHAN : \002\0034".$nick."\0031 -> denied");return}
	    	if(!defined($target)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} ADDCHAN <#channel>");return}
	    	Core::addChan($args);
	    	$_Octopus->join($target);
	    	$_Octopus->msg($_Octopus->{chan},"\002ADDCHAN :\002 ".$nick);
		}
		case "delchan" {
			my ($target) = ($args =~ /([#])(\S+)/);
			if(Core::checkLevel($uid) < 5) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002DELCHAN : \002\0034".$nick."\0031 -> denied");return}
	    	if(!defined($target)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} DELCHAN <#channel>");return}
	    	Core::delChan($args);
	    	$_Octopus->part($target);
	    	$_Octopus->msg($_Octopus->{chan},"\002DELCHAN :\002 ".$nick);
		}
		case "chanclose" {
			my ($target,$reason) = ($args =~ /([#]\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 2) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002CHANCLOSE : \002\0034".$nick."\0031 -> denied");return}
	    	if(!defined($target)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} CHANCLOSE <#channel>");return}
	    	if(Core::checkClose($target)){$_Octopus->notice($nick,"Error : this channel is already closed");return}
	    	if(Core::checkChan($target)){$_Octopus->notice($nick,"Error : this channel is a registered channel");return}
	    	$_Octopus->addClose($target,$reason);
	    	$_Octopus->msg($_Octopus->{chan},"\002CHANCLOSE :\002 ".$nick);
		}		
		case "say" {
			my ($target,$message) = ($args =~ /(\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 3) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002SAY : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target) || !defined($message)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} SAY <channel> <message>");return}
			$_Octopus->msg($target,$message);
			$_Octopus->msg($_Octopus->{chan},"\002SAY :\002 ".$nick);
		}
		case "kill" {								   
			my ($target,$reason) = ($args =~ /(\S+)\s*(.*)/);
			if(Core::checkLevel($uid) < 3) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002KILL : \002\0034".$nick."\0031 -> denied");return}
			if(!defined($target)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} KILL <target> (<reason>)");return}			
			$_Octopus->kill($target,$reason);
			$_Octopus->msg($_Octopus->{chan},"\002KILL :\002 ".$nick);
		}
		case "svsnick" {
			my ($target,$newnick) = ($args =~ /^(\S+)\s+(\S+)/);;
			if(Core::checkLevel($uid) < 5) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002SVSNICK : \002\0034".$nick."\0031 -> denied");return}
	    	if(!defined($target) || !defined($newnick)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} SVSNICK <nick> <newnick>");return}
	    	$_Octopus->svsnick($target,$newnick);
	    	$_Octopus->msg($_Octopus->{chan},"\002SVSNICK :\002 ".$nick);
		}		
		case "svsjoin" {
			my ($chan,$target) = ($args =~ /^([#]\S+)\s+(\S+)/);
			if(Core::checkLevel($uid) < 5) {$_Octopus->notice($nick,"Error : you didn't have the required access");return}
	    	if(!defined($chan) || !defined($target)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} SVSJOIN <#channel> <nick>");$_Octopus->msg($_Octopus->{chan},"SVSJOIN : \002\0034".$nick."\0031 -> denied");return}
	    	$_Octopus->svsjoin($target,$chan);
	    	$_Octopus->msg($_Octopus->{chan},"\002SVSJOIN :\002 ".$nick);
		}		
		case "svspart" {
			my ($chan,$target) = ($args =~ /^([#]\S+)\s+(\S+)/);
			if(Core::checkLevel($uid) < 5) {$_Octopus->notice($nick,"Error : you didn't have the required access");$_Octopus->msg($_Octopus->{chan},"\002SVSPART : \002\0034".$nick."\0031 -> denied");return}
	    	if(!defined($chan) || !defined($target)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} SVSPART <#channel> <nick>");return}
	    	$_Octopus->svspart($target,$chan);
	    	$_Octopus->msg($_Octopus->{chan},"\002SVSPART :\002 ".$nick);
		}		
		case "auth" {
			my ($login,$code) = ($args =~ /^(\S+)\s+(\S+)/);
			$sql = mySQL::connect;
			if(!defined($login) || !defined($code)) {$_Octopus->notice($nick,"Syntax : /msg $_Octopus->{nick} AUTH <login> <password>");return}
			my $isuser = $sql->selectrow_array("SELECT COUNT(*) FROM members WHERE login = '".$login."' AND code = '".sha1_hex($code)."'");
			if($_isauth{$uid}) {$_Octopus->notice($nick,"Error : you're already identified");return}
			if(!$isuser){
				$_Octopus->notice($nick,"\002Error :\002 \0034bad credentials");
				$_Octopus->msg($_Octopus->{chan},"\002AUTH : \002\0034".$nick."\0031 -> denied");
				return;				
			} else {
				$_isauth{$uid} = 1;
				Core::setMemberUid($uid,$login);
				$_Octopus->notice($nick,"\002AUTH :\002 \0033granted");
				$_Octopus->msg($_Octopus->{chan},"\002AUTH : \002 \0033".$nick."\0031 -> granted");
			}
		}	
		case "reload"{
		  if(Core::checkLevel($uid) < 5) {$_Octopus->notice($nick,"Error : you didn't have the required access");return}
		  $_Octopus->notice($nick,"RELOAD : ".$nick." -> reloading...");	
		  $_Octopus->msg($_Octopus->{chan},"RELOAD : ".$nick." -> reloading...");	
		  $_Octopus->msg($_Octopus->{chan},"================ Octopus IRC Service ================");	
		  $_Octopus->msg($_Octopus->{chan},"");
		  $_Octopus->msg($_Octopus->{chan},"- > Reloading functions...");	
		  print "Reloading configuration...\n";
		  delete $INC{"Core/Core.pm"};
		  delete $INC{"Core/Reload.pm"};
		  delete $INC{"Core/Scan.pm"};
		  delete $INC{"Core/mySQL.pm"};
		  delete $INC{"Protocol/Unreal40/Bot.pm"};
		  delete $INC{"Protocol/Unreal40/Commands.pm"};
		  delete $INC{"Protocol/Unreal40/Service.pm"};
		  require "Core/Core.pm";
		  require "Core/Reload.pm";
		  require "Core/Scan.pm";
		  require "Core/mySQL.pm";
		  require "Protocol/Unreal40/Bot.pm";
		  require "Protocol/Unreal40/Commands.pm";
		  require "Protocol/Unreal40/Service.pm";	  
		  $_Octopus->msg($_Octopus->{chan},"- > Reloading users...");	
		  $_Octopus->msg($_Octopus->{chan},"- > Service's version : ".$Core::_version);	
		  $_Octopus->msg($_Octopus->{chan},"");
		  $_Octopus->msg($_Octopus->{chan},"");
		  $_Octopus->msg($_Octopus->{chan},"================ Octopus IRC Service ================");	
    	  $_Octopus->msg($_Octopus->{chan},"RELOAD : ".$nick." -> reload complete...");	
    	  $_Octopus->notice($nick,"RELOAD : ".$nick." -> Reload complete...");	
    	  print "Reload complete.\n";
		}
		else {
			$_Octopus->notice($nick,"This command doesn't exist :: To list commands, type : /msg $_Octopus->{nick} HELP");	
		}            
	}
};

1;