! #############################################
! * This file has several other files combined
!   in it, for ease of downloading. Do not edit
!   this file, any changes will be overwritten
! * You need one other data file to make this
!   program work: jogu_data.txt in the data dir
! #############################################
!
! Files included:
! * utils/dumper.bas
! * utils/toolkit.bas
! * load_jogu_data.bas
! * jogu_adventure.bas
!
! * Functions must be declared before being
!   used, so read this file from the bottom up.
! 
! * Lines starting with a single ! are comments
!
! * Lines starting with a double !! begin
!   and ends a block comment (like /* */ in C)
!
! -- Will Sheppard, 2016

! #############################################
! BEGIN utils/dumper.bas
! #############################################
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
! #############################################
! END utils/dumper.bas
! #############################################

! #############################################
! END utils/toolkit.bas
! #############################################

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

! #############################################
! END utils/toolkit.bas
! #############################################

! #############################################
! BEGIN load_jogu_data.bas
! #############################################
!!

DESCRIPTION

Load a text data file and process the records into a hash of hashes (bundle of bundles).

The custom data format is designed to be human writeable, the focus being on ease-of-use from a mobile device.

Designed to be called by jogu_adventure.bas

NOTES

Patches welcome.

AUTHOR

Will Sheppard

http://github.com/willsheppard/rfobasic

!!

!!
TODO
* Use grabfile to read file, and split on \n
!!

debug.off

! INCLUDES

!include utils/dumper.bas % dumper
!include utils/toolkit.bas % list_summary, bundle_get_keys, substr, chomp


! MAIN FUNCTION START

fn.def load_jogu_data(records, config, datafile$)


! ************** CONFIG ***************

let CONST_AREA_SEPARATOR$ = "/"
let CONST_AREA_SEPARATOR_REGEX$ = "\\"+CONST_AREA_SEPARATOR$

let CONST_AREA_RECORD_KEYS_COUNT = 1 % area
let label_area$    = "area"

let CONST_LOCATION_RECORD_KEYS_COUNT = 3 % loc, desc, exits
let label_location$    = "loc"
let label_description$ = "desc"
let label_exits$       = "exits"

list.create S, valid_location_keys_list
list.add valid_location_keys_list, label_location$, label_description$, label_exits$

! Define config keys
let label_starting_location$ = "starting_location"
let label_area_location_separator$ = "area_location_separator"
let label_area_location_separator_regex$ = "area_location_separator_regex"

! Save config 
bundle.put config, label_area_location_separator$, CONST_AREA_SEPARATOR$
bundle.put config, label_area_location_separator_regex$, CONST_AREA_SEPARATOR_REGEX$


! ************** LOAD DATA ***************

!debug.on

! Setup
file.exists is_datafile_ok, datafile$
if ! is_datafile_ok then end "Error: Failed to open file \""+datafile$+"\" (does it exist in the data directory?). Cannot continue."
text.open r, fh, datafile$
let data_started = 0
let serial_data$ = ""
do
    text.readln fh, line$
    debug.print "processing line: "+line$

    ! count record separators
    if line$ = "#" then num_records += 1

    ! detect start of data
    if starts_with("###", line$) & ! data_started
        let data_started = 1
        d_u.continue
    endif
    if ! data_started then d_u.continue

    if starts_with("!", line$) then d_u.continue % comment

    ! detect end of data
    if starts_with("###", line$) & data_started then d_u.break

    ! read all the record data
    serial_data$ = serial_data$ + line$ + "\n"
    debug.print "serial data = <"+serial_data$+">"

until line$ = "EOF"
text.close fh

debug.print "there are "+format$("###", num_records)+" raw records"

debug.print "all records BEGIN: "+serial_data$+" END."

! split the data into records
split records_raw$[], serial_data$, "#\n"

! print records for debugging
array.length num_records_split, records_raw$[]
debug.print "there are "+format$("###", num_records_split)+" split records"


! ************** PARSE DATA ***************

!debug.on

