debug.off

fn.defdumper(bundle)

letdumper_indent_size=4

letdumper_indent_char$=" "

debug.print"dumper_indent_size = "+format$(" ##",dumper_indent_size)

dumper_outer(bundle,dumper_indent_size,dumper_indent_char$,dumper_indent_size)

fn.end

fn.defstr$(number)

letout$=format$("#####",number)

fn.rtnout$

fn.end

fn.defdumper_indent$(size,dumper_indent_char$)

letindent$=""

debug.print"creating indent of "+format$(" ##",size)

fori=1tosize

indent$=indent$+dumper_indent_char$

nexti

debug.print"returning indent \""+indent$+"\" ("+format$("##",size)+" chars)"

fn.rtnindent$

fn.end

fn.defdumper_outer(bundle,dumper_indent_size,dumper_indent_char$,dumper_indent_size_orig)

print"bundle = {"

debug.print"dumper: dumper_indent_size = "+str$(dumper_indent_size)

dumper_inner(bundle,dumper_indent_size,dumper_indent_char$,dumper_indent_size_orig)

print"}"

fn.end

fn.defdumper_inner(bundle,indent_size,dumper_indent_char$,indent_size_orig)

letindent$=dumper_indent$(indent_size,dumper_indent_char$)

debug.print"inner: indent_size = "+str$(indent_size)

bundle.keysbundle,list

list.sizelist,size

ifsize=0

print"Empty bundle"

print" "

fn.rtn0

endif

fori=1tosize

list.getlist,i,key$

bundle.typebundle,key$,type$

iftype$="S"

bundle.getbundle,key$,value$

printindent$+"\""+key$+"\" => \""+value$+"\","

else

bundle.getbundle,key$,value

printindent$+"\""+key$+"\" => {"

dumper_inner(value,indent_size+indent_size_orig,dumper_indent_char$,indent_size_orig)

letclosing_bracket_indent$=dumper_indent$(indent_size-dumper_indent_size,dumper_indent_char$)

printclosing_bracket_indent$+"}"

endif

nexti

fn.end

fn.defload_jogu_data(records,datafile$)

letlabel_location$="loc"

letlabel_building$="building"

letlabel_exits$="exits"

file.existsis_datafile_ok,datafile$

if!is_datafile_okthenend"cannot open file \""+datafile$+"\" (does it exist?)"

text.openr,fh,datafile$

letdata_started=0

letserial_data$=""

do

text.readlnfh,line$

debug.print"processing line: "+line$

ifline$="#"thennum_records+=1

ifstarts_with("###",line$)&!data_started

letdata_started=1

d_u.continue

endif

if!data_startedthend_u.continue

ifstarts_with("!",line$)thend_u.continue

ifstarts_with("###",line$)&data_startedthend_u.break

serial_data$=serial_data$+line$+"
"

debug.print"serial data = <"+serial_data$+">"

untilline$="EOF"

text.closefh

debug.print"there are "+format$("###",num_records)+" raw records"

debug.print"all records BEGIN: "+serial_data$+" END."

splitrecords_raw$[],serial_data$,"#
"

array.lengthnum_records_split,records_raw$[]

debug.print"there are "+format$("###",num_records_split)+" split records"

building$=""

fori=1tonum_records_split

debug.print"record "+format$("#",i)+" = '"+records_raw$[i]+"'"

ifrecords_raw$[i]=""thenf_n.continue

array.deletefields$[]

splitfields$[],records_raw$[i],"
"

array.lengthnum_fields,fields$[]

bundle.createrecord

letlocation$=""

forj=1tonum_fields

if!is_in(":",fields$[j])

end"Missing ':' in line: "+fields$[j]

endif

array.deleteparts$[]

splitparts$[],fields$[j],": "

letlabel$=parts$[1]

letcontent$=parts$[2]

iflabel$=label_exits$then

array.deleteexits$[]

splitexits$[],content$,",\\s?"

debug.dump.arrayexits$[]

array.lengthnum_exits,exits$[]

bundle.createexits_bundle

fork=1tonum_exits

array.deleteexit_dest$[]

splitexit_dest$[],exits$[k],"\\s?=\\s?"

debug.dump.arrayexit_dest$[]

array.lengthexit_dest_size,exit_dest$[]

ifexit_dest_size<>2thenend"ERROR: Malformed exit data '"+exits$[k]+"'"

bundle.putexits_bundle,exit_dest$[1],exit_dest$[2]

nextk

bundle.putrecord,label$,exits_bundle

else

bundle.putrecord,label$,content$

endif

iflabel$=label_building$thenbuilding$=content$

