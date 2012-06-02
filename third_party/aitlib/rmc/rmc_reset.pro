PRO RMC_RESET,event
;+
; NAME: rmc_reset
;
;
;
; PURPOSE: recondition the first picture, before the substraction
; choosen sources. Just loading the Backup.   
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_RESET,event (from menu in main program)
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
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
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
; $Log: rmc_reset.pro,v $
; Revision 1.2  2002/05/21 13:15:14  slawo
; Add comments
;
;-
   
   

   
   Widget_Control, event.top, Get_UValue=info,/No_Copy
   
   ;; loading backup of lightcurve
   ptr_free,info.messung
   info.messung=ptr_new(*info.messung0)
 
   ;; Set the pointer from "old" image to "new" image. 
   ptr_free,info.image
   info.image=ptr_new(*info.image0)

   ;; plot the original Datas (Lightcurve and Correlation Table)
   Widget_Control, info.drawID, Get_Value=wid
   WSet, wid
   TV, BytScl(*(info.image), Top=!D.Table_Size-1)
  
   Widget_control,info.drawid2,get_value=wid2
   wset,wid2
   rmc_omplot,*info.omegat,*info.messung
   
   Widget_Control, event.top, Set_UValue=info, /No_Copy    
END
