#!/usr/bin/ruby
# -*- coding: euc-jp; -*-
require 'test/unit'
require 'viewdiff'

class TC_DocDiff_Document < Test::Unit::TestCase
  DiffFile = DocDiff::DiffFile

  def setup()
    @docdiff = DocDiff.new

    @classic_diff = <<END
diff --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf
1d0
< a
3,4d1
< c
< d
6a4
> 0
7a6,7
> 1
> 2
9c9
< i
---
> 3
11c11,12
< k
---
> 4
> 5
13,14c14,15
< m
< n
---
> 6
> 7
22d22
< v
23a24,25
> 8
> 9
25c27,28
< y
---
> A
> B
diff --text sample/1/b.en.ascii.lf sample/2/b.en.ascii.lf
1c1,8
< a
---
> @
> <
> >
> -
> +
> *
> !
>
9a17,19
> +
>
>
17d26
< q
24c33
< x
---
> *
26c35
< z
---
> z
\ No newline at end of file
END
    @context_diff = <<END
diff -c --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf
*** sample/1/a.en.ascii.lf      Tue Aug 30 07:07:45 2005
--- sample/2/a.en.ascii.lf      Tue Aug 30 07:33:51 2005
***************
*** 1,17 ****
- a
  b
- c
- d
  e
  f
  g
  h
! i
  j
! k
  l
! m
! n
  o
  p
  q
--- 1,18 ----
  b
  e
  f
+ 0
  g
+ 1
+ 2
  h
! 3
  j
! 4
! 5
  l
! 6
! 7
  o
  p
  q
***************
*** 19,26 ****
  s
  t
  u
- v
  w
  x
! y
  z
--- 20,29 ----
  s
  t
  u
  w
+ 8
+ 9
  x
! A
! B
  z
diff -c --text sample/1/b.en.ascii.lf sample/2/b.en.ascii.lf
*** sample/1/b.en.ascii.lf      Tue Aug 30 07:31:52 2005
--- sample/2/b.en.ascii.lf      Tue Aug 30 07:41:01 2005
***************
*** 1,4 ****
! a
  b
  c
  d
--- 1,11 ----
! @
! <
! >
! -
! +
! *
! !
!
  b
  c
  d
***************
*** 7,12 ****
--- 14,22 ----
  g
  h
  i
+ +
+
+
  j
  k
  l
***************
*** 14,26 ****
  n
  o
  p
- q
  r
  s
  t
  u
  v
  w
! x
  y
! z
--- 24,35 ----
  n
  o
  p
  r
  s
  t
  u
  v
  w
! *
  y
! z
\ No newline at end of file
END
    @context_diff_short = <<END
diff -c --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf
*** sample/1/a.en.ascii.lf      Tue Aug 30 07:07:45 2005
--- sample/2/a.en.ascii.lf      Tue Aug 30 07:33:51 2005
***************
*** 19,26 ****
  s
  t
  u
- v
  w
  x
! y
  z
--- 20,29 ----
  s
  t
  u
  w
+ 8
+ 9
  x
! A
! B
  z
\ No newline at end of file
END
    @unified_diff = <<END
diff -u --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf
--- sample/1/a.en.ascii.lf      2005-08-30 07:07:45.000000000 +0900
+++ sample/2/a.en.ascii.lf      2005-08-30 07:33:51.000000000 +0900
@@ -1,17 +1,18 @@
-a
 b
-c
-d
 e
 f
+0
 g
+1
+2
 h
-i
+3
 j
-k
+4
+5
 l
-m
-n
+6
+7
 o
 p
 q
@@ -19,8 +20,10 @@
 s
 t
 u
-v
 w
+8
+9
 x
-y
+A
+B
 z
diff -u --text sample/1/b.en.ascii.lf sample/2/b.en.ascii.lf
--- sample/1/b.en.ascii.lf      2005-08-30 07:31:52.000000000 +0900
+++ sample/2/b.en.ascii.lf      2005-08-30 07:41:01.000000000 +0900
@@ -1,4 +1,11 @@
-a
+@
+<
+>
+-
++
+*
+!
+
 b
 c
 d
@@ -7,6 +14,9 @@
 g
 h
 i
++
+
+
 j
 k
 l
@@ -14,13 +24,12 @@
 n
 o
 p
-q
 r
 s
 t
 u
 v
 w