iflabel$=label_location$thenlocation$=content$

next

ifbuilding$=""thenend"missing building definition"

record_key$=building$+"+"+location$

bundle.putrecords,record_key$,record

nexti

debug.print"--------------------------"

debug.print"Records bundle:"

debug.dump.bundlerecords

fn.rtnrecords

fn.end

bundle.creater

letdatafile$="jogu_data.txt"

load_jogu_data(&r,datafile$)

letstarting_building$="32 Cowper Road"

letstarting_location$=starting_building$+"+Hallway"

bundle.containr,starting_location$,start_exists

ifstart_exists=0thenend"ERROR: start location \""+starting_location$+"\" not found"

current_location$=starting_location$

current_building$=starting_building$

fn.defbundle_get_keys$(bundle)

letout$=""

bundle.keysbundle,list

list.sizelist,size

fori=1tosize

list.getlist,i,key$

bundle.getbundle,key$,value$

ifout$=""then

out$=out$+key$

else

out$=out$+", "+key$

endif

nexti

fn.rtnout$

fn.end

fn.deffoo(r,current_location$,current_building$)

whilecommand$<>"Q"

bundle.containr,current_location$,current_exists

ifcurrent_exists=0thenend"ERROR: current location \""+current_location$+"\" not found"

bundle.getr,current_location$,here

bundle.gethere,"loc",loc$

bundle.gethere,"desc",desc$

bundle.gethere,"exits",exits_bundle

letexits$=bundle_get_keys$(exits_bundle)

print""

print"("+current_building$+")"

print"==================================="

printloc$

print""

printdesc$

print""

print"Exits: "+exits$

print""

tgetcommand$,"Type a command > ","Jogu Adventure"

array.deletecommand_chars$[]

splitcommand_chars$[],command$,""

debug.print"You entered: '"+command$+"'"

command$=chomp$(command$)

command$=lower$(command$)

debug.print"I processed: '"+command$+"'"

letparsed_command$=parse_direction$(command$)

ifparsed_command$<>""then

debug.print"I parsed: '"+parsed_command$+"'"

parsed_exit$=upper$(parsed_command$)

bundle.containexits_bundle,parsed_exit$,is_direction_valid

ifis_direction_valid=0

then

print"You can't go that way"

w_r.continue

endif

bundle.getexits_bundle,parsed_exit$,new_location$

new_location_key$=current_building$+"+"+new_location$

current_location$=current_building$+"+"+new_location$

w_r.continue

endif

letparsed_command$=parse_look$(command$)

ifparsed_command$<>""then

debug.print"I parsed: '"+parsed_command$+"'"

w_r.continue

endif

debug.print"I parsed: '"+parsed_command$+"'"

print"Sorry, I don't recognise \""+command$+"\", try something else..."

w_r.continue

repeat

fn.rtn1

fn.end

fn.defparse_direction$(command$)

bundle.createv

bundle.putv,"n","n"

bundle.putv,"e","e"

bundle.putv,"s","s"

bundle.putv,"w","w"

bundle.putv,"north","n"

bundle.putv,"east","e"

bundle.putv,"south","s"

bundle.putv,"west","w"

bundle.putv,"ne","ne"

bundle.putv,"se","se"

bundle.putv,"nw","nw"

bundle.putv,"sw","sw"

bundle.putv,"northeast","ne"

bundle.putv,"southeast","se"

bundle.putv,"northwest","nw"

bundle.putv,"southwest","sw"

bundle.putv,"north-east","ne"

bundle.putv,"south-east","se"

bundle.putv,"north-west","nw"

bundle.putv,"south-west","sw"

bundle.containv,command$,valid

ifvalidthen

bundle.getv,command$,parsed_command$

fn.rtnparsed_command$

else

fn.rtn""

endif

fn.end

fn.defparse_look$(command$)

ifcommand$="look"|command$="l"then

fn.rtn"l"

else

fn.rtn""

endif

fn.end

fn.defsubstr$(string$,start,length)

array.deletechars$[]

splitchars$[],string$,""

debug.print"Original string is: '"+string$+"', that breaks down to:"

debug.dump.arraychars$[]

letnewstring$=""

letoffset=1

fori=starttostart+length-offset

newstring$=newstring$+chars$[i+offset]

nexti

debug.print"Extracted substring: '"+newstring$+"'"

fn.rtnnewstring$

fn.end

fn.defchomp$(string$)

array.deletechars$[]

splitchars$[],string$,""

array.lengthlength,chars$[]

newstring$=substr$(string$,1,length-2)

fn.rtnnewstring$

fn.end

foo(r,current_location$,current_building$)

