#!/bin/sh
# sync script (2015 YB)
# rem... are directories, where pubnext.sh or allpub.sh have created files
rem=/home/otheruser/plog
remhtml=$rem/pubhtml
remtext=$rem/pubtext
# loc... are directories, where files shall be published as blog/glog
lochtml=$HOME/html/blog
loctext=$HOME/gopher/glog

# sync all remote blog files into local publication directory
rsync $remhtml/* $lochtml
# make them world readable
chmod a+r $lochtml/*
# sync all remote text/glog files into local publication directory
rsync $remtext/* $loctext
# make them world readable
chmod a+r $loctext/*
