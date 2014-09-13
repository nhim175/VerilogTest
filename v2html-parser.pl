sub _parse_line {

  my ($self,$code,$file,$line,$ps,$rs) = @_;

  if (!exists($ps->{curState})){
      $ps->{curState} = undef;
      $ps->{prevState}= undef;
      $ps->{nextStateStack}= ["START"];
      $ps->{storing}= 0;
      $ps->{stored}= "";
      $ps->{confusedNextState}= "START";
  }

  my $storePos = -1;
  my $lastPos = 0;
  my $posMark;
  my $fromLastPos;
  PARSE_LINE_LOOP: while (1) {

    $lastPos = pos($code) if (defined(pos($code)));

    if ( $code =~ m/\G\s*\Z/gs ) {
	last PARSE_LINE_LOOP;
    }
    else {
	pos($code) = $lastPos;
    }
    
    $code =~ m/\G\s*/gs ; # skip any whitespace

    $ps->{prevState} = $ps->{curState};
    $ps->{curState} = pop(@{$ps->{nextStateStack}}) or
	die "Error: No next state after $ps->{prevState} ".
	    "$file line $line :
 $code";
    print "---- $ps->{curState} $file:$line (".pos($code).")\n" if defined $ps->{curState} && defined pos($code);

    goto $ps->{curState};
    die "Confused: Bad state $ps->{curState}";

    CONFUSED:
	$posMark = '';
	# make the position marker: tricky because code can contain tabs
	#  which we want to match in the blank space before the ^
	$posMark = substr($code,0,$lastPos);
	$posMark =~ tr/	/ /c ; # turn anything that isn't a tab into a space
	$posMark .= "^" ;
	if (substr($code,length($code)-1,1) ne "\n") { $posMark="\n".$posMark; }
	$self->_add_confused("$file:$line: in state $ps->{prevState}:\n".
		    "$code".$posMark);
	@{$ps->{nextStateStack}} = ($ps->{confusedNextState});
       return; # ignore the rest of the line
    START:
      $ps->{confusedNextState}="START";
        if ($code =~ m/\G(?:(\b(?:module|macromodule|primitive)\b)|(\bconfig\b)|(\blibrary\b))/gos) {
          if (defined($1)) {
           print "----  -MODULE ($1)->\n";
           $takenArcs->{'START'}{1}++;
$rs->{t}={ type=>$1, line=>$line };
	      push (@{$ps->{nextStateStack}}, "MODULE_NAME");
	  }
          elsif (defined($2)) {
           print "----  -CONFIG ($2)->\n";
           $takenArcs->{'START'}{2}++;
	      push (@{$ps->{nextStateStack}}, "CONFIG");
	  }
          elsif (defined($3)) {
           print "----  -LIBRARY ($3)->\n";
           $takenArcs->{'START'}{3}++;
	      push (@{$ps->{nextStateStack}}, "LIBRARY");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    MODULE:
      $ps->{confusedNextState}="MODULE";
        if ($code =~ m/\G(?:(\b(?:end(?:module|primitive))\b)|(\bfunction\b)|(\btask\b)|(\b(?:parameter|localparam)\b)|(\bspecify\b)|(\btable\b)|(\bevent\b)|(\bdefparam\b)|(\b(?:and|nand|or|nor|xor|xnor|buf|bufif0|bufif1|not|notif0|notif1|pulldown|pullup|nmos|rnmos|pmos|rpmos|cmos|rcmos|tran|rtran|tranif0|rtranif0|tranif1|rtranif1)\b)|(\bassign\b)|(\b(?:input|output|inout|wire|tri|tri1|supply0|wand|triand|tri0|supply1|wor|time|trireg|trior|reg|integer|real|realtime|genvar)\b)|(\b(?:initial|always)\b)|(\bgenerate\b)|($VID))/gos) {
          if (defined($1)) {
           print "----  -ENDMODULE ($1)->\n";
           $takenArcs->{'MODULE'}{1}++;
if ((($rs->{p}{type} eq "primitive")&&($1 ne "endprimitive"))||
                         (($rs->{p}{type} ne "primitive")&&($1 eq "endprimitive"))){
		     $self->_add_warning("$file:$line: module of type".
                                 " $rs->{p}{type} ended by $1");
	          }
	          $rs->{modules}{$rs->{module}}{end} = $line;
	          $rs->{module}   = "";
	          $rs->{files}{$file}{contexts}{$line}{value}= { name=>"",type=>"" };
                  $rs->{p}= undef;
	      push (@{$ps->{nextStateStack}}, "START");
	  }
          elsif (defined($2)) {
           print "----  -FUNCTION ($2)->\n";
           $takenArcs->{'MODULE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "FUNCTION");
	  }
          elsif (defined($3)) {
           print "----  -TASK ($3)->\n";
           $takenArcs->{'MODULE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "TASK");
	  }
          elsif (defined($4)) {
           print "----  -PARAM ($4)->\n";
           $takenArcs->{'MODULE'}{4}++;
$rs->{t} = { ptype => $4 };
	      push (@{$ps->{nextStateStack}}, "MODULE","PARAM_TYPE");
	  }
          elsif (defined($5)) {
           print "----  -SPECIFY ($5)->\n";
           $takenArcs->{'MODULE'}{5}++;
	      push (@{$ps->{nextStateStack}}, "SPECIFY");
	  }
          elsif (defined($6)) {
           print "----  -TABLE ($6)->\n";
           $takenArcs->{'MODULE'}{6}++;
	      push (@{$ps->{nextStateStack}}, "TABLE");
	  }
          elsif (defined($7)) {
           print "----  -EVENT_DECLARATION ($7)->\n";
           $takenArcs->{'MODULE'}{7}++;
	      push (@{$ps->{nextStateStack}}, "EVENT_DECLARATION");
	  }
          elsif (defined($8)) {
           print "----  -DEFPARAM ($8)->\n";
           $takenArcs->{'MODULE'}{8}++;
	      push (@{$ps->{nextStateStack}}, "DEFPARAM");
	  }
          elsif (defined($9)) {
           print "----  -GATE ($9)->\n";
           $takenArcs->{'MODULE'}{9}++;
	      push (@{$ps->{nextStateStack}}, "GATE");
	  }
          elsif (defined($10)) {
           print "----  -ASSIGN ($10)->\n";
           $takenArcs->{'MODULE'}{10}++;
	      push (@{$ps->{nextStateStack}}, "ASSIGN");
	  }
          elsif (defined($11)) {
           print "----  -SIGNAL ($11)->\n";
           $takenArcs->{'MODULE'}{11}++;
$rs->{t}={ type=>$11, range=>"", dimensions=>[], name=>"" , type2=>"",block=>0};
	      push (@{$ps->{nextStateStack}}, "MODULE","DRIVE_STRENGTH");
	  }
          elsif (defined($12)) {
           print "----  -INITIAL_OR_ALWAYS ($12)->\n";
           $takenArcs->{'MODULE'}{12}++;
	      push (@{$ps->{nextStateStack}}, "MODULE","STMNT");
	  }
          elsif (defined($13)) {
           print "----  -GENERATE ($13)->\n";
           $takenArcs->{'MODULE'}{13}++;
	      push (@{$ps->{nextStateStack}}, "GENERATE");
	  }
          elsif (defined($14)) {
           print "----  -INST ($14)->\n";
           $takenArcs->{'MODULE'}{14}++;
$rs->{t}={ mod=>$14, line=>$line, name=>"" , port=>0 , 
                        params=>{}, param_number=>0 , portName=>"" , vids=>[]};
	      push (@{$ps->{nextStateStack}}, "INST_PARAM");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    MODULE_NAME:
        if ($code =~ m/\G(?:($VID))/gos) {
          if (defined($1)) {
           print "----  -NAME ($1)->\n";
           $takenArcs->{'MODULE_NAME'}{1}++;
my $nState="MODULE_PPL"; 
             my $type = $rs->{t}{type};  $rs->{t}=undef;
if (exists($rs->{modules}{$1})) {
                 $nState = "IGNORE_MODULE";
	         $rs->{modules}{$1}{duplicate} = 1;
	         $self->_add_warning("$file:$line ignoring new definition of ".
                          "module $1, previous was at ".
		          "$rs->{modules}{$1}{file}:$rs->{modules}{$1}{line})");
             }
             else {
               $rs->{module}=$1;
               _init_module($rs->{modules},$rs->{module},$file,$line,$type);
	       $rs->{files}{$file}{modules}{$rs->{module}} = $rs->{modules}{$rs->{module}};
  	       _add_anchor($rs->{files}{$file}{anchors},$line,$rs->{module});
  	       $rs->{files}{$file}{contexts}{$line}{value}= $rs->{p}= $rs->{modules}{$rs->{module}};
  	       $rs->{files}{$file}{contexts}{$line}{module_start}= $rs->{module};
             }
	      push (@{$ps->{nextStateStack}}, "$nState");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    IGNORE_MODULE:
        if ($code =~ m/(?:(\bendmodule\b)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -ENDMODULE ($1)->\n";
           $takenArcs->{'IGNORE_MODULE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "START");
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'IGNORE_MODULE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'IGNORE_MODULE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'IGNORE_MODULE'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'IGNORE_MODULE'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"IGNORE_MODULE"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    MODULE_PPL:
        if ($code =~ m/\G(?:(#))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'MODULE_PPL'}{1}++;
	      push (@{$ps->{nextStateStack}}, "PPL_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"MODULE_PORTS"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    MODULE_PORTS:
        if ($code =~ m/(?:(\b(?:input|output|inout)\b)|(;)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -TYPE ($1)->\n";
           $takenArcs->{'MODULE_PORTS'}{1}++;
           pos($code)=pos($code)-length($1);
	      push (@{$ps->{nextStateStack}}, "MODULE","ANSI_PORTS_TYPE");
	  }
          elsif (defined($2)) {
           print "----  -END ($2)->\n";
           $takenArcs->{'MODULE_PORTS'}{2}++;
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($3)) {
           print "----  -HVID ($3)->\n";
           $takenArcs->{'MODULE_PORTS'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -VID ($4)->\n";
           $takenArcs->{'MODULE_PORTS'}{4}++;
push(@{$rs->{p}{port_order}},$4);
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -NUMBER ($5)->\n";
           $takenArcs->{'MODULE_PORTS'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -STRING ($6)->\n";
           $takenArcs->{'MODULE_PORTS'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"MODULE_PORTS"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    FUNCTION:
        if ($code =~ m/\G(?:(\[)|(\b(?:real|integer|time|realtime)\b)|(\bsigned\b)|(\bautomatic\b)|($VID))/gos) {
          if (defined($1)) {
           print "----  -RANGE ($1)->\n";
           $takenArcs->{'FUNCTION'}{1}++;
	      push (@{$ps->{nextStateStack}}, "FUNCTION","IN_RANGE");
	  }
          elsif (defined($2)) {
           print "----  -TYPE ($2)->\n";
           $takenArcs->{'FUNCTION'}{2}++;
	      push (@{$ps->{nextStateStack}}, "FUNCTION");
	  }
          elsif (defined($3)) {
           print "----  -SIGNED ($3)->\n";
           $takenArcs->{'FUNCTION'}{3}++;
	      push (@{$ps->{nextStateStack}}, "FUNCTION");
	  }
          elsif (defined($4)) {
           print "----  -AUTO ($4)->\n";
           $takenArcs->{'FUNCTION'}{4}++;
	      push (@{$ps->{nextStateStack}}, "FUNCTION");
	  }
          elsif (defined($5)) {
           print "----  -NAME ($5)->\n";
           $takenArcs->{'FUNCTION'}{5}++;
$rs->{function}=$5;
                      $self->_init_t_and_f($rs->{modules}{$rs->{module}},"function",
		      $rs->{function},$file,$line,$rs->{module}."_".$rs->{function});
	              _add_anchor($rs->{files}{$file}{anchors},$line,$rs->{module}."_".$rs->{function});
                      $rs->{files}{$file}{contexts}{$line}{value}= $rs->{p}= $rs->{modules}{$rs->{module}}{t_and_f}{$rs->{function}};
	      push (@{$ps->{nextStateStack}}, "FUNCTION_AFTER_NAME");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    FUNCTION_AFTER_NAME:
        if ($code =~ m/\G(?:(;)|(\())/gos) {
          if (defined($1)) {
           print "----  -SEMICOLON ($1)->\n";
           $takenArcs->{'FUNCTION_AFTER_NAME'}{1}++;
	      push (@{$ps->{nextStateStack}}, "F_SIGNAL");
	  }
          elsif (defined($2)) {
           print "----  -BRACKET ($2)->\n";
           $takenArcs->{'FUNCTION_AFTER_NAME'}{2}++;
	      push (@{$ps->{nextStateStack}}, "F_SIGNAL","ANSI_PORTS_TYPE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    TASK:
        if ($code =~ m/\G(?:(\bautomatic\b)|($VID))/gos) {
          if (defined($1)) {
           print "----  -AUTO ($1)->\n";
           $takenArcs->{'TASK'}{1}++;
	      push (@{$ps->{nextStateStack}}, "TASK");
	  }
          elsif (defined($2)) {
           print "----  -NAME ($2)->\n";
           $takenArcs->{'TASK'}{2}++;
$rs->{task}=$2;
  	              $self->_init_t_and_f($rs->{modules}{$rs->{module}},"task",
		                   $rs->{task},$file,$line,$rs->{module}. "_" .$rs->{task});
 	              _add_anchor($rs->{files}{$file}{anchors},$line,$rs->{module}. "_" . $rs->{task});
                      $rs->{files}{$file}{contexts}{$line}{value}= $rs->{p}= $rs->{modules}{$rs->{module}}{t_and_f}{$rs->{task}};
	      push (@{$ps->{nextStateStack}}, "TASK_AFTER_NAME");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    TASK_AFTER_NAME:
        if ($code =~ m/\G(?:(;)|(\())/gos) {
          if (defined($1)) {
           print "----  -SEMICOLON ($1)->\n";
           $takenArcs->{'TASK_AFTER_NAME'}{1}++;
	      push (@{$ps->{nextStateStack}}, "T_SIGNAL");
	  }
          elsif (defined($2)) {
           print "----  -BRACKET ($2)->\n";
           $takenArcs->{'TASK_AFTER_NAME'}{2}++;
	      push (@{$ps->{nextStateStack}}, "T_SIGNAL","ANSI_PORTS_TYPE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    T_SIGNAL:
        if ($code =~ m/\G(?:(\bendtask\b)|(\b(?:input|output|inout|wire|tri|tri1|supply0|wand|triand|tri0|supply1|wor|time|trireg|trior|reg|integer|real|realtime|genvar)\b)|(\b(?:parameter|localparam)\b))/gos) {
          if (defined($1)) {
           print "----  -ENDTASK ($1)->\n";
           $takenArcs->{'T_SIGNAL'}{1}++;
$rs->{modules}{$rs->{module}}{t_and_f}{$rs->{task}}{end} = $line;
                $rs->{task}="";
	        $rs->{files}{$file}{contexts}{$line}{value}= $rs->{p}= $rs->{modules}{$rs->{module}};
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($2)) {
           print "----  -SIGNAL ($2)->\n";
           $takenArcs->{'T_SIGNAL'}{2}++;
$rs->{t}={ type=>$2, range=>"", dimensions=>[], name=>"" , type2=>"" , block=>0};
	      push (@{$ps->{nextStateStack}}, "T_SIGNAL","DRIVE_STRENGTH");
	  }
          elsif (defined($3)) {
           print "----  -PARAM ($3)->\n";
           $takenArcs->{'T_SIGNAL'}{3}++;
$rs->{t} = { ptype => $3 };
	      push (@{$ps->{nextStateStack}}, "T_SIGNAL","PARAM_TYPE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"ENDTASK","STMNT"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    ENDTASK:
        if ($code =~ m/\G(?:(\bendtask\b))/gos) {
          if (defined($1)) {
           print "----  -ENDTASK ($1)->\n";
           $takenArcs->{'ENDTASK'}{1}++;
$rs->{modules}{$rs->{module}}{t_and_f}{$rs->{task}}{end} = $line;
                $rs->{task}="";
	        $rs->{files}{$file}{contexts}{$line}{value}= $rs->{p}= $rs->{modules}{$rs->{module}};
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    F_SIGNAL:
        if ($code =~ m/\G(?:(\bendfunction\b)|(\b(?:input|output|inout|wire|tri|tri1|supply0|wand|triand|tri0|supply1|wor|time|trireg|trior|reg|integer|real|realtime|genvar)\b)|(\b(?:parameter|localparam)\b))/gos) {
          if (defined($1)) {
           print "----  -ENDFUNCTION ($1)->\n";
           $takenArcs->{'F_SIGNAL'}{1}++;
$rs->{modules}{$rs->{module}}{t_and_f}{$rs->{function}}{end} = $line;
                     $rs->{function}="";
	             $rs->{files}{$file}{contexts}{$line}{value}= $rs->{p}= $rs->{modules}{$rs->{module}};
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($2)) {
           print "----  -SIGNAL ($2)->\n";
           $takenArcs->{'F_SIGNAL'}{2}++;
$rs->{t}={ type=>$2, range=>"", dimensions=>[], name=>"" , type2=>"",block=>0};
	      push (@{$ps->{nextStateStack}}, "F_SIGNAL","DRIVE_STRENGTH");
	  }
          elsif (defined($3)) {
           print "----  -PARAM ($3)->\n";
           $takenArcs->{'F_SIGNAL'}{3}++;
$rs->{t} = { ptype => $3 };
	      push (@{$ps->{nextStateStack}}, "F_SIGNAL","PARAM_TYPE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"ENDFUNCTION","STMNT"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    ENDFUNCTION:
        if ($code =~ m/\G(?:(\bendfunction\b))/gos) {
          if (defined($1)) {
           print "----  -ENDFUNCTION ($1)->\n";
           $takenArcs->{'ENDFUNCTION'}{1}++;
$rs->{modules}{$rs->{module}}{t_and_f}{$rs->{function}}{end} = $line;
                     $rs->{function}="";
	             $rs->{files}{$file}{contexts}{$line}{value}= $rs->{p}= $rs->{modules}{$rs->{module}};
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    PARAM_TYPE:
        if ($code =~ m/\G(?:(\[)|(\bsigned\b)|(\b(?:integer|real|realtime|time)\b))/gos) {
          if (defined($1)) {
           print "----  -RANGE ($1)->\n";
           $takenArcs->{'PARAM_TYPE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "PARAM_NAME","IN_RANGE");
	  }
          elsif (defined($2)) {
           print "----  -SIGNED ($2)->\n";
           $takenArcs->{'PARAM_TYPE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "PARAM_TYPE");
	  }
          elsif (defined($3)) {
           print "----  -OTHER ($3)->\n";
           $takenArcs->{'PARAM_TYPE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "PARAM_NAME");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"PARAM_NAME"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    PARAM_NAME:
        if ($code =~ m/\G(?:($VID))/gos) {
          if (defined($1)) {
           print "----  -NAME ($1)->\n";
           $takenArcs->{'PARAM_NAME'}{1}++;
if ( ($rs->{function} eq "") && ($rs->{task} eq "")) { # ignore parameters in tasks and functions 
              $rs->{t}= { file => $file, line => $line , value => "" ,
                          ptype => $rs->{t}{ptype}}; # ptype is same as the last one
              push(@{$rs->{p}{parameter_order}}, $1) 
                    unless ($rs->{t}{ptype} eq "localparam");
              $rs->{p}{parameters}{$1}=$rs->{t};
	      _add_anchor($rs->{files}{$file}{anchors},$line,""); }
	      push (@{$ps->{nextStateStack}}, "PARAM_AFTER_EQUALS","PARAMETER_EQUAL");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    PARAMETER_EQUAL:
        if ($code =~ m/\G(?:(=))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'PARAMETER_EQUAL'}{1}++;
       $ps->{storing} == 0 or
            die "Setting storing flag when it is already set: PARAMETER_EQUAL:";
       $storePos       = pos($code);
       $ps->{storing}  = 1;
       $ps->{stored}   = '';
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    PARAM_AFTER_EQUALS:
        if ($code =~ m/(?:({)|(,)|(;)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -CONCAT ($1)->\n";
           $takenArcs->{'PARAM_AFTER_EQUALS'}{1}++;
	      push (@{$ps->{nextStateStack}}, "PARAM_AFTER_EQUALS","IN_CONCAT");
	  }
          elsif (defined($2)) {
           print "----  -COMMA ($2)->\n";
           $takenArcs->{'PARAM_AFTER_EQUALS'}{2}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($2));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($2));
}
$ps->{storing}=0;
$ps->{stored}='';
$rs->{t}{value} = $fromLastPos;
	      push (@{$ps->{nextStateStack}}, "PARAM_NAME");
	  }
          elsif (defined($3)) {
           print "----  -SEMICOLON ($3)->\n";
           $takenArcs->{'PARAM_AFTER_EQUALS'}{3}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($3));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($3));
}
$ps->{storing}=0;
$ps->{stored}='';
$rs->{t}{value} = $fromLastPos;
	  }
          elsif (defined($4)) {
           print "----  -HVID ($4)->\n";
           $takenArcs->{'PARAM_AFTER_EQUALS'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -VID ($5)->\n";
           $takenArcs->{'PARAM_AFTER_EQUALS'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -NUMBER ($6)->\n";
           $takenArcs->{'PARAM_AFTER_EQUALS'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($7)) {
           print "----  -STRING ($7)->\n";
           $takenArcs->{'PARAM_AFTER_EQUALS'}{7}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"PARAM_AFTER_EQUALS"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    IN_CONCAT:
        if ($code =~ m/(?:({)|(})|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -CONCAT ($1)->\n";
           $takenArcs->{'IN_CONCAT'}{1}++;
	      push (@{$ps->{nextStateStack}}, "IN_CONCAT","IN_CONCAT");
	  }
          elsif (defined($2)) {
           print "----  -END ($2)->\n";
           $takenArcs->{'IN_CONCAT'}{2}++;
	  }
          elsif (defined($3)) {
           print "----  -HVID ($3)->\n";
           $takenArcs->{'IN_CONCAT'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -VID ($4)->\n";
           $takenArcs->{'IN_CONCAT'}{4}++;
push(@{$rs->{t}{vids}},{name=>$4,line=>$line}) if (exists($rs->{t}{vids}));
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -NUMBER ($5)->\n";
           $takenArcs->{'IN_CONCAT'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -STRING ($6)->\n";
           $takenArcs->{'IN_CONCAT'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"IN_CONCAT"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    IN_RANGE:
        if ($code =~ m/(?:(\[)|(\])|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -RANGE ($1)->\n";
           $takenArcs->{'IN_RANGE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "IN_RANGE","IN_RANGE");
	  }
          elsif (defined($2)) {
           print "----  -END ($2)->\n";
           $takenArcs->{'IN_RANGE'}{2}++;
	  }
          elsif (defined($3)) {
           print "----  -HVID ($3)->\n";
           $takenArcs->{'IN_RANGE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -VID ($4)->\n";
           $takenArcs->{'IN_RANGE'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -NUMBER ($5)->\n";
           $takenArcs->{'IN_RANGE'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -STRING ($6)->\n";
           $takenArcs->{'IN_RANGE'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"IN_RANGE"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    IN_SIG_RANGE:
        if ($code =~ m/(?:(\[)|(\])|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -RANGE ($1)->\n";
           $takenArcs->{'IN_SIG_RANGE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "IN_SIG_RANGE","IN_SIG_RANGE");
	  }
          elsif (defined($2)) {
           print "----  -END ($2)->\n";
           $takenArcs->{'IN_SIG_RANGE'}{2}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($2));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($2));
}
$ps->{storing}=0;
$ps->{stored}='';
$rs->{t}{range}=$fromLastPos;
	  }
          elsif (defined($3)) {
           print "----  -HVID ($3)->\n";
           $takenArcs->{'IN_SIG_RANGE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -VID ($4)->\n";
           $takenArcs->{'IN_SIG_RANGE'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -NUMBER ($5)->\n";
           $takenArcs->{'IN_SIG_RANGE'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -STRING ($6)->\n";
           $takenArcs->{'IN_SIG_RANGE'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"IN_SIG_RANGE"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    IN_MEM_RANGE:
        if ($code =~ m/(?:(\[)|(\])|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -RANGE ($1)->\n";
           $takenArcs->{'IN_MEM_RANGE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "IN_MEM_RANGE","IN_MEM_RANGE");
	  }
          elsif (defined($2)) {
           print "----  -END ($2)->\n";
           $takenArcs->{'IN_MEM_RANGE'}{2}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($2));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($2));
}
$ps->{storing}=0;
$ps->{stored}='';
push(@{$rs->{t}{dimensions}},$fromLastPos);
	  }
          elsif (defined($3)) {
           print "----  -HVID ($3)->\n";
           $takenArcs->{'IN_MEM_RANGE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -VID ($4)->\n";
           $takenArcs->{'IN_MEM_RANGE'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -NUMBER ($5)->\n";
           $takenArcs->{'IN_MEM_RANGE'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -STRING ($6)->\n";
           $takenArcs->{'IN_MEM_RANGE'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"IN_MEM_RANGE"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    IN_BRACKET:
        if ($code =~ m/(?:(\()|(\))|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -BRACKET ($1)->\n";
           $takenArcs->{'IN_BRACKET'}{1}++;
	      push (@{$ps->{nextStateStack}}, "IN_BRACKET","IN_BRACKET");
	  }
          elsif (defined($2)) {
           print "----  -END ($2)->\n";
           $takenArcs->{'IN_BRACKET'}{2}++;
	  }
          elsif (defined($3)) {
           print "----  -HVID ($3)->\n";
           $takenArcs->{'IN_BRACKET'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -VID ($4)->\n";
           $takenArcs->{'IN_BRACKET'}{4}++;
push(@{$rs->{t}{vids}},{name=>$4,line=>$line}) if (exists($rs->{t}{vids}));
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -NUMBER ($5)->\n";
           $takenArcs->{'IN_BRACKET'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -STRING ($6)->\n";
           $takenArcs->{'IN_BRACKET'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"IN_BRACKET"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    IN_STRING:
        if ($code =~ m/(?:(\\\")|(\\\\)|(\"))/gos) {
          if (defined($1)) {
           print "----  -ESCAPED_QUOTE ($1)->\n";
           $takenArcs->{'IN_STRING'}{1}++;
	      push (@{$ps->{nextStateStack}}, "IN_STRING");
	  }
          elsif (defined($2)) {
           print "----  -ESCAPE ($2)->\n";
           $takenArcs->{'IN_STRING'}{2}++;
	      push (@{$ps->{nextStateStack}}, "IN_STRING");
	  }
          elsif (defined($3)) {
           print "----  -END ($3)->\n";
           $takenArcs->{'IN_STRING'}{3}++;
	  }
      }
      else { push(@{$ps->{nextStateStack}},"IN_STRING"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    SPECIFY:
        if ($code =~ m/(?:(\bendspecify\b)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'SPECIFY'}{1}++;
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'SPECIFY'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'SPECIFY'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'SPECIFY'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'SPECIFY'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"SPECIFY"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    TABLE:
        if ($code =~ m/(?:(\bendtable\b)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'TABLE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'TABLE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'TABLE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'TABLE'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'TABLE'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"TABLE"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    EVENT_DECLARATION:
        if ($code =~ m/(?:(;)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'EVENT_DECLARATION'}{1}++;
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'EVENT_DECLARATION'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'EVENT_DECLARATION'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'EVENT_DECLARATION'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'EVENT_DECLARATION'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"EVENT_DECLARATION"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    DEFPARAM:
        if ($code =~ m/(?:(;)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'DEFPARAM'}{1}++;
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'DEFPARAM'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'DEFPARAM'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'DEFPARAM'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'DEFPARAM'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"DEFPARAM"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    GATE:
        if ($code =~ m/(?:(;)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'GATE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'GATE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'GATE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'GATE'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'GATE'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"GATE"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    ASSIGN:
        if ($code =~ m/(?:(\[)|(=)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -RANGE ($1)->\n";
           $takenArcs->{'ASSIGN'}{1}++;
	      push (@{$ps->{nextStateStack}}, "ASSIGN","IN_RANGE");
	  }
          elsif (defined($2)) {
           print "----  -EQUALS ($2)->\n";
           $takenArcs->{'ASSIGN'}{2}++;
	      push (@{$ps->{nextStateStack}}, "ASSIGN_AFTER_EQUALS");
	  }
          elsif (defined($3)) {
           print "----  -HVID ($3)->\n";
           $takenArcs->{'ASSIGN'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -VID ($4)->\n";
           $takenArcs->{'ASSIGN'}{4}++;
if ( exists($rs->{p}{signals}{$4}) &&
		              ($rs->{p}{signals}{$4}{a_line} == -1)) {
	       $rs->{p}{signals}{$4}{a_line} = $line;
	       $rs->{p}{signals}{$4}{a_file} = $file;
               _add_anchor($rs->{files}{$file}{anchors},$line,"");
	    }
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -NUMBER ($5)->\n";
           $takenArcs->{'ASSIGN'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -STRING ($6)->\n";
           $takenArcs->{'ASSIGN'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"ASSIGN"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    ASSIGN_AFTER_EQUALS:
        if ($code =~ m/(?:(,)|({)|(\()|(;)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -COMMA ($1)->\n";
           $takenArcs->{'ASSIGN_AFTER_EQUALS'}{1}++;
	      push (@{$ps->{nextStateStack}}, "ASSIGN");
	  }
          elsif (defined($2)) {
           print "----  -CONCAT ($2)->\n";
           $takenArcs->{'ASSIGN_AFTER_EQUALS'}{2}++;
	      push (@{$ps->{nextStateStack}}, "ASSIGN_AFTER_EQUALS","IN_CONCAT");
	  }
          elsif (defined($3)) {
           print "----  -BRACKET ($3)->\n";
           $takenArcs->{'ASSIGN_AFTER_EQUALS'}{3}++;
	      push (@{$ps->{nextStateStack}}, "ASSIGN_AFTER_EQUALS","IN_BRACKET");
	  }
          elsif (defined($4)) {
           print "----  -END ($4)->\n";
           $takenArcs->{'ASSIGN_AFTER_EQUALS'}{4}++;
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($5)) {
           print "----  -HVID ($5)->\n";
           $takenArcs->{'ASSIGN_AFTER_EQUALS'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -VID ($6)->\n";
           $takenArcs->{'ASSIGN_AFTER_EQUALS'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($7)) {
           print "----  -NUMBER ($7)->\n";
           $takenArcs->{'ASSIGN_AFTER_EQUALS'}{7}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($8)) {
           print "----  -STRING ($8)->\n";
           $takenArcs->{'ASSIGN_AFTER_EQUALS'}{8}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"ASSIGN_AFTER_EQUALS"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    DRIVE_STRENGTH:
        if ($code =~ m/\G(?:(\())/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'DRIVE_STRENGTH'}{1}++;
	      push (@{$ps->{nextStateStack}}, "SCALARED_OR_VECTORED","IN_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"SCALARED_OR_VECTORED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    SCALARED_OR_VECTORED:
        if ($code =~ m/\G(?:(\b(?:scalared|vectored)\b)|(\b(?:input|output|inout|wire|tri|tri1|supply0|wand|triand|tri0|supply1|wor|time|trireg|trior|reg|integer|real|realtime|genvar)\b)|(\b(?:signed)\b))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'SCALARED_OR_VECTORED'}{1}++;
	      push (@{$ps->{nextStateStack}}, "SIGNAL_RANGE");
	  }
          elsif (defined($2)) {
           print "----  -TYPE ($2)->\n";
           $takenArcs->{'SCALARED_OR_VECTORED'}{2}++;
if ($2 eq "reg") { $rs->{t}{type2} = "reg"; }
	      push (@{$ps->{nextStateStack}}, "SCALARED_OR_VECTORED");
	  }
          elsif (defined($3)) {
           print "----  - ($3)->\n";
           $takenArcs->{'SCALARED_OR_VECTORED'}{3}++;
	      push (@{$ps->{nextStateStack}}, "SCALARED_OR_VECTORED");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"SIGNAL_RANGE"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    SIGNAL_RANGE:
        if ($code =~ m/\G(?:(\[))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'SIGNAL_RANGE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "SIGNAL_DELAY","IN_SIG_RANGE");
       $ps->{storing} == 0 or
            die "Setting storing flag when it is already set: SIGNAL_RANGE:";
       $storePos       = pos($code);
       $ps->{storing}  = 1;
       $ps->{stored}   = '';
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"SIGNAL_DELAY"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    SIGNAL_DELAY:
        if ($code =~ m/\G(?:(\#))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'SIGNAL_DELAY'}{1}++;
	      push (@{$ps->{nextStateStack}}, "SIGNAL_NAME","DELAY_VALUE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"SIGNAL_NAME"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    SIGNAL_NAME:
        if ($code =~ m/\G(?:($VID))/gos) {
          if (defined($1)) {
           print "----  -VID ($1)->\n";
           $takenArcs->{'SIGNAL_NAME'}{1}++;
$rs->{t}{name}=$1; $rs->{t}{line}=$line;
print "Found $rs->{t}{type} $rs->{t}{name} $rs->{t}{range} [$line]\n";
if ($rs->{t}{block} != 1) {
              $self->_init_signal($rs->{p}{signals},$1,$rs->{t}{type},$rs->{t}{type2},
                        $rs->{t}{range},$file,$line,1,$rs->{t}{dimensions})
               && _add_anchor($rs->{files}{$file}{anchors},$line,"");
            }
	      push (@{$ps->{nextStateStack}}, "SIGNAL_AFTER_NAME");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    SIGNAL_AFTER_NAME:
        if ($code =~ m/\G(?:(,)|(\[)|(;)|(=))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'SIGNAL_AFTER_NAME'}{1}++;
	      push (@{$ps->{nextStateStack}}, "SIGNAL_NAME");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'SIGNAL_AFTER_NAME'}{2}++;
	      push (@{$ps->{nextStateStack}}, "SIGNAL_AFTER_NAME","IN_MEM_RANGE");
       $ps->{storing} == 0 or
            die "Setting storing flag when it is already set: SIGNAL_AFTER_NAME:";
       $storePos       = pos($code);
       $ps->{storing}  = 1;
       $ps->{stored}   = '';
	  }
          elsif (defined($3)) {
           print "----  -SEMICOLON ($3)->\n";
           $takenArcs->{'SIGNAL_AFTER_NAME'}{3}++;
$rs->{t}=undef;
	  }
          elsif (defined($4)) {
           print "----  -ASSIGN ($4)->\n";
           $takenArcs->{'SIGNAL_AFTER_NAME'}{4}++;
if ($rs->{t}{block} != 1) {
                if ( $rs->{p}{signals}{$rs->{t}{name}}{type} ne "reg" ) {
                  $rs->{p}{signals}{$rs->{t}{name}}{a_line}=$rs->{t}{line};
                  $rs->{p}{signals}{$rs->{t}{name}}{a_file}=$file;
	          _add_anchor($rs->{files}{$file}{anchors},$rs->{t}{line},"");
                }
               }
	      push (@{$ps->{nextStateStack}}, "SIGNAL_AFTER_EQUALS");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    SIGNAL_AFTER_EQUALS:
        if ($code =~ m/(?:(,)|({)|(\()|(;)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'SIGNAL_AFTER_EQUALS'}{1}++;
	      push (@{$ps->{nextStateStack}}, "SIGNAL_NAME");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'SIGNAL_AFTER_EQUALS'}{2}++;
	      push (@{$ps->{nextStateStack}}, "SIGNAL_AFTER_EQUALS","IN_CONCAT");
	  }
          elsif (defined($3)) {
           print "----  - ($3)->\n";
           $takenArcs->{'SIGNAL_AFTER_EQUALS'}{3}++;
	      push (@{$ps->{nextStateStack}}, "SIGNAL_AFTER_EQUALS","IN_BRACKET");
	  }
          elsif (defined($4)) {
           print "----  -END ($4)->\n";
           $takenArcs->{'SIGNAL_AFTER_EQUALS'}{4}++;
$rs->{t}=undef;
	  }
          elsif (defined($5)) {
           print "----  -HVID ($5)->\n";
           $takenArcs->{'SIGNAL_AFTER_EQUALS'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -VID ($6)->\n";
           $takenArcs->{'SIGNAL_AFTER_EQUALS'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($7)) {
           print "----  -NUMBER ($7)->\n";
           $takenArcs->{'SIGNAL_AFTER_EQUALS'}{7}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($8)) {
           print "----  -STRING ($8)->\n";
           $takenArcs->{'SIGNAL_AFTER_EQUALS'}{8}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"SIGNAL_AFTER_EQUALS"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    INST_PARAM:
        if ($code =~ m/\G(?:(\#))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'INST_PARAM'}{1}++;
	      push (@{$ps->{nextStateStack}}, "INST_PARAM_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"INST_NAME"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_PARAM_BRACKET:
        if ($code =~ m/\G(?:(\()|(($VID|$VNUM)))/gos) {
          if (defined($1)) {
           print "----  -BRACKET ($1)->\n";
           $takenArcs->{'INST_PARAM_BRACKET'}{1}++;
	      push (@{$ps->{nextStateStack}}, "INST_PARAM_VALUE");
       $ps->{storing} == 0 or
            die "Setting storing flag when it is already set: INST_PARAM_BRACKET:BRACKET";
       $storePos       = pos($code);
       $ps->{storing}  = 1;
       $ps->{stored}   = '';
	  }
          elsif (defined($2)) {
           print "----  -NO_BRACKET ($2)->\n";
           $takenArcs->{'INST_PARAM_BRACKET'}{2}++;
$self->_add_warning("$file:$line: possible missing brackets after \# in instantiation");
my $inst_num= $#{$rs->{p}{instances}};
              $rs->{t}{params}{$rs->{t}{param_number}} = 
                     { file => $file , line => $line , value => $2 };
              $rs->{t}{param_number}++;
	      push (@{$ps->{nextStateStack}}, "INST_NAME");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_PARAM_VALUE:
        if ($code =~ m/(?:(\()|(\[)|(\{)|(,)|(\)))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'INST_PARAM_VALUE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "INST_PARAM_VALUE","IN_BRACKET");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'INST_PARAM_VALUE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "INST_PARAM_VALUE","IN_RANGE");
	  }
          elsif (defined($3)) {
           print "----  - ($3)->\n";
           $takenArcs->{'INST_PARAM_VALUE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "INST_PARAM_VALUE","IN_CONCAT");
	  }
          elsif (defined($4)) {
           print "----  -COMMA ($4)->\n";
           $takenArcs->{'INST_PARAM_VALUE'}{4}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($4));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($4));
}
$ps->{storing}=0;
$ps->{stored}='';
my $inst_num= $#{$rs->{p}{instances}};
              $rs->{t}{params}{$rs->{t}{param_number}} = 
                     { file => $file , line => $line , value => $fromLastPos };
              $rs->{t}{param_number}++;
	      push (@{$ps->{nextStateStack}}, "INST_PARAM_VALUE");
       $ps->{storing} == 0 or
            die "Setting storing flag when it is already set: INST_PARAM_VALUE:COMMA";
       $storePos       = pos($code);
       $ps->{storing}  = 1;
       $ps->{stored}   = '';
	  }
          elsif (defined($5)) {
           print "----  -END ($5)->\n";
           $takenArcs->{'INST_PARAM_VALUE'}{5}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($5));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($5));
}
$ps->{storing}=0;
$ps->{stored}='';
my $inst_num= $#{$rs->{p}{instances}};
              $rs->{t}{params}{$rs->{t}{param_number}} = 
                     { file => $file , line => $line , value => $fromLastPos };
              $rs->{t}{param_number}++;
	      push (@{$ps->{nextStateStack}}, "INST_NAME");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"INST_PARAM_VALUE"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    INST_NAME:
        if ($code =~ m/\G(?:($VID))/gos) {
          if (defined($1)) {
           print "----  -VID ($1)->\n";
           $takenArcs->{'INST_NAME'}{1}++;
$rs->{t}{name}=$1;
	      push (@{$ps->{nextStateStack}}, "INST_RANGE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"INST_BRACKET"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_NO_NAME:
        if ($code =~ m/(?:(;)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'INST_NO_NAME'}{1}++;
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'INST_NO_NAME'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'INST_NO_NAME'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'INST_NO_NAME'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'INST_NO_NAME'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"INST_NO_NAME"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    INST_RANGE:
        if ($code =~ m/\G(?:(\[))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'INST_RANGE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "INST_BRACKET","IN_RANGE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"INST_BRACKET"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_BRACKET:
        if ($code =~ m/\G(?:(\())/gos) {
          if (defined($1)) {
           print "----  -PORTS ($1)->\n";
           $takenArcs->{'INST_BRACKET'}{1}++;
print "found instance $rs->{t}{name} of $rs->{t}{mod} [$rs->{t}{line}]\n";
$rs->{unres_mod}{$rs->{t}{mod}}=$rs->{t}{mod};
	      $rs->{files}{$file}{instance_lines}{$rs->{t}{line}} = $rs->{t}{mod};
	      push( @{$rs->{p}{instances}} , { module => $rs->{t}{mod} , 
					       inst_name => $rs->{t}{name} ,
					       file => $file,
					       line => $rs->{t}{line},
                                               parameters => $rs->{t}{params},
					       connections => {} });
	      _add_anchor($rs->{files}{$file}{anchors},$rs->{t}{line},
                         $rs->{module}."_".$rs->{t}{name});
	      push (@{$ps->{nextStateStack}}, "INST_PORTS");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_PORTS:
        if ($code =~ m/\G(?:(,)|(\.)|(\)))/gos) {
          if (defined($1)) {
           print "----  -COMMA ($1)->\n";
           $takenArcs->{'INST_PORTS'}{1}++;
$rs->{t}{port}++;
	      push (@{$ps->{nextStateStack}}, "INST_PORTS");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'INST_PORTS'}{2}++;
	      push (@{$ps->{nextStateStack}}, "INST_PORT_NAME");
	  }
          elsif (defined($3)) {
           print "----  - ($3)->\n";
           $takenArcs->{'INST_PORTS'}{3}++;
	      push (@{$ps->{nextStateStack}}, "AFTER_INST");
	  }
      }
      else {
       $ps->{storing} == 0 or
            die "Setting storing flag when it is already set: INST_PORTS:fail";
       $storePos       = $lastPos;
       $ps->{storing}  = 1;
       $ps->{stored}   = '';
push(@{$ps->{nextStateStack}},"INST_NUMBERED_PORT"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_PORT_NAME:
        if ($code =~ m/\G(?:($VID))/gos) {
          if (defined($1)) {
           print "----  -NAME ($1)->\n";
           $takenArcs->{'INST_PORT_NAME'}{1}++;
$rs->{t}{portName}=$1;
             $rs->{t}{vids} = [];
	      push (@{$ps->{nextStateStack}}, "INST_NAMED_PORT_CON_AFTER","INST_NAMED_PORT_CON","INST_NAMED_PORT_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_NAMED_PORT_BRACKET:
        if ($code =~ m/\G(?:(\())/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'INST_NAMED_PORT_BRACKET'}{1}++;
       $ps->{storing} == 0 or
            die "Setting storing flag when it is already set: INST_NAMED_PORT_BRACKET:";
       $storePos       = pos($code);
       $ps->{storing}  = 1;
       $ps->{stored}   = '';
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_NAMED_PORT_CON:
        if ($code =~ m/(?:(\[)|(\{)|(\()|(\))|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON'}{1}++;
	      push (@{$ps->{nextStateStack}}, "INST_NAMED_PORT_CON","IN_RANGE");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON'}{2}++;
	      push (@{$ps->{nextStateStack}}, "INST_NAMED_PORT_CON","IN_CONCAT");
	  }
          elsif (defined($3)) {
           print "----  - ($3)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON'}{3}++;
	      push (@{$ps->{nextStateStack}}, "INST_NAMED_PORT_CON","INST_NAMED_PORT_CON");
	  }
          elsif (defined($4)) {
           print "----  -END ($4)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON'}{4}++;
	  }
          elsif (defined($5)) {
           print "----  -HVID ($5)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -VID ($6)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON'}{6}++;
push(@{$rs->{t}{vids}},{name=>$6,line=>$line});
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($7)) {
           print "----  -NUMBER ($7)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON'}{7}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($8)) {
           print "----  -STRING ($8)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON'}{8}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"INST_NAMED_PORT_CON"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    INST_NAMED_PORT_CON_AFTER:
        if ($code =~ m/\G(?:(\))|(,))/gos) {
          if (defined($1)) {
           print "----  -BRACKET ($1)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON_AFTER'}{1}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($1));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($1));
}
$ps->{storing}=0;
$ps->{stored}='';
if ($rs->{t}{portName} eq "") { $rs->{t}{portName}=$rs->{t}{port}++; }
                 my @vids = @{$rs->{t}{vids}};
                 my $portName = $rs->{t}{portName};
                 $rs->{t}{portName}=""; 
                 $rs->{t}{vids}=[];
my @vidnames; 
            foreach my $vid (@vids) {push @vidnames,$vid->{name};}
            print " Port $portName connected to ".join(",",@vidnames)."\n";
my $inst_num= $#{$rs->{p}{instances}};
              $rs->{p}{instances}[$inst_num]{connections}{$portName}=$fromLastPos;
	      if ($portName =~ /^[0-9]/ ) { # clear named_ports flag if port is a number
                 $rs->{p}{named_ports} = 0;
              }
              else { # remove the bracket from the end if a named port
                 $rs->{p}{instances}[$inst_num]{connections}{$portName}=~s/\)\s*$//s;
              }
	      foreach my $s (@vids) {
                $self->_init_signal($rs->{p}{signals},$s->{name},"wire","","",$file,$s->{line},0,$rs->{t}{dimensions})
                    && _add_anchor($rs->{files}{$file}{anchors},$s->{line},"");
		 push( @{$rs->{p}{signals}{$s->{name}}{port_con}}, 
		        { port   => $portName ,
                          line   => $s->{line},
                          file   => $file,
		          module => $rs->{t}{mod} ,
		          inst   => $rs->{t}{name} });
              }
	      push (@{$ps->{nextStateStack}}, "AFTER_INST");
	  }
          elsif (defined($2)) {
           print "----  -COMMA ($2)->\n";
           $takenArcs->{'INST_NAMED_PORT_CON_AFTER'}{2}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($2));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($2));
}
$ps->{storing}=0;
$ps->{stored}='';
if ($rs->{t}{portName} eq "") { $rs->{t}{portName}=$rs->{t}{port}++; }
                 my @vids = @{$rs->{t}{vids}};
                 my $portName = $rs->{t}{portName};
                 $rs->{t}{portName}=""; 
                 $rs->{t}{vids}=[];
my @vidnames; 
            foreach my $vid (@vids) {push @vidnames,$vid->{name};}
            print " Port $portName connected to ".join(",",@vidnames)."\n";
my $inst_num= $#{$rs->{p}{instances}};
              $rs->{p}{instances}[$inst_num]{connections}{$portName}=$fromLastPos;
	      if ($portName =~ /^[0-9]/ ) { # clear named_ports flag if port is a number
                 $rs->{p}{named_ports} = 0;
              }
              else { # remove the bracket from the end if a named port
                 $rs->{p}{instances}[$inst_num]{connections}{$portName}=~s/\)\s*$//s;
              }
	      foreach my $s (@vids) {
                $self->_init_signal($rs->{p}{signals},$s->{name},"wire","","",$file,$s->{line},0,$rs->{t}{dimensions})
                    && _add_anchor($rs->{files}{$file}{anchors},$s->{line},"");
		 push( @{$rs->{p}{signals}{$s->{name}}{port_con}}, 
		        { port   => $portName ,
                          line   => $s->{line},
                          file   => $file,
		          module => $rs->{t}{mod} ,
		          inst   => $rs->{t}{name} });
              }
	      push (@{$ps->{nextStateStack}}, "INST_DOT");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_DOT:
        if ($code =~ m/\G(?:(\.)|(,))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'INST_DOT'}{1}++;
	      push (@{$ps->{nextStateStack}}, "INST_PORT_NAME");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'INST_DOT'}{2}++;
	      push (@{$ps->{nextStateStack}}, "INST_DOT");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    INST_NUMBERED_PORT:
        if ($code =~ m/(?:(\[)|(\{)|(\()|(\))|(,)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'INST_NUMBERED_PORT'}{1}++;
	      push (@{$ps->{nextStateStack}}, "INST_NUMBERED_PORT","IN_RANGE");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'INST_NUMBERED_PORT'}{2}++;
	      push (@{$ps->{nextStateStack}}, "INST_NUMBERED_PORT","IN_CONCAT");
	  }
          elsif (defined($3)) {
           print "----  - ($3)->\n";
           $takenArcs->{'INST_NUMBERED_PORT'}{3}++;
	      push (@{$ps->{nextStateStack}}, "INST_NUMBERED_PORT","IN_BRACKET");
	  }
          elsif (defined($4)) {
           print "----  -BRACKET ($4)->\n";
           $takenArcs->{'INST_NUMBERED_PORT'}{4}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($4));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($4));
}
$ps->{storing}=0;
$ps->{stored}='';
if ($rs->{t}{portName} eq "") { $rs->{t}{portName}=$rs->{t}{port}++; }
                 my @vids = @{$rs->{t}{vids}};
                 my $portName = $rs->{t}{portName};
                 $rs->{t}{portName}=""; 
                 $rs->{t}{vids}=[];
my @vidnames; 
            foreach my $vid (@vids) {push @vidnames,$vid->{name};}
            print " Port $portName connected to ".join(",",@vidnames)."\n";
my $inst_num= $#{$rs->{p}{instances}};
              $rs->{p}{instances}[$inst_num]{connections}{$portName}=$fromLastPos;
	      if ($portName =~ /^[0-9]/ ) { # clear named_ports flag if port is a number
                 $rs->{p}{named_ports} = 0;
              }
              else { # remove the bracket from the end if a named port
                 $rs->{p}{instances}[$inst_num]{connections}{$portName}=~s/\)\s*$//s;
              }
	      foreach my $s (@vids) {
                $self->_init_signal($rs->{p}{signals},$s->{name},"wire","","",$file,$s->{line},0,$rs->{t}{dimensions})
                    && _add_anchor($rs->{files}{$file}{anchors},$s->{line},"");
		 push( @{$rs->{p}{signals}{$s->{name}}{port_con}}, 
		        { port   => $portName ,
                          line   => $s->{line},
                          file   => $file,
		          module => $rs->{t}{mod} ,
		          inst   => $rs->{t}{name} });
              }
	      push (@{$ps->{nextStateStack}}, "AFTER_INST");
	  }
          elsif (defined($5)) {
           print "----  -COMMA ($5)->\n";
           $takenArcs->{'INST_NUMBERED_PORT'}{5}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($5));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($5));
}
$ps->{storing}=0;
$ps->{stored}='';
if ($rs->{t}{portName} eq "") { $rs->{t}{portName}=$rs->{t}{port}++; }
                 my @vids = @{$rs->{t}{vids}};
                 my $portName = $rs->{t}{portName};
                 $rs->{t}{portName}=""; 
                 $rs->{t}{vids}=[];
my @vidnames; 
            foreach my $vid (@vids) {push @vidnames,$vid->{name};}
            print " Port $portName connected to ".join(",",@vidnames)."\n";
my $inst_num= $#{$rs->{p}{instances}};
              $rs->{p}{instances}[$inst_num]{connections}{$portName}=$fromLastPos;
	      if ($portName =~ /^[0-9]/ ) { # clear named_ports flag if port is a number
                 $rs->{p}{named_ports} = 0;
              }
              else { # remove the bracket from the end if a named port
                 $rs->{p}{instances}[$inst_num]{connections}{$portName}=~s/\)\s*$//s;
              }
	      foreach my $s (@vids) {
                $self->_init_signal($rs->{p}{signals},$s->{name},"wire","","",$file,$s->{line},0,$rs->{t}{dimensions})
                    && _add_anchor($rs->{files}{$file}{anchors},$s->{line},"");
		 push( @{$rs->{p}{signals}{$s->{name}}{port_con}}, 
		        { port   => $portName ,
                          line   => $s->{line},
                          file   => $file,
		          module => $rs->{t}{mod} ,
		          inst   => $rs->{t}{name} });
              }
	      push (@{$ps->{nextStateStack}}, "INST_NUMBERED_PORT");
       $ps->{storing} == 0 or
            die "Setting storing flag when it is already set: INST_NUMBERED_PORT:COMMA";
       $storePos       = pos($code);
       $ps->{storing}  = 1;
       $ps->{stored}   = '';
	  }
          elsif (defined($6)) {
           print "----  -HVID ($6)->\n";
           $takenArcs->{'INST_NUMBERED_PORT'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($7)) {
           print "----  -VID ($7)->\n";
           $takenArcs->{'INST_NUMBERED_PORT'}{7}++;
push(@{$rs->{t}{vids}},{name=>$7,line=>$line});
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($8)) {
           print "----  -NUMBER ($8)->\n";
           $takenArcs->{'INST_NUMBERED_PORT'}{8}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($9)) {
           print "----  -STRING ($9)->\n";
           $takenArcs->{'INST_NUMBERED_PORT'}{9}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"INST_NUMBERED_PORT"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    AFTER_INST:
        if ($code =~ m/\G(?:(;)|(,))/gos) {
          if (defined($1)) {
           print "----  -SEMICOLON ($1)->\n";
           $takenArcs->{'AFTER_INST'}{1}++;
$rs->{t}=undef;
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($2)) {
           print "----  -COMMA ($2)->\n";
           $takenArcs->{'AFTER_INST'}{2}++;
$rs->{t}{line}=$line;
                  $rs->{t}{name}="";
                  $rs->{t}{port}=0;
                  $rs->{t}{portName}="";
                  $rs->{t}{vids}=[];
	      push (@{$ps->{nextStateStack}}, "INST_NAME");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    STMNT:
        if ($code =~ m/\G(?:(\bif\b)|(\b(?:repeat|while|for|wait)\b)|(\bforever\b)|(\bcase[xz]?\b)|(\bbegin\b)|(\bfork\b)|(\#)|(\@)|(\$$VID)|(\b(?:disable|assign|deassign|force|release)\b)|($HVID)|($VID)|({)|(;)|(->))/gos) {
          if (defined($1)) {
           print "----  -IF ($1)->\n";
           $takenArcs->{'STMNT'}{1}++;
	      push (@{$ps->{nextStateStack}}, "MAYBE_ELSE","STMNT","IN_BRACKET","BRACKET");
	  }
          elsif (defined($2)) {
           print "----  -REPEAT_WHILE_FOR_WAIT ($2)->\n";
           $takenArcs->{'STMNT'}{2}++;
	      push (@{$ps->{nextStateStack}}, "STMNT","IN_BRACKET","BRACKET");
	  }
          elsif (defined($3)) {
           print "----  -FOREVER ($3)->\n";
           $takenArcs->{'STMNT'}{3}++;
	      push (@{$ps->{nextStateStack}}, "STMNT");
	  }
          elsif (defined($4)) {
           print "----  -CASE ($4)->\n";
           $takenArcs->{'STMNT'}{4}++;
	      push (@{$ps->{nextStateStack}}, "CASE_ITEM","IN_BRACKET","BRACKET");
	  }
          elsif (defined($5)) {
           print "----  -BEGIN ($5)->\n";
           $takenArcs->{'STMNT'}{5}++;
	      push (@{$ps->{nextStateStack}}, "IN_SEQ_BLOCK","BLOCK_NAME");
	  }
          elsif (defined($6)) {
           print "----  -FORK ($6)->\n";
           $takenArcs->{'STMNT'}{6}++;
	      push (@{$ps->{nextStateStack}}, "IN_PAR_BLOCK","BLOCK_NAME");
	  }
          elsif (defined($7)) {
           print "----  -DELAY ($7)->\n";
           $takenArcs->{'STMNT'}{7}++;
	      push (@{$ps->{nextStateStack}}, "STMNT","DELAY_VALUE");
	  }
          elsif (defined($8)) {
           print "----  -EVENT_CONTROL ($8)->\n";
           $takenArcs->{'STMNT'}{8}++;
	      push (@{$ps->{nextStateStack}}, "EVENT_CONTROL");
	  }
          elsif (defined($9)) {
           print "----  -SYSTEM_TASK ($9)->\n";
           $takenArcs->{'STMNT'}{9}++;
	      push (@{$ps->{nextStateStack}}, "SYSTEM_TASK");
	  }
          elsif (defined($10)) {
           print "----  -DISABLE_ASSIGN_DEASSIGN_FORCE_RELEASE ($10)->\n";
           $takenArcs->{'STMNT'}{10}++;
	      push (@{$ps->{nextStateStack}}, "STMNT_JUNK_TO_SEMICOLON");
	  }
          elsif (defined($11)) {
           print "----  -HIER_ASSIGN_OR_TASK ($11)->\n";
           $takenArcs->{'STMNT'}{11}++;
$rs->{t}={ vids=>[]};
	      push (@{$ps->{nextStateStack}}, "STMNT_ASSIGN_OR_TASK");
	  }
          elsif (defined($12)) {
           print "----  -ASSIGN_OR_TASK ($12)->\n";
           $takenArcs->{'STMNT'}{12}++;
$rs->{t}={ vids=>[{name=>$12,line=>$line}]};
	      push (@{$ps->{nextStateStack}}, "STMNT_ASSIGN_OR_TASK");
	  }
          elsif (defined($13)) {
           print "----  -CONCAT ($13)->\n";
           $takenArcs->{'STMNT'}{13}++;
$rs->{t}={ vids=>[]};
	      push (@{$ps->{nextStateStack}}, "STMNT_ASSIGN","IN_CONCAT");
	  }
          elsif (defined($14)) {
           print "----  -NULL ($14)->\n";
           $takenArcs->{'STMNT'}{14}++;
	  }
          elsif (defined($15)) {
           print "----  -POINTY_THING ($15)->\n";
           $takenArcs->{'STMNT'}{15}++;
	      push (@{$ps->{nextStateStack}}, "POINTY_THING_NAME");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    MAYBE_ELSE:
        if ($code =~ m/\G(?:(\belse\b))/gos) {
          if (defined($1)) {
           print "----  -ELSE ($1)->\n";
           $takenArcs->{'MAYBE_ELSE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "STMNT");
	  }
      }
      else {
 pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    BLOCK_NAME:
        if ($code =~ m/\G(?:(:))/gos) {
          if (defined($1)) {
           print "----  -COLON ($1)->\n";
           $takenArcs->{'BLOCK_NAME'}{1}++;
	      push (@{$ps->{nextStateStack}}, "BLOCK_NAME_AFTER_COLON");
	  }
      }
      else {
 pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    BLOCK_NAME_AFTER_COLON:
        if ($code =~ m/\G(?:($VID))/gos) {
          if (defined($1)) {
           print "----  -VID ($1)->\n";
           $takenArcs->{'BLOCK_NAME_AFTER_COLON'}{1}++;
	      push (@{$ps->{nextStateStack}}, "BLOCK_SIGNAL");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    BLOCK_SIGNAL:
        if ($code =~ m/\G(?:(\b(?:input|output|inout|wire|tri|tri1|supply0|wand|triand|tri0|supply1|wor|time|trireg|trior|reg|integer|real|realtime|genvar)\b))/gos) {
          if (defined($1)) {
           print "----  -SIGNAL ($1)->\n";
           $takenArcs->{'BLOCK_SIGNAL'}{1}++;
$rs->{t}={ type=>$1, range=>"", dimensions=>[], name=>"" , type2=>"" , block=>1};
	      push (@{$ps->{nextStateStack}}, "BLOCK_SIGNAL","DRIVE_STRENGTH");
	  }
      }
      else {
 pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    IN_SEQ_BLOCK:
        if ($code =~ m/\G(?:(\bend\b))/gos) {
          if (defined($1)) {
           print "----  -END ($1)->\n";
           $takenArcs->{'IN_SEQ_BLOCK'}{1}++;
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"IN_SEQ_BLOCK","STMNT"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    IN_PAR_BLOCK:
        if ($code =~ m/\G(?:(\bjoin\b))/gos) {
          if (defined($1)) {
           print "----  -JOIN ($1)->\n";
           $takenArcs->{'IN_PAR_BLOCK'}{1}++;
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"IN_PAR_BLOCK","STMNT"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    DELAY_VALUE:
        if ($code =~ m/\G(?:($VNUM)|($VID)|(\())/gos) {
          if (defined($1)) {
           print "----  -NUMBER ($1)->\n";
           $takenArcs->{'DELAY_VALUE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "DELAY_COLON1");
	  }
          elsif (defined($2)) {
           print "----  -ID ($2)->\n";
           $takenArcs->{'DELAY_VALUE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "DELAY_COLON1");
	  }
          elsif (defined($3)) {
           print "----  -BRACKET ($3)->\n";
           $takenArcs->{'DELAY_VALUE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "DELAY_COLON1","IN_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    DELAY_COLON1:
        if ($code =~ m/\G(?:(:))/gos) {
          if (defined($1)) {
           print "----  -COLON ($1)->\n";
           $takenArcs->{'DELAY_COLON1'}{1}++;
	      push (@{$ps->{nextStateStack}}, "DELAY_VALUE2");
	  }
      }
      else {
 pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    DELAY_VALUE2:
        if ($code =~ m/\G(?:($VNUM)|($VID)|(\())/gos) {
          if (defined($1)) {
           print "----  -NUMBER ($1)->\n";
           $takenArcs->{'DELAY_VALUE2'}{1}++;
	      push (@{$ps->{nextStateStack}}, "DELAY_COLON2");
	  }
          elsif (defined($2)) {
           print "----  -ID ($2)->\n";
           $takenArcs->{'DELAY_VALUE2'}{2}++;
	      push (@{$ps->{nextStateStack}}, "DELAY_COLON2");
	  }
          elsif (defined($3)) {
           print "----  -BRACKET ($3)->\n";
           $takenArcs->{'DELAY_VALUE2'}{3}++;
	      push (@{$ps->{nextStateStack}}, "DELAY_COLON2","IN_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    DELAY_COLON2:
        if ($code =~ m/\G(?:(:))/gos) {
          if (defined($1)) {
           print "----  -COLON ($1)->\n";
           $takenArcs->{'DELAY_COLON2'}{1}++;
	      push (@{$ps->{nextStateStack}}, "DELAY_VALUE3");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    DELAY_VALUE3:
        if ($code =~ m/\G(?:($VNUM)|($VID)|(\())/gos) {
          if (defined($1)) {
           print "----  -NUMBER ($1)->\n";
           $takenArcs->{'DELAY_VALUE3'}{1}++;
	  }
          elsif (defined($2)) {
           print "----  -ID ($2)->\n";
           $takenArcs->{'DELAY_VALUE3'}{2}++;
	  }
          elsif (defined($3)) {
           print "----  -BRACKET ($3)->\n";
           $takenArcs->{'DELAY_VALUE3'}{3}++;
	      push (@{$ps->{nextStateStack}}, "IN_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    EVENT_CONTROL:
        if ($code =~ m/\G(?:((?:$HVID|$VID))|(\*)|(\())/gos) {
          if (defined($1)) {
           print "----  -ID ($1)->\n";
           $takenArcs->{'EVENT_CONTROL'}{1}++;
	      push (@{$ps->{nextStateStack}}, "STMNT");
	  }
          elsif (defined($2)) {
           print "----  -STAR ($2)->\n";
           $takenArcs->{'EVENT_CONTROL'}{2}++;
	      push (@{$ps->{nextStateStack}}, "STMNT");
	  }
          elsif (defined($3)) {
           print "----  -BRACKET ($3)->\n";
           $takenArcs->{'EVENT_CONTROL'}{3}++;
	      push (@{$ps->{nextStateStack}}, "STMNT","IN_EVENT_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    IN_EVENT_BRACKET:
        if ($code =~ m/(?:(\b(?:posedge|negedge)\b)|(\()|(\*)|(\))|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -EDGE ($1)->\n";
           $takenArcs->{'IN_EVENT_BRACKET'}{1}++;
$rs->{t}={ type=>$1 };
	      push (@{$ps->{nextStateStack}}, "IN_EVENT_BRACKET_EDGE");
	  }
          elsif (defined($2)) {
           print "----  -BRACKET ($2)->\n";
           $takenArcs->{'IN_EVENT_BRACKET'}{2}++;
	      push (@{$ps->{nextStateStack}}, "IN_EVENT_BRACKET","IN_EVENT_BRACKET");
	  }
          elsif (defined($3)) {
           print "----  -STAR ($3)->\n";
           $takenArcs->{'IN_EVENT_BRACKET'}{3}++;
	      push (@{$ps->{nextStateStack}}, "IN_EVENT_BRACKET");
	  }
          elsif (defined($4)) {
           print "----  -END ($4)->\n";
           $takenArcs->{'IN_EVENT_BRACKET'}{4}++;
	  }
          elsif (defined($5)) {
           print "----  -HVID ($5)->\n";
           $takenArcs->{'IN_EVENT_BRACKET'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -VID ($6)->\n";
           $takenArcs->{'IN_EVENT_BRACKET'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($7)) {
           print "----  -NUMBER ($7)->\n";
           $takenArcs->{'IN_EVENT_BRACKET'}{7}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($8)) {
           print "----  -STRING ($8)->\n";
           $takenArcs->{'IN_EVENT_BRACKET'}{8}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"IN_EVENT_BRACKET"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    IN_EVENT_BRACKET_EDGE:
        if ($code =~ m/\G(?:($VID))/gos) {
          if (defined($1)) {
           print "----  -VID ($1)->\n";
           $takenArcs->{'IN_EVENT_BRACKET_EDGE'}{1}++;
my $edgeType = $rs->{t}{type}; $rs->{t}=undef;
if (exists($rs->{p}{signals}{$1})) { 
               $rs->{p}{signals}{$1}{$edgeType}=1; };
	      push (@{$ps->{nextStateStack}}, "IN_EVENT_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"IN_EVENT_BRACKET"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    STMNT_ASSIGN_OR_TASK:
        if ($code =~ m/\G(?:([<]?=)|(\[)|(\())/gos) {
          if (defined($1)) {
           print "----  -EQUALS ($1)->\n";
           $takenArcs->{'STMNT_ASSIGN_OR_TASK'}{1}++;
my @vids = @{$rs->{t}{vids}}; $rs->{t}=undef;
foreach my $s (@vids) {
                 my $sigp = undef;
	         if ( exists($rs->{p}{signals}{$s->{name}} )) {
                      $sigp = $rs->{p}{signals}{$s->{name}};
                 }
	         elsif ( exists($rs->{p}{m_signals}) &&
                         exists($rs->{p}{m_signals}{$s->{name}}) ) {
                      $sigp = $rs->{p}{m_signals}{$s->{name}};
                 }
                 if (defined($sigp) && ($sigp->{a_line}==-1)) {
		      $sigp->{a_line}=$s->{line};
		      $sigp->{a_file}=$file;
		      _add_anchor($rs->{files}{$file}{anchors},$s->{line},"");
	         }
               }
	      push (@{$ps->{nextStateStack}}, "STMNT_JUNK_TO_SEMICOLON");
	  }
          elsif (defined($2)) {
           print "----  -RANGE ($2)->\n";
           $takenArcs->{'STMNT_ASSIGN_OR_TASK'}{2}++;
	      push (@{$ps->{nextStateStack}}, "STMNT_ASSIGN","IN_RANGE");
	  }
          elsif (defined($3)) {
           print "----  -BRACKET ($3)->\n";
           $takenArcs->{'STMNT_ASSIGN_OR_TASK'}{3}++;
$rs->{t}=undef;
	      push (@{$ps->{nextStateStack}}, "STMNT_SEMICOLON","IN_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"STMNT_SEMICOLON"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    STMNT_ASSIGN:
        if ($code =~ m/\G(?:([<]?=)|(\[))/gos) {
          if (defined($1)) {
           print "----  -EQUALS ($1)->\n";
           $takenArcs->{'STMNT_ASSIGN'}{1}++;
my @vids = @{$rs->{t}{vids}}; $rs->{t}=undef;
foreach my $s (@vids) {
                 my $sigp = undef;
	         if ( exists($rs->{p}{signals}{$s->{name}} )) {
                      $sigp = $rs->{p}{signals}{$s->{name}};
                 }
	         elsif ( exists($rs->{p}{m_signals}) &&
                         exists($rs->{p}{m_signals}{$s->{name}}) ) {
                      $sigp = $rs->{p}{m_signals}{$s->{name}};
                 }
                 if (defined($sigp) && ($sigp->{a_line}==-1)) {
		      $sigp->{a_line}=$s->{line};
		      $sigp->{a_file}=$file;
		      _add_anchor($rs->{files}{$file}{anchors},$s->{line},"");
	         }
               }
	      push (@{$ps->{nextStateStack}}, "STMNT_JUNK_TO_SEMICOLON");
	  }
          elsif (defined($2)) {
           print "----  -RANGE ($2)->\n";
           $takenArcs->{'STMNT_ASSIGN'}{2}++;
	      push (@{$ps->{nextStateStack}}, "STMNT_ASSIGN","IN_RANGE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    SYSTEM_TASK:
        if ($code =~ m/\G(?:(\())/gos) {
          if (defined($1)) {
           print "----  -BRACKET ($1)->\n";
           $takenArcs->{'SYSTEM_TASK'}{1}++;
	      push (@{$ps->{nextStateStack}}, "STMNT_SEMICOLON","IN_BRACKET");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"STMNT_SEMICOLON"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    POINTY_THING_NAME:
        if ($code =~ m/\G(?:((?:$HVID|$VID)))/gos) {
          if (defined($1)) {
           print "----  -VID ($1)->\n";
           $takenArcs->{'POINTY_THING_NAME'}{1}++;
	      push (@{$ps->{nextStateStack}}, "STMNT_SEMICOLON");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    CASE_ITEM:
        if ($code =~ m/(?:(\bendcase\b)|(:)|(\bdefault\b)|(\[)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -END ($1)->\n";
           $takenArcs->{'CASE_ITEM'}{1}++;
	  }
          elsif (defined($2)) {
           print "----  -COLON ($2)->\n";
           $takenArcs->{'CASE_ITEM'}{2}++;
	      push (@{$ps->{nextStateStack}}, "CASE_ITEM","STMNT");
	  }
          elsif (defined($3)) {
           print "----  -DEFAULT ($3)->\n";
           $takenArcs->{'CASE_ITEM'}{3}++;
	      push (@{$ps->{nextStateStack}}, "CASE_ITEM","STMNT","MAYBE_COLON");
	  }
          elsif (defined($4)) {
           print "----  -RANGE ($4)->\n";
           $takenArcs->{'CASE_ITEM'}{4}++;
	      push (@{$ps->{nextStateStack}}, "CASE_ITEM","IN_RANGE");
	  }
          elsif (defined($5)) {
           print "----  -HVID ($5)->\n";
           $takenArcs->{'CASE_ITEM'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -VID ($6)->\n";
           $takenArcs->{'CASE_ITEM'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($7)) {
           print "----  -NUMBER ($7)->\n";
           $takenArcs->{'CASE_ITEM'}{7}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($8)) {
           print "----  -STRING ($8)->\n";
           $takenArcs->{'CASE_ITEM'}{8}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"CASE_ITEM"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    MAYBE_COLON:
        if ($code =~ m/\G(?:(:))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'MAYBE_COLON'}{1}++;
	  }
      }
      else {
 pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    STMNT_JUNK_TO_SEMICOLON:
        if ($code =~ m/(?:(;)|(\b(?:end|join|endtask|endfunction)\b)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'STMNT_JUNK_TO_SEMICOLON'}{1}++;
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'STMNT_JUNK_TO_SEMICOLON'}{2}++;
           pos($code)=pos($code)-length($2);
	  }
          elsif (defined($3)) {
           print "----  -HVID ($3)->\n";
           $takenArcs->{'STMNT_JUNK_TO_SEMICOLON'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -VID ($4)->\n";
           $takenArcs->{'STMNT_JUNK_TO_SEMICOLON'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -NUMBER ($5)->\n";
           $takenArcs->{'STMNT_JUNK_TO_SEMICOLON'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -STRING ($6)->\n";
           $takenArcs->{'STMNT_JUNK_TO_SEMICOLON'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"STMNT_JUNK_TO_SEMICOLON"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    STMNT_SEMICOLON:
        if ($code =~ m/\G(?:(;)|(\b(?:end|join|endtask|endfunction)\b))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'STMNT_SEMICOLON'}{1}++;
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'STMNT_SEMICOLON'}{2}++;
           pos($code)=pos($code)-length($2);
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    BRACKET:
        if ($code =~ m/\G(?:(\())/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'BRACKET'}{1}++;
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    SEMICOLON:
        if ($code =~ m/\G(?:(;))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'SEMICOLON'}{1}++;
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    CONFIG:
        if ($code =~ m/(?:(\bendconfig\b)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'CONFIG'}{1}++;
	      push (@{$ps->{nextStateStack}}, "START");
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'CONFIG'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'CONFIG'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'CONFIG'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'CONFIG'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"CONFIG"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    LIBRARY:
        if ($code =~ m/(?:(;)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'LIBRARY'}{1}++;
	      push (@{$ps->{nextStateStack}}, "START");
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'LIBRARY'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'LIBRARY'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'LIBRARY'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'LIBRARY'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"LIBRARY"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    GENERATE:
        if ($code =~ m/(?:(\bendgenerate\b)|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'GENERATE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "MODULE");
	  }
          elsif (defined($2)) {
           print "----  -HVID ($2)->\n";
           $takenArcs->{'GENERATE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($3)) {
           print "----  -VID ($3)->\n";
           $takenArcs->{'GENERATE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($4)) {
           print "----  -NUMBER ($4)->\n";
           $takenArcs->{'GENERATE'}{4}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($5)) {
           print "----  -STRING ($5)->\n";
           $takenArcs->{'GENERATE'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"GENERATE"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    ANSI_PORTS_TYPE:
        if ($code =~ m/\G(?:(\b(?:input|output|inout)\b)|(\)))/gos) {
          if (defined($1)) {
           print "----  -TYPE ($1)->\n";
           $takenArcs->{'ANSI_PORTS_TYPE'}{1}++;
$rs->{t}={ type=>$1, range=>"", dimensions=>[], name=>"" , type2=>"",block=>0};
	      push (@{$ps->{nextStateStack}}, "ANSI_PORTS_TYPE2");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'ANSI_PORTS_TYPE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "SEMICOLON");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"ANSI_PORTS_TYPE2"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    ANSI_PORTS_TYPE2:
        if ($code =~ m/\G(?:(\b(?:input|output|inout|wire|tri|tri1|supply0|wand|triand|tri0|supply1|wor|time|trireg|trior|reg|integer|real|realtime|genvar)\b)|(\b(?:signed)\b))/gos) {
          if (defined($1)) {
           print "----  -TYPE ($1)->\n";
           $takenArcs->{'ANSI_PORTS_TYPE2'}{1}++;
if ($1 eq "reg") { $rs->{t}{type2} = "reg"; }
	      push (@{$ps->{nextStateStack}}, "ANSI_PORTS_TYPE2");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'ANSI_PORTS_TYPE2'}{2}++;
	      push (@{$ps->{nextStateStack}}, "ANSI_PORTS_TYPE2");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"ANSI_PORTS_SIGNAL_RANGE"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    ANSI_PORTS_SIGNAL_RANGE:
        if ($code =~ m/\G(?:(\[))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'ANSI_PORTS_SIGNAL_RANGE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "ANSI_PORTS_SIGNAL_NAME","IN_SIG_RANGE");
       $ps->{storing} == 0 or
            die "Setting storing flag when it is already set: ANSI_PORTS_SIGNAL_RANGE:";
       $storePos       = pos($code);
       $ps->{storing}  = 1;
       $ps->{stored}   = '';
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"ANSI_PORTS_SIGNAL_NAME"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    ANSI_PORTS_SIGNAL_NAME:
        if ($code =~ m/\G(?:(\b(?:input|output|inout)\b)|($VID))/gos) {
          if (defined($1)) {
           print "----  -TYPE ($1)->\n";
           $takenArcs->{'ANSI_PORTS_SIGNAL_NAME'}{1}++;
           pos($code)=pos($code)-length($1);
	      push (@{$ps->{nextStateStack}}, "ANSI_PORTS_TYPE");
	  }
          elsif (defined($2)) {
           print "----  -VID ($2)->\n";
           $takenArcs->{'ANSI_PORTS_SIGNAL_NAME'}{2}++;
$rs->{t}{name}=$2; $rs->{t}{line}=$line;
print "Found $rs->{t}{type} $rs->{t}{name} $rs->{t}{range} [$line]\n";
$self->_init_signal($rs->{p}{signals},$2,$rs->{t}{type},$rs->{t}{type2},
                        $rs->{t}{range},$file,$line,1,$rs->{t}{dimensions});
            push(@{$rs->{p}{port_order}},$2) if exists $rs->{p}{port_order};
            _add_anchor($rs->{files}{$file}{anchors},$line,"");
	      push (@{$ps->{nextStateStack}}, "ANSI_PORTS_SIGNAL_AFTER_NAME");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    ANSI_PORTS_SIGNAL_AFTER_NAME:
        if ($code =~ m/\G(?:(,)|(\[)|(\)))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'ANSI_PORTS_SIGNAL_AFTER_NAME'}{1}++;
	      push (@{$ps->{nextStateStack}}, "ANSI_PORTS_SIGNAL_NAME");
	  }
          elsif (defined($2)) {
           print "----  - ($2)->\n";
           $takenArcs->{'ANSI_PORTS_SIGNAL_AFTER_NAME'}{2}++;
	      push (@{$ps->{nextStateStack}}, "ANSI_PORTS_SIGNAL_AFTER_NAME","IN_MEM_RANGE");
	  }
          elsif (defined($3)) {
           print "----  - ($3)->\n";
           $takenArcs->{'ANSI_PORTS_SIGNAL_AFTER_NAME'}{3}++;
	      push (@{$ps->{nextStateStack}}, "SEMICOLON");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    PPL_BRACKET:
        if ($code =~ m/\G(?:(\())/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'PPL_BRACKET'}{1}++;
	      push (@{$ps->{nextStateStack}}, "PPL_PARAM");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    PPL_PARAM:
        if ($code =~ m/\G(?:(\bparameter\b))/gos) {
          if (defined($1)) {
           print "----  -PARAM ($1)->\n";
           $takenArcs->{'PPL_PARAM'}{1}++;
$rs->{t} = { ptype => "parameter" };
	      push (@{$ps->{nextStateStack}}, "PPL_TYPE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    PPL_TYPE:
        if ($code =~ m/\G(?:(\[)|(\bsigned\b)|(\b(?:integer|real|realtime|time)\b))/gos) {
          if (defined($1)) {
           print "----  -RANGE ($1)->\n";
           $takenArcs->{'PPL_TYPE'}{1}++;
	      push (@{$ps->{nextStateStack}}, "PPL_NAME","IN_RANGE");
	  }
          elsif (defined($2)) {
           print "----  -SIGNED ($2)->\n";
           $takenArcs->{'PPL_TYPE'}{2}++;
	      push (@{$ps->{nextStateStack}}, "PPL_TYPE");
	  }
          elsif (defined($3)) {
           print "----  -OTHER ($3)->\n";
           $takenArcs->{'PPL_TYPE'}{3}++;
	      push (@{$ps->{nextStateStack}}, "PPL_NAME");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"PPL_NAME"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    PPL_NAME:
        if ($code =~ m/\G(?:($VID))/gos) {
          if (defined($1)) {
           print "----  -NAME ($1)->\n";
           $takenArcs->{'PPL_NAME'}{1}++;
if ( ($rs->{function} eq "") && ($rs->{task} eq "")) { # ignore parameters in tasks and functions 
              $rs->{t}= { file => $file, line => $line , value => "" ,
                          ptype => $rs->{t}{ptype}}; # ptype is same as the last one
              push(@{$rs->{p}{parameter_order}}, $1) 
                    unless ($rs->{t}{ptype} eq "localparam");
              $rs->{p}{parameters}{$1}=$rs->{t};
	      _add_anchor($rs->{files}{$file}{anchors},$line,""); }
	      push (@{$ps->{nextStateStack}}, "PPL_AFTER_EQUALS","PARAMETER_EQUAL");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"CONFUSED"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
    PPL_AFTER_EQUALS:
        if ($code =~ m/(?:({)|(\()|(,)|(\))|($HVID)|($VID)|($VNUM)|(\"))/gos) {
          if (defined($1)) {
           print "----  -CONCAT ($1)->\n";
           $takenArcs->{'PPL_AFTER_EQUALS'}{1}++;
	      push (@{$ps->{nextStateStack}}, "PPL_AFTER_EQUALS","IN_CONCAT");
	  }
          elsif (defined($2)) {
           print "----  -BRACKET ($2)->\n";
           $takenArcs->{'PPL_AFTER_EQUALS'}{2}++;
	      push (@{$ps->{nextStateStack}}, "PPL_AFTER_EQUALS","IN_BRACKET");
	  }
          elsif (defined($3)) {
           print "----  -COMMA ($3)->\n";
           $takenArcs->{'PPL_AFTER_EQUALS'}{3}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($3));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($3));
}
$ps->{storing}=0;
$ps->{stored}='';
$rs->{t}{value} = $fromLastPos;
	      push (@{$ps->{nextStateStack}}, "PPL_PARAM_OR_NAME");
	  }
          elsif (defined($4)) {
           print "----  -END ($4)->\n";
           $takenArcs->{'PPL_AFTER_EQUALS'}{4}++;
$ps->{storing}==1 or die "fromLastPos used and storing was not set";
if ($storePos==-1) {
   $fromLastPos=$ps->{stored}.       substr($code,0,pos($code)-length($4));
}
else {
   $fromLastPos=substr($code,$storePos,pos($code)-$storePos-length($4));
}
$ps->{storing}=0;
$ps->{stored}='';
$rs->{t}{value} = $fromLastPos;
	      push (@{$ps->{nextStateStack}}, "MODULE_PORTS");
	  }
          elsif (defined($5)) {
           print "----  -HVID ($5)->\n";
           $takenArcs->{'PPL_AFTER_EQUALS'}{5}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($6)) {
           print "----  -VID ($6)->\n";
           $takenArcs->{'PPL_AFTER_EQUALS'}{6}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($7)) {
           print "----  -NUMBER ($7)->\n";
           $takenArcs->{'PPL_AFTER_EQUALS'}{7}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}");
	  }
          elsif (defined($8)) {
           print "----  -STRING ($8)->\n";
           $takenArcs->{'PPL_AFTER_EQUALS'}{8}++;
	      push (@{$ps->{nextStateStack}}, "$ps->{curState}","IN_STRING");
	  }
      }
      else { push(@{$ps->{nextStateStack}},"PPL_AFTER_EQUALS"); last  PARSE_LINE_LOOP; }
    next PARSE_LINE_LOOP;
    PPL_PARAM_OR_NAME:
        if ($code =~ m/\G(?:(\bparameter\b))/gos) {
          if (defined($1)) {
           print "----  - ($1)->\n";
           $takenArcs->{'PPL_PARAM_OR_NAME'}{1}++;
	      push (@{$ps->{nextStateStack}}, "PPL_TYPE");
	  }
      }
      else {
push(@{$ps->{nextStateStack}},"PPL_NAME"); pos($code)=$lastPos; }
    next PARSE_LINE_LOOP;
  }
  if ($storePos!=-1) { $ps->{stored}=substr($code,$storePos);}
  elsif ( $ps->{storing} ) {   $ps->{stored} .= $code; }
}
