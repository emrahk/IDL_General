PRO RMC_COMPLIGHT,event
;+
; NAME: rmc_complight
;
;
;
; PURPOSE: This Program computes a lightcurve for a given point in the
; 2D Plot. It will ask you for an estimated strength of the source and
; after plotting the lightcurve (dashed line) it will ask if this
; strength is ok. 
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: rmc_complight (It is called in a menu)
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
; OUTPUTS: Will plot a second lightcurve (curve) over the original Datacurve
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
;                       $Log: rmc_complight.pro,v $
;                       Revision 1.3  2002/05/17 09:00:24  slawo
;                       Added Comments and modification History
;
;-
   
   
   
;; Computing a Lightcurve for the Maximum pressed, chosen by the
   ;; Xmax,Ymax values. Plotting new Lightcurve over the Original Lightcurve
      
   Widget_Control,event.top, Get_UValue=info, /No_Copy

   IF (info.xmax GE 0) OR (info.ymax GE 0) THEN BEGIN  
       messpkte = n_elements(*(info.messung))
       
       ;; computes the radius and angle tables
       rmc_tables,radius=radius,alpha=alpha,fov=info.fov,dim=info.dim,$
         radint=radint,radgrad=radgrad
       
       radius = radgrad[info.xmax,info.ymax]
       
       azimut = -alpha[info.xmax,info.ymax]
   
       staerke = float(1)   
       power = '100'
       
       gui_ok = ['1, BASE,,ROW',     $
                 '1, BASE,,COLUMN',     $
                 '0, LABEL, Is the count rate ok? , CENTER', $
                 '1, BASE,,ROW',     $
                 '0, BUTTON, YES ,QUIT,TAG=YES,', $
                 '2, BUTTON, NO ,QUIT,TAG=NO,', $
                 '1, BASE,,ROW']
       
       data={ok:1}
       WHILE (data.OK EQ 1) DO BEGIN 

           
           gui_sheet =['1, BASE,,ROW',        $
                       '1, BASE,,COLUMN',     $
                       '0, TEXT,'+ power + ', LABEL_LEFT = Estimated Source'+$
                       ' Count Rate [cps]: ,' $
                       + 'WIDTH=10, TAG=power', $
                       '2, BUTTON, OK , QUIT ,TAG=OK ,', $
                       '1, BASE,,ROW']
           
           widget_control,event.top,sensitive=0
           data = cw_form(gui_sheet,/COLUMN,title='Source Countrate')
           widget_control,event.top,sensitive=1
           
           power=data.power
           
           staerke = float(data.power)
           info.estpow=staerke

           ;; compute a single lightcurve for the choosen point
           curve = rmc_simulate(distance=radius,azimuth=azimut,power=staerke, $
                                resolution=info.w,shift=info.v, $
                                omegat=*(info.omegat), $
                                numpt=messpkte,fov=info.fov)
           
           ;; Plot and Overplot of the Lightcurve
           widget_control,info.drawid2,get_value=wid2
           wset,wid2
           rmc_omplot,*(info.omegat),*(info.messung)
           oplot,*(info.omegat),curve,linestyle = 3
           
           widget_control,event.top,sensitive=0
           gui = cw_form(gui_ok, /COLUMN,Title='Source countrate')
           widget_control,event.top,sensitive=1
           
           IF (gui.yes EQ 1) THEN BEGIN
               data.ok = 0
           ENDIF
           
       ENDWHILE
       
   ENDIF
   
   Widget_Control, event.top, Set_UValue=info, /No_Copy    
END 







