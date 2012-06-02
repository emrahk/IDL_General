PRO RMC_INPUT,scale=scale,name=name,shift=v,image=image,messung=messung,$
              resolution=w,fov=fov,dim=dim,omegat=omegat,numpt=messpkte, $
              rotvel=rotvel
;+
; NAME: rmc_input
;
;
;
; PURPOSE: is used to enter all parameter for the whole rmc program
;
;
;
; CATEGORY:  IAAT RMC tools
;
;
;
; CALLING SEQUENCE:
;             RMC_INPUT,scale=scale,name=name,shift=v,image=image, $
;              resolution=w,fov=fov,dim=dim,omegat=omegat,numpt=messpkte, $
;              rotvel=rotvel,messung=messung,$
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
;           resolution: resolution of the rmc system 
;           fov: Field of view of the RMC
;           dim: dimension of correlation array
;           name: groupname
;           numpt: Number of datapoints for correlation
;           shift: shift of the grids 
;           omegat: position of the rmc in angles
;           rotvel: rotation velocity. Not really necessary, because
;           you can not meassure it. 
;
; OUTPUTS:  image: cortab with changed size to 500X500 Pixels
;           scale: calculated scalesize of final picture
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
;  $Log: rmc_input.pro,v $
;  Revision 1.2  2002/05/21 09:20:41  slawo
;  Add comments
;
;-
   
   gui_sheet =['1,BASE,,COLUMN',$
               '1, BASE,,column',$
               '0, TEXT,'+ name +', LABEL_LEFT    = Name of Group        : ,' $
               + 'WIDTH=10, TAG=name,', $
               '0, TEXT,'+ dim  +', LABEL_LEFT    = Image-Dimensions     : ,' $
               + 'WIDTH=10, TAG=dim', $
               '0, TEXT,'+ fov  +', LABEL_LEFT    = Field of View (deg)  : ,' $
               + 'WIDTH=10, TAG=fov', $
               '0, TEXT,'+ rotvel  +', LABEL_LEFT = Angular Veloc. (1/s) : ,' $
               + 'WIDTH=10, TAG=rotvel', $
               '0, TEXT,'+ w    +', LABEL_LEFT    = Resolution           : ,' $
               + 'WIDTH=10, TAG=w', $
               '0, TEXT,'+ v    +', LABEL_LEFT    = Shift of Grids       : ,' $
               + 'WIDTH=10, TAG=v', $             
               '2, BUTTON, OK , QUIT ,TAG=OK ,', $
               '1, BASE,,ROW']
   
   data = CW_FORM(gui_sheet,/COLUMN,title='Input Parameter')
   
   name =data.name
   
IF data.name EQ '' THEN BEGIN
    gui_error = ['1, BASE,,ROW',        $
                 '1, BASE,,COLUMN',     $
                 '0, LABEL,    Group name: "noname"    , CENTER', $
                 '2, BUTTON, OK , QUIT ,TAG=OK ,', $
                 '1, BASE,,ROW']
    guierror = CW_FORM(gui_error,/Column,Title='Default name')
    name = 'noname'
ENDIF

fov = float(data.fov)
dim = fix(data.dim)
w = float(data.w)
v = float(data.v)
rotvel = float(data.rotvel)



;;Winkel des RMC
idx=findgen(messpkte)
omegat=(idx)*360./messpkte
    
messung = dblarr(messpkte)

cortab = dblarr(dim,dim)

;; Scaling Factor, Size of Picture is 500 Pixel
scale = 500./dim 

SCALE = 10.0E-4 > FLOAT(SCALE)  ; MINIMUM SCALING VALUE.

S = SIZE(cortab, /DIMENSIONS)
XSIZE = S[0]
YSIZE = S[1]

IF FLOAT(SCALE) NE 1.0 THEN BEGIN
    image  = CONGRID(cortab, XSIZE * SCALE, YSIZE * SCALE)
ENDIF ELSE image = cortab

END




















