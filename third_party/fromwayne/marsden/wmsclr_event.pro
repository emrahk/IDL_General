pro wmsclr_event,ev
;************************************************************************
; Program handles the events in the multiscalar histogram widget
; wmsclr.pro, and communicates to the manager program
; msclr.pro via common block variables
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
;           ft.................plot fft of data if = 1
;      periods.................periods for data folding
;         fold.................fold which period 
;         fnme.................filename for storage
;          typ.................type of data set
;      phz_bns.................number of phase bins 
; Common blocks:
;  msclr_block.................stores accumulation variables
;    mev_block.................stores event variables for widgets
; 6/10/94 Current version
; 8/26/94 Annoying print statements eliminated
;************************************************************************
common msclr_block,idf_hdr,idf,date,spectra,livetime,typ
common mev_block,dc,opt,accum,counts,lvtme,idfs,idfe,$
                disp,a_counts,a_lvtme,det,cp,dt,num_dets,$
                pha_edgs,num_tm_bins,pha_choice,ltime,ft,periods,$
                fold,fnme,phz_bns,idf_lvtme,cluster_pos,phz_arr
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common save_block,spec_save,idf_save,wait
common parms,start,new,clear
on_ioerror, bad
wold = wmsclr.base
type = tag_names(ev,/structure)
widget_control,ev.id,get_value=value
;************************************************************************
; Get the value for the pha edges
;************************************************************************
num_pha = n_elements(pha_edgs) - 1
ledg_str = strarr(num_pha) & uedg_str = ledg_str
ledg_str = string(pha_edgs(0:num_pha - 1))
uedg_str = string(pha_edgs(1:num_pha))
pha_str = strcompress(ledg_str + ' TO ' + uedg_str)
str = strarr(num_pha + 1)
str(0:num_pha - 1) = pha_str & str(num_pha) = 'PHA SUM'
pha_str = str
;************************************************************************
; Save the file if desired
;************************************************************************
if (type eq 'WIDGET_TEXT' or type eq 'WIDGET_TEXT_CH') then begin
   widget_control,ev.id,get_uvalue=ndx
   widget_control,ev.id,get_value = entry
   if (fix(ndx) eq 33)then begin
      entr = entry(0)
      if (fnme eq 'get ascii file')then begin
         make_file,idfs,idfe,dt,a_counts,a_lvtme,entr,string(pha_edgs)
         if (entr eq 'error')then fnme = 'get ascii file' else $
                                  fnme = '' 
         new = 0 & start = 0         
         type = 'WIDGET_BUTTON' & value = 'UPDATE'
      endif else begin
         fnme = ''
         save,file=entr,idf_hdr,idf,date,spectra,livetime,typ,dc,opt,$
                        accum,counts,lvtme,idfs,idfe,$
                        disp,a_counts,a_lvtme,det,cp,dt,num_dets,$
                        pha_edgs,num_tm_bins,pha_choice,ltime,ft,$
                        periods,fold,fnme,phz_bns,idf_lvtme
         new = 0 & start = 0         
         type = 'WIDGET_BUTTON' & value = 'UPDATE'
      endelse
   endif
   if (fix(ndx) eq 21)then begin 
      phz_bns = fix(entry(0))
      fold = 1
   endif
   if (fix(ndx) eq 22)then begin
      periods(0) = double(entry(0))
      fold = 1
   endif        
endif
;*************************************************************************
; Session buttons
;*************************************************************************
if (type eq 'WIDGET_BUTTON') then begin
   if(value eq 'DONE') then widget_control,/destroy,ev.top
;*************************************************************************
; Clear button to clear arrays
;*************************************************************************
   if(value eq 'CLEAR')then begin
      clear = 1
      value = 'UPDATE'
   endif
;************************************************************************
; FFT option - do fft on selected data set and display
;************************************************************************
   if(value eq 'FFT' or value eq 'TO FFT')then begin
      ft = 1
      fold = 0 
      value = 'UPDATE'
   endif
;************************************************************************
; Return option
;************************************************************************
   if(value eq 'TO MSCLR')then begin
      ft = 0 
      fold = 0
      value = 'UPDATE'
   endif
   if (value eq 'TO FOLD')then begin
      ft = 0
      fold = -1
      value = 'UPDATE'
   endif    
;************************************************************************
; Get pha choice
;************************************************************************
   d = where(value eq pha_str)
   if (d(0) ne -1) then begin
      pha_choice = d(0) 
      value = 'UPDATE'
   endif else begin
      pha_choice = num_pha
   endelse
;************************************************************************
; Folding data option
;************************************************************************
   if(value eq 'FREQ 1' or value eq 'FREQ 2' or value eq 'FREQ 3')$
   then begin
      case value of
      'FREQ 1' : fold = 1
      'FREQ 2' : fold = 2
      'FREQ 3' : fold = 3
      endcase
      value = 'UPDATE'
   endif
   if(value eq 'FOLD')then begin
      fold = -1
      value = 'UPDATE'
   endif
;************************************************************************
; Option buttons
;************************************************************************
   options,value,opt,disp,det_str,dc,fnme
;************************************************************************
; Update button doing changes
;************************************************************************
   if(value eq 'UPDATE')then begin
      new = 0
      start = 0
      msclr
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
msclr
;***********************************************************************
; Thats all ffolks II
;***********************************************************************
return
end
