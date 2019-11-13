#!/bin/sh
# convert some special characters to HTML
export LC_ALL=C
sed -e 's/°/\&deg;/g
 s/ -- / \&mdash; /g
 s/^------* *$/<div style="page-break-before:always"> <\/div>\
-----/
 s/à/\&agrave;/g
 s/ä/\&auml;/g
 s/ö/\&ouml;/g
 s/ü/\&uuml;/g
 s/�/\&auml;/g
 s/�/\&ouml;/g
 s/�/\&uuml;/g
 s/Ä/\&Auml;/g
 s/Ö/\&Ouml;/g
 s/Ü/\&Uuml;/g
 s/ß/\&szlig;/g
 s/§/\&sect;/g' | tr -c '
 -~	' :
# finish with translation of all other special chars (except whitespace) to :
