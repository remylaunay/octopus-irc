#!/usr/bin/perl

use strict;

require "configuration.pl";

our %config;
our %link;
our %octopus;
our %mysql;

if($link{IRCD} =~ "unreal40") {
	require 'Protocol/Unreal40/Service.pm';
	Service::init($link{SERV},$link{PASS},$link{ADDR},$link{PORT},$link{DESC},$link{SID},$octopus{NICK},$octopus{USER},$octopus{HOST},$octopus{NAME},$octopus{CHAN},$mysql{HOST},$mysql{PORT},$mysql{LOGIN},$mysql{PASS},$mysql{DB});
	#Definir IRCD dans SQL
} elsif($link{IRCD} =~ "insp20") { 
	require 'Protocol/Inspi20/Service.pm';
	Service::init($link{SERV},$link{PASS},$link{ADDR},$link{PORT},$link{DESC},$link{SID},$octopus{NICK},$octopus{USER},$octopus{HOST},$octopus{NAME},$octopus{CHAN},$mysql{HOST},$mysql{PORT},$mysql{LOGIN},$mysql{PASS},$mysql{DB});
	#Definir IRCD dans SQL
} else {
	print "ERROR : wrong IRC daemon in configuration\n";
}

	$SIG{'HUP'} = sub {
		  $Unreal::_Octopus->msg($Unreal::_botchan,"RELOAD : SHELL -> reloading...");
		  $Unreal::_Octopus->msg($Unreal::_botchan,"================ Octopus IRC Service ================");	
		  $Unreal::_Octopus->msg($Unreal::_botchan,"");
		  $Unreal::_Octopus->msg($Unreal::_botchan,"- > Reloading functions...");	
		  delete $INC{"Core/Core.pm"};
		  delete $INC{"Core/Reload.pm"};
		  delete $INC{"Core/Scan.pm"};
		  delete $INC{"Core/mySQL.pm"};
		  delete $INC{"Protocol/Inspi20/Bot.pm"};
		  delete $INC{"Protocol/Inspi20/Commands.pm"};
		  delete $INC{"Protocol/Inspi20/Service.pm"};
		  delete $INC{"Core/Core.pm"};
		  require "Core/Reload.pm";
		  require "Core/Scan.pm";
		  require "Core/mySQL.pm";
		  require "Protocol/Inspi20/Bot.pm";
		  require "Protocol/Inspi20/Commands.pm";
		  require "Protocol/Inspi20/Service.pm";		  
		  $Unreal::_Octopus->msg($Unreal::_botchan,"- > Reloading users...");	
		  $Unreal::_Octopus->msg($Unreal::_botchan,"- > Service's version : ".$Core::_version);	
		  $Unreal::_Octopus->msg($Unreal::_botchan,"");
		  sleep(1);
		  $Unreal::_Octopus->msg($Unreal::_botchan,"");
		  $Unreal::_Octopus->msg($Unreal::_botchan,"================ Octopus IRC Service ================");	
    	  $Unreal::_Octopus->msg($Unreal::_botchan,"RELOAD : SHELL -> reload complete...");	
    	  print "Reload complete.\n";
	};		
