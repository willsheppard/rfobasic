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
* Validate data: Required fields, unexpected fields, exits must all lead somewhere, etc.
* Change "building" to "area" everywhere
* Support multiple buildings
* Change "+" joining char to "/" and abstract out
* Make the first location in the file the starting location, so we don't have to specify it in the code
!!


! INCLUDES

include utils/dumper.bas % dumper
include utils/toolkit.bas % list_summary, bundle_get_keys, substr, chomp

! ************** MAIN FUNCTION ***************
fn.def load_jogu_data(records, datafile$)

! CONSTANTS

let CONST_BUILDING_RECORD_KEYS_COUNT = 1 % building
let label_building$    = "building"

let CONST_LOCATION_RECORD_KEYS_COUNT = 3 % loc, desc, exits
let label_location$    = "loc"
let label_description$ = "desc"
let label_exits$       = "exits"

list.create S, valid_location_keys_list
list.add valid_location_keys_list, label_location$, label_description$, label_exits$

! Config
!debug.on

! #########################################

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

!debug.on

building$ = ""
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
            end error_msg$+"Missing separator ':' in line: " + fields$[j] + "\nCannot continue."
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
        end if

        ! update current building
        if label$ = label_building$ then building$ = content$

        ! save current location
        if label$ = label_location$ then location$ = content$

    next

    debug.print "Record bundle:"
    debug.dump.bundle record

    if building$ = "" then end error_msg$+"Missing building definition. Cannot continue"

    ! add record to the main bundle, indexed by building+location
    ! building entries won't have a location
    record_key$ = building$+"+"+location$
    bundle.put records, record_key$, record

    !debug.print "Records bundle:"
    !debug.dump.bundle records

next i

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

    debug.dump.bundle record
    list.create S, record_keys_list
    bundle.keys record, record_keys_list
    array.delete record_keys_array$[]
    list.toarray record_keys_list, record_keys_array$[]
    array.length num_record_keys, record_keys_array$[]
    debug.print "num_record_keys = "+str$(num_record_keys)

    ! is it a building record?
    bundle.contain record, label_building$, is_building
    debug.print " is building? "+str$(is_building)
    if is_building
        bundle.get record, label_building$, test_building$
        debug.print "Validating building record '"+ test_building$ + "'"
        if num_record_keys <> CONST_BUILDING_RECORD_KEYS_COUNT
            print error_msg$+"Found "+str$(num_record_keys)+" keys but expected "+str$(CONST_BUILDING_RECORD_KEYS_COUNT)+" for building record:"
            dumper(record)
            end "Cannot continue."
        end if

        if record_keys_array$[1] <> label_building$ then end error_msg$+ "Expected building key of '"+label_building$ +"', not '"+ record_keys_array$[1] +"'. Cannot continue."

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
    bundle.keys exits_bundle, exits_list
    array.delete exits_array$[]
    list.toarray exits_list, exits_array$[]
    array.length num_exits, exits_array$[]

    ! Extract the building name from the key
    array.delete location_parts$[]
    split location_parts$[], full_location_key$, "\\+"
    let test_building$ = location_parts$[1]

    for d = 1 to num_exits
        bundle.get exits_bundle, exits_array$[d], destination$
        full_destination$ = test_building$ + "+" + destination$
        debug.print " full_destination = "+ full_destination$
        bundle.contain records, full_destination$, is_valid_location
        if ! is_valid_location then
            print error_msg$+"Could not find location '"+destination$+"' in building '"+test_building$+"':"
            dumper(record)
            end "Cannot continue."
        end if
    next d % num_exits

    end if % location record

next a % num_locations (validation)

debug.print "--------------------------"
debug.print "Records bundle:"
debug.dump.bundle records

!include dumper.bas
!dumper(records)

fn.rtn records

fn.end

!!
! ####################################
! Test

bundle.create b
let datafile$ = "jogu_data.txt"
load_jogu_data(&b, datafile$)

!include dumper.bas
debug.off
dumper(b)

!!