area$ = ""
for i=1 to num_records_split
    debug.print "record "+format$("#",i)+" = '"+records_raw$[i]+"'"

    ! skip blank records
    if records_raw$[i] = "" then f_n.continue

    ! separate out the fields for this record
    array.delete fields$[]
    split fields$[], records_raw$[i], "\n"
    array.length num_fields, fields$[]

    ! process fields into a hash of hashes (bundle of bundles)
    bundle.create record
    let location$ = ""
    for j=1 to num_fields
        ! validate record format
        if ! is_in(":", fields$[j])
            end error_msg$+"Missing separator ':' in line: '" + fields$[j] + "'\nCannot continue."
        end if

        ! parse the record
        array.delete parts$[]
        split parts$[], fields$[j], ": "
        let label$ = parts$[1]
        let content$ = parts$[2]

        ! parse exits
        if label$ = label_exits$ then

            array.delete exits$[]
            split exits$[], content$, ",\\s?"
            debug.dump.array exits$[]

            ! convert to bundle
            array.length num_exits, exits$[]
            bundle.create exits_bundle
            for k = 1 to num_exits
                ! Parse exit destinations
                array.delete exit_dest$[]
                split exit_dest$[], exits$[k], "\\s?=\\s?"
                debug.dump.array exit_dest$[]
                array.length exit_dest_size, exit_dest$[]
                if exit_dest_size <> 2 then end error_msg$+"Malformed exit data '" + exits$[k] + "'"+"\nCannot continue. "

                bundle.put exits_bundle, exit_dest$[1], exit_dest$[2]
            next k

            bundle.put record, label$, exits_bundle

        else
            ! parse non-exit data

            ! save record
            bundle.put record, label$, content$
        end if % exits

        ! update current area
        if label$ = label_area$ then area$ = content$

        ! save current location
        if label$ = label_location$ then
            location$ = content$

            ! Save first location record
            bundle.contain config, label_starting_location$, is_starting_location_saved
            if ! is_starting_location_saved then bundle.put config, label_starting_location$, area$ + CONST_AREA_SEPARATOR$ + location$
            debug.print "debug location:"+ area$ + "+" + location$
        end if

    next j % fields in record

    debug.print "Record bundle:"
    debug.dump.bundle record

    if area$ = "" then end error_msg$+"Missing area definition. Cannot continue"

    ! add record to the main bundle, indexed by area+location
    ! area entries won't have a location
    record_key$ = area$+ CONST_AREA_SEPARATOR$ +location$
    bundle.put records, record_key$, record

    !debug.print "Records bundle:"
    !debug.dump.bundle records

next i % number of records

!dumper(records)


! ************** VALIDATE DATA ***************

let error_msg$ = "Data validation error in file '"+ datafile$ +"': "
!debug.on

bundle.keys records, locations_list
debug.dump.list locations_list
array.delete locations_array$[]
list.toarray locations_list, locations_array$[]
debug.dump.array locations_array$[]
array.length num_locations, locations_array$[]
debug.print "length = "+str$(num_locations)

for a = 1 to num_locations
    let full_location_key$ = locations_array$[a]
    bundle.get records, full_location_key$, record

    !print "validating record:"
    !dumper(record)

    list.create S, record_keys_list
    bundle.keys record, record_keys_list
    array.delete record_keys_array$[]
    list.toarray record_keys_list, record_keys_array$[]
    array.length num_record_keys, record_keys_array$[]
    debug.print "num_record_keys = "+str$(num_record_keys)

    ! is it a area record?
    bundle.contain record, label_area$, is_area
    debug.print " is area? "+str$(is_area)
    if is_area
        bundle.get record, label_area$, test_area$
        debug.print "Validating area record '"+ test_area$ + "'"
        if num_record_keys <> CONST_AREA_RECORD_KEYS_COUNT
            print error_msg$+"Found "+str$(num_record_keys)+" keys but expected "+str$(CONST_AREA_RECORD_KEYS_COUNT)+" for area record:"
            dumper(record)
            end "Cannot continue."
        end if

        if record_keys_array$[1] <> label_area$ then end error_msg$+ "Expected area key of '"+label_area$ +"', not '"+ record_keys_array$[1] +"'. Cannot continue."

    else
        ! assume it is a location record
        bundle.get record, label_location$, test_location$
        debug.print "Validating location record '"+ test_location$ + "'"
        if num_record_keys <> CONST_LOCATION_RECORD_KEYS_COUNT then
            print error_msg$+"Found "+str$(num_record_keys)+" keys but expected "+str$(CONST_LOCATION_RECORD_KEYS_COUNT)+" for location record:"
            dumper(record)
            end "Cannot continue."
        end if

        ! are the location keys all valid?
        for b = 1 to num_record_keys
            let this_key$ = record_keys_array$[b]
            list.search valid_location_keys_list, this_key$, is_valid
            if ! is_valid then
                print error_msg$+"Found invalid key '"+this_key$+"' for location record:"
                dumper(record)
                print "Expected one of: " + list_summary$(valid_location_keys_list)
                end "Cannot continue."
            end if
        next b

    ! Make sure all exits lead somewhere
    bundle.get record, label_exits$, exits_bundle
    !dumper(exits_bundle)
    bundle.keys exits_bundle, exits_list
    array.delete exits_array$[]
    list.toarray exits_list, exits_array$[]
    array.length num_exits, exits_array$[]

    ! Extract the area name from the key
    array.delete location_parts$[]
    split location_parts$[], full_location_key$, CONST_AREA_SEPARATOR_REGEX$
    let test_area$ = location_parts$[1]

    !debug.on
    debug.print " CONST_AREA_SEPARATOR_REGEX = "+CONST_AREA_SEPARATOR_REGEX$
    debug.print "full_location_key = "+full_location_key$
    debug.print "test_area = "+ test_area$

    for d = 1 to num_exits
        bundle.get exits_bundle, exits_array$[d], destination$

        ! Is destination in a different area?
        if is_in(CONST_AREA_SEPARATOR$, destination$) then
            ! e.g. House/Room
            full_destination$ = destination$
        else
            ! e.g. Room
            full_destination$ = test_area$ + CONST_AREA_SEPARATOR$ + destination$
        end if

        debug.print " full_destination = "+ full_destination$

        bundle.contain records, full_destination$, is_valid_location
        if ! is_valid_location then
            print error_msg$+"Could not find location '"+full_destination$+"' in area '"+test_area$+"':"

            dumper(record)
            end "Cannot continue."
        end if
    next d % num_exits

    end if % location record

