#!/usr/bin/perl


###############################
#NE PAS TOUCHER A CETTE PARTIE#
###############################

use strict;
use Service;
use Reload;
use threads;
our %config;
our %link;
our %octopus;
our %mysql;

#######################################
#CONFIGURATION -> MODIFIEZ LES VALEURS#
#######################################

$config{"IRCD"} = "unreal4";

$link{"SERV"} = "remylaunay.fr";
$link{"PASS"} = "*";
$link{"ADDR"} = "x.x.x.x";
$link{"PORT"} = "5530";
$link{"DESC"} = "Perl Devel";
$link{"SID"}  = "015";

$octopus{"NICK"} = "Octopus";
$octopus{"USER"} = "octopus";
$octopus{"HOST"} = "system.khalia-dev.fr";
$octopus{"NAME"} = "Perl Dev";
$octopus{"CHAN"} = "#Central";

$mysql{"HOST"} = "remylaunay.fr";
$mysql{"LOGIN"} = "remylaunay";
$mysql{"PASS"} = "*";
$mysql{"PORT"} = "3306";
$mysql{"DB"} = "octopus";

###############################
#NE PAS TOUCHER A CETTE PARTIE#
###############################


Service::init($link{"SERV"},$link{"PASS"},$link{"ADDR"},$link{"PORT"},$link{"DESC"},$link{"SID"},$octopus{"NICK"},$octopus{"USER"},$octopus{"HOST"},$octopus{"NAME"},$octopus{"CHAN"},$mysql{"HOST"},$mysql{"PORT"},$mysql{"LOGIN"},$mysql{"PASS"},$mysql{"DB"});


