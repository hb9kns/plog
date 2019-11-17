#!/bin/sh
# script to install a post-update githook running allpub.sh
#
# Copyright 2019 Yargo Bonetti
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
githook=hooks/post-update
myself=`basename "$0"`
ver='3.0'
wdir="${1:-.}" # working directory, current if empty

# go to dir of this script, get absolute path, and return to where we've been
mydir=`dirname "$0"`
cd "$mydir"
mydir=`pwd -P`
cd - >/dev/null

ggr=$mydir/.git
if test ! -d $ggr
then echo "$ggr does not exist, aborting!"
 echo "(i.e, $mydir is not a git working directory)"
 exit 1
else echo "installing $ggr/$githook ..."
fi
# hook script in bare repo: pull updated content into working directory
# and execute allpub.sh here
 cat <<EOH >$ggr/$githook
#!/bin/sh
# hook installed by $0
echo post-update:
unset GIT_DIR
cd "$mydir" && git pull origin master && git checkout . && sh "$mydir/allpub.sh"
EOH
