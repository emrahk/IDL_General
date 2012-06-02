PRO RMC_PRINT,event,curve=curve,correlation=correlation
;+
; NAME: rmc_print
;
;
;
; PURPOSE: Printing the lightcurve or the correlation table on printer. 
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_PRINT,event,curve=curve,correlation=correlation
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS: curve: for ploting the lightcurve
;                     correlation: for ploting the correlation
;
;
; OUTPUTS:   A wonderful plot on the chosen printer
;
;
;
; OPTIONAL OUTPUTS: No Plot
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;  $Log: rmc_print.pro,v $
;  Revision 1.2  2002/05/21 13:06:50  slawo
;  Add comments
;
;-
   

   
   ;; Layout of the input widget 
   gui_sheet = ['1,BASE,,COLUMN', $
                   '0,DROPLIST,dcps|hp5,LABEL_LEFT=Printername: ,TAG=name,set_value=0', $
                   '1,BASE,,ROW', $
                      '0,BUTTON,  OK  ,QUIT,Tag=OK,',$
                      '2,BUTTON,CANCEL,QUIT,Tag=cancel,',$
                   '2,BASE,,ROW']
   
   ;; calling the CW_FORM Function to include the printer name             

   title='Print Lightcurve'
   IF (keyword_set(correlation)) THEN title='Print Correlation'

   printer = CW_FORM(gui_sheet, /Column,title=title)

   IF (printer.cancel EQ 1) THEN return 

   
   Widget_Control, event.top, Get_UValue=info, /No_Copy
   
   ;; creating a temporary file to print out the lightcurve
   tmpnam='tmpname.ps'
   open_print,tmpnam,/postscript

   IF (keyword_set(curve)) THEN BEGIN 
       rmc_omplot,*info.omegat,*info.messung
   ENDIF 
   IF (keyword_set(correlation)) THEN BEGIN 
       tvscl,(*info.image),xsize=15,ysize=15,/centimeters
   ENDIF

   close_print

   ;; printing and removing the temporary postscript file
   pname=['dcps','hp5']
   printer='-P'+pname[printer.name]
   spawn,['/usr/bin/lpr',printer,tmpnam],/noshell 
   spawn,['/bin/rm',tmpnam],/noshell

   Widget_Control, event.top, Set_UValue=info, /No_Copy
END





