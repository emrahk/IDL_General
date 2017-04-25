;+
;
; NAME: 
;	FINDFILE_LIST
;
; PURPOSE:
;	This procedure takes a list of files and path (!path format) and
;	returns the directory or library of the first occurrence for each
;	element.
;
; CATEGORY:
;	GEN, UTIL, SYSTEM
;
; CALLING SEQUENCE:
;	FINDFILE_LIST, Files, Path, Locs
;
; CALLS:
;	BSORT, GET_LIB, GET_MOD, BREAK_FILE
;
; INPUTS:
;	Files- List of procedures including .pro extension
;	Path - Path in !path format
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;	Locs - The path for each file.
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	EXTENSION - optional extension, e.g. '.dat' to search for
;	CASE_IGNORE- For non-vms, ignore case (VMS default)
;	NOCURRENT - If set, then don't search the current directory.
;
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
;	For each directory in turn the filenames are extracted and compared to
;	the list.  As each file is located the list to find gets smaller.  The
;	search is terminated when the file list or directory list is exhausted.
;
; MODIFICATION HISTORY:
;	Richard Schwartz, 6 Sept 1996
;	Version 2, richard.schwartz@gsfc.nasa.gov, 30-dec-1997.
;-


pro findfile_list, files, path, locs, extension=extension, case_ignore=case_ignore, nocurrent=nocurrent

if keyword_set(case_ignore) or !version.os eq 'vms' then sproc = 'strlowcase' else sproc = 'string'
if not keyword_set( extension) then extension= '.pro'
if !version.os eq 'vms' then semic=';' else semic=''

libs = get_lib(path)
if keyword_set(nocurrent) then begin
	cd,curr=curr
	w = where( libs ne curr, nw)
	if nw ge 1 then libs = libs(w)
	endif

nlibs= n_elements(libs)

locs = strarr(n_elements(files))
wnull = where( locs eq '', nnull)
i = 0

while nnull ne 0 and i lt nlibs do begin

  if strpos(libs(i),'@') ne 0 then f=file_list(libs(i),'*'+extension +semic, /cd) $
	else begin
	 libs(i) = strmid(libs(i),1,100)
	 f=get_mod(libs(i))+ extension
	endelse

  break_file, f, disk, dir, fnam, ext
  c = call_function( sproc, [files(wnull), fnam+ext])
  s = bsort(c)
  c = c(s)
  wdp = where( c(1:*) eq c, ndp)
  
  if ndp ge 1 then locs(wnull(s(wdp))) = libs(i)

  wnull = where( locs eq '', nnull)
  i = i+1
endwhile

end
