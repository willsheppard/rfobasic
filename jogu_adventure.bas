!!

NAME

Jogu Adventure

DESCRIPTION

A text adventure game / Interactive fiction.

The associated text data file can be rewritten with whatever new locations you can dream up.

NOTES

If I had more time, I would add:
- multiple buildings
- objects which can be examined, picked up and used

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
! Start location - change to match the data

let starting_building$ = "Number 32"
let starting_location$ = "Hallway"

! ******************************************
! *** Don't change any code below here ***

! Load data
include load_jogu_data.bas % load_jogu_data
!include utils/toolkit.bas % list_summary, bundle_get_keys, substr, chomp % already loaded from load_jogu_data.bas

bundle.create r % r for records
let datafile$ = "jogu_data.txt"
load_jogu_data(&r, datafile$)

! Add building name to start of location key
let starting_location$ = starting_building$ + "+" + starting_location$

bundle.contain r, starting_location$, start_exists
if start_exists = 0 then end "ERROR: start location \"" + starting_location$ + "\" not found"

!current_location$ = starting_location$
!current_building$ = starting_building$

! ******************************************
! Display current location
fn.def jogu_main_loop(r, current_location$, current_building$)
! ******************************************
    let quit = 0
    while quit = 0
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
    current_location$ = current_building$ + "+" + new_location$

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


! ##########################################
! Main

jogu_main_loop(r, starting_location$, starting_building$)

