PRO RMC_SIMULATE_PRO,event
;+
; NAME: rmc_simualte_pro
;
;
;
; PURPOSE:    creates an input table for num Sources. It will only add
; a Source when all 3 Parameters are given and the values are not out
; of bounce. You can also change the number of Datapoints for the
; Simualtion 
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_SIMULATE_PRO,event (from menu in main program) 
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
; $log$
;-

   
   widget_control,event.top, get_uvalue=info,/no_copy
 
   datap = info.messpkte
   
   r = sqrt(info.fov^2+(info.fov/2)^2)
   
   ;; Creation of Table for Data input
    
   num=5 ;; Number of Simulated sources
   nn = '0'
   index=strtrim((1+indgen(num)),2)
   

   strength=-1
   azimuth=-1
   distance=-1
   
   bouncetag = -1
   
   labline='0,label,Source '+index+':'
   distline='0,text,,width=5,tag=distance'+index
   azline='0,text,,width=5,tag=azimuth'+index
   strengthline='2,text,100,width=5,tag=strength'+index   
   
   ;; Creates table for the sources
   gui = ['1,BASE,,COLUMN',$
          '1,BASE,,column,frame', $
          '1,base,,row',$
             '1,base,,column', $
                '0,label,source #,',$
                '2,label,        ,',$
             '1,base,,column', $
                '0,label,distance,',$
                '2,label,[deg],center', $
             '1,base,,column', $
                '0,label,azimuth,',$
                '2,label,[deg],center',$
             '1,base,,column', $
                '0,label,strength', $
                '2,label,[cps]', $
             '2,base,,column']
   
   FOR i=0,num-1 DO BEGIN 
       gui=[gui,'1,BASE,,row',$
            labline[i],distline[i],azline[i],strengthline[i]]
   ENDFOR 
   gui=[gui,'0,base,,column',$
         '2, BUTTON, OK , QUIT ,TAG=OK ,', $
         '2, BASE,,ROW']
   

   widget_control,event.top,sensitive=0
   data = CW_FORM(gui,/COLUMN,title='Input Parameter')
   widget_control,event.top,sensitive=1
   
   tags=tag_names(data)
   
   FOR i=1,num DO BEGIN 
       strengthtag='STRENGTH'+strtrim(i,2)
       num=(where(tags EQ strengthtag))[0]
       streval=data.(num)
       IF (streval NE '') THEN BEGIN 
           disttag='DISTANCE'+strtrim(i,2)
           num=(where(tags EQ disttag))[0]
           distval=data.(num)
           IF (distval NE '') THEN BEGIN 
               aztag='AZIMUTH'+strtrim(i,2)
               num=(where(tags EQ aztag))[0]
               azval=data.(num)
               IF (azval NE '') THEN BEGIN 
                   
                   x = distval* sin(azval*!pi/180)
                   y = distval* cos(azval*!pi/180)
                   
                   IF (azval LE 90) AND (azval GE -90) AND $
                     (distval LE r) AND (x LE (info.fov/2)) $
                     AND (y LE info.fov) AND (distval GE 0) THEN  BEGIN 
                       
                       strength=[strength,float(streval)]
                       azimuth=[azimuth,float(azval)]
                       distance=[distance,float(distval)]
                   ENDIF ELSE BEGIN 
                       bouncetag = 1
                   ENDELSE
                   
               ENDIF 
           ENDIF 
       ENDIF
   ENDFOR  
    
   IF (bouncetag GT 0) THEN BEGIN 
       gui_error = ['1, BASE,,ROW',        $
                    '1, BASE,,COLUMN',     $
                    '0, LABEL, There is at least 1 wrong source parameter',$
                    '2, BUTTON, OK , QUIT ,TAG=OK ', $
                    '1, BASE,,ROW']
       
       widget_control,event.top,sensitive=0
       guierror = CW_FORM(gui_error,/Column,Title='Wrong Source')        
       widget_control,event.top,sensitive=1
       
   ENDIF 
   nn=n_elements(strength)
    
   IF (n_elements(strength) GT 1) THEN BEGIN 
       strength=strength[1:nn-1]
       azimuth=azimuth[1:nn-1]
       distance=distance[1:nn-1]
   ENDIF  
   
   
   IF (nn EQ 1) THEN BEGIN 
       
       no_source = ['1, BASE,,ROW',        $
                    '1, BASE,,COLUMN',     $
                    '0, LABEL, There is no given source to simulate',$
                    '2, BUTTON, OK , QUIT ,TAG=OK ', $
                    '1, BASE,,ROW']
       
        widget_control,event.top,sensitive=0
        nosource = CW_FORM(no_source,/Column,Title='No Source')
        widget_control,event.top,sensitive=1
        
        Widget_Control, event.top, Set_UValue=info, /No_Copy
        return
    ENDIF
    
    str='You simulate '+strtrim(nn-1,2)+' source'
    IF (nn GT 2) THEN str=str+'s'

    datasheet = ['1,BASE,,Column', $
                 '1,BASE,,Column', $
                 '0,label,'+str,$
                 '2,Text,'+strtrim(datap,2)+',LABEL_LEFT= Datapoints: ,' $
                 +'Width = 10,Tag=datap', $
                 '1,BASE,,Column',$
                 '0, label,Do you want noise',$
                 '0, label,to be added on',$
                 '2,Button,Yes|No,Set_Value=1,Exclusive,Tag=noise,ROW',$
                 '1,Base,,Row',$
                 '0,Button,  OK  ,QUIT,Tag=OK,', $
                 '2,BUTTON,CANCEL, QUIT,Tag=CANCEL' $
                ]

    widget_control,event.top,sensitive=0
    points = cw_form(datasheet,/COLUMN,title='datapoints')
    widget_control,event.top,sensitive=1
    
    IF (points.CANCEL EQ 1) THEN BEGIN 
        
        Widget_Control, event.top, Set_UValue=info, /No_Copy
        return
    ENDIF

    ;; Starting simulation and correlation with given Parameters
    widget_control,/hourglass
   
    info.messpkte = fix(points.datap)
    
    ;;Winkel des RMC
    omegat=findgen(info.messpkte)*360./info.messpkte
    ptr_free,info.omegat
    info.omegat=ptr_new(omegat)


    ;; creating a new lightcurve with the given data
    messung = rmc_simulate(distance=distance,azimuth=azimuth,power=strength, $
                           resolution=info.w,shift=info.v, $
                           numpt=info.messpkte,fov=info.fov,$
                           omegat=*info.omegat)
    
    widget_control,/hourglass
   
    IF points.noise EQ 0 THEN  BEGIN 

        time = *info.omegat/info.rotvel
        
        deadtime_simul,time,messung,nrate,seed = 24245
        messung = nrate

    ENDIF
      
    ;; copying the variables as a backup
    cormess=messung
    ptr_free,info.messung
    info.messung=Ptr_New(messung)
    ptr_free,info.messung0
    info.messung0=Ptr_New(messung)

    ;; correlating simulated lightcurve with my correlation table
    rmc_correlate,cormess=cormess,resolution=info.w,fov=info.fov, $
      dim=info.dim,alpha=*info.alpha, $
      cortab=cortab,shift=info.v,radius=*info.radius,omegat=*info.omegat

    ;; backup of cortab
    ptr_free,info.cortab
    info.cortab=Ptr_New(cortab)
   
    ;; rotating cortab to have a correct display image
    cortab = rotate(cortab,2)
   
    ;; Resize the new correlation table
    s = size(cortab, /DIMENSIONS)
    xsize = s[0]
    ysize = s[1]
    cortab  = congrid(cortab, xsize * info.scale, $
                      ysize * info.scale)
    
    ;; backup of the correlation image
    ptr_free,info.image0
    info.image0=ptr_new(cortab)
    
    ;; Set the pointer from old image to new image. 
    ptr_free,info.image
    info.image=ptr_new(cortab)
    
    ;; saving the simulation under the name: "simulation."
    rmc_save_data,radius=info.radius,alpha=info.alpha,fov=info.fov, $
      messung=messung, name='simulation', $
      dim=info.dim,resolution=info.w,shift=info.v,cortab=cortab
    
   
    ;; Update the displayed images (Correlation and Lightcurve)
    Widget_Control, info.drawID, Get_Value=wid
    WSet, wid
    TV, BytScl(cortab, Top=!D.Table_Size-1)
    
    Widget_Control, info.drawID2, Get_Value=wid2
    WSet, wid2
    rmc_omplot,*(info.omegat),*(info.messung),title='Simulation'

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

