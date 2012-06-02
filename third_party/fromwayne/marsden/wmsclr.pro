pro wmsclr
;***********************************************************************
; Widget displays and updates a histogram of multiscalar counts
; per channel.
; inputs:
;           dc.................detector code
;           cp.................cluster position
;     pha_edgs.................pha channel grouping edges
;      idf_hdr.................science header data
;       counts.................1 idf counts(position,det,pha_grp,tm_bin)
;        lvtme.................1 idf total livetme(position,det)
;     a_counts.................acc. counts(position,det,pha_grp,tm_bin)
;      a_lvtme.................acc. total livetme(position,det)
;    idfs,idfe.................idf start,stop #s for hist_accum.
;          idf.................current idf
;          dts.................start,date,time array
;           dt.................start,stop date,time array
;          opt.................cluster orientation code
;  num_tm_bins.................# of time bins
;     num_dets.................# detectors
;         disp.................show 1 idf(0) or accumulated(1)
;        start.................first time(0) or subsequent(1)
;          new.................new file(1) or not(0)
;        clear.................clear variable arrays if defined
;        ltime.................time step
;   pha_choice.................pha bin choice to display
;           ft.................plot fft of data if = 1
;      periods.................periods to fold data on
;         fold.................fold which period
;         fnme.................filename for data storage
;      phz_bns.................Number of phase bins
;      phz_arr.................Folded counts array
; Common blocks:
;    mev_block.................stores event variables for widgets
; 6/10/94 Current version
; 7/13/94 Bug fixed - smoother exit when done
; 1/11/95 Kills previous widget differently
; 4/31/95 Handles dates correctly
; 11/10/95 Accumulates livetime array
; Start constructing the widgets
;*********************************************************************
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common mev_block,dc,opt,accum,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,det,cp,dt,num_dets,pha_edgs,$
                 num_tm_bins,pha_choice,ltime,ft,periods,fold,fnme,$
                 phz_bns,idf_lvtme,cluster_pos,phz_arr
if (xregistered("wmsclr")ne 0) then kill = 1 else kill = 0
wmsclr = {	base:0L}
device,get_screen_size = scrsiz
wmsclr.base = widget_base(title = 'MULTISCALAR DATA',/frame,/column)
if (ks(phz_bns) eq 0)then phz_bns = 10
;**********************************************************************
; First get the strings for pha edges
;**********************************************************************
opt_str = ['OFF+','OFF-','ON SOURCE']
num_pha = n_elements(pha_edgs) - 1
ledg_str = strarr(num_pha) & uedg_str = ledg_str
ledg_str = string(pha_edgs(0:num_pha - 1))
uedg_str = string(pha_edgs(1:num_pha))
pha_str = strcompress('"' + ledg_str + ' TO ' + uedg_str + '"')
p_str = strcompress(ledg_str + ' TO ' + uedg_str)
pha_str_ = strarr(num_pha + 1)
pha_str_(0:num_pha - 1) = p_str & pha_str_(num_pha) = 'PHA SUM'
idfs_string = strcompress(idfs,/remove_all)
idfe_string = strcompress(idfe,/remove_all)
;**********************************************************************
; Form subtitle and get detector
;**********************************************************************
stle = strcompress('PHA CHNS: ' + pha_str_(pha_choice))
if (num_dets gt 1)then begin
   d1 = strcompress('DET' + string(indgen(num_dets) + 1),/remove_all)
   d2 = ['DET SUM','SHOW ALL']
   det_str = [strcompress(d1,/remove_all),d2]
endif else det_str = ['DET1']
det = where(det_str eq dc) + 1
det = det(0)
;**********************************************************************
; Process the latest values of the control variables opt,disp,det,
; and data_choice for the plotting.
;**********************************************************************
num_pha = n_elements(pha_edgs) - 1
if (disp eq 0)then begin
   cnts = counts & time = lvtme
   c = lonarr(num_pha,num_tm_bins)
   ntbins = num_tm_bins
   tle = 'IDF ' + idfe_string + ', ' + dc + ', ' + opt_str(opt-3)
   tle = strcompress(tle)
endif else begin
   cnts = a_counts & time = a_lvtme
   ntbins = n_elements(cnts(0,0,0,*))
   c = lonarr(num_pha,ntbins)
   tle = 'IDF ' + idfs_string + ' TO ' + idfe_string + ', ' + dc 
   tle = strcompress(tle + ', ' + opt_str(opt-3))
endelse
if (det lt 5)then begin
   c(*,*) = cnts(opt-3,det - 1,*,*) & tme = time(opt-3,det-1)
endif else begin
   cnts_ = reform(cnts(opt-3,*,*,*),num_dets,num_pha,ntbins)
   add = 0
   for i = 0,num_dets-1 do add = add + cnts_(i,*,*)
   c = reform(add,num_pha,ntbins)
   tme = total(time(opt-3,*))
endelse
cc = lonarr(ntbins) & b = lonarr(num_pha)
b(*) = 1 
if (pha_choice eq num_pha)then begin
   cc(*) = b#c
endif else begin
   cc(*) = c(pha_choice,*)
