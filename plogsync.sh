#!/bin/sh
rem=/home/otheruser/plog
remhtml=$rem/pubhtml
remtext=$rem/pubtext
lochtml=$HOME/html/blog
loctext=$HOME/gopher/glog

rsync $remhtml/* $lochtml
chmod a+r $lochtml/*
rsync $remtext/* $loctext
chmod a+r $loctext/*
