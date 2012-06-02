pro wfit,idfs,idfe,dt,cp,rt,ltime,opt,det,a,sigmaa,mdl,chisqr,nfree,$
 x,yfit,astring,typ,strtbn,stpbn,det_str
;***********************************************************************
; Widget fits the rates to simple Gaussian models and 
; displays the result.
; Variables are:
;	  idfs,idfe.............start,stop IDF#
;                rt.............rate to fit
;             ltime.............livetime string for rate
;                dt.............array of dates,times (start,stop)
;                cp.............cluster position
;               mdl.............model to fit
;               opt.............data option
;               det.............detector choice
;                 a.............array of parameters
;           astring.............array of parameter names
;              yfit.............fitted values
;                 x.............channel centers
;            chisqr.............chisqared statistic
;              iter.............number of iterations for fit
;             nfree.............   "    " degrees of freedom
;               typ.............data type for fitting
;      strtbn,stpbn.............start,stop bin of fit
;           det_str.............detector labelling string
; 6/10/94 Current version
; Start constructing the widget:
;***********************************************************************
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
if (xregistered("wfit")ne 0) then wold = wfit.base
if (xregistered("whist")ne 0) then wold = whist.base
if (xregistered("wphapsa")ne 0) then wold = wphapsa.base
if (xregistered("wcalhist")ne 0) then wold = wcalhist.base
if (xregistered("warchist")ne 0) then wold = warchist.base
tl = strcompress('FIT MODEL : ' + mdl)
np = n_elements(a) 
f = .06*(float(np gt 7))
device,get_screen_size = scrsiz
wfit = {	base:0L}
wfit.base = widget_base(title = tl,/frame,/column)
;***********************************************************************
; Get some variables
;***********************************************************************
num_chns = stpbn - strtbn + 1
case opt of
   1 : opt_str = ' NET ON'
   2 : opt_str = ' NET OFF'
   3 : opt_str = ' OFF+'
   4 : opt_str = ' OFF-'
   5 : opt_str = ' ON SRC'
   6 : opt_str = ' ANY'
endcase
time = float(ltime)
;**********************************************************************
; Display 'Attitude' data at top
;**********************************************************************
if (keyword_set(chisqr) eq 0)then begin
   chisqr = 1. & nfree = 1
endif    
wtable,wfit.base,dt,idfs,idfe,cp,ltime,chisqr,nfree
;****************************************************************
; Create the plotting area in the lower left
;****************************************************************
wplot,wfit.base,380,320,draw,row3,rw
;****************************************************************
; Options buttons
;*****************************************************************
w1 = widget_button(rw,value='FIT PARAMETERS')
w1 = widget_button(rw,value='SAVE FIT')
w1 = widget_button(rw,value=strcompress('DONE : RETURN TO '+ typ))
;*****************************************************************
; Right collumn, show latest parameters, errors, and other fit 
; information
;****************************************************************
parms,row3,a,sigmaa,astring
;****************************************************************
; Realize the widgets
;****************************************************************
widget_control,wfit.base,/realize
widget_control,get_value = window, draw
wset, window
;****************************************************************
; Draw the counts histogram and overplot fit array
;****************************************************************
trate = 'n'
if (typ eq 'PHSs')then begin
   pltphapsa,plt,opt,det,idfs,idfe,rt,strtbn,stpbn,x,yfit
endif else begin
   plthst,num_spec,1,det,rt,idfs,idfe,int,opt_str,trate,strtbn,$
          stpbn,x,yfit,det_str
endelse
;****************************************************************
; Kill old widgets and reset
;****************************************************************
xmanager,'wfit',wfit.base
if (ks(wold))then widget_control,wold,/destroy
wold = wfit.base
;****************************************************************
; Thats all ffolks. 
;****************************************************************
return
end