endelse
;****************************************************************
; Create correct date string
;****************************************************************
d = dt
if (disp eq 0)then d(1,*) = dt(0,*)
;*********************************************************************
; Display 'Attitude' data at top
;*********************************************************************
wtable,wmsclr.base,d,idfs_string,idfe_string,cp,string(tme)
;*********************************************************************
; Create the plotting area in the lower left
;*********************************************************************
wplot,wmsclr.base,400,400,draw,row3
;*********************************************************************
; Right collumn : create pull down menus
;**********************************************************************
rcol = widget_base(row3,/column)
rcol1 = widget_base(rcol,/column,/frame)
xpdmenu,['"DISPLAY"{','"1 IDF"','"ACCUM."','}'],rcol1
dstr = strcompress('"'+det_str+'"')
xpdmenu,['"DETS."{',dstr,'}'],rcol1
if (fold le 0 and ft eq 0)then $
opstr = strcompress('"'+['OFF+','OFF-','ON SRC','FFT','FOLD']+'"') $
else opstr = strcompress('"'+['OFF+','OFF-','ON SRC']+'"') 
xpdmenu,['"OPTION"{',opstr,'}'],rcol1
xpdmenu,['"PHA DISP"{','"IND."{',pha_str,'}','"PHA SUM"','}'],$
         rcol1
;********************************************************************
; Prompt for filename for storage or not
;********************************************************************
if (fnme eq 'get idl file' or fnme eq 'get ascii file')then begin
   str = strmid(fnme,4,strlen(fnme)-4)
   str = strcompress('ENTER ' + strupcase(str))
   w2 = widget_base(rcol1,/frame,/column)
   w1 = widget_label(w2,value=str)
   w1 = widget_text(w2,value='',uvalue=33,xsize=13,ysize=1,$
        /editable)
endif else begin
   xpdmenu,['"SESSION"{','"SAVE"{','"ASCII FILE"','"IDL FILE"','}',$
        '"DONE"','"CLEAR"','}'],rcol1
endelse
;**********************************************************************
; If in fft mode create fft box displaying 3 highest periods, 
; confidence levels,and folding option
;**********************************************************************
if (ft)then begin
   xpdmenu,['"RETURN"{','"TO MSCLR"','}'],rcol1
   xtle = 'FREQUENCY (S!E-1!N)'
   ytle = 'NORMALIZED POWER'
   tle = strcompress('FFT, ' + tle)
   ntbins = n_elements(cc)
   x = dindgen(1+ntbins/long(2))/(ntbins*ltime)
   cc_ = cc
   fftbox,cc_,x,rcol,periods,prob,nrm_pwr,phz_bns
   yy = nrm_pwr
   yymin = 0
   low = x - 1./(2.*ntbins*ltime)
   high = x + 1./(2.*ntbins*ltime)   
endif else begin
;**********************************************************************
; Do user-entered fold option
;**********************************************************************
   if (fold eq -1)then begin
      rcol2 = widget_base(rcol,/column,/frame)
      w1 = widget_label(rcol2,value='FOLDING:',/frame)
      w1 = widget_label(rcol2,value='PERIOD (S)')
      per = strcompress(periods(0))
      w1 = widget_text(rcol2,value=per,uvalue=22,xsize=5,ysize=1,$
           /editable)
      w1 = widget_label(rcol2,value='# PHZ BINS:')
      w1 = widget_text(rcol2,value=string(phz_bns),uvalue=21,xsize=5,$
           ysize=1,/editable)
      w1 = widget_button(rcol2,value='UPDATE',/frame)
   endif
;**********************************************************************
; Do buttons for fft mode and fold mode of data
;**********************************************************************
   if (fold gt 0)then begin
      xpdmenu,$
      ['"RETURN"{','"TO FFT"','"TO FOLD"','"TO MSCLR"','}'],rcol1
      per = periods(fold-1)
      ytle = 'COUNTS' & xtle = 'RELATIVE PHASE'
      tle = strcompress('PULSE PROFILE, ' + tle)
      per = periods(fold-1)
      time = ltime*dindgen(n_elements(cc))
      x = findgen(phz_bns)/(phz_bns-1.)
      fold_time_arr,time,cc,per,yy,np=phz_bns
      phz_arr = yy
      yymin = .9*min(yy)
      stle = strcompress(stle + ', PERIOD = ' + string(per) + ' S')
      low = x - .5*(x(1)-x(0))
      high = x + .5*(x(1)-x(0))
   endif else begin   
      x = findgen(ntbins) & yy = cc
      xtle = 'TIME (SEC)'
      ytle = 'COUNTS'
      yymin = 0
      low = ltime*findgen(ntbins)
      high = low + ltime
   endelse
endelse
;**********************************************************************
; Realize the widgets
;**********************************************************************
widget_control,wmsclr.base,/realize
widget_control,get_value = window, draw
wset, window
;**********************************************************************
; Now plot the arrays
;**********************************************************************
!x.style = 1 & !y.style = 1
!p.multi = 0
if (ft) then ft = 0
if (fold gt 0) then fold = 0
yrnge = [yymin,1.1*max(yy)]
xrnge = [max([min(low),0.]),max(high)]
hstplot,low,high,yy,xtle,ytle,tl=tle,st=stle,xr=xrnge,yr=yrnge
nz = where(yy ne 0)
if (nz(0) eq -1)then begin
   print,string(7b)
   xyouts,215,220,'NO DATA',/device,$
          charsize = 2,alignment=.5
   xyouts,220,195,'FOR THIS SELECTION',/device,$
          charsize = 2,alignment=.5
   xyouts,220,170,'(TRY AGAIN)',/device,$
          charsize = 2,alignment=.5
endif
;****************************************************************
; Kill old widgets and reset
;****************************************************************
xmanager,'wmsclr',wmsclr.base
if (kill)then widget_control,/destroy,wold
wold = wmsclr.base
;**********************************************************************
; Thats it for now
;**********************************************************************
return
end
