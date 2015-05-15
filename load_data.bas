!!
TODO
* nothing
!!

! CONSTANTS

let label_location$ = "loc"
let label_building$ = "building"

print "Loading..."

! Config
debug.on
!debug.echo.on
datafile$ = "mud.txt"

! #########################################

! Functions

FN.DEF bprint(bundle, msg$)
 debug.PRINT msg$

 ! get the list of the keys
 ! in this bundle
 ! and the number of keys
 ! if the numbers of keys
 ! is zero then the bundle
 ! has no keys

 BUNDLE.KEYS bundle, list
 LIST.SIZE list, size
 IF size = 0
  debug.PRINT "Empty bundle"
  debug.PRINT " "
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
   BUNDLE.GET bundle, key$, value$
   debug.PRINT key$, value$
  ELSE
   BUNDLE.GET bundle, key$, value
   debug.PRINT key$, value
  ENDIF
 NEXT i

 debug.PRINT " "
 FN.RTN 1
FN.END


! #########################################

! Setup
! File.exists(is_datafile_ok, datafile$)
text.open r, fh, datafile$
let data_started = 0
let serial_data$ = ""
do
    !Debug.show.program

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
! TODO try using a list instead
! maybe need to count records first?
split records_raw$[], serial_data$, "#\n"

! print records for debugging
array.length num_records_split, records_raw$[]
debug.print "there are "+format$("###", num_records_split)+" split records"

!list.create N, records
bundle.create records
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
        array.delete parts$[]
        split parts$[], fields$[j], ": "
        let label$ = parts$[1]
        let content$ = parts$[2]
        bundle.put record, label$, content$

        ! update current building
        if label$ = label_building$ then building$ = content$

        ! save current location
        if label$ = label_location$ then location$ = content$

    next

    debug.print "Record bundle:"
    debug.dump.bundle record

    if building$ = "" then end "missing building definition"

    ! add record to the main bundle, indexed by building+location
    record_key$ = building$+"+"+location$
    bundle.put records, record_key$, record

debug.print "Records bundle:"
debug.dump.bundle records

next i

debug.print "Records bundle:"
debug.dump.bundle records

!cls


