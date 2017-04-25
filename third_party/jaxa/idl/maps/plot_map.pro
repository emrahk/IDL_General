;+
; Project     : SOHO_CDS
;
; Name        : PLOT_MAP
;
; Purpose     : Plot an image map
;
; Category    : imaging
;
; Syntax      : plot_map,map
;
; Inputs      : MAP = image structure map created by MAKE_MAP
;               INDEX = optional index (if array of maps) [def=0]
;
; Keywords    : See plot_map_index

; History     : 13 June 2012, Zarro (ADNET)
;               - written as vectorized wrapper to plot_map_index
;               25 February 2013, Zarro (ADNET)
;               - added call to REM_DUP_KEYWORDS to protect
;                against duplicate keyword strings (e.g. LOG vs
;                LOG_SCALE)
;               31 August 2015, Zarro (ADNET)
;               - supporting passing keywords without map input
;                 (useful for overlays)
;               7 February 2016, Zarro (ADNET)
;               - replace NEAREST by CLOSEST as it clashed
;                 /NEAREST_NEIGHBOR in ROT_MAP
;
; Contact     : dzarro@solar.stanford.edu
;-

pro plot_map,map,index,_ref_extra=extra,closest=closest

extra=rem_dup_keywords(extra)

if n_params() eq 0 then begin
 plot_map_index,_extra=extra
 return
endif

nmaps=n_elements(map)
if ~is_number(index) then index=0 else index= 0 > index < (nmaps-1)

;-- establish plot time for map arrays

if (nmaps gt 1) && valid_map(map) then begin
 if valid_time(closest) then tnear=anytim2tai(closest) 
 if valid_map(closest) then tnear=get_map_time(closest,/tai)
 if valid_time(tnear) then begin
  diff=abs(tnear-get_map_time(map,/tai))
  chk= where(diff eq min(diff))
  index=chk[0]
  mprint,'Plotting closest map at '+map[index].time,/info
 endif 
endif

if (nmaps le 1) then plot_map_index,map,_extra=extra else $
 plot_map_index,map[index],_extra=extra

return & end
