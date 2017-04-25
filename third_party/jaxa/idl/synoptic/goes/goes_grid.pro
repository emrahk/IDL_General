pro goes_grid, color=color, grid_thick=grid_thick
;
;+
;   Name: goes_grid
;
;   Purpose: draw grid on previously drawn goes plot (assume utplot)
;
;   History:
;      1-sep-1992 (circa) (SLF)
;      7-Dec-1992 (use normalized coords)
;     13-Sep-1994 added grid_thick to control grid thickness
;     14-Sep-1994 guard against  undefined grid_thick
;
;-
nhoriz=6
coln=n_elements(color)
gcolor=intarr(nhoriz)
if n_elements(grid_thick) eq 0 then grid_thick=1

case 1 of
   coln eq 0:  gcolor(0)=replicate(255,nhoriz)
   coln eq 1:  gcolor(0)=replicate(color,nhoriz)
   coln ge nhoriz: gcolor(0)=color(0:nhoriz-1)
   else: gcolor(0)=color
endcase
   
yvals=findgen(nhoriz)+1
yvals=yvals*(!y.window(1)-!y.window(0))/nhoriz
yvals=yvals+!y.window(0)
for i=0,4 do $
   plots,!x.window,replicate(yvals(i),2),color=gcolor(i),/normal, $
	thick=grid_thick
return
end

