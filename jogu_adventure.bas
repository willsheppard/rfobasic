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

let starting_location$ = "32 Cowper Road+Hallway"
bundle.contain r, starting_location$, start_exists
if start_exists = 0 then end "ERROR: start location \"" + starting_location$ + "\" not found"

current_location$ = starting_location$

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
        bundle.type bundle, key$, type$
        if type$ = "S"
            bundle.get bundle, key$, value$
            out$ = out$ + key$
        else
            bundle.get bundle, key$, format$("######", value)
            out$ = out$ + key$
        endif

    next i
    fn.rtn out$
fn.end


! ******************************************
! Display current location
fn.def foo(r, current_location$)
! ******************************************
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
    print "==================================="
    print loc$
    print ""
    print desc$
    print ""
    print "Exits: " + exits$
    print ""

    ! Display prompt
    tget command$, "Type a command > ", "Jogu Adventure"
    !print "I recognise: " + command$

    ! Parse command
    let valid_command = bar(command$)

    ! Change current location
    ! ...needs data

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
    foo(r, current_location$)
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