next a % num_locations (validation)

debug.print "--------------------------"
debug.print "Records bundle:"
debug.dump.bundle records

!dumper(records)

fn.rtn 1 % data is returned via input params, not here

fn.end


!!
! ************** TEST ***************

! Inputs
let datafile$ = "jogu_data.txt"

! Outputs
bundle.create b % contains all location records
bundle.create c % contains start location

! Run
load_jogu_data(&b, &c, datafile$)

! Show result
dumper(b)
dumper(c)

!!
! #############################################
! END load_jogu_data.bas
! #############################################

! #############################################
! BEGIN jogu_adventure.bas
! #############################################

!!

NAME

Jogu Adventure

DESCRIPTION

A text adventure game / Interactive fiction.

This program allows the player to walk around different areas and read their descriptions. No manipulation of objects or other actions are possible.

NOTES

The associated text data file "jogu_data.txt" can be rewritten with whatever new locations you may dream up.

Program flow:

Load description data
Display starting location
Wait for user input
Parse input
If direction, check exits
If exit exists, display that description
If quit, do that

Patches welcome.

BUGS

The built-in 'tget' function requires the cursor to remain where it is following the prompt (v1.87). If you move the cursor by accident, it may send something different than what you typed.

AUTHOR

Will Sheppard

http://github.com/willsheppard/rfobasic

!!

