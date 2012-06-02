pro wphapsa
;*********************************************************************
; Widget displays and updates a pha/psa display of counts
; per psa,pha channel.
; Get and define some values:
;         dc.................detector code
;         cp.................cluster position
;        opt.................data display option
;      accum.................accumulation option
;    idf_hdr.................science header data
;     rates0.................counts/sec for single idf
;     rates1.................counts/sec for accum
;     counts.................1 idf counts(position,det,psachns,chn)
;      lvtme.................1 idf ltime(position,det,psachns)
;   a_counts.................accumulated counts(position,det,chn)
;   a_lvtime.................accumulated livetime(position,det)
;  idfs,idfe.................idf start,stop #s for accum.
;        dts.................start,date,time array
;         dt.................start,stop date,time array
;    psachns.................# of pulse shape channels
;    phachns.................# of pulse height channels
;   num_dets.................# detectors
;       disp.................show 1 idf(0) or accumulated(1)
;        plt.................plotting option(surface,shade_surf,slice)
;  chn_slice.................slice in psa/pha space to plot
;      start.................first time(0) or repeat(1)
;        new.................new file(1) or not(0)
;      clear.................clear variable arrays if defined
;       colr.................color table code
;  idf_lvtme.................array of livetimes
; Common blocks:
;  pev_block.................between phapsa and wphapsa event manager
; 6/10/94 Current version
; 7/13/94 Bug fixed - smoother exit when done
; 1/11/95 Kills previous widget differently
; 5/31/95 Handles dates correctly
; 11/10/95 Livetime array
; Start constructing the widgets
;*********************************************************************
common pev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,chn_slice,det,rt,cp,dt,ltime,$
                 rates0,rates1,det_str,psachns,phachns,plt,num_dets,$
                 colr,fnme,idf_lvtme
common phapsa_block,idf_hdr,idf,date,spectra,livetime,typ
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common nai,arr,nai_only
if (xregistered('wphapsa') ne 0 or xregistered('wfit') ne 0)$
then kill = 1 else kill = 0
rate = rt
ltime = strcompress(ltime,/remove_all)
idfs = strcompress(idfs,/remove_all)
idfe = strcompress(idfe,/remove_all)
if (det eq 6)then begin
   num_psa = n_elements(rate(0,*,0))
   num_pha = n_elements(rate(0,0,*))
endif else begin
   num_psa = n_elements(rate(*,0))
   num_pha = n_elements(rate(0,*))
endelse
;*********************************************************************
; Construct new widget
;*********************************************************************
device,get_screen_size = scrsiz
wphapsa = {	base:0L}
wphapsa.base = widget_base(title = 'PHA/PSA DISPLAY',/frame,/column)
;*********************************************************************
; Get color table information
;*********************************************************************
plt_code = strarr(40)
plt_code(0) = ['"SHADE SURF"{']
clr_tble_names = ['"BLACK/WHITE"','"BLUE/WHITE"','"G/R/B & W"',$
                  '"RED TEMP."','"B/G/R & Y"','"STD GAMMA"',$
                  '"PRISM"','"RED/PURP"','"GREEN/WHITE L"',$
                  '"GREEN/WHITE E"','"GREEN/PINK"','"BLUE/RED"',$
                  '"16 LEVEL"','"RAINBOW1"','"STEPS"','"PY DREAM"',$
                  '"HAZE"','"BLUE/PAS./RED"','"PASTELS"','"HUE SAT 1"',$
                  '"HUE SAT 2"','"HUE SAT 3"','"CTHULHU"',$
                  '"PUP/RED/STR"','"BEACH"','"MAC STY"','"EOS A"',$
                  '"EOS B"','"CANDY"','"NATURE"','"SURFING"','"PPRMINT"',$
                  '"PLASMA"','"BLUE/RED2"','"RAINBOW2"','"WAVES1"',$
                  '"VOLCANO"','"WAVES2"}','}']
plt_code(1:39) = clr_tble_names
if (ks(nai_only) eq 0)then events = '"NAI ONLY"' else $
events = '"ALL EVTS."'
plt3 = ['"SLICE"{','"PHA SLICE"','"PSA SLICE"','}']
;*************************************************************************
; Get the detector code string
;*************************************************************************
if (idf_hdr.nd eq 1)then begin
   d_str = strarr(num_dets + 2)
   d_str(num_dets + 1) = '}'
   d_str(1:num_dets) = strcompress('"' + det_str + '"')
