!!

DESCRIPTION

Toolkit of useful functions.

NOTES

Built from the perspective of a Perl developer

Patches welcome.

AUTHOR

Will Sheppard

http://github.com/willsheppard/rfobasic

!!

! ******************************************
! Return a list's items as a string, comma separated
fn.def list_summary$(list)
! ******************************************
    array.delete list_summary_array$[]
    list.toarray list, list_summary_array$[]
    array.length num_list_items, list_summary_array $[]
    let out$ = ""
    for c = 1 to num_list_items
        let item$ = list_summary_array$[c]
        if out$ = "" then
            out$ = out$ + item$
        else
            out$ = out$ + ", " + item$
        end if
    next c
    fn.rtn out$
fn.end

! ******************************************
! Return a bundle's keys as a string, comma separated
fn.def bundle_get_keys$(bundle)
! ******************************************
    let out$ = ""

    bundle.keys bundle, list
    list.size list, size
    for i = 1 to size
        list.get list, i, key$
        bundle.get bundle, key$, value$
        if out$ = "" then
            out$ = out$ + key$
        else
            out$ = out$ + ", " + key$
        end if
    next i
    fn.rtn out$
fn.end

! ******************************************
! Easily extract a substring from a string
fn.def substr$(string$, start, length)
! ******************************************
    array.delete chars$[]
    split chars$[], string$, ""
    debug.print "Original string is: '" + string$ + "', that breaks down to:"
    debug.dump.array chars$[]

    let newstring$ = ""
    let offset = 1 % to avoid empty char in first slot
    for i = start to start + length - offset
        newstring$ = newstring$ + chars$[i+offset]
    next i
    debug.print "Extracted substring: '" + newstring$ + "'"

    fn.rtn newstring$
fn.end

! ******************************************
! Remove newline from end of a string
fn.def chomp$(string$)
! ******************************************
    array.delete chars$[]
    split chars$[], string$, ""
    array.length length, chars$[]
    if chars$[length] = "\n" then
        newstring$ = substr$(string$, 1, length - 2) % 2 = 1 empty char on first slot + 1 newline in final slot
    else
        newstring$ = string$
    end if
    fn.rtn newstring$
fn.end