! ******************************************
fn.def jogu_adventure(r, c)
! ******************************************

    ! Get location separators and regex from the config data
    bundle.get c, "area_location_separator", CONST_AREA_SEPARATOR$
    bundle.get c, "area_location_separator_regex", CONST_AREA_SEPARATOR_REGEX$

    ! Get starting location from config data
    let label_starting_location$ = "starting_location"
    bundle.get c, label_starting_location$, starting_index$

    debug.print " starting_index = "+ starting_index$

    bundle.contain r, starting_index$, start_exists
    if start_exists = 0 then end "ERROR: start location \"" + starting_index$ + "\" not found"

    let current_location$ = starting_index$

    let quit = 0

    ! ************** MAIN LOOP ***************

    while quit = 0
    !cls

    ! Extract the area name from the key
    array.delete location_parts$[]
    split location_parts$[], current_location$, CONST_AREA_SEPARATOR_REGEX$ 
    let current_area$ = location_parts$[1]

    debug.print " CONST_AREA_SEPARATOR_REGEX = "+CONST_AREA_SEPARATOR_REGEX$
    debug.print " current_location = "+ current_location$
    debug.print "current_area = "+ current_area$

    ! Check current location
    bundle.contain r, current_location$, current_exists
    if current_exists = 0 then end "ERROR: current location \"" + current_location$ + "\" not found"

    ! Get current location data
    bundle.get r, current_location$, here
    bundle.get here, "loc", loc$
    bundle.get here, "desc", desc$
    bundle.get here, "exits", exits_bundle
    let exits$ = bundle_get_keys$(exits_bundle)

    ! Display current location
    print ""
    print "(" + current_area$ + ")"
    print "==================================="
    print loc$
    print ""
    print desc$
    print ""
    print "Exits: " + exits$
    print ""

    ! Display prompt and read input
    !NOTE: tget command doesn't work properly before RFO BASIC v1.88
    tget command$, "Type a command > ", "Jogu Adventure"

    ! Remove newline from the end
    !array.delete command_chars$[]
    !split command_chars$[], command$, ""
    debug.print "You entered: '" + command$ + "'"

    ! Process raw input
    command$ = chomp$(command$) % remove newline
    command$ = lower$(command$)
    debug.print "I processed: '" + command$ + "'"

    ! Parse command

    let parsed_command$ = parse_direction$(command$)

    if parsed_command$ <> "" then
    ! User entered a location
    debug.print "I parsed: '" + parsed_command$ + "'"

    ! Change current location
    ! If command is a direction
    parsed_exit$ = upper$(parsed_command$)
    bundle.contain exits_bundle, parsed_exit$, is_direction_valid
    if is_direction_valid = 0
    then
        print "You can't go that way"
        w_r.continue
    end if

    ! Direction is valid, change location
    bundle.get exits_bundle, parsed_exit$, new_location$

    debug.print "current_area = " + current_area$
    debug.print "new_location = " + new_location$

    ! Is destination in a different area?
    if is_in(CONST_AREA_SEPARATOR$, new_location$) then
        ! e.g. House/Room
        full_destination$ = new_location$
    else
        ! e.g. Room
        full_destination$ = current_area$ + CONST_AREA_SEPARATOR$ + new_location$
    end if

    debug.print "full_destination = "+ full_destination$

    current_location$ = full_destination$

    w_r.continue

    end if % direction

    let parsed_command$ = parse_look$(command$)

    if parsed_command$ <> "" then
        ! User wants to "look"
        ! Just loop and the description will be printed again
        debug.print "I parsed: '" + parsed_command$ + "'"
        w_r.continue
    end if

    let parsed_command$ = parse_quit$(command$)
    if parsed_command$ <> "" then
        ! User wants to quit
        debug.print "I parsed: '" + parsed_command$ + "'"
        let quit = 1
        w_r.break % redundant
    end if

    ! Nothing matched, command is not recognised
    debug.print "I parsed: '" + parsed_command$ + "'"
    print "Sorry, I don't recognise \"" + command$ + "\", try something else..."

    repeat % main "while" loop

    print "\n...\n\nYou jack out of the matrix and return to reality."

    fn.rtn 1

fn.end

! ******************************************
fn.def parse_direction$(command$)
! ******************************************
    ! List of valid directions
    bundle.create v
    bundle.put v, "n", "n"
    bundle.put v, "e", "e"
    bundle.put v, "s", "s"
    bundle.put v, "w", "w"
    bundle.put v, "north", "n"
    bundle.put v, "east", "e"
    bundle.put v, "south", "s"
    bundle.put v, "west", "w"
    bundle.put v, "ne", "ne"
    bundle.put v, "se", "se"
    bundle.put v, "nw", "nw"
    bundle.put v, "sw", "sw"
    bundle.put v, "northeast", "ne"
    bundle.put v, "southeast", "se"
    bundle.put v, "northwest", "nw"
    bundle.put v, "southwest", "sw"
    bundle.put v, "north-east", "ne"
    bundle.put v, "south-east", "se"
    bundle.put v, "north-west", "nw"
    bundle.put v, "south-west", "sw"

    ! Check if command is valid
    bundle.contain v, command$, valid

    if valid then
        bundle.get v, command$, parsed_command$
        fn.rtn parsed_command$
    else
        fn.rtn ""
    end if
fn.end

! ******************************************
fn.def parse_look$(command$)
! ******************************************
    if command$ = "look" | command$ = "l" then
        fn.rtn "l"
    else
        fn.rtn ""
    end if
fn.end

! ******************************************
fn.def parse_quit$(command$)
! ******************************************
    if command$ = "quit" | command$ = "q" then
        fn.rtn "q"
    else
        fn.rtn ""
    end if
fn.end


! ************** SETUP ***************

! Load data
!include load_jogu_data.bas % load_jogu_data
! !include utils/toolkit.bas % list_summary, bundle_get_keys, substr, chomp % already loaded from load_jogu_data.bas

! Outputs
bundle.create r % r for records
bundle.create c % c for config

! Inputs
let datafile$ = "jogu_data.txt"

load_jogu_data(&r, &c, datafile$)

!dumper(r)
!dumper(c)

! ************** START ***************

jogu_adventure(r, c)


! #############################################
! END jogu_adventure.bas
! #############################################