-x
+*
 y
-z
+z
\ No newline at end of file
END
  end

  def test_guess_diff_type_classic()
    expected = "classic"
    result = DiffFile.new(@classic_diff).guess_diff_type(@classic_diff)
    assert_equal(expected, result)
  end
  def test_guess_diff_type_context()
    expected = "context"
    result = DiffFile.new(@context_diff).guess_diff_type(@context_diff)
    assert_equal(expected, result)
  end
  def test_guess_diff_type_unified()
    expected = "unified"
    result = DiffFile.new(@unified_diff).guess_diff_type(@unified_diff)
    assert_equal(expected, result)
  end
  def test_guess_diff_type_unknown()
    expected = "unknown"
    result = DiffFile.new(@unified_diff).guess_diff_type("")
    assert_equal(expected, result)
  end

  def test_difffile_src()
    expected = @classic_diff
    result = DiffFile.new(@classic_diff).src
    assert_equal(expected, result)
  end

  def test_scan_text_for_diffs_simplified()
    expected = 12
    result = @docdiff.scan_text_for_diffs(@classic_diff + @context_diff + @unified_diff).size
    assert_equal(expected, result)
  end

  def test_scan_text_for_diffs()
    expected = [
 "diff file1 file2\n",
 "1d0\n< a\n6a4\n> 0\n7a6,7\n> 1\n> 2\n9c9\n< i\n---\n> 3\n",
 "diff -o f3 f4\n",
 "26c35\n< z\n---\n> z\n No newline at end of file\n",
 "lorem insum\n",
 "diff -o f1 f2\n",
 "*** f1 blah\n--- f2 blab\n***************\n*** 1,17 ****\n- a\n  b\n  p\n  q\n--- 1,18 ----\n  b\n  e\n  f\n+ 0\n  g\n+ 1\n+ 2\n  h\n***************\n*** 19,26 ****\n  w\n  x\n! y\n  z\n--- 20,29 ----\n  x\n! A\n! B\n  z\n No newline at end of file\n",
 "diff f3 f4\n",
 "*** f3 foo\n--- f4 bar\n***************\n*** 7,12 ****\n--- 14,22 ----\n  g\n  h\n  i\n+ +\n+\n+\n  j\n  k\n  l\n",
 "\n",
 "foo\n\n",
 "diff -o\n",
 "--- f1 foo\n+++ f2 bar\n@@ -19,8 +20,10 @@\n s\n t\n u\n-v\n w\n+8\n+9\n x\n-y\n+A\n+B\n z\n",
 "diff -o\n",
 "--- f3\n+++ f4\n@@ -7,6 +14,9 @@\n g\n h\n i\n++\n+\n+\n j\n k\n l\n@@ -14,13 +24,12 @@\n y\n-z\n+z\n No newline at end of file"
    ]
    result = @docdiff.scan_text_for_diffs("diff file1 file2
1d0
< a
6a4
> 0
7a6,7
> 1
> 2
9c9
< i
---
> 3
diff -o f3 f4
26c35
< z
---
> z
\ No newline at end of file
lorem insum
diff -o f1 f2
*** f1 blah
--- f2 blab
***************
*** 1,17 ****
- a
  b
  p
  q
--- 1,18 ----
  b
  e
  f
+ 0
  g
+ 1
+ 2
  h
***************
*** 19,26 ****
  w
  x
! y
  z
--- 20,29 ----
  x
! A
! B
  z
\ No newline at end of file
diff f3 f4
*** f3 foo
--- f4 bar
***************
*** 7,12 ****
--- 14,22 ----
  g
  h
  i
+ +
+
+
  j
  k
  l

foo

diff -o
--- f1 foo
+++ f2 bar
@@ -19,8 +20,10 @@
 s
 t
 u
-v
 w
+8
+9
 x
-y
+A
+B
 z
diff -o
--- f3
+++ f4
@@ -7,6 +14,9 @@
 g
 h
 i
++
+
+
 j
 k
 l
@@ -14,13 +24,12 @@
 y
-z
+z
\ No newline at end of file")
    assert_equal(expected, result)
  end

  def test_anatomize_classic()
    expected = [
      [:common_elt_elt, ["diff --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf\n"], ["diff --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf\n"]],
      [:common_elt_elt, ["1d0", "\n"], ["1d0", "\n"]],
      [:del_elt, ["< ", "a", "\n"], nil],
      [:common_elt_elt, ["3,4d1", "\n"], ["3,4d1", "\n"]],
      [:del_elt, ["< ", "c", "\n", "< ", "d", "\n"], nil],
      [:common_elt_elt, ["6a4", "\n"], ["6a4", "\n"]],
      [:add_elt, nil, ["> ", "0", "\n"]],
      [:common_elt_elt, ["7a6,7", "\n"], ["7a6,7", "\n"]],
      [:add_elt, nil, ["> ", "1", "\n", "> ", "2", "\n"]],
      [:common_elt_elt, ["9c9", "\n"], ["9c9", "\n"]],
      [:change_elt, ["< ", "i"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["---", "\n"], ["---", "\n"]],
      [:change_elt, nil, ["> ", "3"]],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["11c11,12", "\n"], ["11c11,12", "\n"]],
      [:change_elt, ["< ", "k"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["---", "\n"], ["---", "\n"]],
      [:change_elt, nil, ["> ", "4", "\n", "> ", "5"]],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["13,14c14,15", "\n"], ["13,14c14,15", "\n"]],
      [:change_elt, ["< ", "m"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:change_elt, ["< ", "n"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["---", "\n"], ["---", "\n"]],
      [:change_elt, nil, ["> ", "6"]],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:change_elt, nil, ["> ", "7"]],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["22d22", "\n"], ["22d22", "\n"]],
      [:del_elt, ["< ", "v", "\n"], nil],
      [:common_elt_elt, ["23a24,25", "\n"], ["23a24,25", "\n"]],
      [:add_elt, nil, ["> ", "8", "\n", "> ", "9", "\n"]],
      [:common_elt_elt, ["25c27,28", "\n"], ["25c27,28", "\n"]],
      [:change_elt, ["< ", "y"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["---", "\n"], ["---", "\n"]],
      [:change_elt, nil, ["> ", "A", "\n", "> ", "B"]],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["diff --text sample/1/b.en.ascii.lf sample/2/b.en.ascii.lf\n"], ["diff --text sample/1/b.en.ascii.lf sample/2/b.en.ascii.lf\n"]],
      [:common_elt_elt, ["1c1,8", "\n"], ["1c1,8", "\n"]],
      [:change_elt, ["< ", "a"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["---", "\n"], ["---", "\n"]],
      [:change_elt, nil, ["> ", "@", "\n", "> ", "<", "\n", "> ", ">", "\n", "> ", "-", "\n", "> ", "+", "\n", "> ", "*", "\n", "> ", "!", "\n", ">"]],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["9a17,19", "\n"], ["9a17,19", "\n"]],
      [:add_elt, nil, ["> ", "+", "\n", ">", "\n", ">", "\n"]],
      [:common_elt_elt, ["17d26", "\n"], ["17d26", "\n"]],
      [:del_elt, ["< ", "q", "\n"], nil],
      [:common_elt_elt, ["24c33", "\n"], ["24c33", "\n"]],
      [:change_elt, ["< ", "x"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["---", "\n"], ["---", "\n"]],
      [:change_elt, nil, ["> ", "*"]],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["26c35", "\n"], ["26c35", "\n"]],
      [:change_elt, ["< "], nil],
      [:common_elt_elt, ["z", "\n"], ["z", "\n"]],
      [:common_elt_elt, ["---", "\n"], ["---", "\n"]],
      [:change_elt, nil, ["> "]],
      [:common_elt_elt, ["z", "\n"], ["z", "\n"]],
      [:common_elt_elt, [" No newline at end of file\n"], [" No newline at end of file\n"]]
    ]
    result = @docdiff.anatomize_classic(@classic_diff)
    assert_equal(expected, result)
  end

  def test_anatomize_classic_hunk()
    expected = [
      [:common_elt_elt, ["9c9", "\n"], ["9c9", "\n"]],
      [:change_elt, ["< ", "i"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["---", "\n"], ["---", "\n"]],
      [:change_elt, nil, ["> ", "3"]],
      [:common_elt_elt, ["\n"], ["\n"]],
    ]
    result = @docdiff.anatomize_classic_hunk("9c9\n< i\n---\n> 3\n", "US-ASCII", "LF")
    assert_equal(expected, result)
  end

  def test_anatomize_context()
    expected = [
      [:common_elt_elt, ["diff ", "-c ", "--text ", "1a ", "2a", "\n"], ["diff ", "-c ", "--text ", "1a ", "2a", "\n"]],
      [:common_elt_elt, ["*** ", "1a", "\n"], ["*** ", "1a", "\n"]],
      [:common_elt_elt, ["--- ", "2a", "\n"], ["--- ", "2a", "\n"]],
      [:common_elt_elt, ["***************", "\n"], ["***************", "\n"]],
      [:common_elt_elt, ["*** ", "1,17 ", "****", "\n"], ["*** ", "1,17 ", "****", "\n"]],
      [:del_elt, ["- ", "a", "\n"], nil],
      [:common_elt_elt, ["  ", "b", "\n"], ["  ", "b", "\n"]],
      [:common_elt_elt, ["--- ", "1,18 ", "----", "\n"], ["--- ", "1,18 ", "----", "\n"]],
      [:common_elt_elt, ["  ", "b", "\n"], ["  ", "b", "\n"]],
      [:common_elt_elt, ["***************", "\n"], ["***************", "\n"]],
      [:common_elt_elt, ["*** ", "19,26 ", "****", "\n"], ["*** ", "19,26 ", "****", "\n"]],
      [:common_elt_elt, ["! "], ["! "]],
      [:change_elt, ["v"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["--- ", "20,29 ", "----", "\n"], ["--- ", "20,29 ", "----", "\n"]],
      [:common_elt_elt, ["! "], ["! "]],
      [:change_elt, nil, ["8"]],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["diff ", "-c ", "--text ", "1b ", "2b", "\n"], ["diff ", "-c ", "--text ", "1b ", "2b", "\n"]],
      [:common_elt_elt, ["*** ", "1b", "\n"], ["*** ", "1b", "\n"]],
      [:common_elt_elt, ["--- ", "2b", "\n"], ["--- ", "2b", "\n"]],
      [:common_elt_elt, ["***************", "\n"], ["***************", "\n"]],
      [:common_elt_elt, ["*** ", "7,12 ", "****", "\n"], ["*** ", "7,12 ", "****", "\n"]],
      [:common_elt_elt, ["--- ", "14,22 ", "----", "\n"], ["--- ", "14,22 ", "----", "\n"]],
      [:add_elt, nil, ["+ ", "g", "\n"]]
    ]
    result = @docdiff.anatomize_context("diff -c --text 1a 2a
*** 1a
--- 2a
***************
*** 1,17 ****
- a
  b
--- 1,18 ----
  b
***************
*** 19,26 ****
! v
--- 20,29 ----
! 8
diff -c --text 1b 2b
*** 1b
--- 2b
***************
*** 7,12 ****
--- 14,22 ----
+ g
")
    assert_equal(expected, result)
  end

  def test_anatomize_context_hunk()
    expected = [
      [:common_elt_elt, ["***************", "\n"], ["***************", "\n"]],
      [:common_elt_elt, ["*** ", "19,26 ", "****", "\n"], ["*** ", "19,26 ", "****", "\n"]],
      [:common_elt_elt, ["  ", "s", "\n  ", "t", "\n  ", "u", "\n"], ["  ", "s", "\n  ", "t", "\n  ", "u", "\n"]],
      [:del_elt, ["- ", "v", "\n"], nil],
      [:common_elt_elt, ["  ", "w", "\n  ", "x", "\n"], ["  ", "w", "\n  ", "x", "\n"]],
      [:common_elt_elt, ["! "], ["! "]],
      [:change_elt, ["y"], nil],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["  ", "z", "\n"], ["  ", "z", "\n"]],
      [:common_elt_elt, ["--- ", "20,29 ", "----", "\n"], ["--- ", "20,29 ", "----", "\n"]],
      [:common_elt_elt, ["  ", "s", "\n  ", "t", "\n  ", "u", "\n  ", "w", "\n"], ["  ", "s", "\n  ", "t", "\n  ", "u", "\n  ", "w", "\n"]],
      [:add_elt, nil, ["+ ", "8", "\n", "+ ", "9", "\n"]],
      [:common_elt_elt, ["  ", "x", "\n"], ["  ", "x", "\n"]],
      [:common_elt_elt, ["! "], ["! "]],
      [:change_elt, nil, ["A", "\n", "! ", "B"]],                         # <= this should be :change_elt !
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, ["  ", "z", "\n"], ["  ", "z", "\n"]],
    ]
    result = @docdiff.anatomize_context_hunk("***************
*** 19,26 ****
  s
  t
  u
- v
  w
  x
! y
  z
--- 20,29 ----
  s
  t
  u
  w
+ 8
+ 9
  x
! A
! B
  z
", "US-ASCII", "LF")
    assert_equal(expected, result)
  end

  def test_anatomize_context_hunk_scanbodies()
    expected = [
      [
        [:common_elt_elt, ["  ", "w", "\n"], ["  ", "w", "\n"]],
        [:common_elt_elt, ["! "], ["! "]],
        [:change_elt, ["x"], nil],
        [:common_elt_elt, ["\n"], ["\n"]],
        [:common_elt_elt, ["  ", "y", "\n"], ["  ", "y", "\n"]]
      ],
      [
        [:common_elt_elt, ["  ", "w", "\n"], ["  ", "w", "\n"]],
        [:common_elt_elt, ["! "], ["! "]],
        [:change_elt, nil, ["*"]],
        [:common_elt_elt, ["\n"], ["\n"]],
        [:common_elt_elt, ["  ", "y", "\n"], ["  ", "y", "\n"]]
      ]
    ]
    result = @docdiff.anatomize_context_hunk_scanbodies("  w
! x
  y
", "  w
! *
  y
", "US-ASCII", "LF")
    assert_equal(expected, result)
  end

  def test_anatomize_context_hunk_scanbodies_lackformer()
    expected = [
      [
      ],
      [
        [:common_elt_elt, ["  ", "a", "\n"], ["  ", "a", "\n"]],
        [:add_elt, nil, ["+ ", "x", "\n"]],
        [:common_elt_elt, ["  ", "b", "\n"], ["  ", "b", "\n"]]
      ]
    ]
    result = @docdiff.anatomize_context_hunk_scanbodies("","  a\n+ x\n  b\n", "US-ASCII", "LF")
    assert_equal(expected, result)
  end

  def test_anatomize_unified_hunk()
    expected = [
      [:common_elt_elt, ["@@ ", "-19,8 ", "+20,10 ", "@@", "\n"], ["@@ ", "-19,8 ", "+20,10 ", "@@", "\n"]],
      [:common_elt_elt, [" ", "s", "\n ", "t", "\n ", "u", "\n"], [" ", "s", "\n ", "t", "\n ", "u", "\n"]],
      [:del_elt, ["-v", "\n"], nil],
      [:common_elt_elt, [" ", "w", "\n"], [" ", "w", "\n"]],
      [:add_elt, nil, ["+8", "\n", "+9", "\n"]],
      [:common_elt_elt, [" ", "x", "\n"], [" ", "x", "\n"]],
      [:change_elt, ["-y"], nil],
      [:change_elt, nil, ["+A", "\n", "+B"]],
      [:common_elt_elt, ["\n"], ["\n"]],
      [:common_elt_elt, [" ", "z", "\n"], [" ", "z", "\n"]]
    ]
    result = @docdiff.anatomize_unified_hunk("@@ -19,8 +20,10 @@
 s
 t
 u
-v
 w
+8
+9
 x
-y
+A
+B
 z
", "US-ASCII", "LF")
    assert_equal(expected, result)
  end

  def test_anatomize_unified()
    expected = 
[[:common_elt_elt,
  ["diff ",
   "-u ",
   "--text ",
   "sample/1/a.en.ascii.lf ",
   "sample/2/a.en.ascii.lf",
   "\n",
   "--- ",
   "sample/1/a.en.ascii.lf ",
   "     ",
   "2005-08-30 ",
   "07:07:45.000000000 ",
   "+0900",
   "\n",
   "+++ ",
   "sample/2/a.en.ascii.lf ",
   "     ",
   "2005-08-30 ",
   "07:33:51.000000000 ",
   "+0900",
   "\n"],
  ["diff ",
   "-u ",
   "--text ",
   "sample/1/a.en.ascii.lf ",
   "sample/2/a.en.ascii.lf",
   "\n",
   "--- ",
   "sample/1/a.en.ascii.lf ",
   "     ",
   "2005-08-30 ",
   "07:07:45.000000000 ",
   "+0900",
   "\n",
   "+++ ",
   "sample/2/a.en.ascii.lf ",
   "     ",
   "2005-08-30 ",
   "07:33:51.000000000 ",
   "+0900",
   "\n"]],
 [:common_elt_elt,
  ["@@ ", "-1,17 ", "+1,18 ", "@@", "\n"],
  ["@@ ", "-1,17 ", "+1,18 ", "@@", "\n"]],
 [:del_elt, ["-a", "\n"], nil],
 [:common_elt_elt, [" ", "b", "\n"], [" ", "b", "\n"]],
 [:common_elt_elt, ["-c", "\n"], ["-c", "\n"]],
 [:common_elt_elt, ["-d", "\n"], ["-d", "\n"]],
 [:common_elt_elt, [" ", "e", "\n"], [" ", "e", "\n"]],
 [:common_elt_elt, [" ", "f", "\n"], [" ", "f", "\n"]],
 [:common_elt_elt, ["+0", "\n"], ["+0", "\n"]],
 [:common_elt_elt, [" ", "g", "\n"], [" ", "g", "\n"]],
 [:common_elt_elt, ["+1", "\n"], ["+1", "\n"]],
 [:common_elt_elt, ["+2", "\n"], ["+2", "\n"]],
 [:common_elt_elt, [" ", "h", "\n"], [" ", "h", "\n"]],
 [:common_elt_elt, ["-i", "\n"], ["-i", "\n"]],
 [:common_elt_elt, ["+3", "\n"], ["+3", "\n"]],
 [:common_elt_elt, [" ", "j", "\n"], [" ", "j", "\n"]],
 [:common_elt_elt, ["-k", "\n"], ["-k", "\n"]],
 [:common_elt_elt, ["+4", "\n"], ["+4", "\n"]],
 [:common_elt_elt, ["+5", "\n"], ["+5", "\n"]],
 [:common_elt_elt, [" ", "l", "\n"], [" ", "l", "\n"]],
 [:common_elt_elt, ["-m", "\n"], ["-m", "\n"]],
 [:common_elt_elt, ["-n", "\n"], ["-n", "\n"]],
 [:common_elt_elt, ["+6", "\n"], ["+6", "\n"]],
 [:common_elt_elt, ["+7", "\n"], ["+7", "\n"]],
 [:common_elt_elt, [" ", "o", "\n"], [" ", "o", "\n"]],
 [:common_elt_elt, [" ", "p", "\n"], [" ", "p", "\n"]],
 [:common_elt_elt, [" ", "q", "\n"], [" ", "q", "\n"]],
 [:common_elt_elt,
  ["@@ ", "-19,8 ", "+20,10 ", "@@", "\n"],
  ["@@ ", "-19,8 ", "+20,10 ", "@@", "\n"]],
 [:common_elt_elt,
  [" ", "s", "\n ", "t", "\n ", "u", "\n"],
  [" ", "s", "\n ", "t", "\n ", "u", "\n"]],
 [:common_elt_elt, ["-v", "\n"], ["-v", "\n"]],
 [:common_elt_elt, [" ", "w", "\n"], [" ", "w", "\n"]],
 [:common_elt_elt, ["+8", "\n"], ["+8", "\n"]],
 [:common_elt_elt, ["+9", "\n"], ["+9", "\n"]],
 [:common_elt_elt, [" ", "x", "\n"], [" ", "x", "\n"]],
 [:common_elt_elt, ["-y", "\n"], ["-y", "\n"]],
 [:common_elt_elt, ["+A", "\n"], ["+A", "\n"]],
 [:common_elt_elt, ["+B", "\n"], ["+B", "\n"]],
 [:common_elt_elt, [" ", "z"], [" ", "z"]],
 [:common_elt_elt,
  ["diff ",
   "-u ",
   "--text ",
   "sample/1/b.en.ascii.lf ",
   "sample/2/b.en.ascii.lf",
   "\n",
   "--- ",
   "sample/1/b.en.ascii.lf ",
   "     ",
   "2005-08-30 ",
   "07:31:52.000000000 ",
   "+0900",
   "\n",
   "+++ ",
   "sample/2/b.en.ascii.lf ",
   "     ",
   "2005-08-30 ",
   "07:41:01.000000000 ",
   "+0900",
   "\n"],
  ["diff ",
   "-u ",
   "--text ",
   "sample/1/b.en.ascii.lf ",
   "sample/2/b.en.ascii.lf",
   "\n",
   "--- ",
   "sample/1/b.en.ascii.lf ",
   "     ",
   "2005-08-30 ",
   "07:31:52.000000000 ",
   "+0900",
   "\n",
   "+++ ",
   "sample/2/b.en.ascii.lf ",
   "     ",
   "2005-08-30 ",
   "07:41:01.000000000 ",
   "+0900",
   "\n"]],
 [:common_elt_elt,
  ["@@ ", "-1,4 ", "+1,11 ", "@@", "\n"],
  ["@@ ", "-1,4 ", "+1,11 ", "@@", "\n"]],
 [:del_elt, ["-a", "\n"], nil],
 [:common_elt_elt, ["+@", "\n"], ["+@", "\n"]],
 [:common_elt_elt, ["+<", "\n"], ["+<", "\n"]],
 [:common_elt_elt, ["+>", "\n"], ["+>", "\n"]],
 [:common_elt_elt, ["+-", "\n"], ["+-", "\n"]],
 [:common_elt_elt, ["++", "\n"], ["++", "\n"]],
 [:common_elt_elt, ["+*", "\n"], ["+*", "\n"]],
 [:common_elt_elt, ["+!", "\n"], ["+!", "\n"]],
 [:common_elt_elt, ["+", "\n"], ["+", "\n"]],
 [:common_elt_elt, [" ", "b", "\n"], [" ", "b", "\n"]],
 [:common_elt_elt, [" ", "c", "\n"], [" ", "c", "\n"]],
 [:common_elt_elt, [" ", "d", "\n"], [" ", "d", "\n"]],
 [:common_elt_elt,
  ["@@ ", "-7,6 ", "+14,9 ", "@@", "\n"],
  ["@@ ", "-7,6 ", "+14,9 ", "@@", "\n"]],
 [:common_elt_elt,
  [" ", "g", "\n ", "h", "\n ", "i", "\n"],
  [" ", "g", "\n ", "h", "\n ", "i", "\n"]],
 [:common_elt_elt, ["++", "\n"], ["++", "\n"]],
 [:common_elt_elt, ["+", "\n"], ["+", "\n"]],
 [:common_elt_elt, ["+", "\n"], ["+", "\n"]],
 [:common_elt_elt, [" ", "j", "\n"], [" ", "j", "\n"]],
 [:common_elt_elt, [" ", "k", "\n"], [" ", "k", "\n"]],
 [:common_elt_elt, [" ", "l", "\n"], [" ", "l", "\n"]],
 [:common_elt_elt,
  ["@@ ", "-14,13 ", "+24,12 ", "@@", "\n"],
  ["@@ ", "-14,13 ", "+24,12 ", "@@", "\n"]],
 [:common_elt_elt,
  [" ", "n", "\n ", "o", "\n ", "p", "\n"],
  [" ", "n", "\n ", "o", "\n ", "p", "\n"]],
 [:common_elt_elt, ["-q", "\n"], ["-q", "\n"]],
 [:common_elt_elt, [" ", "r", "\n"], [" ", "r", "\n"]],
 [:common_elt_elt, [" ", "s", "\n"], [" ", "s", "\n"]],
 [:common_elt_elt, [" ", "t", "\n"], [" ", "t", "\n"]],
 [:common_elt_elt, [" ", "u", "\n"], [" ", "u", "\n"]],
 [:common_elt_elt, [" ", "v", "\n"], [" ", "v", "\n"]],
 [:common_elt_elt, [" ", "w", "\n"], [" ", "w", "\n"]],
 [:common_elt_elt, ["-x", "\n"], ["-x", "\n"]],
 [:common_elt_elt, ["+*", "\n"], ["+*", "\n"]],
 [:common_elt_elt, [" ", "y", "\n"], [" ", "y", "\n"]],
 [:common_elt_elt, ["-z", "\n"], ["-z", "\n"]],
 [:common_elt_elt, ["+z", "\n"], ["+z", "\n"]],
 [:common_elt_elt,
  [" ", "No ", "newline ", "at ", "end ", "of ", "file", "\n"],
  [" ", "No ", "newline ", "at ", "end ", "of ", "file", "\n"]]]
    result = @docdiff.anatomize_unified(@unified_diff)
    assert_equal(expected, result)
  end

  def teardown()
    #
  end

end
