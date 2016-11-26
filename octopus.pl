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
		  print "Reloading configuration...\n";
		  delete $INC{"Service.pm"};
		  require "Service.pm";
		  delete $INC{"Octopus.pm"};
    	  require "Octopus.pm";
    	  delete $INC{"Scan.pm"};
    	  require "Scan.pm";    	  
		  $Unreal::_Octopus->msg($Unreal::_botchan,"- > Reloading users...");	
		  $Unreal::_Octopus->msg($Unreal::_botchan,"- > Service's version : ".$Service::_version);	
		  $Unreal::_Octopus->msg($Unreal::_botchan,"");
		  sleep(1);
		  $Unreal::_Octopus->msg($Unreal::_botchan,"");
		  $Unreal::_Octopus->msg($Unreal::_botchan,"================ Octopus IRC Service ================");	
    	  $Unreal::_Octopus->msg($Unreal::_botchan,"RELOAD : SHELL -> reload complete...");	
    	  print "Reload complete.\n";
	};		
