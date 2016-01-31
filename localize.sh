#!/bin/bash

PREFIX=/var/www/html/PHPCI

for A in `ls -1 localization`
do
  FILENAME=0
  while read line
  do
    if [ $FILENAME == 0 ] 
    then
      FILENAME=$line
      echo "======================================="
      echo "Processing $FILENAME"
      if [[ $FILENAME =~ ^.*View.*$ ]]
      then
        TYPE=View
      else
        TYPE=Controller
      fi
      cat $PREFIX/$FILENAME | grep Lang\; >/dev/null
      if [ $? != 0 ]
      then 
        sed -i '1 i <?php use PHPCI\\Helper\\Lang; ?>' $PREFIX/$FILENAME
      fi
    else
      LOC="`echo $line | awk -F'=' '{ print $1 }'`"
      REP="`echo $line | awk -F'=' '{ print $2 }'`"
      if [ "$TYPE" == 'View' ]
      then
        if [[ $LOC =~ ^.*\+.*$ ]]
        then
       	  TAG="`echo $LOC | awk -F'+' ' {print $1 }'`"
          STR="`echo $LOC | awk -F'+' ' {print $2 }'`"
	  sed -i "s~<\($TAG.*>\)\s*$STR\s*</$TAG>~<\1<?php Lang::out('$REP'); ?></$TAG>~g" $PREFIX/$FILENAME
        else
          sed -i "s~$LOC~<?php Lang::out('$REP'); ?>~g" $PREFIX/$FILENAME
        fi
      else
        sed -i "s~'$LOC'~Lang::get('$REP')~g" $PREFIX/$FILENAME
      fi
    fi
  done <localization/$A
done
