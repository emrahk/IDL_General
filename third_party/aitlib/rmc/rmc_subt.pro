PRO RMC_SUBT,event
;+
; NAME: rmc_subt
;
;
;
; PURPOSE:    Subtracting the computed lightcurve from the original
; lightcurve and computing a new lightcurve and a new correlation
; table  
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_SUBT,event (from menu in main program)
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
; $Log: rmc_subt.pro,v $
; Revision 1.2  2002/05/21 13:47:08  slawo
; Add comments
;
;-

   
   Widget_Control,event.top, Get_UValue=info, /No_Copy
   
   IF info.xmax EQ -1 THEN BEGIN 
       Widget_Control,event.top, Set_UValue=info, /No_Copy
       return
   ENDIF 
   ;; Procedure to subtract single lightcurve from messurement
   widget_control,/hourglass

   rmc_subtract,messung=info.messung,xmax=info.xmax,ymax=info.ymax,$
               resolution=info.w,fov=info.fov,shift=info.v,$
               dim=info.dim,cortab=cortab,neumessung=neumessung, $
               omegat=info.omegat,numpt=info.messpkte,estpow=info.estpow, $
               alpha=info.alpha,radius=info.radius
   
   
   ;; backup of new meassurement
   
   ptr_free,info.messung
   info.messung= ptr_new(neumessung)
   
   ptr_free,info.cortab
   info.cortab=ptr_new(cortab)
   
   ;; Resize the new correlation table
   s = size(cortab, /DIMENSIONS)
   xsize = s[0]
   ysize = s[1]
   cortab  = congrid(cortab, xsize * info.scale, $
                    ysize * info.scale)
   
   ;; Set the pointer from old image to new image. 
   ptr_free,info.image
   info.image=ptr_new(cortab)
      
   ;; Update the displayed images
   Widget_Control, info.drawID, Get_Value=wid
   WSet, wid
   TV, BytScl(*info.image, Top=!D.Table_Size-1)
   
   Widget_Control, info.drawID2, Get_Value=wid2
   WSet, wid2
   rmc_omplot,*info.omegat,*info.messung
   
   ;; Reset displayed information
   Widget_Control, info.xLocationID, Set_Value=''
   Widget_Control, info.yLocationID, Set_Value=''
   Widget_Control, info.valueID, Set_Value=''
   Widget_Control, info.xMaxLocationID, Set_Value=''
   Widget_Control, info.yMaxLocationID, Set_Value=''
   Widget_Control, info.maxValueID, Set_Value=''
   
   ;; Reset parameters for position
   info.xmax=-1
   info.ymax=-1

   Widget_Control, event.top, Set_UValue=info, /No_Copy 
END







