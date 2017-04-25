;+
; Name: plotman::get_yloc
; 
; Purpose: Plotman method - in a plotman window with overlays, returns the y location of each panel in the window as
; a [2,n] array where the first dimension is the start/end of the panel and the second dimension is the panel number.
; i.e. bottom of top panel is given in yloc[0,0] and top of top panel is given in yloc[1,0].
; The units are percentage of the window, or if /frac is set, fraction of the window.
; 0. is at the bottom, 100. (or if /frac is set, 1.) is at the top of the window.
; If the panel y sizes weren't specified explicitly, then an array of 0s is returned.
; 
; Input Keyword:
;  ov_num - overlay number to get y location for.  If not passed, returns all.
;  frac - if set, returns y locations as fraction of window height
;  overlay_ysize - overlay sizes in percent (in case they haven't been saved in obj yet)
;  overlay_panel - overlay panel names (in case they haven't been save in obj yet)
;  
; Output Keywords:
;  new_size - array of sizes for each panel (in percentage or fraction, depending on frac keyword)
;  
; Example:
;   yloc = p->get_yloc()
;   help,yloc
;   <Expression>    FLOAT     = Array[2, 13]
;   
; Written: Kim Tolbert 6-Sep-2012
; 27-Nov-2012, Kim.  Changed ov_num from an arg to a keyword and added 4 more keywords. Also default is to return percent 
;   now, unless frac is set
;-

function plotman::get_yloc, $
  overlay_ysize=overlay_ysize, $
  overlay_panel=overlay_panel, $
  frac=frac, $
  ov_num=ov_num, $
  new_size=ysize

; get overlay sizes in percent, and convert to fraction 
ysize = keyword_set(overlay_ysize) ? overlay_ysize : self -> get(/overlay_ysize)
ysize0 = ysize[0]
;message, /info, 'ysize0 = '+ trim(ysize0)

zeroes = ysize * 0  ; array of correct length containing all zeroes

overlay_panel = keyword_set(overlay_panel) ? overlay_panel : self -> get(/overlay_panel)

ind = where (overlay_panel ne '', count)
  
; If panel y sizes weren't specified explicitly (all ysizes are 0), or there are no overlay panels, 
; return array of 0s
if total(ysize) eq 0. or count eq 0 then begin
  ylo = zeroes
  yhi = zeroes
endif else begin

  if total(ysize[ind]) eq 0 then begin
    ; if overlay panels don't have any ysizes already set, divide up the space remaining after the first panel
    ; evenly among the remaining overlays 
    ysize[1:*] = 0
    for i=0,count-1 do ysize[ind[i]] = (100 - ysize0) / count
  endif else begin
    ; if overlay panels do have ysizes already set, divide up the space remaining after the first panel
    ; evenly among the remaining overlays 
    total_ysize_left = total(ysize[ind])
    old_ysize = ysize
    ysize[1:*] = 0
    for i=0,count-1 do ysize[ind[i]] = (100 - ysize0) * old_ysize[ind[i]]/total_ysize_left
  endelse
  
  ylo = 100. - total(ysize,/cum)
  yhi = ylo + ysize
endelse

if keyword_set(frac) then begin
  ysize = ysize / 100.
  ylo = ylo / 100.
  yhi = yhi / 100.
endif

;print,'ylo: ', ylo
;print,'yhi: ', yhi

return, exist(ov_num) ? [ylo[ov_num], yhi[ov_num]] : transpose([ [ylo], [yhi] ])
end
