!!

DESCRIPTION

Basic! JSON Parser
This was downloaded from http://laughton.com/basic/programs/utilities/

NOTES

* Modified to run as a function (Will Sheppard, May 2015)

Patches welcome.

http://github.com/willsheppard/rfobasic

!!


!ASCII Code Reference (decimal values):
!
!   ¨   double quote     34
!   '   single quote     39
!   \   backslash        92
!   /   forward slash    47
!       space            32
!   {   left brace       123
!   }   right brace      125
!   [   left bracket     91
!   ]   right bracket    93
!   \b  backspace        8
!   \f  form feed        12
!   \n  line feed        10
!   \r  carriage return  13
!   \t  horizontal tab   9
!   0   numeral 0        48
!   9   numeral 9        57
!   -   minus            45
!   +   plus             43
!   .   period           46
!   e   lower case e     101
!   E   upper case E     69
!

! Function definitions

!=====FUNCTION: jsnp_next(c$,jsnpa[])
!Get the next char and advance the pointer. At EOF return 0.
!If c$ parameter is provided, verify that it matches the current char.
!c$ parameter must be a single character string or empty string.
Fn.def jsnp_next(c$,jsnpa[])
  a = ASCII(c$)

  If ((c$ <> "") & (a <> jsnpa[1])) Then
    Print "Error in jsnp_next. c$=";c$;", ch=";jsnpa[1];", at=";jsnpa[2]
    Goto jsnp_fail
  Endif

  If jsnpa[2] = jsnpa[4]
    jsnpa[1] = 0   %End of text. Set current char to NULL
    Fn.rtn 0   %Return NULL.
  Endif

  jsnpa[2] += 1
  jsnpa[1] = jsnpa[jsnpa[2]]
  Fn.rtn jsnpa[1]
Fn.end

!=====FUNCTION: jsnp_white(jsnpa[])
!Skip whitespace, if any.
!Returns nothing
Fn.def jsnp_white(jsnpa[])
  While ( (jsnpa[1] <> 0) & (jsnpa[1] <= 32) )
    jsnp_next("",jsnpa[])
  Repeat
Fn.end

!=====FUNCTION: jsnp_ishex(n)
!n is an ASCII decimal character code.
!Returns true if n is a valid hexadecimal character. Else false.
Fn.def jsnp_ishex(n)
  If (n >= 48) & (n <= 57) Then   %in range of ASCII 0 to 9
    Fn.rtn 1
  Endif
  If (n >= 65) & (n <= 70) Then   %in range of ASCII A to F
    Fn.rtn 1
  Endif
  If (n >= 97) & (n <= 102) Then   %in range of ASCII a to f
    Fn.rtn 1
  Else
    Fn.rtn 0
  Endif
Fn.end

!=====FUNCTION: jsnp_pushkey(key$,jsnpa[])
!Pushes key$ onto the key stack. This is done by dot-concatenating key$ with whatever key is at the top
!of the stack and pushing the result onto the stack.
!Returns nothing
Fn.def jsnp_pushkey(key$,jsnpa[])
  sptr = jsnpa[6]
  Stack.IsEmpty sptr, empty
  If empty = 0   %stack is not empty
    Stack.peek sptr, t$
    t$ = t$ + "." + key$
    Stack.push sptr, t$
!PRINT "Push: ";t$
  Else   %stack is empty
    Stack.push sptr, key$
!PRINT "Push: ";key$
  Endif
  Fn.rtn 0
Fn.end


!=====FUNCTION: jsnp_word(jsnpa[])
!Parse the words true, false, null from the JSON string.
!Returns 1 for true, 0 for false and null
Fn.def jsnp_word(jsnpa[])
  If jsnpa[1] = ASCII("t") Then
    jsnp_next("t",jsnpa[])
    jsnp_next("r",jsnpa[])
    jsnp_next("u",jsnpa[])
    jsnp_next("e",jsnpa[])
    Fn.rtn 1   %return true
  Endif
  If jsnpa[1] = ASCII("f") Then
    jsnp_next("f",jsnpa[])
    jsnp_next("a",jsnpa[])
    jsnp_next("l",jsnpa[])
    jsnp_next("s",jsnpa[])
    jsnp_next("e",jsnpa[])
    Fn.rtn 0   %return false
  Endif
  If jsnpa[1] = ASCII("n") Then
    jsnp_next("n",jsnpa[])
    jsnp_next("u",jsnpa[])
    jsnp_next("l",jsnpa[])
    jsnp_next("l",jsnpa[])
    Fn.rtn 0   %return null/false
  Endif  
   
  Print "Unexpected char in jsnp_word. ch=";jsnpa[1];", at=";jsnpa[2]
  Goto jsnp_fail
Fn.end


!=====END OF FUNCTION DEFINITIONS
Goto jsnp_startprog


