# News

### 0.6.6 (2026-02-18)

* User-visible changes:
  - `--encoding` and `--eol` options now accept lowercase values, such as ascii or crlf, as well as ASCII or CRLF.
* Developer-related changes:
  - Applied some lint (except for lib/docdiff/diff/).
  - `make all` now generates docs, tarball, and gem, in addition to running tests.

### 0.6.5 (2025-12-29)

* User-visible changes:
  - Fixed label option not accumulating correctly.
  - Fixed CRLF bug ([#57](https://github.com/hisashim/docdiff/issues/57)), where CRLFs in the input text are gobbled and not printed in the output when using `tty`, `wdiff`, and `user` formats. This problem seems to have existed since 0.3.
* Developer-related changes:
  - Moved CLI-related stuff from `bin/docdiff` to `lib/docdiff/cli.rb`.
  - Miscellaneous fixes and refactoring.

### 0.6.4 (2025-12-13)

* User-visible changes:
  - Removed ChangeLog.
  - Reorganized and updated documents: most documents are moved to `doc/`.
  - `$XDG_CONFIG_HOME`-style user configuration file name (`~/.config/docdiff/docdiff.conf`) is supported and encouraged to use.
  - Added a manual page (`doc/man/docdiff.1` will be generated from `.adoc` by `make docs`).
  - Added shell completion scripts for Zsh and Bash.
  - Cleaned up CLI help message a bit.
  - Added pager support with `--pager=` and `--no-pager` options. `$DOCDIFF_PAGER` is consulted as well.
  - Added `--iso8859` to supersede `--iso8859x`; ditto for `--display=block` and `--display=multi`.
  - Marked to-be-deprecated features as deprecated, e.g.: `--format=stat`, `--stat`, `--cache`, `--iso8859x`, `--display=multi`, `--verbose`, `--license`, `--author`, `~/etc/docdiff/docdiff.conf`, and `~/.docdiff/docdiff.conf`.
* Developer-related changes:
  - Removed test logging.
  - Fixed erroneous tarball generation (`make dist`).
  - Introduced additional development requirements: git, md2html, asciidoctor.
  - Fixed irregular time stamps of gem members by setting `$SOURCE_DATE_EPOCH`.
  - Converted EUC-JP code files to UTF-8.

### 0.6.3 (2025-12-13)

This version was revoked due to a mistake in the release procedure.

### 0.6.2 (2025-11-28)

* User-visible changes:
  - Add support for stdin (`-`) in command line arguments (thanks to tamo)
  - Add `--config-file` option (thanks to tamo)
  - Fix incompatibility with Ruby 3.4 `Regexp` (thanks to yoshuki)
  - Resolve frozen literal warnings introduced by Ruby 3.4.
* Developer-related changes:
  - Remove unused files: ViewDiff and its tests.
  - Update email address in `.gemspec`.

### 0.6.1 (2021-06-07)

* User-visible changes:
  - none
* Developer-related changes:
  - Update information in `.gemspec`. (Primary repository is now GitHub, etc.)
  - Fix: Use `VERSION` from local library when building a gem.

### 0.6.0 (2020-07-10)

* User-visible changes:
  - Drop support for Ruby 1.8 (thanks to takahashim).
  - Fix various encoding problems (thanks to takahashim).
  - Add CP932 (Windows-31J) support through a new option `--cp932` (thanks to emasaka).
  - Introduce `readme.md`, which will obsolete `readme.html` eventually (thanks to takahashim).
* Developer-related changes:
  - Use Mutex#synchronize instead of Thread.exclusive (thanks to hsbt).
  - Remove `JIS0208.TXT` to comply with its terms of use (thanks to kmuto).
  - Introduce top-level class `DocDiff` to avoid name conflict (thanks to hibariya).

### 0.5.0 (2011-08-12)

* Gemify. Now you can download docdiff via rubygems.org.
* Fix failing test on ruby1.9.2-p290.

### 0.4.0 (2011-02-23)

* Compatible with Ruby 1.9 (thanks to Kazuhiko).

### 0.3.4 (2007-12-10)

* Increased context length in digest mode from 16 to 32.
* Added `--display=inline|multi` option. With inline, things before change and things after change are displayed inline. With multi, they are displayed in separate blocks. Default is inline.
* Added `--iso8859x` option as an alias to `--encoding=ASCII`, so that users notice DocDiff can handle text in ISO-8859-* encoding.

### 0.3.3 (2006-02-03)

* Fixed arg test so that we can compare non-normal files, such as device files and named pipes (thanks to Shugo Maeda).
* Added DocDiff Web UI sample (experimental).
* Fixed HTML output to produce valid XHTML (thanks to Hiroshi OHKUBO).  Note that CSS in HTML output is slightly changed.
* Replaced underscores(`_`) in CSS class names to hyphens(`-`) so that older UAs can understand them (thanks to Kazuhiro NISHIYAMA).

### 0.3.2 (2005-01-03)

* Readme is multilingualized (added partial Japanese translation).  Try switching CSS between en and ja.  Monolingual files are also available (`readme.en.html`, `readme.ja.html`).
* Outputs better error messages when it failed to auto-detect the encoding and/or eol, though the accuracy is the same.
* Switched revision control system from CVS to Subversion.

### 0.3.1 (2004-08-29)

* Added `-L` (`--label`) option place holder in order to be used as external diff program from Subversion.

### 0.3.0 (2004-05-29)

* Re-designed and re-written from scratch.
* Supports multiple encodings (ASCII, EUC-JP, Shift_JIS, UTF-8) and multiple eols (CR, LF, CRLF).
* Supports more output formats (tty, HTML, Manued, wdiff-like, user-defined markup text).
* Supports configuration files (`/etc/docdiff/docdiff.conf`, `~/etc/docdiff/docdiff.conf` (or `~/.docdiff/docdiff.conf`)).
* Introduced digest (summary) mode.
* Approximately 200% faster than older versions, thanks to akr's diff library.
* Better documentation and help message.
* License changed from Ruby's to modified BSD style.
* Pure Ruby.  Does not require external diff program such as GNU diff, or morphological analyzer such as ChaSen.
* Runs on both Unix and Windows (tested on Debian GNU/Linux and Cygwin).
* Unit tests introduced to decrease bugs and to encourage faster development.
* Makefile introduced.

### 0.1.8 (2003-12-14)

* Displays warning when `--bymorpheme` is specified but ChaSen is not available (patch by Akira YAMADA: Debian bug #192258).
* Supports system-wide configuration file (if `~/.chasenrc.docdiff` does not exist, reads `/etc/docdiff/chasenrc`) (patch by Akira YAMADA: Debian bug #192261).

### 0.1.7 (2003-11-21)

* HTML output retains spaces (`&nbsp;` patch by Akira YAMADA).
* Manued output is added.  Use `--manued` command line option to get result in Manued-like format.
* Fixed `.chasenrc.docdiff` to be compatible with the latest ChaSen, so that it does not cause error.
* Alphabet words in the output may look ugly, since ChaSen does not keep spaces between alphabetical words recently.
* Other minor bug fixes and code cleanup.

### 0.2.0b2 (2001-08-31)

* Code cleanup.

### 0.2.0b1 (2001-08-31)

* A bit faster than 0.1.x, using file cache.
* A bit cleaner code.

### 0.1.6 (2001-05-16)

* Increased diff option number from 100000 to 1000000 in order to support 900KB+ text files.

### 0.1.5 (2001-01-17)

* Erased useless old code which were already commented out.
* Added documentation. (Updated README, more comments)
* First public release.  Registered to RAA.

### 0.1.4 (2001-01-16)

* Output is like `<tag>ab</tag>`, instead of ugly `<tag>a</tag><tag>b</tag>` (thanks again to Masatoshi Seki for suggestion).
* Fixed hidden bug (`puts` was used to output result).
* Some code clean-up, though still hairy enough.

### 0.1.3 (2001-01-09)

* Tested with Ruby 1.6.2.
* Fixed `meth(a,b,)` bug (thanks to Masatoshi Seki).
* Switched development platform from Windows to Linux, but it should work fine on Windows too, except for ChaSen stuff.

### 0.1.2 (2000-12-28)

* Mostly bug fix.

### 0.1.1 (2000-12-25)

* Bug fix and some cleanup.
* Quotes some of HTML special characters (`<>&`) when output in HTML.
* Added support for tty output using escape sequence.

### 0.1.0 (2000-12-19)

* ChaSen works fine now.
* GetOptLong was introduced to support command line options.

### 0.1.0a1 (2000-12-16)

* Added ChaSen support.  Japanese word by word comparison requires ChaSen.
* Converted scripts from Shift_JIS/CRLF to EUC-JP/LF.

### 0.0.2 (2000-12-10)

* Rewritten to use class.

### 0.0.1 (2000-12-09)

* First version.  Proof-of-concept.
* Supports ASCII, EUC-JP, LF only.
* Supports HTML output only.
* Requires GNU diff.
* Distributed under the same license as Ruby's.

See the source repository for detail.
