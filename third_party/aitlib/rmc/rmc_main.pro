PRO RMC_MAIN,image=image,group_leader=groupleader, $
             scale=scale, messung = messung, name = name, $
             resolution=w,fov=fov,dim=dim,shift=v,omegat=omegat, $
             numpt=messpkte,rotvel=rotvel,cortab=cortab
   
;+
; NAME: rmc_main
;
;
;
; PURPOSE:  As the name implies, this is the main heart of the whole
; rmc routines. This program creates the widgets and also calls all
; subroutines. It also declare the info structure, which will hold all
; variables for the subroutines
;
;
;
; CATEGORY:  IAAT RMC tools
;
;
; CALLING SEQUENCE:
;             RMC_MAIN,image=image,group_leader=groupleader, $
;             scale=scale, messung = messung, name = name, $
;             resolution=w,fov=fov,dim=dim,shift=v,omegat=omegat, $
;             numpt=messpkte,rotvel=rotvel,cortab=cortab
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
; KEYWORD PARAMETERS:image: empty 2D Array.
;                    scale: calculated scalesize of final picture
;                    messung: measured or simulated datas
;                    name: Groupname
;                    resolution: resolution of the rmc system
;                    fov: Field of view of the RMC
;                    dim: dimension of correlation array
;                    shift: shift of the grids 
;                    omegat: position of the rmc in angles
;                    numpt: Number of Datapoints
;                    rotvel: rotation velocity of the RMC
;                    cortab: original correlation datas with dimXdim
;                    (not scaled)
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
; $Log: rmc_main.pro,v $
; Revision 1.2  2002/05/21 10:02:30  slawo
; Add comments
;
;-
   
   
   
   ;; main program and widget controller of the button and image
   ;; widgets.
   s = size(image, /dimensions)
   xsize = s[0]
   ysize = s[1]
   ;; create mother widget
   mother = widget_base(title='rmk versuch, astronomisches institut',$
                        row=2,tlb_frame_attr=1, $
                        base_align_left=1,mbar=menu_bar)

  desc=['1\File', $
        '0\Load\rmc_load',$
        '0\Save\rmc_save',$
        '0\Parameter\rmc_parameter',$
        '2\Exit\rmc_exit',$
        '1\Simulation', $
        '0\Simulate\rmc_simulate_pro',$
        '0\Compute lightcurve\rmc_complight', $
        '0\Subtract lightcurve\rmc_subt', $
        '2\Restore lightcurve\rmc_reset',$
        '1\Print',$
        '0\Lightcurve\rmc_print_curve',$
        '2\Correlation table\rmc_print_cor',$
        '1\?',$
        '0\Version\rmc_version',$
        '2\Help\rmc_help'$
  ]
  
  menu=cw_pdmenu(menu_bar,desc,/mbar,/return_full_name)

   ;; create widget for lightcurve
   tlb1 = widget_base(mother,title='Modulation Lightcurve',$
                     row=1, tlb_frame_attr=1, $
                     base_align_center=1)
   
   drawid2 = widget_draw(tlb1, xsize=600, ysize=400,retain=2)
   
   ;; create widgets for correlation
   tlb2 = widget_base(mother,title=title, row=1, tlb_frame_attr=1, $
                      base_align_center=1)
   
   drawid = widget_draw(mother, xsize=xsize, ysize=ysize, $
                        motion_events=1,button_events=1,$
                        event_pro='rmc_motion',retain=2) 
    
   ;; create widget for button and values
   buttonbaseid2 = widget_base(mother, colum=1)
   xlabelid = widget_label(buttonbaseid2, value=' X loc: ')
   xlocationid = widget_text(buttonbaseid2, scr_xsize=40)
   ylabelid = widget_label(buttonbaseid2, value=' Y loc: ')
   ylocationid = widget_text(buttonbaseid2, scr_xsize=40)
   vallabelid = widget_label(buttonbaseid2, value=' Value: ')
   valueid = widget_text(buttonbaseid2, scr_xsize=120)
   xmaxlabelid = widget_label(buttonbaseid2, value=' Xmax: ')
   xmaxlocationid = widget_text(buttonbaseid2, scr_xsize=40)
   ymaxlabelid = widget_label(buttonbaseid2, value=' Ymax: ')
   ymaxlocationid = widget_text(buttonbaseid2, scr_xsize=40)
   maxvallabelid = widget_label(buttonbaseid2, value='max. Value: ')
   maxvalueid = widget_text(buttonbaseid2, scr_xsize=120)
   
   ;; realizing both widgets   
   widget_control, mother, /realize
;   widget_control,buttonbaseid,/realize
   
   
   ;; display image.
   widget_control, drawid, get_value=wid
   wset, wid
   tv, bytscl(image, top=!d.table_size-1)
   
   widget_control, drawid2, get_value=wid2
   wset, wid2
   rmc_omplot,omegat,messung
     
   ;; structure to hold program information.
   
   ;; computing alpha and radii tables
   rmc_tables,radius=radius,alpha=alpha,radgrad=radgrad,fov=fov,$
               radint=radint,dim=dim  
   
   ;; reset conditions for variables
   ymax = -1
   xmax = -1
   messung0 = messung
   image0=image
   numsource=0
   estpow=0
   
   ;; definition of the variable structure of all variables
   info = { image0:ptr_new(image0), $
            image:ptr_new(image), $          ; the image data.
            scale:scale, $                   ; the scaling factor.
            xlocationid:xlocationid, $       ; the x location widget id.
            ylocationid:ylocationid, $       ; the y location widget id.
            valueid:valueid, $               ; the image value widget id
            xmaxlocationid:xmaxlocationid, $ ; the xmax location widget id
            ymaxlocationid:ymaxlocationid, $ ; the ymax location widget id
            maxvalueid:maxvalueid, $         ; the image max value widget id
            drawid:drawid, $                 ; the id of the image window
            drawid2:drawid2, $1              ; the id of the plot window
            xmax:xmax,ymax:ymax, $           ; the xmax and ymax variabl
            name:name, $                     ; groupname
            messung:ptr_new(messung), $      ; lightcurve 
            estpow:estpow, $                 ; estimated pow. of lightcurvesim.
            dim:dim,fov:fov, $               ; dimension and field of view
            w:w,v:v, $                       ; rmc parameter
            omegat:ptr_new(omegat), $        ; the angle*time of the rmc
            messung0:ptr_new(messung0), $    ; original lightcurve 
            messpkte:messpkte, $             ; number of datapoints
            numsource:numsource, $           
            cortab:ptr_new(cortab), $
            radius:ptr_new(radius), $
            alpha:ptr_new(alpha), $
            rotvel:rotvel, $
            radgrad:ptr_new(radgrad)}
   
   widget_control, mother, set_uvalue=info, /no_copy

   ;; xmanager for two widgets

;   xmanager, 'rmc', buttonbaseid,/no_block, $
;     cleanup='rmc_cleanup', group_leader=groupleader 
   
   xmanager, 'rmc', mother, /no_block, $
     cleanup='rmc_cleanup', group_leader=groupleader
end




















