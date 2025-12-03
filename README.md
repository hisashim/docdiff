# DocDiff

* English | [Japanese](README_ja.md)

(C) 2000 Hisashi MORITA

## Description

Compares two text files by word, by character, or by line

## Screenshots

<div style="display: grid; grid-template-columns: 1fr 1fr;">

<p>HTML output in web browser<br />
<img src="doc/img/docdiff-screenshot-format-html-firefox.png" alt="HTML output in web browser"/></p>

<p>HTML output in web browser (digest)<br />
<img src="doc/img/docdiff-screenshot-format-html-digest-firefox.png" alt="HTML output in web browser (digest)" /></p>

<p>tty output in terminal<br />
<img src="doc/img/docdiff-screenshot-format-tty-rxvtunicode-en.png" alt="tty output in terminal" /></p>

<p>tty output in terminal (comparing Japanese text)<br />
<img src="doc/img/docdiff-screenshot-format-tty-rxvtunicode-ja.png" alt="tty output in terminal (comparing Japanese text)" /></p>

<p>tty output in terminal<br />
<img src="doc/img/docdiff-screenshot-format-tty-xterm-en.png" alt="tty output in terminal" /></p>

<p>tty output in terminal (comparing Japanese text)<br />
<img src="doc/img/docdiff-screenshot-format-tty-xterm-ja.png" alt="tty output in terminal (comparing Japanese text)" /></p>

</div>

<p>Comparing English text (codepage 437) on Windows (Cygwin)<br />
<img src="doc/img/docdiff-screenshot-format-tty-cmdexe-en.png" alt="Comparing English text (codepage 437) on Windows (Cygwin)" /></p>

<p>Comparing Japanese text (codepage 932) on Windows (Cygwin)<br />
<img src="doc/img/docdiff-screenshot-format-tty-cmdexe-ja.png" alt="Comparing Japanese text (codepage 932) on Windows (Cygwin)" /></p>

<p>You can compare text files by line, word, or character (format: tty)<br/>
<img src="doc/img/docdiff-screenshot-resolution-linewordchar-xterm.png" alt="You can compare text files by line, word, or character (format: tty)" /></p>

Screenshots as of version 0.3.2.

## Summary

DocDiff compares two text files and shows the difference.  It can compare files word by word, character by character, or line by line.  It has several output formats such as HTML, tty, Manued, or user-defined markup.

It supports several encodings and end-of-line characters, including ASCII (and other single byte encodings such as ISO-8859-*), UTF-8, EUC-JP, Shift_JIS, CR, LF, and CRLF.

## Requirement

