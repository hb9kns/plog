#!/bin/sh
# script to process all files in current directory with pubnext.sh
# (2015 YCB)
mydir=`dirname $0`
# working directory, use current if empty:
wdir="${1:-.}"
# pattern to look for files that may be processed:
prefix='t'
# list of e-mail addresses:
adds='ad.txt'
# directory to save text files for publication:
pubtext="$HOME/plog/pubtext"
# number of text files to be included in the index:
lentext=24
# name of index file for text:
indtext='gophermap'
# directory to save HTML/blog files for publication:
pubhtml="$HOME/plog/pubhtml"
# number of HTML files to be included in the index:
lenhtml=12
# name of index file for HTML/blog:
indhtml='list.html'
# name of RSS file (to be saved in $pubhtml):
rsshtml='rss.xml'
# base name of HTML/blog directory (from outside):
rsslink='http://www.example.com/blog'

# process all possible files in the working directory
while sh $mydir/pubnext.sh "$wdir" $prefix $adds $pubhtml $pubtext
do : # colon is a shell NO-OP
done

# now create HTML/blog index
cd $pubhtml

# index header
cat <<EOH >$indhtml
<html><head>
<title>most recent entries in inverse chronological order</title>
 <link rel="alternate" type="application/rss+xml"
  href="$rsslink/$rsshtml" title="RSS feed">
</head>
<body><dl>
EOH

# RSS header
cat <<EOH >$rsshtml
<?xml version="1.0"?><rss version="2.0">
<channel><title>blog title</title>
<description>blog description</description>
<link>$rsslink</link>
EOH

# list all possible file names in chronological order, take first $lenhtml ones
ls -1t $prefix* | head -n $lenhtml | { while read hname
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
  <link>$rsslink/$hname</link>
 </item>
EOI

done
}

# index footer
cat <<EOF >>$indhtml
</dl>
<p><small>
last updated: `date -u`
</small></p></body></html>
EOF

# RSS footer
echo '</channel></rss>' >>$rsshtml

# make index and RSS world readable, and return to previous directory
chmod a+r $indhtml $rsshtml
cd -

# create text (Gopher) index
cd $pubtext

# index header
cat <<EOH >$indtext
most recent entries in inverse chronological order
EOH

# list all possible file names in chronological order, take first $lentext ones
ls -1t $prefix* | head -n $lentext | { while read tname
do
 # take up to 50 chars from first line as excerpt
 fline=`head -n 1 $tname | sed -e 's/^ *//;s/\(.\{50\}\).*/\1.../'`
 # create index entry
 echo "0$fline	./$tname" >>$indtext
done
}

# make index world readable, and return to previous directory (cosmetics..)
chmod a+r $indtext
cd -
