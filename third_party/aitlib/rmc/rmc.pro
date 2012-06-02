;+
; NAME:  rmc.pro
;
;
;
; PURPOSE:  Main program to start widgets and first definiton of variables
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: rmc
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
; $Log: rmc.pro,v $
; Revision 1.3  2002/05/10 14:08:41  slawo
; * Add a standard documentation to the file
;                      
;
;-

;; Groupname
name = ''

;; Dimension of Simulation Array
dim='100'

;; field of view 
fov ='8.'

;; Resolution faktor: W = d/D 
w = '0.33703011' 

;; shift of the grid
v='0.5'

;; Number of Bins for Lightcurve
messpkte = 90

;; Winkelgeschw.
rotvel = '10'

rmc_input,scale=scale,name=name,shift=v,image=image,messung=messung,$
  resolution=w,fov=fov,dim=dim,omegat=omegat,numpt=messpkte,rotvel=rotvel

rmc_main,image=image,scale=scale,messung=messung,name=name,shift=v,$
  resolution=w,fov=fov,dim=dim,omegat=omegat,numpt=messpkte,rotvel=rotvel


END

















