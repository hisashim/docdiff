#!/usr/bin/ruby
require 'test/unit'
require 'viewdiff'

class TC_Document < Test::Unit::TestCase

  def setup()
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
    result = DiffFile.guess_diff_type(@classic_diff)
    assert_equal(expected, result)
  end
  def test_guess_diff_type_context()
    expected = "context"
    result = DiffFile.guess_diff_type(@context_diff)
    assert_equal(expected, result)
  end
  def test_guess_diff_type_unified()
    expected = "unified"
    result = DiffFile.guess_diff_type(@unified_diff)
    assert_equal(expected, result)
  end
  def test_guess_diff_type_unknown()
    expected = true
    result =   begin
                 DiffFile.guess_diff_type("")
               rescue RuntimeError
                 true
               else
                 false
               end
    assert_equal(expected, result)
  end

  def test_parse_classic_diff_old()
    expected = [
      "diff --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf\n",
      "1d0\n",
      "< a\n",
      "3,4d1\n",
      "< c\n< d\n",
      "6a4\n",
      "> 0\n",
      "7a6,7\n",
      "> 1\n> 2\n",
      "9c9\n",
      "< i\n",
      "---\n",
      "> 3\n",
      "11c11,12\n",
      "< k\n",
      "---\n",
      "> 4\n> 5\n",
      "13,14c14,15\n",
      "< m\n< n\n",
      "---\n",
      "> 6\n> 7\n",
      "22d22\n",
      "< v\n",
      "23a24,25\n",
      "> 8\n> 9\n",
      "25c27,28\n",
      "< y\n",
      "---\n",
      "> A\n> B\n",
      "diff --text sample/1/b.en.ascii.lf sample/2/b.en.ascii.lf\n",
      "1c1,8\n",
      "< a\n",
      "---\n",
      "> @\n> <\n> >\n> -\n> +\n> *\n> !\n>\n",
      "9a17,19\n",
      "> +\n>\n>\n",
      "17d26\n",
      "< q\n",
      "24c33\n",
      "< x\n",
      "---\n",
      "> *\n",
      "26c35\n",
      "< z\n",
      "---\n",
      "> z\n",
      "\ No newline at end of file\n"
    ]
    result = DiffFile.new(@classic_diff).parse_classic_diff_old(@classic_diff)
    assert_equal(expected, result)
#   result.each{|e| 
#     puts("#{e.inspect}#{if e.op then ": " + e.op.inspect + ': ' + e.counterpart.inspect; end}")
#   }
  end
  def test_parse_classic_diff
    expected = [
      "diff --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf\n",
      "1d0\n",
      "< a\n",
      "3,4d1\n",
      "< c\n",
      "< d\n",
      "6a4\n",
      "> 0\n",
      "7a6,7\n",
      "> 1\n",
      "> 2\n",
      "9c9\n",
      "< i\n",
      "---\n",
      "> 3\n",
      "11c11,12\n",
      "< k\n",
      "---\n",
      "> 4\n",
      "> 5\n",
      "13,14c14,15\n",
      "< m\n",
      "< n\n",
      "---\n",
      "> 6\n",
      "> 7\n",
      "22d22\n",
      "< v\n",
      "23a24,25\n",
      "> 8\n",
      "> 9\n",
      "25c27,28\n",
      "< y\n",
      "---\n",
      "> A\n",
      "> B\n",
      "diff --text sample/1/b.en.ascii.lf sample/2/b.en.ascii.lf\n",
      "1c1,8\n",
      "< a\n",
      "---\n",
      "> @\n",
      "> <\n",
      "> >\n",
      "> -\n",
      "> +\n",
      "> *\n",
      "> !\n",
      ">\n",
      "9a17,19\n",
      "> +\n",
      ">\n",
      ">\n",
      "17d26\n",
      "< q\n",
      "24c33\n",
      "< x\n",
      "---\n",
      "> *\n",
      "26c35\n",
      "< z\n",
      "---\n",
      "> z\n",
      "\ No newline at end of file\n"
    ]
    result = DiffFile.new(@classic_diff).parsed_diff
    assert_equal(expected, result)
