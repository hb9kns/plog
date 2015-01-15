#!/bin/sh
# script to generate HTML and text (Gopher) file from Markdown formatted text
# and to send e-mails containing both to a list of recipients
#
# Copyright 2015 Yargo Bonetti
#
# This file is part of plog.
# 
# plog is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with plog.  If not, see <http://www.gnu.org/licenses/>.
#
myself=`basename "$0"`
mydir=`dirname "$0"`
ver='2.1'
wdir="${1:-.}" # working directory, current if empty
cfgf="$wdir/.plog.rc" # config file

### following values might be overridden by $cfgf
subject='[newsletter]' # prefix for mail subject
fprefix='t' # prefix for source file names
adds='ad.txt' # address list for recipients
pubhtml='' # directory to save result from HTML conversion
pubtext='' # directory to save result from text conversion
draft='DRAFT' # mark for draft texts (must be at beginning of one line)
arch='Archiv' # archive directory for processed texts
htmlhead='<HTML><BODY>'
htmlfoot="</BODY><!-- generated by $myself --></HTML>"
logfile='_pubnext.log'
convert1='mrkdwn.pl' # markdown to HTML converter
convert2='lynx -display_charset=US-ASCII -force-html -dump' # HTML to text
mailer=mailx # mail program
tmpf1='_pubnext.html'
tmpf2='_pubnext.txt'
lockf='.pubnext.lock' # lockfile

# source config file, if readable
if test -r "$cfgf"
then . "$cfgf"
fi

# in general, nothing should be modified below this line
donefile='' # name of sent file

# if no argument given, print usage information
if test "$1" = ""
then cat <<EOH >&2

    This is $myself, Version $ver
    Copyright (C) 2015 Yargo Bonetti
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions. See COPYING.txt for further information.

usage: $myself <dir> [<prefix> <addressfile> <pubhtml> <pubtext>]
 will change to directory <dir>, and send first <text> with <prefix> to all
 addresses in <addressfile>,
 after Markdown conversion with $convert1
 (adding html&body tags for standalone HTML file),
 and HTML-text conversion with $convert2,
 and copy the text to <pubhtml> as HTML and to <pubtext> as pure text
 (with .html/.txt suffixes, respectively, ignoring nonexistent directories),
 and do "git mv <text> $arch" afterwards (or just "mv", unless .git present)

 configuration is taken from <dir>/.plog.rc

 only texts not containing "$draft" at beginning of lines will be considered

 addressfile contains one address per line, lines with leading # are ignored

 return value 0 if <text> found and processed, >0 otherwise
 (logging into $logfile, lockfile $lockf)

EOH
exit 1
fi

logit () { echo "$@" >>$logfile ; }

abort () { # end script and remove lockfile, if return code higher than 9
 exc=$1
 shift
 logit "abort: $@" # log all remaining arguments
 if test $exc -gt 9 # if first arg>9
 then rm -f $lockf
 fi
 # report to stdout, will generate e-mail if launched by cronjob
 echo "tail $logfile:"
 tail $logfile
 exit $exc
}

# go to dir of this script, get absolute path, and return to where we've been
cd "$mydir"
mydir=`pwd -P`
cd - >/dev/null

# if it's not a directory where we can execute and write and read
if test ! -x "$wdir" -o ! -w "$wdir" -o ! -r "$wdir" -o ! -d "$wdir"
then abort 5 "$wdir is not a fully accessible directory"
fi

cd "$wdir"

# just fail if there is a lock file
# very dumb logic, could be improved with timeout and retry
if test -f $lockf
then abort 6 "lockfile $lockf exists"
fi

now=`date -u`
echo "lockfile for $myself with PID $$" >$lockf
echo "at $now" >>$lockf
echo >$tmpf1 # create empty file

logit starting at $now in `pwd -P`

fprefix=${2:-$fprefix}
logit looking for files with prefix $fprefix
adds=${3:-$adds}
logit looking for mailing addresses in $adds

# only log if pubhtml or pubtext are non-empty (ignore empty ones)
pubhtml=${4:-$pubhtml}
if test "$pubhtml" != ""
then logit directory for saving HTML files: $pubhtml
fi
pubtext=${5:-$pubtext}
if test "$pubtext" != ""
then logit directory for saving text files: $pubtext
fi

# try to update from remote repo
# very dumb, may fail spectacularly if git is not installed
git pull >/dev/null 2>&1

# process all files with names beginning with $fprefix
ls -1 $fprefix* 2>/dev/null | { while read fn
do
 if ! grep "^$draft" "$fn" >/dev/null 2>&1
 then # if no draft flag found in text
  logit processing $fn
  echo "$htmlhead" >$tmpf1 # start with HTML file header
  # convert markdown to html, and replace German lower case umlauts (UTF8)
  # (might be improved with a separate character conversion list)
  "$mydir/$convert1" "$fn" |
   sed -e 's/ä/\&auml;/g;s/ö/\&ouml;/g;s/ü/\&uuml;/g' >>$tmpf1
  # get title from first <h1> header and remove all tags
  titl=`grep '<h1' $tmpf1 | head -n 1 | sed -e 's/<[^>]*>//g'`
  echo "$htmlfoot" >>$tmpf1 # finish with HTML footer
  # now generate text from HTML version
  $convert2 $tmpf1 >$tmpf2
  logit sending to
  # remove comments and empty lines from address list, and send e-mails
  sed -e 's/[ 	]*[#;].*//;/^$/d' $adds | { while read adrow
   do logit : $adrow
   $mailer -a $tmpf1 -s "$subject $titl" $adrow <$tmpf2
   done
   }
  # remove suffix from filename
  namebase=${fn%.*}
  # copy HTML version into pubhtml and make world readable
  if test "$pubhtml" != ""
  then
   cat $tmpf1 >$pubhtml/$namebase.html 2>/dev/null &&
     chmod a+r $pubhtml/$namebase.html 2>/dev/null
  fi
  # copy text version into pubtext and make world readable
  if test "$pubtext" != ""
  then
   cat $tmpf2 >$pubtext/$namebase.txt 2>/dev/null &&
     chmod a+r $pubtext/$namebase.txt 2>/dev/null
  fi
  logit done with $fn
  # we are here in a subshell, therefore
  # save name of processed file for enclosing script
  # (at this point, we don't need $tmpf1 any more, therefore recycle)
  echo $fn >$tmpf1
  break
 else logit ignoring draft $fn
 fi
done
}

# get name of processed file
donefile=`cat $tmpf1`
if test ! -r "$donefile" # if that is not a readable file
then
 logit no file found and nothing processed
 retval=1 # return value FALSE if nothing processed
else
 retval=0 # else return value TRUE
 # try moving processed file with git into archive
 if git mv "$donefile" $arch >/dev/null 2>&1
 then logit git mv done
  # add modified logfile to commit
  git add $logfile
  # commit and push archived text file
  git commit -m ": $myself processing $wdir/$donefile" >/dev/null 2>&1 && logit git commit done
  sleep 5 # wait a bit, to let file system finish its work after git
  git push >/dev/null 2>&1 && logit git push done
 else # simply use mv for archiving
  mv "$donefile" $arch && logit mv into $arch done
 fi
fi

rm -f $lockf
logit finished.
echo >>$logfile # empty line in logfile increases readability
exit $retval # report back return value: allpub.sh uses this for while-loop