* [Ruby](http://www.ruby-lang.org)

  (Note that you may need additional ruby library such as iconv, if your OS's Ruby package does not include those.)

## Installation

Note that you need appropriate permission for proper installation (you may have to have a root/administrator privilege).

1. Place `docdiff/` directory and its contents to ruby library directory, so that ruby interpreter can load them.

   ```
   # cp -r docdiff /usr/lib/ruby/1.9.1
   ```

2. Place `docdiff.rb` in command binary directory.

   ```
   # cp docdiff.rb /usr/bin/
   ```

3. (Optional) You may want to rename it to `docdiff`.

   ```
   # mv /usr/bin/docdiff.rb /usr/bin/docdiff
   ```

4. (Optional) When invoked as `chardiff` or `worddiff`, docdiff runs with resolution set to `char` or `word`, respectively.

   ```
   # ln -s /usr/bin/docdiff.rb /usr/bin/chardiff.rb
   # ln -s /usr/bin/docdiff.rb /usr/bin/worddiff.rb
   ```

5. Set appropriate permission.

   ```
   # chmod +x /usr/bin/docdiff.rb
   ```

6. (Optional) If you want site-wide configuration file, place `docdiff.conf.example` as `/etc/docdiff/docdiff.conf` and edit it.

   ```
   # cp docdiff.conf.example /etc/docdiff.conf
   # $EDITOR /etc/docdiff.conf
   ```

7. (Optional) If you want per-user configuration file, place `docdiff.conf.example` as `~/etc/docdiff/docdiff.conf` and edit it.

   ```
   % cp docdiff.conf.example ~/etc/docdiff.conf
   % $EDITOR ~/etc/docdiff.conf
   ```

## Usage

### Synopsis

```
% docdiff [options] oldfile newfile
```

e.g.

```
% docdiff old.txt new.txt > diff.html
```

See the help message for detail (`docdiff --help`).

### Example

<pre>
% cat sample/01.en.ascii.lf
Hello, my name is Watanabe.
I am just another Ruby porter.
% cat sample/02.en.ascii.lf
Hello, my name is matz.
It's me who has created Ruby.  I am a Ruby hacker.
% docdiff sample/01.en.ascii.lf sample/02.en.ascii.lf
Hello, my name is <span class="before-change" style="background: yellow; border: thin inset;"><del>Watanabe.</del></span><span class="after-change" style="background: lime; font-weight: bolder; border: thin outset;"><ins>matz.</ins></span>
<span class="add" style="background: deepskyblue; font-weight: bolder; border: thin outset;"><ins>It's me who has created Ruby.&nbsp;&nbsp;</ins></span>I am <span class="before-change" style="background: yellow; border: thin inset;"><del>just another </del></span><span class="after-change" style="background: lime; font-weight: bolder; border: thin outset;"><ins>a </ins></span>Ruby <span class="before-change" style="background: yellow; border: thin inset;"><del>porter.</del></span><span class="after-change" style="background: lime; font-weight: bolder; border: thin outset;"><ins>hacker.</ins></span>
%
</pre>

## Configuration

You can place configuration files at:

* `/etc/docdiff/docdiff.conf` (site-wide configuration)
* `~/etc/docdiff/docdiff.conf` (user configuration)
  (`~/etc/docdiff/docdiff.conf` is used by default in order to keep home directory clean, preventing dotfiles and dotdirs from scattering around. Alternatively, you can use `~/.docdiff/docdiff.conf` as user configuration file name, following the traditional Unix convention.)

Notation is as follows (also refer to the file `docdiff.conf.example` included in the distribution archive):

```
# comment
key1 = value
key2 = value
...
```

Every value is treated as string, unless it seems like a number.  In such case, value is treated as a number (usually an integer).

## Troubleshooting and Tips

### wrong argument type nil (expected Module) (TypeError)

Sometimes DocDiff fails to auto-recognize encoding and/or end-of-line character.  You may get an error like this.

```
charstring.rb:47:in `extend': wrong argument type nil (expected Module) (TypeError)
```

In such a case, try explicitly specifying encoding and end-of-line character (e.g. `docdiff --utf8 --crlf`).

### Inappropriate Insertion / Deletion

When comparing space-separated texts (such as English or program source code), the word next to the end of line is sometimes unnecessarily deleted and inserted.  This is due to the limitation of DocDiff's word splitter.  It splits strings into words like the following.

text 1:

```
foo bar
```

(`"foo bar"  => ["foo ", "bar"]`)

text 2:

```
foo
bar
```

(`"foo\nbar" => ["foo", "\n", "bar"]`)

comparison result:

<pre>
<del>foo </del><ins>foo</ins><ins>
</ins>bar
</pre>

(`"<del>foo </del><ins>foo</ins><ins>\n</ins>bar"`)

Foo is (unnecessarily) deleted and inserted at the same time.

I would like to fix this sometime, but it's not easy.  If you split single space as single element (i.e. `["foo", " ", "bar"]`), the word order of the comparison result will be less natural.  Suggestions are welcome.

### Using DocDiff with Version Control Systems

If you want to use DocDiff as an external diff program from VCSs, the following may work.

* Subversion
  ```
  % svn diff --diff-cmd=docdiff --extensions "--ascii --lf --tty --digest"
  ```
* Git
  ```
  % GIT_EXTERNAL_DIFF=~/bin/gitdocdiff.sh git diff
  ```
  `~/bin/gitdocdiff.sh`:
  ```
  #!/bin/sh
  docdiff --ascii --lf --tty --digest $2 $5
  ```

With zsh, you can use DocDiff or other utility to compare arbitrary sources.  In the following example, we compare specific revision of foo.html in a repository with one on a website.

* CVS:
  ```
  % docdiff =(cvs -Q update -p -r 1.3 foo.html) =(curl --silent http://www.example.org/foo.html)
  ```
* Subversion:
  ```
  % docdiff =(svn cat -r3 http://svn.example.org/repos/foo.html) =(curl --silent http://www.example.org/foo.html)
  ```

### Comparing Non-plain Text Files Such As HTML or Microsoft Word Documents

You can compare files other than plain text, such as HTML and Microsoft Word documents, if you use appropriate converter.

Comparing the content of two HTML documents (without tags):

```
% docdiff =(w3m -dump -cols 10000 foo.html) =(w3m -dump -cols 10000 http://www.example.org/foo.html)
```

Comparing the content of two Microsoft Word documents:

```
% docdiff =(wvWare foo.doc | w3m -T text/html -dump -cols 10000) =(wvWare bar.doc | w3m -T text/html -dump -cols 10000)
```

### Workaround for Latin-* (ISO-8859-*) encodings: Use ASCII

If you want to compare Latin-* (ISO-8859-*) texts, try using ASCII as their encoding.  When ASCII is specified, DocDiff assumes single-byte characters.

Comparing Latin-1 texts:

```
% docdiff --encoding=ASCII latin-1-old.txt latin-1-new.txt
```

## License

This software is distributed under so-called modified BSD style license (<http://www.opensource.org/licenses/bsd-license.php>) (without advertisement clause)).  By contributing to this software, you agree that your contribution may be incorporated under the same license.

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

diff library (`docdiff/diff.rb` and `docdiff/diff/*`) was originally a part of Ruby/CVS by Akira TANAKA.  Ruby/CVS is licensed under modified BSD style license.  See the following for detail.

* <http://raa.ruby-lang.org/list.rhtml?name=ruby-cvs>
* <http://cvs.m17n.org/~akr/ruby-cvs/>

## Credits

* Hisashi MORITA (primary author)

## Acknowledgments

* Akira TANAKA (diff library author)
* Shin'ichiro HARA (initial idea and algorithm suggestion)
* Masatoshi SEKI (patch)
* Akira YAMADA (patch, Debian package)
* Kenshi MUTO (testing, bug report, Debian package)
* Kazuhiro NISHIYAMA (bug report)
* Hiroshi OHKUBO (bug report)
* Shugo MAEDA (bug report)
* Kazuhiko (patch)
* Shintaro Kakutani (patches)
* Masayoshi Takahashi (patches)
* Masakazu Takahashi (patch)
* Hibariya (bug report)
* Hiroshi SHIBATA (patch)
* Tamotsu Takahashi (patches)
* MIKAMI Yoshiyuki (patch)

Excuse us this list is far from complete and fails to acknowledge many
more who have helped us somehow. We really appreciate it.

## Resources

### Format

* [HTML/XHTML](http://www.w3.org)
* tty (Graphic rendition using VT100 / ANSI escape sequence)
  - [VT100](http://vt100.net/docs/tp83/appendixb.html)
  - [ANSI](http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html)
* [Manued](http://www.archi.is.tohoku.ac.jp/~yamauchi/otherprojects/manued/index.shtml) (Manuscript Editing language: a proofreading method for text)

### Similar Software

There are several other software that can compare text word by word and/or character by character.

* [GNU wdiff](http://www.gnu.org/directory/GNU/wdiff.html) (Seems to support single byte characters only.)
* [cdif](http://srekcah.org/~utashiro/perl/scripts/cdif) by Kazumasa UTASHIRO (Supports several Japanese encodings.)
* [ediff](http://www.xemacs.org/Documentation/packages/html/ediff.html) for Emacsen
* [diff-detail](http://ohkubo.s53.xrea.com/xyzzy/index.html#diff-detail) for xyzzy, by Hiroshi OHKUBO
* [Manuediff](http://hibiki.miyagi-ct.ac.jp/~suzuki/comp/export/manuediff.html) (Outputs difference in Manued format.)
* [YASDiff](http://nnri.dip.jp/~yf/cgi-bin/yaswiki2.cgi?name=YASDiff&parentid=0) (Yet Another Scheme powered diff) by Y. Fujisawa
* [WinMerge](http://winmerge.org/) (GUI diff tool for Windows)
