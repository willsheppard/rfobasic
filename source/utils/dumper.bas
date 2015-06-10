!!

DESCRIPTION

Recursively print out a bundle of bundles

NOTES

* Treats any number as a bundle pointer,
  this means only strings should be stored.

* The implementation is a bit more complex than necessary - we have to pass many parameters around many functions - because global variables are not accessible inside functions. It could be simplified if reimplemented using gosubs instead of functions.

Patches welcome.

AUTHOR

Will Sheppard

http://github.com/willsheppard/rfobasic

!!

!debug.on

! ***************************************

fn.def dumper(bundle)
    ! Config
    let dumper_indent_size = 4
    let dumper_indent_char$ = " "

    debug.print "dumper_indent_size = "+format$(" ##", dumper_indent_size)

    dumper_outer(bundle, dumper_indent_size, dumper_indent_char$, dumper_indent_size)
fn.end

! ***************************************

! convenience function to format a number for output
fn.def str$(number)
    let out$ = format$("#####", number)
    fn.rtn out$
fn.end

! ***************************************

fn.def dumper_indent$(size, dumper_indent_char$)
    let indent$ = ""
    debug.print "creating indent of "+format$(" ##",size)
    for i = 1 to size
        indent$ = indent$ + dumper_indent_char$
    next i
    debug.print "returning indent \"" + indent$ + "\" (" + format$("##",size) + " chars)"
    fn.rtn indent$
fn.end

! ***************************************

fn.def dumper_outer(bundle, dumper_indent_size, dumper_indent_char$, dumper_indent_size_orig)
    print "bundle = {"

    debug.print "dumper: dumper_indent_size = "+str$(dumper_indent_size)

    dumper_inner(bundle, dumper_indent_size, dumper_indent_char$, dumper_indent_size_orig)
    print "}"
fn.end

fn.def dumper_inner(bundle, indent_size, dumper_indent_char$, indent_size_orig)

    let indent$ = dumper_indent$(indent_size, dumper_indent_char$)

    debug.print "inner: indent_size = "+str$(indent_size)

   ! get the list of the keys
   ! in this bundle
   ! and the number of keys
   ! if the numbers of keys
   ! is zero then the bundle
   ! has no keys

   BUNDLE.KEYS bundle, list
   LIST.SIZE list, size
   IF size = 0
       PRINT "Empty bundle"
       PRINT " "
       FN.RTN 0
   ENDIF

   ! For each key,
   ! get the key type
   ! and then get key's
   ! value base upon
   ! the type

   FOR i = 1 TO size
       LIST.GET list, i, key$
       BUNDLE.TYPE bundle, key$, type$
       IF type$ = "S"
           ! Value is a string.
           ! Display key and value
           BUNDLE.GET bundle, key$, value$
           PRINT indent$ + "\"" + key$ + "\" => \"" + value$ + "\","
       ELSE
           ! Value is a number.
           ! Display key, and treat value as a bundle pointer
           ! This means if the bundle contains actual numbers, you will get unexpected results.
           BUNDLE.GET bundle, key$, value
           PRINT indent$ + "\"" + key$ + "\" => {" % + value

           ! Display the bundle pointed to by this value
           dumper_inner(value, indent_size + indent_size_orig, dumper_indent_char$, indent_size_orig)

           ! Make indent less for closing bracket
           let closing_bracket_indent$ = dumper_indent$(indent_size - dumper_indent_size, dumper_indent_char$)
           print closing_bracket_indent$ + "}"
       ENDIF
 
    NEXT i

fn.end

!!
#########################################
Test

bundle.create a
Bundle.put a, "name1", "frank"
Bundle.put a, "name2", "maya"
!bundle.put a, "number3", 3 % doesn't work - displays a sub-bundle with pointer 3 instead of the number "3.0"

bundle.create b
bundle.put b, "foo", "bar"
bundle.put a, "sub-bundle", b

bundle.create c
bundle.put c, "baz", "quuuuuux"
bundle.put b, "sub-sub-bundle", c

print "+++++++ dump.bundle (built in) ++++++"
debug.on
debug.dump.bundle a
debug.off

print "+++++++ dumper (custom) ++++++"
dumper(a)

!!
