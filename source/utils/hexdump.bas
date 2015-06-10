!!
 DESCRIPTION

	hexdump.bas 
	This file contains 3 functions 
		hex$ to convert a byte to a hexadecimal string
		printasciidump$ to print a hex dump of an ascii string.
		listasciidump$ load a list with the hex dump of an ascii string.
	
 AUTHOR

	Rev. Jonathan C. Watt
	Fourth Sunday after the Epiphany
	January 2012

 CHANGES

 * Fixed bug where the original text output was one more character than the hex output (Will Sheppard, May 2015)
 * Display a star instead of dot for non-printable characters (Will Sheppard, May 2015)

 VERSION 0.2

 http://github.com/willsheppard/rfobasic
!!

fn.def hexdump( s$ )
    ! Convenience function
    let wid = 10
    call printasciidump( s$, wid )
    fn.rtn 1
fn.end


fn.def hex$( b )
!!
	hex$( b ) - Return the hexadecimal string for a byte 0 - 255
		b - byte value 0 - 255
	returns
		2 characters printable Hexadecimal

	Rev. Jonathan C. Watt
	Fourth Sunday after the Epiphany
	January 2012
!!
	if b > 255 then
		fn.rtn ""
	endif
	array.load hx$[],"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"
	by = b
	r = mod ( by, 16 )
	by = by - r
	by = by / 16
	h$ = hx$[by+1] + hx$[b-by*16+1]
	fn.rtn h$
fn.end

fn.def listasciidump( s$, wid )
!!
	listasciidump( s$, wid ) - creates a list of an ASCII Dump of the specified string.
		s$ - String to dump
		wid - width of line to dump (number of bytes of s$).
	returns
		list containing formated ascii dump of string.  
	
	Rev. Jonathan C. Watt
	The Third Sunday after the Epiphany
	January 2012.
!!
 	list.create S, dm
	sl = len(s$)
	addr = 1	  % character offset
	do 
		r$ = ""				% string to print
		saddr = addr		% start address 
		r$ = r$ + format$("%%%%", addr-1) + " - "
		w = 1				% keep track of the width
		xdone = 0
		do
			c$ = mid$(s$,addr,1)
			a = ascii(c$)
			h$ = hex$(a)
			r$ = r$ + h$ + " " 
			w = w + 1
			if w > wid then xdone = 1
			addr = addr + 1
			if i >= sl then xdone = 1
		until xdone
		r$ = r$ + "'" 
		! loop for printing only printable chars
		for i = saddr to saddr + wid - 1
			c$ = mid$( s$, i, 1 )
			ca = ascii(c$)
			if ((ca >= 32) & (ca <= 126)) then
				r$ = r$ + c$
			else
				r$ = r$ + "★"
			endif
		next i
		r$ = r$ + "'" 
		list.add dm, r$ 
	until addr > sl
fn.rtn dm				% replace 1 with dm to return list

fn.end

fn.def printasciidump( s$, wid )
!!
	printasciidump( s$, wid ) - prints an ascii dump of the specified string to standard output
		s$ - String to dump
		wid - width of line to dump (number of bytes of s$).
	returns
		1
	
	Rev. Jonathan C. Watt
	The Fourth Sunday after the Epiphany
	January 2012.
!!
	sl = len(s$)
	addr = 1				% character offset
	do 
		r$ = ""				% strint to print
		saddr = addr		% start address 
		r$ = r$ + format$("%%%%", addr-1) + " - "
		w = 1				% keep track of the width
		xdone = 0
		do 
			c$ = mid$(s$,addr,1)
			a = ascii(c$)
			h$ = hex$(a)
			r$ = r$ + h$ + " " 
			w = w + 1
			if w > wid then xdone = 1
			addr = addr + 1
			if i >= sl then xdone = 1
		until xdone
		r$ = r$ + "'" 
		! loop for printing only printable chars
		for i = saddr to saddr + wid - 1
			c$ = mid$( s$, i, 1 )
			ca = ascii(c$)
			if ((ca >= 32) & (ca <= 126)) then		
				r$ = r$ + c$
			else
				r$ = r$ + "★"
			endif
		next i
		r$ = r$ + "'" 
		print r$  
	until addr > sl
fn.rtn 1				
fn.end


