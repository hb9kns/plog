#!/bin/sh
# mark some tags for textual output
sed -e 's,<em>,<em>_,g
 s,</em>,_</em>,g
 s,<strong>,<strong>**,g
 s,</strong>,**</strong>,g'
