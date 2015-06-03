!!

DESCRIPTION

Load a text data file and process the records into a hash of hashes (bundle of bundles).

The custom data format is designed to be human writeable, the focus being on ease-of-use from a mobile device.

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
!!


! INCLUDES

include utils/dumper.bas

! ************** MAIN FUNCTION ***************
fn.def load_jogu_data(records, datafile$)

! CONSTANTS

let label_location$ = "loc"
let label_building$ = "building"
let label_exits$    = "exits"

! Config
!debug.on

! #########################################

! Setup
file.exists is_datafile_ok, datafile$
if ! is_datafile_ok then end "cannot open file \""+datafile$+"\" (does it exist?)"
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
            end "Missing ':' in line: " + fields$[j]
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
                if exit_dest_size <> 2 then end "ERROR: Malformed exit data '" + exits$[k] + "'"

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

    if building$ = "" then end "missing building definition"

    ! add record to the main bundle, indexed by building+location
    ! building entries won't have a location
    record_key$ = building$+"+"+location$
    bundle.put records, record_key$, record

    !debug.print "Records bundle:"
    !debug.dump.bundle records

next i

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