!=====SUBROUTINE: jsnp_parse
!Parse an entire JSON string
!
!Inputs:
!jsnp_text$: JSON string
!jsnp_bptr: pointer to bundle into which all the keys and values extracted from the JSON string will be placed.
!
!If successful, this subroutine returns with jsnp_parse_retval == 1. If there is a recoverable failure, it
!returns with jsnp_parse_retval == -1. If unrecoverable failure we jump to jsnp_fail:
!
!This parser needs a few internally global variables that are accessible across different functions. Because
!RFO Basic disallows access to global variables from within functions, the working values for this
!parser are maintained in an internal numeric array. By passing a single array in each function call,
!the effect of global variables can be achieved and without passing a dozen parameters in each function call.
!
!The JSON text is initially extracted as ASCII and placed in the internal "globals" array mentioned above,
!which also serves as a buffer, again minimizing the number of parameters that must be passed in each function call.
!
!Regular expressions are not used. No switches are used.
!
!Fixed array element values are:
! jsnpa[1] - current character ASCII value (ch)
! jsnpa[2] - current character pointer (at)
! jsnpa[3] - total number of chars in JSON string
! jsnpa[4] - array index of last character of JSON text
! jsnpa[5] - bundle pointer passed from caller, bptr
! jsnpa[6] - local key string stack pointer, sptr
! jsnpa[7] - extra space
! jsnpa[8...n] - JSON text characters as numeric ASCII values

jsnp_parse:
  jsnp_l = Len(jsnp_text$)
  If jsnp_l = 0 Then
    Print "JSON string is empty"
    jsnp_parse_retval = -1
    Return
  Endif
  debug.print "json string is " + format$("###", jsnp_l) + " chars long"
  Stack.create S, jsnp_sptr
  Dim jsnpa[7+jsnp_l]
  jsnpa[2] = 8
  jsnpa[3] = jsnp_l
  jsnpa[4] = jsnp_l+7
  jsnpa[5] = jsnp_bptr   %output result bundle pointer passed from caller
  jsnpa[6] = jsnp_sptr   %stack used locally for key strings
  
!Extract JSON text and convert to numeric ASCII
  For i = 1 to jsnp_l
    jsnpa[i+7] = ASCII(Mid$(jsnp_text$, i, 1))
  Next
  jsnpa[1] = jsnpa[jsnpa[2]]

!Execute the parsing process by calling jsnp_value.
  Gosub jsnp_value
  jsnp_white(jsnpa[])
  If jsnpa[1] <> 0 Then   %we should have exhausted all chars in the JSON string
    Print "Extra chars found"
    Goto jsnp_fail
  Endif
  
!Clean up after ourselves
  Stack.clear jsnp_sptr
  UnDim jsnpa[]
  jsnp_parse_retval = 1
  Return
!===== END OF SUBROUTINE jsnp_parse


!=====SUBROUTINE: jsnp_value
!Parse a JSON value. It could be an object, array, string, number, or word
!Returns nothing

jsnp_value:
  jsnp_value_s$ = ""
  jsnp_white(jsnpa[])
  If jsnpa[1] = 123   %Left brace. An object?
    Gosub jsnp_object
  ElseIf jsnpa[1] = 91 Then   %if left bracket then array
    Gosub jsnp_array
  ElseIf jsnpa[1] = 34 Then   %Double quote. A string?
    Gosub jsnp_string
    jsnp_value_s$ = jsnp_string_retval$
    Stack.pop jsnp_sptr, jsnp_key$
    Bundle.put jsnp_bptr, jsnp_key$, jsnp_value_s$
  ElseIf (jsnpa[1] = 45) | ((jsnpa[1] >= 48) & (jsnpa[1] <= 57)) Then   %Minus sign or numeric 0-9. A number?
    Gosub jsnp_number
    jsnp_n = jsnp_number_retval
    Stack.IsEmpty jsnp_sptr, jsnp_empty
    If jsnp_empty <> 0 Then   %empty stack is an error
      Print "Empty key stack"
      Goto jsnp_fail
    Endif
    Stack.pop jsnp_sptr, jsnp_key$
    Bundle.put jsnp_bptr, jsnp_key$, jsnp_n
  Else   %word?
    jnsp_n = jsnp_word(jsnpa[])
    Stack.pop jsnp_sptr, jsnp_key$
    Bundle.put jsnp_bptr, jsnp_key$, jsnp_n
  Endif
  Return
!=====END OF SUBROUTINE jsnp_value

!=====SUBROUTINE: jsnp_object
!Parse an object value from the JSON string.
!Returns nothing

