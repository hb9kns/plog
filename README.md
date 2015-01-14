# plog

*Please note: there is now one common configuration file .plog.rc.*
*It is not part of the suite, but a template file progrc.template is*
*included, which should be copied to .plog.rc during setup.*

*ToDo: There is still missing a nice example of a working setup!*
*It will be added soon, to help in understanding the system.*

## Overview

Plog is a suite of some scripts to be run on a UNIX server for handling
Markdown formatted blogs, glogs, and email newsletters with Git.

An example of the generated output can be found at my personal
[blog]( http://yargo.andropov.org/blog/list.html ) and
[glog]( gopher://sdf.org/1/users/yargo ) sites.

This is describing version 2.1 of the suite.

### Notes about the Gopher protocol

Please note that _most browsers_ are unfortunately _incapable_ of displaying
[Gopher]( http://gopherproject.org ) links!

There is a fine
[Public Gopher Proxy]( http://gopher.floodgap.com/gopher/ )
on [Floodgap]( http://www.floodgap.com ) for those crippled browsers.
Therefore, if the direct gopher link above does not work,
you may try to access it
[via proxy]( http://gopher.floodgap.com/gopher/gw.lite?sdf.org/1/users/yargo ).

If you are using Seamonkey or Firefox, you may try the "OverbiteFF"
add-on for Gopher functionality. Overbite also is available for Android,
via gopherproject.org or Floodgap.

---

## Installation and Usage

### Prerequisites

The plog suite mainly consists of the (sh/bash) shell scripts `pubnext.sh`
and `allpub.sh`, a configuration file, and a suitable directory structure.

It makes use of the standard command line tools like `grep` and `sed`
available on almost all Unix systems.

In addition, it needs `perl` (version 5.6) for Markdown-HTML conversion
(and of course the corresponding script `mrkdwn.pl` included in the plog
suite), and `lynx` for HTML-text conversion.

`git` is used to `git mv` the processed files to an archive directory;
however, in case of failure, the scripts should gracefully switch to a
simple `mv`.

The main scripts `pubnext.sh, mrkdwn.pl, allpub.sh` should be installed
in the same directory.

### Customisation of scripts with `.plog.rc`

The two shell scripts have some variables set at the beginning, which
should be configured to your needs.

They can be used for processing several collections of postings through
the run-time argument of the working directory (see below). In case you
need very different configuration, you can simply copy the scripts and
use different instances for different collections.

The scripts share a common configuration file `.plog.rc`, which has to
be in the same directory as the scripts themselves. It is basically an
additional shell script which is executed at the beginning of each of the
other scripts, but after setting of the variables. This way, values set
in the configuration file will override the defaults hardcoded in scripts.

In the plog suite, there is a `plogrc.template` file, which can be copied
into `.plog.rc`, and modified according to your needs.

Here is a copy of the current template file, followed
by a detailed description of all used variables.

	## Template file for plog configuration
	## Please copy as .plog.rc and modify as needed!
	
	# list of e-mail addresses
	adds='ad.txt'
	
	# directory to save text files for publication
	pubtext="$HOME/plog/pubtext"
	# number of text files to be included in the index
	lentext=24
	# name of index file for text
	indtext='gophermap'
	# header for text index file
	indtexthead='most recent entries in reverse chronological order'
	
	# directory to save HTML files for publication
	pubhtml="$HOME/plog/pubhtml"
	# number of HTML files to be included in the index
	lenhtml=12
	# name of index file for HTML/blog
	indhtml='list.html'
	# title in index file for HTML/blog
	indhtmltitle='blog title'
	# name of RSS file (to be saved in $pubhtml):
	rsshtml='rss.xml'
	# title in RSS file
	rsstitle='blog feed'
	# description in RSS file
	rssdesc='blog description'
	
	# base name of HTML/blog directory (from outside):
	baselink='http://www.example.com/blog'
	
	# prefix for mail subject
	subject='[newsletter]'
	
	# prefix for text file names
	fprefix='t'
	
	# mark for draft texts (must be at beginning of one line)
	draft='DRAFT'
	
	# archive directory for processed texts
	arch='Archiv'
	
	htmlhead='<HTML><BODY>'
	htmlfoot="</BODY><!-- generated by $myself --></HTML>"
	
	logfile='_pubnext.log'
	
	# markdown to HTML converter
	convert1='mrkdwn.pl'
	# HTML to text converter
	convert2='lynx -display_charset=US-ASCII -force-html -dump'
	# e-mail transmission program
	mailer=mailx
	# mailer="logit ::" # test dummy
	
	# temporary file for saving HTML file
	tmpf1='_pubnext.html'
	# temporary file for saving text file
	tmpf2='_pubnext.txt'
	
	# lockfile
	lockf='.pubnext.lock'

- `adds` is a string with the name of the address file of the e-mail recipients
- `pubtext` is a directory, where pure text versions and (by `allpub.sh`)
  an index file suitable for a gopher server will be saved
- `lentext` is the maximum number of text version posts that will be indexed
- `indtext` is the name of the index file for pure text version; if you are
  planning to use it as gopher index, it probably should be called `gophermap`
- `indtexthead` is inserted at the beginning of the index file, as description
- `pubhtml`, `lenhtml`, and `indhtml` are parameters analogous to their
  text counterparts, but for the HTML files and index
- `rsshtml` is the filename for an RSS feed; in most cases `rss.xml` is best
- `rsstitle` and `rssdesc` are title and description inserted in the RSS file
- `baselink` is the basename of the blog directory as accessible from outside
  (i.e, not the possibly different name for accessing it from your shell)
- `subject` is a string prepended to e-mail subjects,
  and could serve as a flag for the recipients
- `fprefix` is a string with the beginning of filenames to be
  considered as texts to be processed (e.g 'text', 'post',
  whatever) -- but make sure it does not match other files
  in the working directory, like the archive directory,
  address files, or log and temporary files!
- `draft` contains the string that should mark draft texts
  which are not (yet) to be published; it is used as a
  `grep` pattern, so be careful with punctuation
- `arch` denotes a directory (must be writable of course)
  where postings (input text/Markdown files) are moved,
  after being processed and published
- `htmlhead` defines the string prepended to the files
  resulting from Markdown-HTML conversion
- `htmlfoot` is the analogue for the ending of these files
- `logfile` is the file logging all activity by `pubnext.sh`
- `convert1` is the script for Markdown-HTML conversion
- `convert2` is the script for HTML-text conversion
- `mailer` is the program for transmitting e-mail
- `tmpf1` and `tmpf2` are temporary files
- `lockf` is the lockfile used to control execution of `pubnext.sh`

*Please note:*

- arguments for `fprefix`, `adds`, `pubhtml`, `pubtext` can be given to
  `pubnext.sh` on the command line, overriding the settings in the script
- a single argument can be given to `allpub.sh`, indicating the working
  directory where the source (Markdown formatted) files are stored; it will
  be passed on to `pubnext.sh`, and if empty, the current directory is used
- all directories are *relative to the working directory*
  given as first (and mandatory) argument to the scripts
- to have only plaintext functionality without Markdown and HTML conversion,
  set `convert1` and `convert2` both to `cat`

### Usage considerations

#### Directories

In any case, you need a directory (the "working directory"), where the
source texts (Markdown formatted) are stored. Typically, this would be
inside of a directory which is version controlled by Git, but plog should
still work without that. In this directory, all its subdirectories, and
additional directories needed for publication, the plog scripts (either
launched manually by you or by some automatic process like a cron job)
in principal need complete access permission (read, write, and execute).

As a subdirectory, you should set up the archive directory, and you have
to accordingly set the variable `arch` in `pubnext.sh`.

#### File names for "posts", or source texts

Next, you have to choose how to name your source files: they all need
a common prefix, so that plog knows what to look for. *Please make sure
not to use a prefix that would match any of the additional files or
directories residing in the working directory, or the scripts may crash or
even destroy necessary files or get into an infinite loop!* Good choices
might be simply `t`, or `text`, or `post`, or any letter combination
not including the address file; don't use any punctuation, except for
`-` or `_` after at least one letter.

Set this prefix as a pattern in the configuration variable `tprefix`.
(The file suffix is irrelevant: They will all be treated as text files.)

`pubnext.sh` will generate the list of all files matching the prefix
pattern, and then process the first file in that list which does
*not* bear the "draft pattern" as defined by its `draft` variable. If
you want to have your files processed in a certain order, you should
therefore name them in such a way that the lexical order of their names
corresponds to the desired processing order. An example would be naming
them as `pYYMMDDI`, where `YYMMDD` is indicating year, month, and day of
writing, with a possible additional index letter `I`, or `text_NNN.md`
with a numerical index `NNN`.

#### E-mail addresses

If you want to send an e-mail newsletter, you have to list the recipient
addresses in a file whose name needs to be set in the `adds` variables of
the scripts.

This file should be a simple text file with one recipient address per
line. Lines beginning with `#` are ignored and can be used for comments.
However, never use `#` after an address: it would be part of the latter!

If you do not need the newsletter functionality, you *still have to have
an address file!* It can be empty (or only contain comment lines),
but it *must be present and readable.*

#### Script execution

Both `allpub.sh` and `pubnext.sh` can of course be executed manually.
However, in most cases, it might be more useful to launch them automatically,
e.g from a daily or weekly cron job.

`pubnext.sh` processes just the next available (non-draft) post, and send it
in processed (HTML and pure text) form to all e-mail recipients, and save the
processed forms in the appropriate directories for later use (blog/glog
publication).

`allpub.sh` will call `pubnext.sh` repeatedly, until the latter cannot find
any available post, and then generate index files in HTML and pure text
version for publication as blog and glog.

#### Publication (blog/glog)

As it might not be desirable to publish the generated HTML and pure text
files (together with their respective index files) as the same user who
launched the plog scripts, a copying step for the final publication may
be necessary.

A possible solution is given in the script `allsync.sh`. It simply uses
`rsync` to pull the files from a "remote" directory (which of course may
be on the same machine) to a "local" directory, and make all of them world
readable. Also a simple `cp` could of course be used, but `rsync` only
copies files which are not yet present in the target ("local") directory.

If you want to make use of `allsync.sh`, please set its variables
according to your working and publication directories! You should
understand how `rsync` is working before doing so, though.

---

_2015-Jan-10 YB_

    # Copyright 2015 Yargo Bonetti
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
