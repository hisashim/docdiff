# DocDiff

2000-12-09..2011-02-23 Hisashi MORITA

## Todo

* Incorporate ignore space patch.
* Better auto-recognition of encodings and eols.
* Make CSS and tty escape sequence customizable in config files.
* Better multilingualization using Ruby 1.9 feature.
* Write "DocPatch".


## Description

Compares two text files by word, by character, or by line

## Summary

DocDiff compares two text files and shows the difference.  It can compare files word by word, character by character, or line by line.  It has several output formats such as HTML, tty, Manued, or user-defined markup.

It supports several encodings and end-of-line characters, including ASCII (and other single byte encodings such as ISO-8859-*), UTF-8, EUC-JP, Shift_JIS, CR, LF, and CRLF.


## Requirement

* Ruby (http://www.ruby-lang.org)
  (Note that you may need additional ruby library such as iconv, if your OS's Ruby package does not include those.)

## Installation

Note that you need appropriate permission for proper installation (you may have to have a root/administrator privilege).

* Place `docdiff/` directory and its contents to ruby library directory, so that ruby interpreter can load them.

```
# cp -r docdiff /usr/lib/ruby/1.9.1
```

* Place `docdiff.rb` in command binary directory.

```
# cp docdiff.rb /usr/bin/
```

* (Optional) You may want to rename it to `docdiff`.

```
# mv /usr/bin/docdiff.rb /usr/bin/docdiff
```

* (Optional) When invoked as `chardiff` or `worddiff`, docdiff runs with resolution set to `char` or `word`, respectively.

```
# ln -s /usr/bin/docdiff.rb /usr/bin/chardiff.rb
# ln -s /usr/bin/docdiff.rb /usr/bin/worddiff.rb
```

* Set appropriate permission.

```
# chmod +x /usr/bin/docdiff.rb
```

* (Optional) If you want site-wide configuration file, place `docdiff.conf.example` as `/etc/docdiff/docdiff.conf` and edit it.

```
# cp docdiff.conf.example /etc/docdiff.conf
# $EDITOR /etc/docdiff.conf
```

* (Optional) If you want per-user configuration file, place `docdiff.conf.example` as `~/etc/docdiff/docdiff.conf` and edit it.

```
% cp docdiff.conf.example ~/etc/docdiff.conf
% $EDITOR ~/etc/docdiff.conf
```

## Usage

### Synopsis

    % docdiff [options] oldfile newfile

e.g.

    % docdiff old.txt new.txt > diff.html

See the help message for detail (`docdiff --help`).

## License

This software is distributed under so-called modified BSD style license (http://www.opensource.org/licenses/bsd-license.php (without advertisement clause)).  By contributing to this software, you agree that your contribution may be incorporated under the same license.

Copyright and condition of use of main portion of the source:

```
Copyright (C) Hisashi MORITA.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of the University nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
```

diff library (`docdiff/diff.rb` and `docdiff/diff/*`) was originally a part of Ruby/CVS by Akira TANAKA.
Ruby/CVS is licensed under modified BSD style license.
See the following for detail.

* http://raa.ruby-lang.org/list.rhtml?name=ruby-cvs
* http://cvs.m17n.org/~akr/ruby-cvs/

## Credits

* Hisashi MORITA (primary author)

## Acknowledgments

* Akira TANAKA (diff library author)</li>
* Shin'ichiro HARA (initial idea and algorithm suggestion)</li>
* Masatoshi SEKI (patch)</li>
* Akira YAMADA (patch, Debian package)</li>
* Kenshi MUTO (testing, bug report, Debian package)</li>
* Kazuhiro NISHIYAMA (bug report)</li>
* Hiroshi OHKUBO (bug report)</li>
* Shugo MAEDA (bug report)</li>
* Kazuhiko (patch)</li>


## Resources

### Format

* HTML/XHTML http://www.w3.org
* tty (Graphic rendition using VT100 / ANSI escape sequence)
    * VT100: http://vt100.net/docs/tp83/appendixb.html
    * ANSI: http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
* Manued (Manuscript Editing language: a proofreading method for text)
    * http://www.archi.is.tohoku.ac.jp/~yamauchi/otherprojects/manued/index.shtml

=== Similar Software

There are several other software that can compare text word by word and/or character by character.

* GNU wdiff (Seems to support single byte characters only.)
     http://www.gnu.org/directory/GNU/wdiff.html
* cdif by Kazumasa UTASHIRO (Supports several Japanese encodings.)
     http://srekcah.org/~utashiro/perl/scripts/cdif
* ediff for Emacsen
     http://www.xemacs.org/Documentation/packages/html/ediff.html
* diff-detail for xyzzy, by Hiroshi OHKUBO
     http://ohkubo.s53.xrea.com/xyzzy/index.html#diff-detail
* Manuediff (Outputs difference in Manued format.)
     http://hibiki.miyagi-ct.ac.jp/~suzuki/comp/export/manuediff.html
* YASDiff (Yet Another Scheme powered diff) by Y. Fujisawa
     http://nnri.dip.jp/~yf/cgi-bin/yaswiki2.cgi?name=YASDiff&amp;parentid=0
* WinMerge (GUI diff tool for Windows)
     http://winmerge.org/
