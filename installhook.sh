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
ver='3.0'
if test $# -ne 2
then cat <<EOH
usage: $0 <repo> <working>	(ver.$ver / 2019-11-26 / HB9KNS)
 will install into a (bare) git <repo> a git post-update hook pointing to
 allpub.sh (and companion scripts) in the directory of $0,
 while the <working> directory is where contents of <repo> will be pulled
 to when updating the latter
 (absolute paths for <repo> and <working> might be safest)
EOH
 exit 0
fi

githook=hooks/post-update
myself=`basename "$0"`
repo="$1"
wrkg="$2"

# go to dir of this script, get absolute path, and return to where we've been
mydir=`dirname "$0"`
cd "$mydir"
mydir=`pwd -P`
cd - >/dev/null

cat <<EOT
: scriptdir	$mydir
: repo dir	$repo
: working dir	$wrkg
: installing git-hook ...
EOT

# check whether repo and wrkg directories exist
if test -d "$repo" -a -d "$wrkg"
# check whether subdirectory for hooks exists
then if test ! -d "$repo/${githook%/*}"
then
  echo "missing $repo/${githook%/*} directory, aborting!"
  exit 2
else
# hook script in bare repo: pull updated content into working directory
# and execute allpub.sh here
 cat <<EOH > "$repo/$githook"
#!/bin/sh
# hook installed by $0
echo post-update:
unset GIT_DIR
cd "$wrkg" && git pull origin master && git checkout . && sh "$mydir/allpub.sh"
EOH
 chmod a+rx "$repo/$githook"
 echo ": done!"
fi
else
 echo "arguments aren't existing directories, aborting!"
 exit 1
fi
