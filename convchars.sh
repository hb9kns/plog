#!/bin/sh
# convert some special characters to HTML
sed -e 's/°/\&deg;/g
 s/ -- / \&mdash; /g
 s/à/\&agrave;/g
 s/ä/\&auml;/g
 s/ö/\&ouml;/g
 s/ü/\&uuml;/g
 s/Ä/\&Auml;/g
 s/Ö/\&Ouml;/g
 s/Ü/\&Uuml;/g
 s/ß/\&szlig;/g
 s/§/\&sect;/g' | tr -c '
 -~	' :
# finish with translation of all other special chars (except whitespace) to :
