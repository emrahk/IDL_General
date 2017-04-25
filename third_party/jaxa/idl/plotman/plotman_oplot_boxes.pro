; Written:  Sam Krucker
; Modified:
; 21-Apr-2001, Kim Tolbert.  Added labelwindow option.
;	25-May-2001, Kim.  Take care of case when cw_pixes=-1 and cw_nop=-1 (previously tried
;		to plot if they were defined without checking value)
;	21-Jul-2002, Kim.  Added thick keyword
; 2-Aug-2002, Kim.  Changed position of labelwindow label to make it more readable
;	11-Apr-2003, Kim.  Added cw_inverse keyword - draws dashed line for inverse boxes
;	19-Jul-2005, Kim.  Added boxnum keyword to choose which box(es) to draw
;	6-Nov-2007, Kim.  Save psym, set to 0, then restore at end. don't want histogram set
; 8-Jul-2008, Kim.  Renamed to plotman_oplot_boxes from hsi_oplot_clean_boxes (and removed
;   extraneous stuff) to remove hessi dependencies

PRO plotman_oplot_boxes,color=color,cw_pixels=cw_pixels,cw_nop=cw_nop, $
   labelwindow=labelwindow, thick=thick, cw_inverse=cw_inverse, boxnum=boxnum

nwin = 0

psym_save = !p.psym
!p.psym=0

linestyle = keyword_set(cw_inverse) ? 2 : 0

if keyword_set(cw_pixels) then begin

  if cw_nop[0] gt 0 then begin
	  nbox=n_elements(cw_nop)
	  nwin = nbox
	  first_pixel=0
	  for i=0,nbox-1 do begin
	        x=cw_pixels(0,first_pixel:first_pixel+cw_nop(i)-1)
	        x=[x(*),cw_pixels(0,first_pixel)]
	        y=cw_pixels(1,first_pixel:first_pixel+cw_nop(i)-1)
	        y=[y(*),cw_pixels(1,first_pixel)]
	        first_pixel=first_pixel+cw_nop(i)
            if exist(boxnum) then if where(i eq boxnum) eq -1 then continue
	        oplot,x,y,color=color, thick=thick, linestyle=linestyle
	        if keyword_set(labelwindow) then begin
	            a = convert_coord ([0,0], [0,!d.y_ch_size], [0,0], /device, /to_data)
	            yhalf = abs(a[1,1] - a[1,0]) / 2.
	            maxy = max(y, maxy_elem)
	            xyouts,x[maxy_elem], maxy+yhalf,strtrim(i,2),color=color, charsize=1.2
	        endif
	  endfor
   endif

endif

!p.psym=psym_save
END