#   result.each{|e| 
#     puts("#{e.inspect}#{if e.op then ": " + e.op.inspect + ': ' + e.counterpart.inspect; end}")
#   }
  end

  def test_tokenize_classic_diff()
    expected = [
      "diff --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf\n",
      "1d0\n",
      "< a\n",
      "3,4d1\n",
      "< c\n",
      "< d\n",
      "6a4\n",
      "> 0\n",
      "7a6,7\n",
      "> 1\n",
      "> 2\n",
      "9c9\n",
      "< i\n",
      "---\n",
      "> 3\n",
      "11c11,12\n",
      "< k\n",
      "---\n",
      "> 4\n",
      "> 5\n",
      "13,14c14,15\n",
      "< m\n",
      "< n\n",
      "---\n",
      "> 6\n",
      "> 7\n",
      "22d22\n",
      "< v\n",
      "23a24,25\n",
      "> 8\n",
      "> 9\n",
      "25c27,28\n",
      "< y\n",
      "---\n",
      "> A\n",
      "> B\n",
      "diff --text sample/1/b.en.ascii.lf sample/2/b.en.ascii.lf\n",
      "1c1,8\n",
      "< a\n",
      "---\n",
      "> @\n",
      "> <\n",
      "> >\n",
      "> -\n",
      "> +\n",
      "> *\n",
      "> !\n",
      ">\n",
      "9a17,19\n",
      "> +\n",
      ">\n",
      ">\n",
      "17d26\n",
      "< q\n",
      "24c33\n",
      "< x\n",
      "---\n",
      "> *\n",
      "26c35\n",
      "< z\n",
      "---\n",
      "> z\n",
      "\ No newline at end of file\n"
    ]
    result = DiffFile.new(@classic_diff).tokenize_classic_diff(@classic_diff)
    assert_equal(expected, result)
  end

  def test_parse_context_diff()
    expected = [
"diff -c --text sample/1/a.en.ascii.lf sample/2/a.en.ascii.lf\n",
"*** sample/1/a.en.ascii.lf      Tue Aug 30 07:07:45 2005\n",
"--- sample/2/a.en.ascii.lf      Tue Aug 30 07:33:51 2005\n",
"***************\n",
"*** 1,17 ****\n",
"- a\n",
"  b\n",
"- c\n- d\n",
"  e\n",
"  f\n",
"  g\n",
"  h\n",
"! i\n",
"  j\n",
"! k\n",
"  l\n",
"! m\n! n\n",
"  o\n",
"  p\n",
"  q\n",
"--- 1,18 ----\n",
"  b\n",
"  e\n",
"  f\n",
"+ 0\n",
"  g\n",
"+ 1\n+ 2\n",
"  h\n",
"! 3\n",
"  j\n",
"! 4\n! 5\n",
"  l\n",
"! 6\n! 7\n",
"  o\n",
"  p\n",
"  q\n",
"***************\n",
"*** 19,26 ****\n",
"  s\n",
"  t\n",
"  u\n",
"- v\n",
"  w\n",
"  x\n",
"! y\n",
"  z\n",
"--- 20,29 ----\n",
"  s\n",
"  t\n",
"  u\n",
"  w\n",
"+ 8\n+ 9\n",
"  x\n",
"! A\n! B\n",
"  z\n",
"diff -c --text sample/1/b.en.ascii.lf sample/2/b.en.ascii.lf\n",
"*** sample/1/b.en.ascii.lf      Tue Aug 30 07:31:52 2005\n",
"--- sample/2/b.en.ascii.lf      Tue Aug 30 07:41:01 2005\n",
"***************\n",
"*** 1,4 ****\n",
"! a\n",
"  b\n",
"  c\n",
"  d\n",
"--- 1,11 ----\n",
"! @\n! <\n! >\n! -\n! +\n! *\n! !\n!\n",
"  b\n",
"  c\n",
"  d\n",
"***************\n",
"*** 7,12 ****\n",
"--- 14,22 ----\n",
"  g\n",
"  h\n",
"  i\n",
"+ +\n+\n+\n",
"  j\n",
"  k\n",
"  l\n",
"***************\n",
"*** 14,26 ****\n",
"  n\n",
"  o\n",
"  p\n",
"- q\n",
"  r\n",
"  s\n",
"  t\n",
"  u\n",
"  v\n",
"  w\n",
"! x\n",
"  y\n",
"! z\n",
"--- 24,35 ----\n",
"  n\n",
"  o\n",
"  p\n",
"  r\n",
"  s\n",
"  t\n",
"  u\n",
"  v\n",
"  w\n",
"! *\n",
"  y\n",
"! z\n",
"\ No newline at end of file\n"
    ]
    result = DiffFile.new(@context_diff).parsed_diff
    assert_equal(expected, result)
#    result.each{|e| 
#      puts("#{e.inspect}#{if e.op then ": " + e.op.inspect + ': ' + e.counterpart.inspect; end}")
#    }
  end

  def teardown()
    #
  end

end
