pro whist_event,ev
;************************************************************************
; Program handles the events in the histogram widget
; whist.pro, and communicates to the manager program
; hist.pro via common block variables
; Common blocks are:
;          hev_block..........histogram event block
;         hist_block..........latest data
; 6/10/94 Version update
; 8/26/94 Annoying print statements eliminated.
; 11/10/95 Livetime vs idf# array added
; 12/7/95 Area and cluster position accumulated
;************************************************************************
common hev_block,dc,opt,int,counts,lvtme,idfs,idfe,disp,$
       a_counts,a_lvtme,det,rt,cp,dt,num_dets,rates0,rates1,$
       num_chns,num_spec,det_str,fnme,idf_lvtme,clstr_pos,$
       ltime,prs
common hist_block,idf_hdr,idf,date,spectra,livetime,typ
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common save_block,spec_save,idf_save,wait
common parms,start,new,clear
on_ioerror, bad
type = tag_names(ev,/structure)
widget_control,ev.id,get_value=value
wold = whist.base
clstr = idf_hdr.clstr_id
if (clstr eq 'CEU II')then cluster = 2 else cluster = 1
;***********************************************************************
; Change the parameters in fitbox or save file
;***********************************************************************
if (type eq 'WIDGET_TEXT' or type eq 'WIDGET_TEXT_CH') then begin
   fitbox_parms,ev,num_lines,strtbin,stpbin
   widget_control,ev.id,get_uvalue=ndx
   if (fix(ndx) eq 33)then begin
      widget_control,ev.id,get_value = entry
      entr = entry(0)
      if (fnme eq 'get ascii file')then begin
         make_file,idfs,idfe,dt,a_counts,a_lvtme,entr
         if (entr eq 'error')then fnme = 'get ascii file' else $
                                  fnme = '' 
         new = 0 & start = 0         
         type = 'WIDGET_BUTTON' & value = 'UPDATE'
      endif
      if (fnme eq 'get idl file' and fnme ne 'get fits file')then begin
         fnme = ''
         save,file=entr,idf_hdr,idf,date,spectra,livetime,typ,dc,opt,$
                        int,counts,lvtme,idfs,idfe,disp,a_counts,$
                        a_lvtme,det,rt,cp,dt,num_dets,rates0,$
                        rates1,num_chns,num_spec,det_str,fnme,$
                        idf_lvtme,clstr_pos
         new = 0 & start = 0 
         type = 'WIDGET_BUTTON' & value = 'UPDATE'
      endif
      if (fnme eq 'get fits file')then begin
         fnme = ''
         entr = strcompress(entr,/remove_all)
         len = strlen(entr)
         bkg = fix(strmid(entr,strpos(entr,',')+1,2))
         fil = strmid(entr,0,strpos(entr,','))
         make_hexte_pha,a_counts,a_lvtme,fn=fil,bk=bkg,$
                        cl=cluster,pr=prs
         new = 0 & start = 0
         type = 'WIDGET_BUTTON' & value = 'UPDATE'
      endif
   endif         
endif
if (type eq 'WIDGET_BUTTON') then begin
;***********************************************************************
; Fitting model selected - do fitting widget
;***********************************************************************
   get_mdl,value,mdl
   if (mdl ne '-1')then begin
      fit_stor,num_lines,mdl,mdln,a,sigmaa,chisqr,iter,astring,nfree,rt,$
      idfs,idfe,dt,cp,ltime,opt,det,'HIST',strtbin,stpbin,0
      fitit
   endif
;***********************************************************************
; Session buttons
;**********************************************************************
   if(value eq 'DONE') then widget_control,/destroy,ev.top
;***********************************************************************
; Standard buttons
;***********************************************************************
   options,value,opt,disp,det_str,dc,fnme
;***********************************************************************
; Integration options
;***********************************************************************
   if (ks(prs) eq 0)then begin
      int,value,int
   endif else begin
      phzbin = strcompress((indgen(num_spec)+1),/remove_all)
      in = where(value eq phzbin)
      if (in(0) ne -1)then begin
         int = in(0) + 1
         value = 'UPDATE'
      endif
   endelse
;***********************************************************************
; Clear button to clear arrays
;***********************************************************************
   if(value eq 'CLEAR')then begin
      clear = 1
      value = 'UPDATE'
   endif
;***********************************************************************
; Update button doing changes
;***********************************************************************
   if(value eq 'UPDATE')then begin
      new = 0
      start = 0
      hist,pr=prs
   endif
endif
;***********************************************************************
; Thats all ffolks I
;***********************************************************************
return
;***********************************************************************
; Error handling routine
;***********************************************************************
bad : print,'BAD FILENAME ENTERED! IS IT ALREADY USED?'
fnme = 'get idl file'
new = 0 & start = 0
hist,pr=prs
;***********************************************************************
; Thats all ffolks II
;***********************************************************************
return
end
