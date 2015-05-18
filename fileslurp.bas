!!
FileSlurp v0.01
Read a text file into a string
Will Sheppard
18th May 2015

How to use this function:

    include fileslurp.bas

    let datafile$ = "file.txt"
    let result$ = fileslurp$(datafile$)
    print "result = " + result$

BUGS
* will probably add a newline to the end of the file
!!

!debug.on

fn.def fileslurp$(datafile$)

    !let datafile_exists = 0
    file.exists datafile_exists, datafile$

    if datafile_exists = 0 then end datafile$ + " does not exist"

    text.open r, fh, datafile$
    let serial_data$ = ""
    let num_lines = 0
    do
        text.readln fh, line$
        debug.print "processing line: "+line$

        if line$ = "EOF" then d_u.continue

        ! read all teh dataz
        serial_data$ = serial_data$ + line$ + "\n"
        num_lines += 1
    until line$ = "EOF"
    text.close fh

    debug.print "there were "+format$("###", num_lines)+" lines"

    debug.print "serialised string: BEGIN\n" + serial_data$ + "\nEND"

    fn.rtn serial_data$
fn.end
