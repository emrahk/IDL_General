PRO RMC_PARAMETER,event
;+
; NAME: rmc_parameter
;
;
;
; PURPOSE: declaration of changed parameter in the info-structure
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_PARAMETER,event (from menu in the main program)
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
; $Log: rmc_parameter.pro,v $
; Revision 1.2  2002/05/21 12:47:19  slawo
; Add comments
;
;-
   
   
   Widget_Control, event.top, Get_UValue=info, /No_Copy    
   
   name=info.name
   v=string(info.v)
   w=string(info.w)
   dim=string(info.dim)
   fov=string(info.fov)
   rotvel=string(info.rotvel)
   
   RMC_INPUT,scale=scale,name=name,messung=messung, $
     image=image,numpt=info.messpkte,shift=v, $
     resolution=w,fov=fov,dim=dim,omegat=omegat,rotvel=rotvel

   ;; Set the pointer from old image to new image. 
   ptr_free,info.image
   info.image=ptr_new(image)
   
   ptr_free,info.messung
   info.messung=ptr_new(messung)
   info.scale=scale
   info.name=name
   info.messpkte=info.messpkte
   info.v=v
   info.w=w
   info.fov=fov
   info.dim=dim
   
   ptr_free,info.omegat
   info.omegat=ptr_new(omegat)
   info.rotvel=rotvel
   
   ;; Display image.
   Widget_Control, info.drawID, Get_Value=wid
   WSet, wid
   TV, BytScl(*(info.image), Top=!D.Table_Size-1)
  
   Widget_control,info.drawid2,get_value=wid2
   wset,wid2
   rmc_omplot,*(info.omegat),*(info.messung)
   
   Widget_Control, event.top, Set_UValue=info, /No_Copy    
END










