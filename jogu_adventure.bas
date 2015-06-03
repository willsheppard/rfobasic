! JOGU ADVENTURE
! a toy adventure project
! (c) 2015 Will Sheppard
! http://github.com/willsheppard/rfobasic

!!
Pseudo code:
Load description data into data structure
Verify data integrity
Display starting location
Wait for user input
Parse input
If direction, check exits
If exit exists, display that description.
If action, display object description.
If quit or exit, do that.
Wait for user input.
!!

!!
TODO
* sort exits alphabetically
* sort exits in custom order: N, E, S, W, etc.
!!

! load data
include load_jogu_data.bas

bundle.create r % r for records
let datafile$ = "jogu_data.txt"
load_jogu_data(&r, datafile$)

let starting_building$ = "32 Cowper Road"
let starting_location$ = starting_building$ + "+Hallway"
bundle.contain r, starting_location$, start_exists
if start_exists = 0 then end "ERROR: start location \"" + starting_location$ + "\" not found"

current_location$ = starting_location$
current_building$ = starting_building$

! ******************************************
! Return a bundle's keys as a string
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
! Display current location
fn.def foo(r, current_location$, current_building$)
! ******************************************
    while command$ <> "Q"
    !cls

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
    print "(" + current_building$ + ")"
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
    array.delete command_chars$[]
    split command_chars$[], command$, ""
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
    new_location_key$ = current_building$ + "+" + new_location$
    current_location$ = current_building$ + "+" + new_location$

    w_r.continue

    end if % direction

    let parsed_command$ = parse_look$(command$)

    if parsed_command$ <> "" then
        ! User wants to "look"
        debug.print "I parsed: '" + parsed_command$ + "'"
        w_r.continue
    end if

    ! Nothing matched, command is not recognised
    debug.print "I parsed: '" + parsed_command$ + "'"
    
    !if parsed_command$ = ""
    !then
        print "Sorry, I don't recognise \"" + command$ + "\", try something else..."
        w_r.continue
    !end if

    repeat % main "while" loop

    fn.rtn 1

fn.end

! ******************************************
! Parse the command, check if valid
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

fn.def parse_look$(command$)
    if command$ = "look" | command$ = "l" then
        fn.rtn "l"
    else
        fn.rtn ""
    end if
fn.end

fn.def substr$(string$, start, length)
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

! Remove newline from end of the string
fn.def chomp$(string$)
    array.delete chars$[]
    split chars$[], string$, ""
    array.length length, chars$[]
    newstring$ = substr$(string$, 1, length - 2) % 2 = 1 empty char on first slot + 1 newline in final slot
    fn.rtn newstring$
fn.end

!!

!fn.def get_first_char(

!fn.def validate_command(
!!

! ******************************************
! ******************************************

! ******************************************
! ******************************************

! ******************************************
! ******************************************

! #########################################

! Main

foo(r, current_location$, current_building$)


!!
Wait for user input
Parse input
If direction, check exits
If exit exists, display that description.
If action, display object description.
If quit or exit, do that.
Wait for user input.
!!



