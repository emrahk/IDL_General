PRO rmc_save_data,radius=radius,alpha=alpha,fov=fov,messung=messung, $
         dim=dim,resolution=w,shift=v,cortab=cortab,name=name
   
;+
; NAME: save
;
;
;
; PURPOSE: saves all datas for the correlation programs in differen
;          .dat files
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; KEYWORD PARAMETERS:
;           resolution: resolution of the RMC system 
;           fov: Field of view of the RMC
;           radius: array of different radius values for picture size
;           alpha: array of different angle values for picture size
;           dim: size of array
;           shift: shift of the grids of the RMC
;           cortab: solution of the crosscorrelation between
;                   correlationtable and datas
;            messung: original datas from Photomultiplier
;   
; OUTPUTS: parameter.dat: file containing dim,fov,resolution,shift
;          alpha.dat: file containing array of angles
;          radius.dat: file containing array of radii
;          correlation.dat: file containing solution of cross
;                           correlation
;          messung.dat: file containing original Dataset
            
; OPTIONAL OUTPUTS:
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
;   Version 1.0, 2001.09.11, Slawomir Suchy, slawo@astro.uni-tuebingen.de
;       Initial Revision.
; $Log: rmc_save_data.pro,v $
; Revision 1.2  2002/05/21 13:43:13  slawo
; Add $Log$
;
;- 
   
;; Abspeichern der Winkeltabelle
openw,unit,name+'.parameter',/get_lun
printf,unit,dim
printf,unit,fov
printf,unit,w
printf,unit,v
printf,unit,'Folgende parameter abgespeichert: dim,fov,w,v'
free_lun,unit

;; Abspeichern der Winkeltabelle
openw,unit,name+'.alpha',/get_lun
printf,unit,alpha
free_lun,unit

;; Abspeichern der Radiustabelle
openw,unit,name+'.radius',/get_lun
printf,unit,radius
free_lun,unit

;; Abspeichern der Correlationstabelle
openw,unit,name+'.correlation',/get_lun
printf,unit,cortab
free_lun,unit

;; Abspeichern der Messkurve
openw,unit,name+'.messung',/get_lun
printf,unit,messung
free_lun,unit

open_print,name+'.correlation.ps',/postscript
tvscl,cortab,xsize=10,ysize=10,/centimeters
close_print

END 












