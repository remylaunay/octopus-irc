#!/usr/bin/perl


###############################
#NE PAS TOUCHER A CETTE PARTIE#
###############################

use strict;
use warnings;
use Switch;
use IO::Socket;
use Service;


our %link;
our %octopus;

#######################################
#CONFIGURATION -> MODIFIEZ LES VALEURS#
#######################################

$config{"IRCD"} = "unreal4";

$link{"SERV"} = "octopus.khalia-dev.fr";
$link{"PASS"} = "**********";
$link{"ADDR"} = "remylaunay.fr";
$link{"PORT"} = "5530";
$link{"DESC"} = "Perl Devel";
$link{"SID"}  = "002";

$octopus{"NICK"} = "Octopus";
$octopus{"USER"} = "octopus";
$octopus{"HOST"} = "system.khalia-dev.fr";
$octopus{"NAME"} = "Perl Dev";
$octopus{"CHAN"} = "#Central";

###############################
#NE PAS TOUCHER A CETTE PARTIE#
###############################

my $Service = Service->init($link{"SERV"},$link{"PASS"},$link{"ADDR"},$link{"PORT"},$link{"DESC"},$link{"SID"},$octopus{"NICK"},$octopus{"USER"},$octopus{"HOST"},$octopus{"NAME"},$octopus{"CHAN"});