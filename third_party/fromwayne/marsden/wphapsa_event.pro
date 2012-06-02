pro wphapsa_event,ev
;************************************************************************
; Program handles the events in the pha/psa widget
; wpsapha.pro, and communicates to the manager program
; phapsa.pro via common block variables
;         dc.................detector code
;         cp.................cluster position
;        opt.................data display option
;      accum.................accumulation option
;    idf_hdr.................science header data
;     rates0.................counts/sec for single idf
;     rates1.................counts/sec for accum
;     counts.................1 idf counts(position,det,psachns,chn)
;      lvtme.................1 idf livetime(position,det,psachns)
;   a_counts.................accumulated counts(position,det,chn)
; a_livetime.................accumulated livetime(position,det)
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
;       colr.................color table value
;       fnme.................file name for data storage
;        typ.................data type
;  idf_lvtme.................array of livetimes
;  clstr_pos.................cluster postion vs idf array
; Common blocks:
;  pev_block.................between phapsa and wphapsa event manager
; 6/10/94 Current version
; 8/26/94 Annoying print statements eliminated
; 2/5/95  Only writes displayed rates to file
; First do common blocks
;************************************************************************
common pev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,chn_slice,det,rt,cp,dt,ltime,$
                 rates0,rates1,det_str,psachns,phachns,plt,num_dets,$
                 colr,fnme,idf_lvtme,clstr_pos
common phapsa_block,idf_hdr,idf,date,spectra,livetime,typ
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common save_block,spec_save,idf_save,wait
common parms,start,new,clear
common nai,arr,nai_only
;**********************************************************************
; Do some routine stuff
;**********************************************************************
on_ioerror, bad
wold = wphapsa.base
if (n_elements(nai_only) eq 0)then nai_only = 0
type = tag_names(ev,/structure)
widget_control,ev.id,get_value=value
models = ["N GAUSSIAN LINES","N LINES + CONST.","N LINES + LINEAR",$
         "N LINES + PWRLAW","N LINES + PWRLAW + CONST."]
clr_tble_names = ['BLACK/WHITE','BLUE/WHITE','G/R/B & W','RED TEMP.',$
                  'B/G/R & Y','STD GAMMA','PRISM','RED/PURP',$
                  'GREEN/WHITE L','GREEN/WHITE E','GREEN/PINK',$
                  'BLUE/RED','16 LEVEL','RAINBOW1','STEPS',$
                  'PY DREAM','HAZE','PLUE/PAS./RED','PASTELS',$
                  'HUE SAT 1','HUE SAT 2','HUE SAT 3','CTHULHU',$
                  'PURP/RED/STR','BEACH','MAC STY','EOS A','EOS B',$
                  'CANDY','NATURE','SURFING','PPRMINT','PLASMA',$
                  'BLUE/RED2','RAINBOW2','WAVES1','VOLCANO','WAVES2']
;***********************************************************************
; Session buttons
;***********************************************************************
if (type eq 'WIDGET_BUTTON') then begin
   if(value eq 'DONE') then widget_control,/destroy,ev.top
;**************************************************************************
; Change the parameters in fitbox and do fitting . Only works if plt > 1
;**************************************************************************
   if (plt gt 1)then begin
      get_mdl,value,mdl
      if (mdl ne '-1')then begin
         fit_stor,num_lines,mdl,mdln,a,sigmaa,chisqr,iter,astring,$
                  nfree,rt,idfs,idfe,dt,cp,ltime,opt,det,'PHAPSA',$
                  strtbin,stpbin,0,det_str
         fitit
      endif
   endif
;*********************************************************************
; Plot options
;*********************************************************************
   if(value eq 'CONTOUR')then begin
      plt = 1
      value = 'UPDATE'
   endif
   if(value eq 'PHA SLICE')then begin
      plt = 3
      value = 'UPDATE'
   endif
   if(value eq 'PSA SLICE')then begin
      plt = 2
      value = 'UPDATE'
   endif
   if(value eq 'DO SLICE')then value = 'UPDATE'
   clr_choice = where(value eq clr_tble_names)
   if (clr_choice(0) ne -1) then begin
      colr = clr_choice(0)
      plt = 0
      value = 'UPDATE'
   endif
   if(value eq 'SAVE')then begin
      str = 'PHAPSA'
;      make_file,str,idfs,idfe,dt,a_counts,a_lvtme
      make_phfile,idfs,idfe,dt,det,det_str,opt,rt,ltime
   endif
;***********************************************************************
; Option buttons
;***********************************************************************
   options,value,opt,disp,det_str,dc,fnme
;***********************************************************************
; Clear button to clear arrays
;***********************************************************************
   if(value eq 'CLEAR')then begin
      clear = 1
      phapsa
   endif
;**********************************************************************
; NaI only buttons for accepting only Sodium Iodide events or 
; accepting all events.
;**********************************************************************
   if(value eq 'NAI ONLY')then begin
      if (ks(arr) eq 0)then get_nai
      nai_only = 1
      value = 'UPDATE'
   endif
   if(value eq 'ALL EVTS.')then begin
      if (ks(arr) eq 0)then get_nai
      nai_only = 0
      value = 'UPDATE'
   endif   
;**********************************************************************
; Update button doing changes
;**********************************************************************
   if(value eq 'UPDATE')then begin
      new = 0
      start = 0
      phapsa
   endif
endif
;**************************************************************************
; Adjust channel slice value
;**************************************************************************
if (type eq 'WIDGET_TEXT' or type eq 'WIDGET_TEXT_CH')then begin
   widget_control,ev.id,get_value=entry
   widget_control,ev.id,get_uvalue=ndx
   fitbox_parms,ev,num_lines,strtbin,stpbin
   if (ndx eq 10 or ndx eq 11 or ndx eq 12 or ndx eq 13)then begin
      if (ndx eq 10 or ndx eq 12)then chn_slice(0) = fix(entry) else $
      chn_slice(1) = fix(entry)
   endif
   if (fix(ndx) eq 33)then begin
      widget_control,ev.id,get_value = entry
      entr = entry(0)
      if (fnme eq 'get ascii file')then begin
;         make_file,idfs,idfe,dt,a_counts,a_lvtme,entr,'PHSs'
         make_phfile,idfs,idfe,dt,det,det_str,opt,rt,ltime,entr
         if (entr eq 'error')then fnme = 'get ascii file' else $
                                  fnme = '' 
         new = 0 & start = 0
         phapsa
      endif else begin
         fnme = ''
         save,file=entr,idf_hdr,idf,date,spectra,livetime,typ,dc,opt,$
                        counts,lvtme,idfs,idfe,disp,a_counts,$
                        a_lvtme,det,rt,ltime,cp,dt,num_dets,rates0,$
                        rates1,det_str,psachns,phachns,plt,$
                        num_dets,colr,fnme,idf_lvtme
         new = 0 & start = 0
         phapsa
      endelse
   endif         
endif
;**************************************************************************
; Thats all ffolks I
;**************************************************************************
return
;***********************************************************************
; Error handling routine
;***********************************************************************
bad : print,'BAD FILENAME ENTERED!'
fnme = 'get idl file'
new = 0 & start = 0
phapsa
;***********************************************************************
; Thats all ffolks II
;***********************************************************************
return
end
