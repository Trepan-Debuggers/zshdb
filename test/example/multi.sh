#!/bin/zsh
# Test debugger handling of lines  with multiple commands per line 
# and subshells in a line

x=1; y=2; z=3
(builtin cd  . ; x=`builtin echo *`; (builtin echo "ho") )
case `builtin echo "testing"; builtin echo 1,2,3`,`builtin echo 1,2,3` in
  *c*,-n*) ECHO_N= ECHO_C='
' ECHO_T='	' ;;
  *c*,*  ) ECHO_N=-n ECHO_C= ECHO_T= ;;
  *)       ECHO_N= ECHO_C='\c' ECHO_T= ;;
esac

(builtin cd  . ; x=`builtin echo *`; (builtin echo "ho") )

x=5; y=6;