jsnp_object:
  If jsnpa[1] <> 123   %not a left brace?
    Print "Bad object"
    Goto jsnp_fail
  Endif
  jsnp_next("{",jsnpa[])
  jsnp_white(jsnpa[])
  If jsnpa[1] = 125   %if right brace then empty object.
    jsnp_next("}",jsnpa[])
    Return
  Endif
  
  While jsnpa[1] <> 0
    Gosub jsnp_string
    jsnp_key$ = jsnp_string_retval$   %key extracted
    jsnp_pushkey(jsnp_key$,jsnpa[])
    jsnp_white(jsnpa[])
    jsnp_next(":",jsnpa[])
    Gosub jsnp_value   %extracts the value and adds to the bundle
    jsnp_white(jsnpa[])
    If jsnpa[1] = 125   %if right brace then done with this object
      jsnp_next("}",jsnpa[])
      If jsnpa[1] <> 0   %if not at end of json string, the stack is not empty
        Stack.pop jsnp_sptr, jsnp_key$   %pop the object's name key and discard it.
      Endif
      W_R.break
    Endif
    jsnp_next(",",jsnpa[])
    jsnp_white(jsnpa[])
  Repeat

  Return
!=====END OF SUBROUTINE jsnp_object

!=====SUBROUTINE: jsnp_number
!Parse a numeric value from the JSON string.
!Returns a numeric value in jsnp_number_retval.
!Builds a temporary string in jsnp_number_s$, then converts it to a number before returning it.

jsnp_number:
  jsnp_number_s$ = ""   %init

  If jsnpa[1] = 45 Then   %minus sign?
    jsnp_number_s$ += "-"
    jsnp_next("",jsnpa[])
  Endif
  While ((jsnpa[1] >= 48) & (jsnpa[1] <= 57))   %ch from 0 to 9
    jsnp_number_s$ += CHR$(jsnpa[1])
    jsnp_next("",jsnpa[])
  Repeat
  If jsnpa[1] = 46 Then   %dot or period
    jsnp_number_s$ += "."
    While (jsnp_next("",jsnpa[]) & (jsnpa[1] >= 48) & (jsnpa[1] <= 57))
      jsnp_number_s$ += CHR$(jsnpa[1])
    Repeat
  Endif
  If ((jsnpa[1] = 101) | (jsnpa[1] = 69)) Then   %if lower or upper case E
    jsnp_number_s$ += CHR$(jsnpa[1])
    jsnp_next("",jsnpa[])
    If ((jsnpa[1] = 45) | (jsnpa[1] = 43)) Then   %if plus or minus
      jsnp_number_s$ += CHR$(jsnpa[1])
      jsnp_next("",jsnpa[])
    Endif
    While ((jsnpa[1] >= 48) & (jsnpa[1] <= 57))   %while numeric 0-9
      jsnp_number_s$ += CHR$(jsnpa[1])
      jsnp_next("",jsnpa[])
    Repeat
  Endif
  
  jsnp_number_retval = VAL(jsnp_number_s$)
  Return
!=====END OF SUBROUTINE jsnp_number

!=====SUBROUTINE: jsnp_string()
!Parse a string value from the JSON string.
!Builds and returns the string in jsnp_string_retval$

jsnp_string:
  jsnp_string_retval$ = ""   %init

!Parse and look for " and \ characters
  If jsnpa[1] = 34   %if double quote
    While jsnp_next("",jsnpa[])
      If jsnpa[1] = 34   %if another double quote
        jsnp_next("",jsnpa[])   %skip the quote and return
        W_R.break
      Endif
      If jsnpa[1] = 92   %if backslash
        jsnp_next("",jsnpa[])
        If jsnpa[1] = ASCII("u")   %if we have \u then hex string
          For i = 1 to 4
            If jsnp_ishex(jsnpa[1])
              jsnp_string_retval$ += CHR$(jsnpa[1])
            Else
              Print "Bad hex char in jsnp_string(). ch=";jsnpa[1];", at=";jsnpa[2]
              Goto jsnp_fail
            Endif
          Next i
        Else   %we have a backslash. handle escape characters
          If jsnpa[1] = 34   %double quote
            jsnp_string_retval$ += CHR$(34)
          ElseIf jsnpa[1] = 92   %backslash
            jsnp_string_retval$ += CHR$(92)
          ElseIf jsnpa[1] = 47   %forward slash
            jsnp_string_retval$ += CHR$(47)
          ElseIf jsnpa[1] = 98   %b
            jsnp_string_retval$ += CHR$(92) + CHR$(98)
          ElseIf jsnpa[1] = 102   %f
            jsnp_string_retval$ += CHR$(92) + CHR$(102)
          ElseIf jsnpa[1] = 110   %n
            jsnp_string_retval$ += CHR$(92) + CHR$(110)
          ElseIf jsnpa[1] = 114   %r
            jsnp_string_retval$ += CHR$(92) + CHR$(114)
          ElseIf jsnpa[1] = 116   %t
            jsnp_string_retval$ += CHR$(92) + CHR$(116)
          Else
            Print "Bad escaped char in jsnp_string(). ch=";jsnpa[1];", at=";jsnpa[2]
            Goto jsnp_fail
          Endif
        Endif
      Else
        jsnp_string_retval$ += CHR$(jsnpa[1])
      Endif
    Repeat
    Return
  Endif
  
  Print "Bad string in jsnp_string(). ch=";jsnpa[1];", at=";jsnpa[2]
  Goto jsnp_fail
