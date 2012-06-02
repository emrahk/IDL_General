pro x_event, event
;*********************************************************************
; Program handles the events coming through the socket
; 6/10/94 Current version
; 10/12/94 Removed some print statements
;*********************************************************************

; Modification history:
; 1994 June 22 P. R. Blanco, CASS/UCSD. 
; Replaced the CALL_EXTERNAL to linkread.so (read a "socket" linking
; the GSE software with IDL). Now X_EVENT reads a text file (the "socket file" 
; containing name of the next GSE file to process). If this socket
; file's contents begin with a "reset-string" (currently '-----------') 
; it means that there is no new data file from the GSE to process, and X_EVENT
; returns to the caller (in this case X_MANAGER.PRO). If a valid file name
; is found, however, X_EVENT processes the data in this file, displays it etc.
; 
; Constants:
commfile = '$GSEIDLDIR/idlcomm.dat' ; file used for communications with the
;                                     GSE software.

reset_string = '-----------'    ; string written to idlcomm.dat to signal the
;                                 GSE C code that this routine has finished 
;                                 processing the last file and is ready for 
;                                 another.

; Common blocks:
common basecom,base,idfold,beep,chc
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common parms,start,new,clear

if (not(ks(start)))then begin
   start = 1 & new = 1 & clear = 0
endif
if (ks(chc) eq 0)then chc = ''
if (ks(idfold) eq 0)then idfold = 0 
widget_control,base,time = .5
if (event.id eq base) then begin
;*********************************************************************
; Filename needs to be read from socket file
;
;*********************************************************************
; Initialize filename to the "reset-string", and try to read a new filename
; from idlcomm.dat in the GSEIDLDIR directory.
   reset_string = '-----------'
   commfile = '$GSEIDLDIR/idlcomm.dat'

   fnme = reset_string  ; initialize to the reset string
   socketlu = 66L       ; any arbitrary integer value for initializing

;  Set a label to jump to for I/O errors (usually due to an open file conflict
;  with the GSE C code), and reset error flag.
!ERR = 0
ON_IOERROR, RESETFILE 

   GET_LUN, socketlu 
   OPENR, socketlu, commfile
   READU, socketlu, fnme
RESETFILE:
   CLOSE, socketlu 
   FREE_LUN, socketlu
   IF !ERR NE 0 THEN BEGIN 
      MESSAGE, /INFO, !ERR_STRING+' Trying again...'
      !ERR = 0
      RETURN
   ENDIF

   IF fnme EQ reset_string THEN BEGIN
      PRINT, FORMAT='($, "No IDF to process...")'
      RETURN
   ENDIF

;  If we get here, we have a filename to process
   fnme = strcompress(fnme,/remove_all)
;   print,'FNME=',fnme
;   print,'length(fnme)=',strlen(fnme)
   fnme = strmid(fnme,0,11)

; (1994 June 22: "if keyword_set(s)" block removed here - always TRUE)

      if (xregistered('wfit')ne 0)then widget_control,wfit.base,/destroy
      get_data,fnme,typ,idf,date,spectra,livetime,lost_events,idf_hdr
;      print,'NEW IDF =',idf
      if (typ eq 'HSTs' and idf ne idfold) then begin
;**********************************************************************
; Histogram Idf
;**********************************************************************
         new = 1 & clear = 0
         if (xregistered('whist')ne 0)then begin
            start = 0
         endif else begin
            start = 1
         endelse
         if (ks(beep))then print,string(7b)
         hist_stor,idf_hdr,idf,date,spectra,livetime,typ
         hist
         idfold = idf
      endif
      if (typ eq 'CALh' and idf ne idfold) then begin
;**********************************************************************
; Callibration histogram Idf
;**********************************************************************
         new = 1 & clear = 0
         if (xregistered('wcalhist')ne 0)then begin
            start = 0
         endif else begin
            start = 1
         endelse
         if (ks(beep))then print,string(7b)
         calhist_stor,idf_hdr,idf,date,spectra,livetime,typ
         calhist
         idfold = idf
      endif
      if (typ eq 'ARCh' and idf ne idfold) then begin
;*********************************************************************
; Archive histogram Idf
;*********************************************************************
         new = 1 & clear = 0
         if (xregistered('warchist')ne 0)then begin
            start = 0
         endif else begin
            start = 1
         endelse
         if (ks(beep))then print,string(7b)
         archist_stor,idf_hdr,idf,date,spectra,livetime,typ
         archist
         idfold = idf
      endif
      if (typ eq 'PHSs' and idf ne idfold) then begin
;**********************************************************************
; Pha Psa Idf
;**********************************************************************
         new = 1 & clear = 0
         if (xregistered('wphapsa')ne 0)then begin
            start = 0
         endif else begin
            start = 1
         endelse
         if (ks(beep))then print,string(7b)
         phapsa_stor,idf_hdr,idf,date,spectra,livetime,typ
         phapsa     
         idfold = idf
      endif
      if (typ eq 'MSCs' and idf ne idfold)  then begin
;**********************************************************************
; Multiscalar Idf
;**********************************************************************
         new = 1 & clear = 0
         if (xregistered('wmsclr')ne 0)then begin
            start = 0
         endif else begin
            start = 1
         endelse
         if (ks(beep))then print,string(7b)
         msclr_stor,idf_hdr,idf,date,spectra,livetime,typ
         msclr
         idfold = idf
      endif     
      if (typ eq 'ARCm' and idf ne idfold)  then begin
;**********************************************************************
; Archive multiscalar Idf
;**********************************************************************
         new = 1 & clear = 0
         if (xregistered('wam')ne 0)then begin
            start = 0
         endif else begin
            start = 1
         endelse
         if (ks(beep))then print,string(7b)
         am_stor,idf_hdr,idf,date,spectra,livetime,typ
         am
         idfold = idf
      endif     
;      if (typ eq 'EVTs' and idf ne idfold and chc ne 'hold') then begin
;**********************************************************************
; Event List Idf
;**********************************************************************
;         evt_stor,idf_hdr,idf,date,spectra,livetime,typ
;         evt
;         idfold = idf
;     endif     

endif
;**********************************************************************
; Thats all ffolks
;**********************************************************************
; All done with that file, so create a new idlcomm.dat with the reset string
; at the beginning (plus the name of the file just processed, for debugging).

MESSAGE, /INFO, ' Finished processing ' + fnme + '.'

ON_IOERROR, NULL
GET_LUN, socketlu  
OPENW,  socketlu, commfile
PRINTF, socketlu, reset_string + $
       ' X_EVENT.PRO is ready (just finished processing ' + fnme +').'
CLOSE,  socketlu 
FREE_LUN, socketlu
END
