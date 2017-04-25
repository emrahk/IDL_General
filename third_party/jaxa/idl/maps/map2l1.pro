;+
; Project     : SOHO-CDS
;
; Name        : MAP2L1
;
; Purpose     : convert EARTH-view image map to L1-view
;
; Category    : imaging
;
; Syntax      : lmap=map2l1(map)
;
; Inputs      : MAP = image map structure
;
; Outputs     : LMAP = remapped structure 
;
; Keywords    : INVERSE = set to map SOHO to EARTH-view
;               PARTIAL = set to correct offset pointing for partial frame 
;                         images
;
; History     : Written 17 October 1999, D. Zarro, SM&A/GSFC
;               Modified 23 February 2005, Zarro (L-3Com/GSFC) 
;                 - added /partial
;               Modified 17 November 2008, Zarro (ADNET)
;                - added check for SOHO in map ID
;
; Contact     : dzarro@solar.stanford.edu
;-

function map2l1,map,inverse=inverse,verbose=verbose,_extra=extra

if ~valid_map(map,old=old_format) then begin
 message,'Invalid input map',/cont       
 if exist(map) then return,map else return,''
endif
if (old_format) then begin
 message,'Old format not supported',/cont
 if exist(map) then return,map else return,''
endif

lmap=map
soho_added=0b
have_ang=have_tag(lmap,'l0')
if ~have_tag(lmap,'soho') then begin
 lmap=add_tag(lmap,0b,'soho')
 soho_added=1b
endif

dfac=1.01
to_soho=~keyword_set(inverse)
nmaps=n_elements(map)
for i=0,nmaps-1 do begin
 is_soho=stregex(lmap[i].id,'SOHO',/bool,/fold)
 if is_soho and soho_added then lmap[i].soho=1b
 at_soho=lmap[i].soho

;-- map to SOHO at L1

 if to_soho and ~at_soho then begin
  lmap[i].dx=dfac*lmap[i].dx
  lmap[i].dy=dfac*lmap[i].dy
  lmap[i].soho=1b
  if have_ang then begin
   ang=pb0r(lmap[i].time,l0=l0,/arcsec,/soho)
   b0=ang[1] & rsun=ang[2]
   lmap[i].l0=l0
   lmap[i].b0=b0
   lmap[i].rsun=rsun
  endif
 endif

;-- map to earth

 if ~to_soho and at_soho then begin
  lmap[i].dx=lmap[i].dx/dfac
  lmap[i].dy=lmap[i].dy/dfac
  lmap[i].soho=0b
  if have_ang then begin
   ang=pb0r(lmap[i].time,l0=l0,/arcsec)
   b0=ang[1] & rsun=ang[2]
   lmap[i].l0=l0
   lmap[i].b0=b0
   lmap[i].rsun=rsun
  endif
 endif

endfor
 
return,lmap & end


