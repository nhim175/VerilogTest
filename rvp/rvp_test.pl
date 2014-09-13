#!/usr/bin/perl -w -I ..
###############################################################################
#
# File:         rvp_test.pl
# RCS:          $Header: /home/cc/v2html/rvp_scripts/RCS/rvp_test.pl,v 1.6 2006/01/09 20:51:23 cc Exp $
# Description:  Test RVP functions not used by v2html
# Author:       Costas Calamvokis
# Created:      Fri May  1 06:53:02 1998
# Modified:     Mon Jan  9 20:51:16 2006
# Language:     Perl
#
# Copyright (c) 1998-2006 Costas Calamvokis, all rights reserved.
#
###############################################################################

require rvp;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);
use Term::ANSIColor qw(:constants);

@files            = @ARGV;
%cmd_line_defines = ();
$quiet            = 1;
@inc_dirs         = ();
@lib_dirs         = ();
@lib_exts         = ();
$production 			= 1;
$debug 						= 1;

$vdb = rvp->read_verilog(\@files,[],\%cmd_line_defines,
			  $quiet,\@inc_dirs,\@lib_dirs,\@lib_exts);
my @problems = $vdb->get_problems();
print "Problems:\n";
if (@problems) {
    foreach my $problem ($vdb->get_problems()) {
	print "$problem.\n";
    }
    # die "Warnings parsing files!";
}

# parse parameter into correct value
# parameters: signal string, module contain signal
sub parse_parameter {
	my ($signal,$module) = @_;
	unless (looks_like_number($signal)) {
		my (%parameters) = $vdb->get_modules_parameters($module);
		foreach my $p (keys %parameters) {
			$signal =~ s/$p/$parameters{$p}/g;
		}
		my @range = split(/:([^:]+)$/, $signal);
		$signal = "$range[0]-$range[1]+1";
		$signal = eval($signal);
	}
	return $signal;
}

sub print_warning {
	my ($str) = @_;
	if ($production == 1) {
		print "<span class='warning'>Warning: $str</span><br/>";
	} else {
		print BOLD, YELLOW, "-----Warning: $str!\n", RESET;
	}
}

sub print_error {
	my ($str) = @_;
	if ($production == 1) {
		print "<span class='error'>Error: $str</span><br/>";
	} else {
		print BOLD, RED, "-----Error: $str!\n", RESET;
	}
}

sub print_title {
	my ($str) = @_;
	if ($production == 1) {
		print "<span class='title'>$str</span><br/><br/>";
	} else {
		print BOLD, "$str!\n\n", RESET;
	}	
}

sub log {
	my ($str) = @_;
	if ($debug == 1) {
		print "$str";
	}
}

foreach $module (sort $vdb->get_modules()) {
    &print_title("Module $module");

    %parameters = $vdb->get_modules_parameters($module);
    foreach my $p (sort keys %parameters) {
	my $v = $parameters{$p};
	$v =~ s/[ \n]//gs;
	unless (looks_like_number($v)) {
		foreach my $p (keys %parameters) {
			$v =~ s/$p/$parameters{$p}/g;
		}
		$v = eval($v);
	}
	&log("   parameter: $p defaults to \"$v\"\n");
    }


    foreach $sig (sort $vdb->get_modules_signals($module)) {
	($line,$a_line,$i_line,$type,$file,$posedge,$negedge,
	 $type2,$s_file,$s_line,$range,$a_file,$i_file,$dims, $width) = 
	   $vdb->get_module_signal($module,$sig);

	&log ("   signal: $sig $type $type2 |$range|\n");
  # Error: Input declared as reg
	if(($type eq "input") && ($type2 eq "reg")) {
		&print_error("Input signal $sig has been declared as reg ($file:$line)");
	}
  # Warning: Declared as integer
  if($type2 eq "integer") {
    &print_warning("Signal $sig has been declared as integer ($file:$line)");
  }
  # Error: Variable has more than one definition
  if(($type =~ m/input|output|inout/) && ($type2 =~ m/input|output|inout/)) {
    &print_error("Signal $sig has more than one definition ($file:$line)");
  }
	&log ("      defined  $file:$line\n");
	&log ("      assigned $a_file:$a_line\n");
	&log ("      source   $s_file:$s_line\n");
	&log ("      input    $i_file:$i_line\n");
	&log ("      edges: $posedge,$negedge\n");
	$width = &parse_parameter($width, $module);
	&log ("      width: $width\n");
	foreach $dim (@$dims) {
	    &log ("        dimension: $dim\n");
	}


	for (($imod,$iname,$port,$l, $f) = 
	     $vdb->get_first_signal_port_con($module,$sig );
	     $imod;
	     ($imod,$iname,$port,$l, $f) = 
	     $vdb->get_next_signal_port_con()) {
			my ($s_line,$s_a_line,$s_i_line,$s_type,$s_file,$s_p,$s_n, $s_type2,$s_r_file,$s_r_line,$range,$s_a_file,$s_i_file, $s_dimension, $s_width) = $vdb->get_module_signal($imod,$port);
			$s_width = &parse_parameter($s_width, $imod);
	    &log ("     connected to: port $port (width: $s_width) of instance $iname of $imod\n");

	    # Check if port width mismatch
	    if ($width != $s_width) {
	    	&print_warning("Signal $sig (width: $width) connected to: port $port (width: $s_width) of instance $iname of $imod ($l:$f)");
	    }
	}
    }

    print "\n";
    for (($imod,$f,$iname,$l) = $vdb->get_first_instantiation($module );
	 $imod;
         ($imod,$f,$iname,$l) = $vdb->get_next_instantiation()) {

	&log ("     instance: $iname of $imod\n");
	%port_con = $vdb->get_current_instantiations_port_con();
	foreach $port (sort keys %port_con) {
	    my $p = $port_con{$port};
	    $p =~ s/[ \n]//gs;
	    &log ("        $port connected to \"$p\"\n");
	}


	%parameters = $vdb->get_current_instantiations_parameters();
	foreach my $p (sort keys %parameters) {
	    my $v = $parameters{$p};
	    $v =~ s/[ \n]//gs;
	    &log ("        parameter $p set to to \"$v\"\n");
	}


    }
    print "\n";

}

