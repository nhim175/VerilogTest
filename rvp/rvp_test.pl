#!/usr/bin/perl -w -I ..

require "./rvp.pm";
use Data::Dumper;
use Scalar::Util qw(looks_like_number);
use Term::ANSIColor qw(:constants);
use constant false => 0;
use constant true  => 1;

@files            = @ARGV;
%cmd_line_defines = ();
$quiet            = 1;
@inc_dirs         = ();
@lib_dirs         = ();
@lib_exts         = ();
$production 	= 1;
$debug 		= 0;

print "<div class='hidden'>";
$vdb = rvp->read_verilog(\@files,[],\%cmd_line_defines,
			  $quiet,\@inc_dirs,\@lib_dirs,\@lib_exts);
print "</div>";
my @problems = $vdb->get_problems();
print "Problems:\n";
if (@problems) {
    foreach my $problem ($vdb->get_problems()) {
	print "$problem.\n";
    }
    # die "Warnings parsing files!";
}


sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s };
sub rtrim { my $s = shift; $s =~ s/\s+$//;       return $s };
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

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

sub get_width_from_range {
  my ($range,$module) = @_;
  if ($range =~ m/([^:]+?):([^:]+?)/) {
    my $left = $1;
    my $right = $2;
    my ($left_val, $right_val);
    if(looks_like_number($left)) {
      $left_val = eval($left);
    } else {
      $left_val = &parse_parameter($left,$module);
    }

    if(looks_like_number($right)) {
      $right_val = eval($right);
    } else {
      $right_val = &parse_parameter($right,$module);
    }

    return $left_val + 1 - $right_val;
  }
  return -1;
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

sub count_string_in_file {
  # return line number
  my ($str, $file) = @_;
  my ($file_path) = $vdb->get_files_full_name($file);
  my ($in_comment_block) = false;
  my $count = 0;
  if (length $file_path == 0) {
    return -1;
  }
  my $fh;
  open $fh, "<", $file_path or die "could not open $file: $!";
  while(<$fh>) {
    if(/\/\*/) { $in_comment_block = true; }
    if(/\*\//) { $in_comment_block = false; }
    if(not /(^`.*)|(^\/\/.*)/) { #comment or directives
      $count = $count + 1 if /$str/ and $in_comment_block == false;
    }
  }
  return $count;
}

sub find_string_in_file {
  # return line number
  my ($str, $file) = @_;
  my ($file_path) = $vdb->get_files_full_name($file);
  my ($in_comment_block) = false;
  if (length $file_path == 0) {
    return -1;
  }
  my $fh;
  open $fh, "<", $file_path or die "could not open $file: $!";
  while(<$fh>) {
    if(/\/\*/) { $in_comment_block = true; }
    if(/\*\//) { $in_comment_block = false; }
    if(not /(^`.*)|(^\/\/.*)/) { #comment or directives
      return $. if /$str/i and $in_comment_block == false;
    }
  }
  return -1;
}

sub get_line_in_file {
  my ($lineWanted, $file) = @_;
  my ($file_path) = $vdb->get_files_full_name($file);
  open my $fh, '<', $file_path or die "$file_path: $!";
  my $line;
  while( <$fh> ) {
      if( $. == $lineWanted ) { 
          $line = $_;
          return $line;
          last;
      }
  }
}

foreach $module (sort $vdb->get_modules()) {
    &print_title("Module $module");

    my ($module_path) = $vdb->get_modules_file($module);
    
    #Warning: Initial
     my $initial_line = &find_string_in_file("initial", $module_path);
     if($initial_line != -1) {
       &print_warning("Initial setting will be ignored in synthesize process! ($module_path:$initial_line)");
     }


    #Error: assign
    # my $assign_line = &find_string_in_file("assign", $module_path);
    # if(($assign_line != -1)&& ($type2 eq "reg"))  {
    #   &print_error("variable should set as wire ($module_path:$assign_line)");
    # }

    #Error: if
     #my $if_line = &find_string_in_file("if\s*+.(\s*\w*\s*=\s*\w*.)"|"else if\s*+.(\s*\w*\s*=\s*\w*.)", $module_path);
     # if($if_line != -1)  {
     # &print_error("equal "=" can not be used in condition statement ($module_path:$assign_line)");
     #}


    #Warning: Delay
    my $delay_line = &find_string_in_file("#[0-9]+", $module_path);
    if($delay_line != -1) {
      &print_warning("Delay is not synthesizable! ($module_path:$delay_line)");
    }

    #Warning: Division
    #my $division_line = &find_string_in_file("[a-zA-Z0-9_\$]+\ *\/\ *[a-zA-Z0-9_\$]+", $module_path);
    #if($division_line != -1) {
    #  &print_warning("Division is not synthesizable! ($module_path:$division_line)");
    #}

    #Error: = is not condition
    # my $condition_line = &find_string_in_file("if\ +\(\ *[a-zA-Z][a-zA-Z0-9_\$]+\ *=[^=]", $module_path);
    # if($condition_line != -1) {
    #   &print_warning("= is not condition! ($module_path:$division_line)"); 
    # }

    #Warning: === !== operators
    my $operator_line = &find_string_in_file("===|!==", $module_path);
    if($operator_line != -1) {
      &print_warning("=== or !== is not synthesizable! ($module_path:$operator_line)");
    }

    #Warning: fork join operators
    my $fork_join_line = &find_string_in_file("fork|join", $module_path);
    if($fork_join_line != -1) {
      &print_warning("fork and join is not synthesizable! ($module_path:$fork_join_line)");
    }

    #Warning: trigger operators
    my $trigger_line = &find_string_in_file("->", $module_path);
    if($trigger_line != -1) {
      &print_warning("trigger is not synthesizable! ($module_path:$trigger_line)");
    }

    # Error: begin end not match
    my $begins = &count_string_in_file(qr/begin(\s|$)/, $module_path);
    my $ends = &count_string_in_file(qr/end(\s|$)/, $module_path);
    if ($begins < $ends) {
      &print_error("found redundant ends");
    } elsif ($begins > $ends) {
      &print_error("found missing ends");
    }

    # Warning: overload
    my ($file_path) = $vdb->get_files_full_name($module_path);
    my ($in_comment_block) = false;
    if (length $file_path != 0) {
      my $fh;
      open $fh, "<", $file_path or die "could not open $file_path!";
      while(<$fh>) {

        if(/\/\*/) { $in_comment_block = true; }
        if(/\*\//) { $in_comment_block = false; }
        if(not /(^`.*)|(^\/\/.*)/) { #comment or directives
          if ($_ =~ m/((?:[A-Za-z_][A-Za-z_0-9\$]*|\\\\\S+)\s*(?:\[\s*(?:\d+)\s*\:\s*(?:\d+)\s*\])?)\s*=\s*((?:(?:(?:[A-Za-z_][A-Za-z_0-9\$]*|\\\\\S+)\s*(?:\[\s*(?:\d+)\s*\:\s*(?:\d+)\s*\])?)|\d+))\s*\+\s*((?:(?:(?:[A-Za-z_][A-Za-z_0-9\$]*|\\\\\S+)\s*(?:\[\s*(?:\d+)\s*\:\s*(?:\d+)\s*\])?)|\d+))/ and $in_comment_block == false) {
            my $left = trim($1);
            my $right1 = trim($2);
            my $right2 = trim($3);
            my ($max_right1, $max_right2, $max_left, $right1_range, $right2_range);
            ($l_line,$l_a_line,$l_i_line,$l_type,$l_file,$l_p,$l_n,
         $l_type2,$l_r_file,$l_r_line,$l_range,$l_a_file,$l_i_file) = 
                      $vdb->get_module_signal($module,$left);
            my $left_range = $l_range;
            if ($left =~ /\[([^:]+?:[^:]+?)\]/) {
              $left_range = $1;
            }

            unless(looks_like_number($right1)) {
              ($r1_line,$r1_a_line,$r1_i_line,$r1_type,$r1_file,$r1_p,$l_n,
         $r1_type2,$r1_r_file,$r1_r_line,$r1_range,$r1_a_file,$r1_i_file) = 
                      $vdb->get_module_signal($module,$right1);
              $right1_range = $r1_range;
              if ($right1 =~ /\[([^:]+?:[^:]+?)\]/) {
                $right1_range = $1;
              }
            }

            unless(looks_like_number($right2)) {
              ($r2_line,$r2_a_line,$r2_i_line,$r2_type,$r2_file,$r2_p,$l_n,
         $r2_type2,$r2_r_file,$r2_r_line,$r2_range,$r2_a_file,$r2_i_file) = 
                      $vdb->get_module_signal($module,$right2);
              $right2_range = $r2_range;
              if ($right2 =~ /\[([^:]+?:[^:]+?)\]/) {
                $right2_range = $1;
              }
            }

            $max_left = &get_width_from_range($left_range, $module);
            $max_right1 = &get_width_from_range($right1_range, $module);
            $max_right2 = &get_width_from_range($right2_range, $module);

            if($max_left <= $max_right1 or $max_left <= max_right2) {
              &print_warning("Overload detected ($.:$module_path)")  
            }
          }
        }
      }
    }

    #Warning: casex
    # my $casex_line = &find_string_in_file("casex", $module_path);
    # if($casex_line != -1) {
    #   &print_warning("casex is not synthesizable! ($module_path:$casex_line)");
    # }

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

    # Check if variable is not used
    # my $count = &count_string_in_file($sig, $s_file);
    # print "found $count occurrences of $sig in $s_file";
    # if($count == 1) {
    #   &print_warning("Signal $sig has not been used!");
    # }

	&log ("   signal: $sig $type $type2 |$range|\n");
  # Error: Input declared as reg
	if(($type eq "input") && ($type2 eq "reg")) {
		&print_error("Input signal $sig has been declared as reg ($file:$line)");
	}
  # Warning: Declared as integer
  if($type eq "integer" || $type2 eq "integer") {
    &print_warning("Signal $sig should not be declared as integer ($file:$line)");
  }

   #Error: assign
     my $assign_line = &find_string_in_file("assign", $module_path);
     if(($assign_line != -1) and ($type2 eq "reg"|| $type eq "reg"))  {
       &print_error("variable should set as wire ($module_path:$assign_line)");
     }

  # Error: Variable has more than one definition
  #if(($type =~ m/input|output|inout|reg|wire|integer/) && ($type2 =~ m/input|output|inout|reg|wire|integer/)) {
   # &print_error("Signal $sig has more than one definition ($file:$line)");
  #}
  #Warning: Variable has not been used
  if($a_line == -1 and length $s_file == 0) {
    &print_warning("Signal $sig has not been used. ($file:$line)");
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
      my $line = &get_line_in_file($l, $f);
      $line =~ m/\((?:[A-Za-z_][A-Za-z_0-9\$]*|\\\\\S+)\s*\[\s*(\d+)\s*\:\s*(\d+)\s*\]\s*\)/;
      my $width_tmp;
      if ($1) {
        $width_tmp = eval("$1 + 1 - $2");
      } else {
        $width_tmp = $width;
      }
      if ($width_tmp != $s_width) {
        &print_warning("Signal $sig (width: $width_tmp) connected to: port $port (width: $s_width) of instance $iname of $imod ($l:$f)");
      }
  }
    }

    print "\n";
    my @declared_instances = ();
    for (($imod,$f,$iname,$l) = $vdb->get_first_instantiation($module );
	       $imod;
         ($imod,$f,$iname,$l) = $vdb->get_next_instantiation()) {
      my %declared_instances_hash = map {$_ => 1} @declared_instances;
      if(exists($declared_instances_hash{$iname})) {
        &print_error("Module $iname has been declared before. ($f:$l)");
      } else {
        push(@declared_instances, $iname);
      }
    	&log ("     instance: $iname of $imod\n");
    	%port_con = $vdb->get_current_instantiations_port_con();

      # Warning: Unconnected module
      my $unconnected = true;
    	foreach $port (sort keys %port_con) {
    	    my $p = $port_con{$port};
    	    $p =~ s/[ \n]//gs;
    	    &log ("        $port connected to \"$p\"\n");
          if ($p) { $unconnected = false; }
    	}

      if($unconnected == true) {
        &print_warning ("Module $iname is unconnected. ($f:$l)")
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

