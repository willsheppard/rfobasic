!!

DESCRIPTION

Recursively print out a bundle of bundles

NOTES

* Treats any number as a bundle pointer,
  this means only strings should be stored.

* No end curly braces } are printed

Patches welcome.

AUTHOR

Will Sheppard

http://github.com/willsheppard/rfobasic

!!

fn.def dumper(bundle)
    print "bundle = {"
    let indent2$ = "    "
    dumper_inner(bundle, indent2$)
    fn.rtn 1
fn.end

fn.def dumper_inner(bundle, indent$)

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
           PRINT indent$ + "\"" + key$ + "\" => \"" + value$ + "\""
       ELSE
           ! Value is a number.
           ! Display key, and treat value as a bundle pointer
           ! This means if the bundle contains actual numbers, you will get unexpected results.
           BUNDLE.GET bundle, key$, value
           PRINT indent$ + "\"" + key$ + "\" => {" % + value

           ! Display the bundle pointed to by this value
           dumper_inner(value, indent$ + indent$)
       ENDIF
 
    NEXT i

    fn.rtn 1
fn.end

!!
#########################################
Test

bundle.create a
Bundle.put a, "name1", "frank"
Bundle.put a, "name2", "maya"
!bundle.put a, "number3", 3 % doesn't work - displays a sub-bundle instead of "3.0"

bundle.create b
bundle.put b, "foo", "bar"
bundle.put a, "sub-bundle", b

bundle.create c
bundle.put c, "baz", "quuuuuux"
bundle.put b, "sub-sub-bundle", c

print "+++++++ dump.bundle (built in) ++++++"
debug.on
debug.dump.bundle a

print "+++++++ dumper (custom) ++++++"
dumper(a)

!!
