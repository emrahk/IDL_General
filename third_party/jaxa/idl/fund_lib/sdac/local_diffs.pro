;+
; PROJECT: 
;	SDAC
; NAME: 
;	LOCAL_DIFFS
;
; PURPOSE:
;	This procedure finds all of the idl procedures in a directory(ies)
;	and reports those that are in the path.
;
; CATEGORY:
;	SYSTEM
;
; CALLING SEQUENCE:
;	Local_diffs, dirs, fname, status [, PATH=PATH, DELETE=DELETE]
;
; CALLS:
;	none
;
; INPUTS:
;       Dirs - source directory(ies)
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       Fname - files found in path.
;	Status - 0 file is identical, 1 file is different.
;	File_in_path - The first instance of the equivalent file in the path.
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORD INPUTS:
;	PATH - alternate search path in !path format. If submitted as an
;	array of strings, the !path format path will be constructed from
;	the elements using path_dir().
;	DELETE - If set, delete identical routines.
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	Version 1, richard.schwartz@gsfc.nasa.gov, 5-jan-1998.	
;-
pro local_diffs, dirs, fname, status, file_in_path, PATH=PATH, DELETE=DELETE

fname = ''
status= 0
f =strarr(20000)
jf=0L
for i=0,n_elements(dirs)-1 do begin
	
	ff = file_list(dirs(i),'*.pro',/cd)
	nf = n_elements(ff)
	if nf gt 0 then f(jf) = ff
	jf = jf + nf
endfor
if jf eq 0 then return

f = f(0:jf-1)

break_file,f,disk,dir,f1,ext

spath = size(path)
if spath(0) ge 1 then begin
	spath=path(*)
	path = path_dir( spath(0) )
	if n_elements(spath) gt 1 then for i=1,n_elements(spath)-1 do path = [path, path_dir( spath(i))]
	path = arr2str(path,':') 
endif

findfile_list,f1+'.pro',fcheck( path, !path),locs, /nocurrent

w = where( locs ne '', nw)

if nw ge 1 then begin
	break_file,f,disk,dir,f1,ext

	f2=concat_dir(locs(w),f1(w)+'.pro')
	file_in_path = f2
	fname = f(w)
	status = intarr(nw)
	for i=0,nw-1 do status(i) = file_diff(fname(i),f2(i),/idl)

	if keyword_set(delete) then begin
		w = where( status eq 0, nw)
		if nw ge 1 then begin
		print,(string(status)+'      '+fname)(w),form='(a)'
		test = ''
		read,'Enter KILL to delete:   ',test
		if strupcase(test) eq 'KILL' then $
		file_delete, fname(w)
		endif
	endif
endif
end
