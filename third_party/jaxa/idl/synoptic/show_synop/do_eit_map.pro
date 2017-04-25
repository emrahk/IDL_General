;+
; Project     : SOHO-CDS
;
; Name        : DO_EIT_MAP
;
; Purpose     : make EIT maps 
;
; Category    : planning
;
; Explanation : wrapper around mk_eit_map that works within SSW and CDS-SOFT
;
; Syntax      : emap=do_eit_map(data,header,index=index)
;
; Inputs      : DATA = data array
;               HEADER = FITS header (if not entered check INDEX)
; Opt. Inputs : 
;
; Outputs     : DATA = scale EIT image
;
; Keywords    : INDEX = index structure (used if HEADER not entered)
;               OUTSIZE = output image size
;
; History     : Written 1 June, 1998 Zarro (SAC/GSFC)
;               Modified 9 July, 2003 Zarro (EER/GSFC) - check SOHO orientation
;               Modified 9 Feb, 2004 Zarro (L-3Com/GSFC) - improved ROLL correction
;
; Contact     : dzarro@solar.stanford.edu
;-

function do_eit_map,data,header=header,index=index,outsize=outsize

err=''

;-- check inputs

header_input=is_string(header)
index_input=is_struct(index)

if (not exist(data)) or ((1-header_input) and (1-index_input)) then begin
 err='Invalid input data'
 pr_syntax,'data=do_eit_map(data,header=header,[index=index])
 return,-1
endif

if header_input then nindex=fitshead2struct(header) else nindex=index

;-- correct for SOHO roll

soho_roll=abs(get_soho_roll(nindex.date_obs))
rolled=soho_roll eq 180.

if rolled then begin
 message,'correcting for SOHO roll...',/cont
 data=rotate(temporary(data),2)
 nindex=rot_fits_head(nindex)
endif

return,mk_eit_map(nindex,data,outsize=outsize) 

end