!=====END OF SUBROUTINE jsnp_string()

!=====SUBROUTINE: jsnp_array
!Parse an array from the JSON string.
!Returns nothing

jsnp_array:
  If jsnpa[1] <> 91   %if not a left bracket then bad array syntax
    Print "Bad array syntax"
    Goto jsnp_fail
  Endif
  jsnp_next("[",jsnpa[])
  jsnp_white(jsnpa[])
  If jsnpa[1] = 93   %if right bracket then empty array
    jsnp_next("]",jsnpa[])
    Return
  Endif

  jsnp_ai = 1   %Initialize array index counter to 1
  jsnp_key$ = FORMAT$("#####",jsnp_ai)
  jsnp_key$ = REPLACE$(jsnp_key$," ","")
  jsnp_pushkey(jsnp_key$,jsnpa[])
  
  While jsnpa[1] <> 0
    Gosub jsnp_value   %extracts the value and adds to the bundle
    jsnp_white(jsnpa[])
    If jsnpa[1] = 93   %if right bracket then done with this array
      jsnp_next("]",jsnpa[])
      Stack.pop jsnp_sptr, jsnp_key$   %pop the name of the array and discard it.
      W_R.break
    Endif
    jsnp_white(jsnpa[])
    If jsnpa[1] = ASCII(",")   %must be another array element
      jsnp_next(",",jsnpa[])
      jsnp_white(jsnpa[])
!     Array index has already been popped. Push the next one on the stack.
      jsnp_ai += 1
      jsnp_key$ = FORMAT$("#####",jsnp_ai)
      jsnp_key$ = REPLACE$(jsnp_key$," ","")
      jsnp_pushkey(jsnp_key$,jsnpa[])   %push the next array index
      W_R.continue
    Else
      Print "Unexpected characters in JSON array"
      W_R.break
    Endif
  Repeat

  Return
!=====END OF SUBROUTINE jsnp_array

jsnp_fail:
Print "Parser failure"
End


jsnp_startprog:


!!

json_text2$ = "{\"coord\":{\"lon\":-80.34,\"lat\":39.28},\"sys\":{\"type\":1,\"id\":3051,\"message\":0.0303,\"country\":\"US\",\"sunrise\":1412248740,\"sunset\":1412290920},\"weather\":[{\"id\":741,\"main\":\"Fog\",\"description\":\"fog\",\"icon\":\"50n\"},{\"id\":701,\"main\":\"Mist\",\"description\":\"mist\",\"icon\":\"50n\"}],\"base\":\"cmc stations\",\"main\":{\"temp\":285.3,\"pressure\":1018,\"humidity\":100,\"temp_min\":284.15,\"temp_max\":287.15},\"wind\":{\"speed\":1.76,\"deg\":179.007},\"clouds\":{\"all\":90},\"dt\":1412228100,\"id\":4802316,\"name\":\"Clarksburg\",\"cod\":200}"


debug.on
let num_lines = 0
let json_text3$ = ""
text.open r, fh, "json.txt"
do
    text.readln fh, line$
    debug.print "processing line: "+line$
    if line$ <> "EOF" then let json_text3$ = json_text3$ + line$
    num_lines += 1
until line$ = "EOF"
text.close fh

debug.print "there are "+format$("###", num_lines)+" lines"
!!

!=====MAIN function

debug.on

fn.def parse_json(jsnp_text$, jsnp_bptr)

    debug.print "JSON Parser Test\n\n"

    !jsnp_text$ = json_text3$
    debug.print "Dump of original JSON text:"
    debug.print jsnp_text3$
    debug.print "Calling the parser"

    !Bundle.create jsnp_bptr
    Gosub jsnp_parse

    debug.dump.bundle jsnp_bptr

    !Console.save "json_parse_output.txt"

    !return jsnp_bptr
fn.end
!=====END OF MAIN function

!!

! Test

json_text1$ = "{\"coord\":{\"lon\":-80.34,\"lat\":39.28},\"sys\":{\"type\":1,\"id\":3051,\"message\":0.0303,\"country\":\"US\",\"sunrise\":1412248740,\"sunset\":1412290920}}"

include hexdump.bas
include fileslurp.bas

let s$ = fileslurp$("json.txt")
!hexdump(json_text1$)
hexdump(s$)

bundle.create bb
!parse_json(json_text1$, &bb)
parse_json(s$, &bb)

debug.print "result = "
debug.dump.bundle bb

!!

