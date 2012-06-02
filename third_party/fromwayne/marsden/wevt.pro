pro wevt
;**********************************************************************
; Widget gets the choice for event list accumulation.
; Also gets the necessary parameters for accumulation
; once the data type is set. Event list widget variables are:
;          prms...........array of three parameters
;            go...........execute parameters
;         burst...........burst list idf
; For explanation of other variable see evt.pro
; First the common blocks
;********************************************************************** 
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common basecom,base,idfold,beep,chc
common evt_parms,prms,prms_save,burst
;**********************************************************************
; Do preliminary set up stuff for widgets.
;**********************************************************************
if (ks(prms) eq 0 and chc eq 'h')then begin
   prms = [1.,0.,63.,2] & prms_save = prms
endif
if (ks(prms) eq 0 and chc eq 'm')then begin
   prms = [1.,2,0,1,10,20,40,70,100,150,200,256] & prms_save = prms
endif
if (ks(prms) eq 0 and chc eq 'p')then begin
   prms = [1.,1.,1.,1.] & prms_save = prms
endif
if (ks(prms) eq 0 and chc eq 'prs')then begin
   prms = [1d,0d,0d,10d,0d]
   prms_save = prms
endif
if (ks(prms_save) eq 0)then prms_save = [1.,1.,1.,1.]
if (ks(chc) eq 0)then chc = ''
device,get_screen_size = scrsiz
if (xregistered('wevt')ne 0)then wold = wevt.base
wevt = {	base:0L}
if (ks(burst) ne 0)then begin
   tl = 'BURST LIST'
   oplist = ['HISTOGRAM','MULTISCALAR','PHA TIME','DONE']
endif else begin
   tl = 'EVENT LIST'
   oplist = ['HISTOGRAM','MULTISCALAR','PHA PSA','P.R.S.','DONE']
endelse
wevt.base = widget_base(title=tl,/frame,/column)
base1 = widget_base(wevt.base,/frame,/column)
if (chc eq '')then begin
;**********************************************************************
; Display the menu for the data choices
;**********************************************************************   
   w1 = widget_label(base1,value='DATA TYPE (CHOOSE ONE)',/frame)
   xmenu,oplist,base1,/column,/exclusive,/frame
endif else begin
;**********************************************************************
; Display possible parameter choices for each data type
;          h............histogram bin
;          m............multiscalar bin
;          p............phapsa
;         pp............pha vs time (burst list)
; First do histogram bin:
;**********************************************************************
   if (chc eq 'h')then begin      
      w1 = widget_label(base1,va='ENTER HISTOGRAM PARAMETERS:',/frame)
      w1 = widget_slider(base1,title='PHA/BIN',uv=1,va=prms(0),$
           minimum=1,maximum=256,/frame)
      if (ks(burst) eq 0)then begin
         w1 = widget_slider(base1,title='MINIMUM PSA',uv=2,va=prms(1)$
           ,/frame,minimum=0,maximum=62)
         w1 = widget_slider(base1,title='MAXIMUM PSA',uv=3,va=prms(2)$
           ,/frame,minimum=1,maximum=63)
         w1 = widget_button(base1,va='PSULD OFF ONLY')
         w1 = widget_button(base1,va='PSULD ON ONLY') 
      endif
      w1 = widget_button(base1,va='NAI EVENTS ONLY')   
   endif
