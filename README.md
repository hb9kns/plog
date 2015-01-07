# plog

## Overview

Plog is a suite of some scripts to be run on a UNIX server for handling
Markdown formatted blogs, glogs, and email newsletters with Git.

An example of the generated output can be found at my personal
[blog]( http://yargo.andropov.org/blog/list.html ) and
[glog]( gopher://sdf.org/1/users/yargo ) sites.

### Notes about the Gopher protocol

Please note that _most browsers_ are unfortunately _incapable_ of displaying
[Gopher]( http://gopherproject.org ) links!

There is a fine
[Public Gopher Proxy]( http://gopher.floodgap.com/gopher/ )
on [Floodgap]( http://www.floodgap.com ) for those crippled browsers.
Therefore, if the direct gopher link above does not work,
you may try to access it
[via proxy]( http://gopher.floodgap.com/gopher/gw.lite?sdf.org/1/users/yargo ).

If you are using Seamonkey or Firefox, you may try the "OverbiteFF" add-on
for Gopher functionality. Overbite also is available for Android, via gopherproject.org or Floodgap.

---

## Installation and Usage

_WORK IN PROGRESS_

### prerequisites

The plog suite mainly consists of the (sh/bash) shell scripts `pubnext.sh` and `allpub.sh`, and some configuration files and a suitable directory structure.

It makes use of the standard command line tools like `grep` and `sed` available on almost all Unix systems.

In addition, it needs `perl` (version 5.6) for Markdown-HTML conversion (and of course the corresponding script `mrkdwn.pl` included in the plog suite), and `lynx` for HTML-text conversion. _If there is sufficient interest, I may be motivated to enhance the scripts for graceful fallbacks to simple plain text processing -- just send me a note in that case!_

`git` is used to `git mv` the processed files to an archive directory; however, in case of failure, the scripts should gracefully switch to a simple `mv`.


---

_2015-1-7,YCB_
