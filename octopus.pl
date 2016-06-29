#!/usr/bin/perl


###############################
#NE PAS TOUCHER A CETTE PARTIE#
###############################

use strict;
use Service;

our %config;
our %link;
our %octopus;
our %mysql;

#######################################
#CONFIGURATION -> MODIFIEZ LES VALEURS#
#######################################

$config{"IRCD"} = "unreal4";

$link{"SERV"} = "octopus.khalia-dev.fr";
$link{"PASS"} = "**********";
$link{"ADDR"} = "**********";
$link{"PORT"} = "5530";
$link{"DESC"} = "Perl Devel";
$link{"SID"}  = "002";

$octopus{"NICK"} = "Octopus";
$octopus{"USER"} = "octopus";
$octopus{"HOST"} = "system.khalia-dev.fr";
$octopus{"NAME"} = "Perl Dev";
$octopus{"CHAN"} = "#Central";

$mysql{"HOST"} = "127.0.0.1";
$mysql{"LOGIN"} = "******";
$mysql{"PASS"} = "******";
$mysql{"PORT"} = "3306";
$mysql{"DB"} = "octopus";

###############################
#NE PAS TOUCHER A CETTE PARTIE#
###############################

	$SIG{HUP} = sub {
    	  print "got SIGHUP\n";
    	  delete $INC{"Octopus.pm"};
    	  delete $INC{"Service.pm"};
    	  require "Octopus.pm";
    	  require "Service.pm";
  	};

print "================ Octopus IRC Service ================\n";
print "\n";
print "- > Version : ".$Service::version."\n";
print "- > PID : ".$$."\n";
print "\n";
print "================ Octopus IRC Service ================\n\n";


Service::init($link{"SERV"},$link{"PASS"},$link{"ADDR"},$link{"PORT"},$link{"DESC"},$link{"SID"},$octopus{"NICK"},$octopus{"USER"},$octopus{"HOST"},$octopus{"NAME"},$octopus{"CHAN"},$mysql{"HOST"},,$mysql{"PORT"},$mysql{"LOGIN"},$mysql{"PASS"},$mysql{"DB"});