;**********************************************************************
; Now do multiscalar
;**********************************************************************
   if (chc eq 'm')then begin
      w1 = widget_label(base1,va='ENTER MULTISCALAR PARAMETERS:',/frame)
      base15 = widget_base(base1,/frame,/row)
      w1 = widget_label(base15,va='TIME BINSIZE (S)')
      w1 = widget_text(base15,uv=1,va=string(prms(0)),xsize=10,$
           /editable,ysize=1)
      base15 = widget_base(base1,title='DETECTORS',/frame,/row)
      w1 = widget_button(base15,va='4 DETECTORS')
      w1 = widget_button(base15,va='SUMMED DETECTORS')
      base15 = widget_base(base1,/frame,/row)
      w1 = widget_button(base15,va='64 PHA BINS')
      w1 = widget_button(base15,va='8 PHA BINS')
      w1 = widget_button(base15,va='1 PHA BIN')
      base15 = widget_base(base1,/frame,/row)
      w1 = widget_button(base15,va='NAI EVENTS ONLY')
   endif
   if (chc eq 'mm')then begin
      w1 = widget_label(base1,va='ENTER PHA BINS:',/frame)
      base15 = widget_base(base1,/frame,/row)
      base2 = widget_base(base15,/column)
      for i = 1,4 do begin
       s1 = strcompress('PHA CHANNEL ' + string(i) + ':')
       w1 = widget_label(base2,va=s1,/frame)
       base4 = widget_base(base2,/row)
       w1 = widget_label(base4,va='LOWER EDGE (keV)')
       w1 = widget_text(base4,uv=i+2,va=string(prms(i+2)),xsize=10,$
            ysize=1,/editable)
       base5 = widget_base(base2,/row)
       w1 = widget_label(base5,va='UPPER EDGE (keV)')
       w1 = widget_text(base5,uv=i+3,va=string(prms(i+3)),xsize=10,$
            ysize=1,/editable)
      endfor
      base2 = widget_base(base15,/column) 
      for i = 5,8 do begin
       s1 = strcompress('PHA CHANNEL ' + string(i) + ':')
       w1 = widget_label(base2,va=s1,/frame)
       base4 = widget_base(base2,/row)
       w1 = widget_label(base4,va='LOWER EDGE (keV)')
       w1 = widget_text(base4,uv=i+2,va=string(prms(i+2)),xsize=10,$
            ysize=1,/editable)
       base5 = widget_base(base2,/row)
       w1 = widget_label(base5,va='UPPER EDGE (keV)')
       w1 = widget_text(base5,uv=i+3,va=string(prms(i+3)),xsize=10,$
            ysize=1,/editable)
      endfor
      w1 = widget_button(base1,va='BARYCENTER CORRECT?',/frame)
   endif
   if (chc eq 'mmm')then begin 
      prms(4) = 256.     
      w1 = widget_label(base1,va='ENTER PHA BIN:',/frame)
      base15 = widget_base(base1,/frame,/row)
      base2 = widget_base(base15,/column)
      s1 = strcompress('PHA CHANNEL ' + string(1) + ':')
      w1 = widget_label(base2,va=s1,/frame)
      base4 = widget_base(base2,/row)
      w1 = widget_label(base4,va='LOWER EDGE (keV)')
      w1 = widget_text(base4,uv=4,va=string(1),xsize=10,$
            ysize=1,/editable)
      base5 = widget_base(base2,/row)
      w1 = widget_label(base5,va='UPPER EDGE (keV)')
      w1 = widget_text(base5,uv=5,va=string(256),xsize=10,$
           ysize=1,/editable)
      w1 = widget_button(base1,va='BARYCENTER CORRECT?',/frame)
   endif
;**********************************************************************
; Do phapsa
;**********************************************************************
   if (chc eq 'p')then begin
      w1 = widget_label(base1,value='ENTER PHAPSA PARAMETERS:',/frame)
      w1 = widget_slider(base1,title='PHA/BIN',uv=1,va=prms(0),$
           minimum=1,maximum=256,/frame)
      w1 = widget_slider(base1,title='PSA/BIN',uv=2,va=prms(1),$
           minimum=1,maximum=64,/frame)
      w1 = widget_button(base1,va='NAI EVENTS ONLY')
   endif
;**********************************************************************
; Do phase-resolved spectroscopy
;**********************************************************************
   if (chc eq 'prs')then begin
      w1 = widget_label(base1,value='ENTER P.R.S. PARAMETERS:',/frame)
      w1 = widget_label(base1,va='FREQUENCY (HZ):')
      w1 = widget_text(base1,uv=1,va=string(prms(0)),xsize=10,$
           ysize=1,/editable)
      w1 = widget_label(base1,va='FDOT:')
      w1 = widget_text(base1,uv=2,va=string(prms(1)),/editable,$
           xsize=10,ysize=1)
      w1 = widget_label(base1,va='F2DOT:')
      w1 = widget_text(base1,uv=3,va=string(prms(2)),/editable,$
           xsize=10,ysize=1)
      w1 = widget_label(base1,va='T0_GEO (MJD):')
      w1 = widget_text(base1,uv=5,va=string(prms(4)),/editable,$
           xsize=10,ysize=1)
      w1 = widget_slider(base1,title='# PHASE BINS',uv=4,va=prms(3),$
           minimum=1,maximum=256,/frame)
      w1 = widget_button(base1,va='CRAB IOC')
      w1 = widget_button(base1,va='NAI EVENTS ONLY')
      w1 = widget_button(base1,va='BARYCENTER CORRECT?',/frame)
   endif
;**********************************************************************
; Get ra & dec for barycenter correcting
;**********************************************************************
   if (chc eq 'bary')then begin
      w1 = widget_label(base1,value='ENTER RA & DEC:',/frame)
      w1 = widget_label(base1,va='RA DEGREES (J2000):')
      w1 = widget_text(base1,uv=1,va='0.0',xsize=10,ysize=1,/editable)
      w1 = widget_label(base1,va='DEC DEGREES (J2000):')
      w1 = widget_text(base1,uv=2,va='0.0',xsize=10,ysize=1,/editable)
   endif 
;**********************************************************************
; Do control buttons
;**********************************************************************
   r1 = widget_base(base1,/row,/frame)
   w1 = widget_button(r1,value='GO')
   w1 = widget_button(r1,value='RESET')
endelse      
;**********************************************************************
; Realize the widgets
;**********************************************************************
widget_control,wevt.base,/realize
xmanager,'wevt',wevt.base
wold = wevt.base
;**********************************************************************
; Thats all, ffolks
;**********************************************************************
return
end
