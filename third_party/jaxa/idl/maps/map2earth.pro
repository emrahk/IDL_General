;+
; Project     : HESSI
;
; Name        : MAP2EARTH
;
; Purpose     : convert map to Earth-view
;
; Category    : imaging
;
; Syntax      : emap=map2earth(map)
;
; Inputs      : MAP = image map structure
;
; Outputs     : EMAP = remapped structure 
;
; Opt. Outputs: None
;
; Keywords    : TIME = time to differentially rotate map to
;                      [def keep at current map time]
;               REMAP = new keyword to remap disk pixels to Earth-orbit view
;
; Restrictions: Only remaps regions on disk.
;
; History     : Written 18 Oct 1999, D. Zarro, SM&A/GSFC
;               Modified, 20 April 2008, Zarro (ADNET) 
;                - improved to remap pixels to Earth-orbit view
;               Modified, 21 November 2010, Zarro (ADNET)
;                - made /remap and center=[0,0] the defaults
;
; Contact     : dzarro@solar.stanford.edu
;-

function map2earth,map,time=time,_extra=extra,remap=remap

if ~valid_map(map) then begin
 pr_syntax,'emap=map2earth(map)'
 return,-1
endif

if is_number(remap) then remap= (0 > remap < 1) else remap=1
remap=byte(remap)

if ~keyword_set(remap) then begin
 message,'recommend using /REMAP for more accurate Earth-view correction',/cont
 return,map2l1(map,/inverse)
endif

;-- compute Earth-orbit view angles to project to

nmaps=n_elements(map)
for i=0,nmaps-1 do begin
 etime=get_map_time(map[i]) 
 if valid_time(time) then etime=time
 ang=pb0r(etime,l0=l0,/arcsec)
 b0=ang[1] & rsun=ang[2]

 emap=drot_map(map[i],time=etime,b0=b0,l0=l0,rsun=rsun,$
      roll=0.,_extra=extra,center=[0,0])
 if have_tag(emap,'soho') then emap.soho=1b else begin
  soho=stregex(map[i].id,'SOHO',/bool,/fold)
  if soho then emap=add_tag(emap,1b,'soho')
 endelse
 emaps=merge_struct(emaps,emap,/no_copy)
endfor

return,emaps

end


