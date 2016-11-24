#!/usr/bin/perl
package Reload;
use strict;
use IO::Async::Timer::Periodic;
use IO::Async::Loop;
use mySQL;

sub init{
	my ( $_Octopus ) = @_; 
	my $_mySQL = mySQL::connect;
	my $loop = IO::Async::Loop->new;
	my $ac_timer = IO::Async::Timer::Periodic->new(
	    interval => 3,

	    on_tick => sub {
			my $rq = $_mySQL->prepare("SELECT * FROM actions;");
			$rq->execute();
		 	while ( my $data = $rq->fetchrow_hashref ) {
		    	my $action = $data->{action};
				my @args = split(/;;00xE;;/, $data->{args});
		    	$_Octopus->$action(@args);
		  	}
		  	$rq = $_mySQL->prepare("TRUNCATE actions;");
			$rq->execute();	       
	    },
	 );

  	 my $bl_timer = IO::Async::Timer::Periodic->new(
	    interval => 14400,

	    on_tick => sub {
	    	system "sh updateDb.sh &";
	    },
	 );
	 
	 $bl_timer->start;
	 $ac_timer->start;
	 $loop->add( $ac_timer );
	 $loop->add( $bl_timer );
	 $loop->run;	 
}


1;
