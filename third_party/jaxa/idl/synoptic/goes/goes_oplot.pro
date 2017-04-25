;+
; Name: goes_oplot
;
; Purpose: Overlay a GOES plot with bad points and level information.
;
; Explanation:  An X is drawn on the Y curve at the location of elements that
;   had to be interpolated because of glitches.  The letter A,B,C, etc is drawn
;   to the right of the Y axis at the level of that indicator (A=1.e-8, etc).
;
;   This is called via the addplot_name, addplot_args mechanism from
;   the xyplot plot object.  All of the arguments (xcept dim1_xxx) were put
;   into the addplot_args structure, which was set into the xyplot object.
;   When this is called from the xyplot object, it joins the structure of
;   its own properties with this structure - that's where dim1_xxx comes from.

; Input Keywords:
;   markbad - If set, mark bad points with Xs
;   showclass - If set, display A,B,C,M,X indicators at right of plot
;   tarray    - array of times
;   ydata - yarray of plot (may be ntimes or ntimesx2channels)
;   ybad - elements in ydata that were bad
;   dim1_use - channel we're plotting (if ydata is (ntx2), dim1_use
;     may be 0, or 1, or [0,1] )
;   dim1_colors - color for each channel (blank string array if none)
;
; Written: Kim Tolbert 25-Aug-2005
;
; Modifications:
; 12-Jan-2006, Kim.  Use dim1_colors from xyplot object for colors of bad points
; 6-Aug-2008, Kim.  Don't plot bad points with index=-1. (was plotting X at -1, beginning of plot)
;-


pro goes_oplot, $
   markbad=markbad, showclass=showclass, $
   tarray=tarray, ydata=ydata, ybad=ybad, dim1_use=dim1_use, dim1_colors=dim1_colors

psymsave=!p.psym
!p.psym=0

if keyword_set(markbad) then begin

   for i=0,n_elements(*dim1_use)-1 do begin
      ind = (*dim1_use)[i]
      ; if no colors defined (blank string), use 255
      color = is_string( (*dim1_colors)[i],/blank) ? 255 : (*dim1_colors)[i]
      q=where(ybad[*,ind] ne -1,c)
      if c gt 0 then oplot, tarray(ybad[q,ind]), ydata(ybad[q,ind],ind), psym=7, color=color
   endfor

endif

if (keyword_set(showclass)) then begin
   ylims = crange('y')
   ytickv = 10.^[-13+indgen(12)]
   ytickname = [' ',' ',' ',' ',' ','A','B','C','M','X',' ',' ']
   ymm = ylims + ylims*[-1.e-7, 1.e-7]
   q = where(( ytickv ge ymm(0)) and ( ytickv le ymm(1)), kq)
   if kq gt 0 then axis, yaxis=1, ytickv = ytickv(q),/ylog,  $
         ytickname=ytickname(q),yrange=ylims, yticks=n_elements(q)
endif

!p.psym = psymsave

end
