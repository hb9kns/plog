#!/bin/sh
# script to process all files in current directory with pubnext.sh
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
# plog is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with plog.  If not, see <http://www.gnu.org/licenses/>.
#
myself=`basename "$0"`
ver='2.1'
wdir="${1:-.}" # working directory, current if empty

# go to dir of this script, get absolute path, and return to where we've been
mydir=`dirname "$0"`
cd "$mydir"
mydir=`pwd -P`
cd - >/dev/null

# configuration file
cfgf="$wdir/.plog.rc"

### following values might be overridden by contents of $cfgf
# pattern to look for files that may be processed:
fprefix='t'
# list of e-mail addresses:
adds='ad.txt'
# directory to save text files for publication:
pubtext="$HOME/plog/pubtext"
# number of text files to be included in the index:
lentext=24
# name of index file for text:
indtext='gophermap'
# header line in index file
indtexthead='most recent entries in reverse chronological order'
# directory to save HTML/blog files for publication:
pubhtml="$HOME/plog/pubhtml"
# number of HTML files to be included in the index:
lenhtml=12
# name of index file for HTML/blog:
indhtml='list.html'
# title in index file for HTML/blog
indhtmltitle='blog title'
# name of RSS file (to be saved in $pubhtml):
rsshtml='rss.xml'
# title of RSS file
rsstitle='blog feed'
# description of RSS file
rssdesc='blog description'
# base name of HTML/blog directory (from outside):
baselink='http://www.example.com/blog'

# source config file, if readable
if test -r "$cfgf"
then . "$cfgf"
fi

# process all possible files in the working directory
while sh $mydir/pubnext.sh "$wdir" $fprefix $adds $pubhtml $pubtext
do : # colon is a shell NO-OP
done

# all directories are relative to wdir (or absolute)
cd "$wdir"

# now create HTML/blog index
cd "$pubhtml"

# index header
cat <<EOH >$indhtml
<html><head>
<title>$indhtmltitle</title>
 <link rel="alternate" type="application/rss+xml"
  href="$baselink/$rsshtml" title="RSS feed">
</head>
<body><dl>
EOH

# RSS header
cat <<EOH >$rsshtml
<?xml version="1.0"?><rss version="2.0">
<channel><title>$rsstitle</title>
<description>$rssdesc</description>
<link>$baselink</link>
EOH

# list all possible file names in chronological order, take first $lenhtml ones
ls -1t $fprefix* | head -n $lenhtml | { while read hname
do
 # look for first <h1> tag and take its contents as title:
 htit=`grep '<h1' $hname | head -n 1 | sed -e 's/<h1>//;s/<.h1>//;'`
 # create index entry
 cat <<EOI >>$indhtml
 <dt><a href="$hname">$hname</a></dt>
  <dd>$htit</dd>
EOI
 # start RSS entry
 cat <<EOI >>$rsshtml
 <item>
  <title>$htit</title>
  <description>
EOI

 # get non-title lines, remove tags, and take first four ones as excerpt
 grep -v '<h1' $hname | sed -e 's/<[^>]*>//g;/^ *$/d' | head -n 4 >>$rsshtml

 # end RSS entry
 cat <<EOI >>$rsshtml
  [...] </description>
  <link>$baselink/$hname</link>
 </item>
EOI

done
}

# index footer
cat <<EOF >>$indhtml
</dl>
<p><small>
updated `date -u` :: by $myself v$ver
</small></p></body></html>
EOF

# RSS footer
echo '</channel></rss>' >>$rsshtml

# make index and RSS world readable, and return to previous directory
chmod a+r $indhtml $rsshtml
cd - >/dev/null

# create text (Gopher) index
cd "$pubtext"

# index header
echo "$indtexthead" >$indtext

# list all possible file names in chronological order, take first $lentext ones
ls -1t $fprefix* | head -n $lentext | { while read tname
do
 # take up to 50 chars from first line as excerpt
 fline=`head -n 1 $tname | sed -e 's/^ *//;s/\(.\{50\}\).*/\1.../'`
 # count words, removing whitespace
 wcnt=`cat $tname | wc -w | ( read wcw _; echo $wcw; )`
 # create gopher index entry with word count (note: <TAB> before ./$tname)
 echo "0$fline [$wcnt words]	./$tname" >>$indtext
done
}

echo "updated `date -u` :: by $myself v$ver" >>$indtext

# make index world readable, and return to previous directory (cosmetics..)
chmod a+r $indtext
cd - >/dev/null
