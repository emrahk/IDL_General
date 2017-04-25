;+
; Project     : HESSI
;
; Name        : GOES_FITS_FILES
;
; Purpose     : Return a list of possible SDAC GOES file names for specified times and all possible 
;  satellites.  File names are ordered as follows:  all files in time order for
;  the satellite requested, followed by all files in time order for each of the remaining
;  satellites ordered by reverse satellite number.
;  Calls gfits_files for file names, this routine just does the sorting.
;
; Category    : synoptic gbo
;
; Syntax      : IDL> files=goes_fits_files(stime,etime,sat=sat,_extra=extra)
;
; Inputs      : STIME, ETIME = start/end times to search
;
; Outputs     : List of filenames
;
; Keywords    : SAT - satellite number of files we think we want
;               NO_COMPLEMENT = set to not include non-matching satellites
;
; History     : Written 12 July 2005, S. Bansal, (SSAI/GSFC)
; 15-Dec-2005, Kim. Rewrote and changed header doc.
; 26-Dec-2005, Zarro (L-3Com/GSFC) - trapped missing or non-existent satellite
; 27-Dec-2005, Zarro (L-3Com/GSFC) - added /NO_COMPLEMENT
; 21-Apr-2007, Kim. call goes_sat instead of making array of sat #'s here.
; 10-Aug-2008, Kim. Removed part that finds file names - let gfits_files do that.
;  Also, in check for requested sat files, added Xsat... files (< 1980)
; 9-Oct-2008, Kim. prepend year_dir to file names, and change strmid check for sat
;
;-

function goes_fits_files, stime, etime, sat=satellite,$
         no_complement=no_complement, _extra=extra

if not is_number(satellite) then satellite=12

sat = trim(satellite, '(i2.2)')  ; make sure it's a string, with 2 digits

sat_list = trim(goes_sat(/number), '(i2.2)')

; files will be ordered by date, and then satellite number
gfits_files, stime, etime, sat_list, files, nfile, year_dir=year_dir
for i=0, n_elements(year_dir)-1 do  files[i,*] = year_dir[i] + '/' + files[i,*]

; now find the files for the requested satellite (gosat... for > 1980, Xsat... for < 1980)
q = where ( (strmid(files,5,4) eq 'go'+sat) or (strmid(files,5,3) eq 'X'+sat), $
           complement=comp, ncomplement=ncomp,count)

; return requested sat files first, then the rest of the files

if keyword_set(no_complement) then begin
 if count eq 0 then return,''
 return,files[q]
endif else begin
 if count eq 0 then return,files[comp]
 if ncomp eq 0 then return,files[q]
 return, [files[q], files[comp]]
endelse

end
