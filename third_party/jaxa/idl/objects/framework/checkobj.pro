; Time-stamp: <Tue Nov 04 2003 10:53:01 csillag soleil.ifi.fh-aargau.ch>

pro checkobj, variable, default, object_name

checkvar, variable, default

if not obj_valid( variable ) then begin 
    variable=obj_new( object_name, variable )
endif

end
