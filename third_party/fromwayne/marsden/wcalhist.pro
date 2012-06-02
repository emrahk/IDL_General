pro wcalhist,det,rate,idfs,idfe,cp,dt,livetime,opt,num_spec,int,$
            disp,trate,fnme
;*********************************************************************
; Widget displays and updates a histogram of callibration counts
; per channel.
; inputs:
;          det..............detector code
;         rate..............rate to plot
;    idfs,idfe..............start,stop idf#
;           dt..............array of start,stop dates and times
;           cp..............cluster position
;     livetime..............livetime for rate
;          int..............integrations to plot
;          opt..............data option
;         disp..............(0) 1 idf or (1) summed
;     num_spec..............number of spectra to plot 
;        trate..............total count rate/detector
;         fnme..............filename for saving
; 6/10/94 Current version
; 7/13/94 Bug fixed - smoother exit when donr
; 1/11/95 Kills previous widget differently
; 4/31/95 Handles dates correctly
; Start constructing the widgets
;*********************************************************************
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
if (xregistered('wcalhist') ne 0 or xregistered('wfit') ne 0)$
then kill = 1 else kill = 0
case opt of
   1 : opt_str = ' NET ON'
   2 : opt_str = ' NET OFF'
   3 : opt_str = ' OFF+'
   4 : opt_str = ' OFF-'
   5 : opt_str = ' ON SRC'
   6 : opt_str = ' ANY'
endcase 
livetime = strcompress(livetime,/remove_all)
idfs = strcompress(idfs,/remove_all)
idfe = strcompress(idfe,/remove_all)
;*********************************************************************
; Construct new widget
;*********************************************************************
device,get_screen_size = scrsiz
wcalhist = {	base:0L}
wcalhist.base = widget_base(title = 'CALLIBRATION HISTOGRAM',$
                /frame,/column)
;****************************************************************
; Create correct date string
;****************************************************************
d = dt
if (disp eq 0)then d(1,*) = dt(0,*)
;****************************************************************
; Display 'Attitude' data at top
;****************************************************************
wtable,wcalhist.base,d,idfs,idfe,cp,livetime
;****************************************************************
; Create the plotting area in the lower left
;****************************************************************
wplot,wcalhist.base,380,320,draw,row3
;****************************************************************
; Right collumn : create pull down menus
;****************************************************************
menu,row3,0,rcol,fnme
;****************************************************************
; Fitting box
;****************************************************************
fitbox,rcol,rcol1
;****************************************************************
; Create update button for doing changes, and realize the widgets
;****************************************************************
widget_control,wcalhist.base,/realize
widget_control,get_value = window, draw
wset, window
;****************************************************************
; Draw the counts histogram
;****************************************************************
plthst,num_spec,disp,det,rate,idfs,idfe,0,opt_str,trate   
;****************************************************************
; Kill old widgets and reset
;****************************************************************
xmanager,'wcalhist',wcalhist.base
if (kill)then widget_control,/destroy,wold
wold = wcalhist.base
;****************************************************************
; Thats it 
;****************************************************************
return
end