endif else begin
   d_str = strarr(num_dets + 3)
   d_str(num_dets + 2) = '}'
   d_str(1:num_dets + 1) = strcompress('"' + det_str + '"')
endelse
d_str(0) = '"DETS."{' 
;************************************************************************
; Define temporary variable for date display
;************************************************************************
d = dt
if (disp eq 0)then d(1,*) = d(0,*)
;************************************************************************
; Display 'Attitude' data at top
;************************************************************************
wtable,wphapsa.base,d,idfs,idfe,cp,ltime
;************************************************************************
; Create the plotting area in the lower left
;************************************************************************
wplot,wphapsa.base,450,350,draw,row3,rr
;************************************************************************
; Right collumn : create pull down menus
;************************************************************************
rcol = widget_base(row3,/column)
if (plt eq 3)then begin
   s_str = 'PHA START:' & e_str = 'PHA END:'
   r_str = strcompress('PHA CHNS AVAILABLE : 1 TO ' + string(num_pha) + ':')  
   r4 = widget_base(rr,/frame,/column)
   w1 = widget_label(r4,/frame,value = 'ENTER SLICE')
   w1 = widget_label(r4,value = r_str)
   col1 = widget_base(r4,/row)
   w1 = widget_label(col1,value = s_str)
   w1 = widget_text(col1,/editable,uvalue=10,$
        value=string(chn_slice(0)),xsize = 10,ysize = 1)       
   w1 = widget_label(col1,value = e_str)
   w1 = widget_text(col1,/editable,uvalue=11,$
        value=string(chn_slice(1)),xsize = 10,ysize = 1) 
   w1 = widget_button(r4,value = 'DO SLICE')
endif
if (plt eq 2)then begin
   s_str = 'PSA START:' & e_str = 'PSA END:'
   r_str = strcompress('PSA CHNS AVAILABLE : 1 TO ' + string(num_psa) + ':')  
   r4 = widget_base(rr,/frame,/column)
   w1 = widget_label(r4,/frame,value = 'ENTER SLICE')
   w1 = widget_label(r4,value = r_str)
   col1 = widget_base(r4,/row)
   w1 = widget_label(col1,value = s_str)
   w1 = widget_text(col1,/editable,uvalue=12,$
        value=string(chn_slice(0)),xsize = 10,ysize = 1)       
   w1 = widget_label(col1,value = e_str)
   w1 = widget_text(col1,/editable,uvalue=13,$
        value=string(chn_slice(1)),xsize = 10,ysize = 1) 
   w1 = widget_button(r4,value = 'DO SLICE')
endif
rcol1 = widget_base(rcol,/column,/frame)
xpdmenu,['"DISPLAY"{','"1 IDF"','"ACCUM."','}'],rcol1
xpdmenu,d_str,rcol1
xpdmenu,['"DATA OPTION"{','"NET ON"','"NET OFF"','"OFF+"',$
        '"OFF-"','"ON SRC"','"ANY"','}'],rcol1
xpdmenu,['"PLOT OPTION"{',plt_code,plt3,'"CONTOUR"',$
        events,'}'],rcol1
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
;********************************************************************
; Create update button for doing changes
;********************************************************************
;w1 = widget_button(rcol1,value='UPDATE')
;***********************************************************************
; Fitting box
;***********************************************************************
if (plt eq 2)then maxbin = psachns 
if (plt eq 3)then maxbin = phachns
if (plt lt 2)then maxbin = phachns
fitbox,rcol,maxbin
;***********************************************************************
; Realize the Widgets and draw the plotting area
;***********************************************************************
widget_control,wphapsa.base,/realize
widget_control,get_value = window, draw
wset, window
;***********************************************************************
; Draw the correct plot
;***********************************************************************
pltphapsa,colr,float(ltime),chn_slice,disp,plt,opt,det,det_str,idfs,$
       idfe,rate,rt
;****************************************************************
; Kill old widgets and reset
;****************************************************************
xmanager,'wphapsa',wphapsa.base
if (kill)then widget_control,/destroy,wold
wold = wphapsa.base
;***********************************************************************
; Thats it for now
;***********************************************************************
return
end
