#!/bin/sh
mydir=`dirname $0`
prefix='t'
adds='ad.txt'
pubtext="$HOME/plog/pubtext"
lentext=24
indtext='gophermap'
pubhtml="$HOME/plog/pubhtml"
lenhtml=12
indhtml='list.html'
rsshtml='rss.xml'
rsslink='http://www.example.com/blog'

while sh $mydir/pubnext.sh . $prefix $adds $pubhtml $pubtext
do :
done

cd $pubhtml

cat <<EOH >$indhtml
<html><head>
<title>most recent entries in inverse chronological order</title>
 <link rel="alternate" type="application/rss+xml"
  href="$rsslink/$rsshtml" title="RSS feed">
</head>
<body><dl>
EOH

cat <<EOH >$rsshtml
<?xml version="1.0"?><rss version="2.0">
<channel><title>blog title</title>
<description>blog description</description>
<link>$rsslink</link>
EOH

ls -1t $prefix* | head -n $lenhtml | { while read hname
do
 htit=`grep '<h1>' $hname | sed -e 's/<h1>//;s/<.h1>//;'`

 cat <<EOI >>$indhtml
 <dt><a href="$hname">$hname</a></dt>
  <dd>$htit</dd>
EOI

 cat <<EOI >>$rsshtml
 <item>
  <title>$htit</title>
  <description>
EOI

 # get some non-empty lines from the beginning, except title, and remove tags
 grep -v '<h1' $hname | sed -e 's/<[^>]*>//g;/^ *$/d' | head -n 4 >>$rsshtml

 cat <<EOI >>$rsshtml
  [...] </description>
  <link>$rsslink/$hname</link>
 </item>
EOI

done
}

cat <<EOF >>$indhtml
</dl>
<p><small>
last updated: `date -u`
</small></p></body></html>
EOF

echo '</channel></rss>' >>$rsshtml

chmod a+r $indhtml $rsshtml
cd -

cd $pubtext
cat <<EOH >$indtext
most recent entries in inverse chronological order
EOH
ls -1t $prefix* | head -n $lentext | { while read tname
do
 fline=`head -n 1 $tname | sed -e 's/^ *//;s/\(.\{50\}\).*/\1.../'`
 echo "0$fline	./$tname" >>$indtext
done
}
chmod a+r $indtext
cd -
