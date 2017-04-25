pro gif2ps,name,key1, BLACK=black, FNAME=fname, COLOR=color
;
;  This is an idl procedure that reads a gif file
;  or an input array and generates a .ps file.  
;
; INPUTS
;  name is name of GIF file or 2d bytarr
;  key1 is set to l or p for landscape or portrait.
;  key2 is set to c for color
;
; KEYWORDS
;  BLACK	If set, background will be black (default
;		is white)
;  FNAME	Set equal to desired output filename.
;  COLOR	Set for color postscript output
;
; Written by Nathan Rich, NRL/LASCO/Interferometrics
;
; MODIFIED
;   2/16/01, nbr - Allow array input
;
;-
;
	if ( key1 ne 'l') and ( key1 ne 'p') then begin
		print,'Please enter l for landscape or p for portrait - returning'
		return
	   endif
;
out=''
IF datatype(name) EQ 'STR' THEN BEGIN
   read_gif,name,t,r,g,b 
   nn=strpos(name,'.')
   out=strmid(name,0,nn)+'.ps'
ENDIF ELSE BEGIN
   IF keyword_set(FNAME) THEN out=fname ELSE read,'Please enter output filename: ',out
   t=name
   tvlct,r,g,b,/get
ENDELSE
;
;
set_plot,'ps',/interpolate
if keyword_set(BLACK) THEN !p.background=0
device,file=out
;
IF keyword_set(COLOR) THEN BEGIN
   device,/color
   print,'Making color plot'
ENDIF ELSE print,'B&W Output'
;
if key1 eq 'l' then begin
	device,bits_per_pixel=8,/landscape
	landscape_layout,t
    endif
;
if key1 eq 'p' then begin
	device,bits_per_pixel=8,/portrait
	portrait_layout,t
    endif
;
tvlct,r,g,b
tv,t
;
device,/close
set_plot,'x'
;
return
;
end


