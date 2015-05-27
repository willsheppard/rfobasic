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

!cls

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
!    while 1 % change this to allow quitting

    ! Check current location
    bundle.contain r, current_location$, current_exists
    if current_exists = 0 then end "ERROR: current location \"" + current_location$ + "\" not found"

    ! Get current location data
    bundle.get r, current_location$, here
    !dumper(here)
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
    tget command$, "Type a command > ", "Jogu Adventure"

    ! Remove newline from the end
    !array.delete command_chars$[]
    !split command_chars$[], command$, ""
!debug.on
!debug.print "hello"
!    debug.dump.array command_chars$[]
!end "done"
    print "I recognise: " + command$

    ! Parse command
    let valid_command = bar(command$)
!!
    if valid_command = 0
    then
        print "Sorry, I don't recognise \"" + command$ + "\", try something else..."
        w_r.continue
    end if
!!

!!
    ! Change current location
    ! If command is a direction
    ! TODO: Normalise direction, e.g. uppercase
    bundle.get exits_bundle, command$, new_location$
    new_location_key$ = current_building$ + "+" + new_location$
    !bundle.get r, new_location_key$, new_here

    current_location$ = current_building$ + "+" + new_location$
!!
!    repeat % main "while" loop

    fn.rtn 1

fn.end

! ******************************************
! Parse the command, check if valid
fn.def bar(command$)
! ******************************************
    ! Load list of valid commands
    ! TODO: Read from a data file instead
    bundle.create all_valid_commands
    bundle.put all_valid_commands, "N", 1
     bundle.put all_valid_commands, "E", 1
    bundle.put all_valid_commands, "S", 1
   bundle.put all_valid_commands, "W", 1

    ! Check if command is valid
    bundle.contain all_valid_commands, command$, is_valid

    fn.rtn valid
fn.end


! ******************************************
! ******************************************

! ******************************************
! ******************************************

! ******************************************
! ******************************************

! #########################################

! Main

while 1
foo(r, current_location$, current_building$)
repeat

!!
Wait for user input
Parse input
If direction, check exits
If exit exists, display that description.
If action, display object description.
If quit or exit, do that.
Wait for user input.
!!



