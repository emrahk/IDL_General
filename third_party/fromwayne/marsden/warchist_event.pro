pro warchist_event,ev
;************************************************************************
; Program handles the events in the archive histogram widget
; warchist.pro, and communicates to the manager program
; archist.pro via common block variables
; 6/10/94 Current version
; 8/26/94 Annoying print statements eliminated.
; 11/10/95 Accumulates array of livetimes vs idf
;************************************************************************
common archev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
 a_counts,a_lvtme,det,rt,ltime,cp,dt,num_dets,rates0,rates1,num_chns,$
 num_spec,det_str,fnme,idf_lvtme,clstr_pos
common archist_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common parms,start,new,clear
on_ioerror, bad
type = tag_names(ev,/structure)
wold = warchist.base
widget_control,ev.id,get_value=value
clstr = idf_hdr.clstr_id
if (clstr eq 'CEU II')then cluster = 2 else cluster = 1
;***********************************************************************
; Change the parameters in fitbox
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
         make_hexte_pha,a_counts,a_lvtme,fn=fil,bk=bkg,cl=cluster
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
      idfs,idfe,dt,cp,ltime,opt,det,'ARCHIST',strtbin,stpbin,0
      fitit
   endif
;***********************************************************************
; Session buttons
;***********************************************************************
   if(value eq 'DONE') then widget_control,/destroy,ev.top
;***********************************************************************
; Standard buttons
;***********************************************************************
   options,value,opt,disp,det_str,dc,fnme
;***********************************************************************
; Clear button to clear arrays
;***********************************************************************
   if(value eq 'CLEAR')then begin
      clear = 1
      value = 'UPDATE'
   endif
;**********************************************************************
; Update button doing changes
;**********************************************************************
   if(value eq 'UPDATE')then begin
      new = 0
      start = 0
      archist
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
archist
;***********************************************************************
; Thats all ffolks II
;***********************************************************************
return
end
