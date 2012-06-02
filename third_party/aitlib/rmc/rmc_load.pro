PRO RMC_LOAD,event
;+
; NAME: rmc_load
;
;
;
; PURPOSE: loading of datasets. 
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_LOAD,event  (It is called in a menu)
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
; OUTPUTS:  changing of messung, cortab, image and omegat, and also
; their backups
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
; $Log: rmc_load.pro,v $
; Revision 1.3  2002/05/21 09:42:21  slawo
; Add comments
;
; Revision 1.2  2002/05/21 09:33:07  slawo
; *** empty log message ***
;
;-
   
   
;; creates an  input widget to enter the name of loading the
   ;; datas. When no name is given, it will take the groupname (enter
   ;; at the beginning) of the session. 
   
   widget_control, event.top, get_uvalue=info,/no_copy
   
   ;; layout widget for loading data
   datname = ''
   gui_sheet = ['1,BASE,,ROW', $
                '1,BASE,, COLUMN', $
                '0,TEXT,'+datname+',LABEL_LEFT= Filename: ,' $
                +'WIDTH = 25,TAG=datname', $
                '2,BUTTON,OK,QUIT,TAG=OK,',$
                '1,BASE,,ROW']
   
      
   
   ;; calling the cw_form function to load ready data 
   nnn=''
   WHILE NOT file_exist(nnn+'.messung') DO BEGIN 
       widget_control,event.top,sensitive=0
       load = cw_form(gui_sheet, /column, title='Enter Filename')
       widget_control,event.top,sensitive=1
       
       nnn=load.datname
       
       IF NOT (file_exist(nnn+'.messung')) THEN BEGIN 
           gui_error = ['1, BASE,,ROW',        $
                        '1, BASE,,COLUMN',     $
                        '0, LABEL, File does not exist, CENTER', $
                        '2, BUTTON, OK , QUIT, TAG=OK ,', $
                        '1, BASE,,ROW']
           
           widget_control,event.top,sensitive=0
           guierror = CW_FORM(gui_error,/Column,Title='File not found')
           widget_control,event.top,sensitive=1
           
           Widget_Control, event.top, Set_UValue=info,/No_Copy
           return
       END 
   END 
   name = load.datname+'.messung'   

   IF strlen(load.datname) NE 0 THEN BEGIN
       
       ;; Counts the number of Datapoints
       
       spawn,['/usr/bin/wc','-w',name],no,/noshell

       info.messpkte = fix(no)
       
       ;;Winkel des RMC
       idx=findgen(info.messpkte)
       omegat=(idx)*360./info.messpkte
       ptr_free,info.omegat
       info.omegat=ptr_new(omegat)
       
       ;; Loading Datas from given file
       var = dblarr(info.messpkte)  

       openr,unit,name, /get_lun   
       readf,unit,var
       free_lun,unit
       
       ptr_free,info.messung0
       info.messung0=ptr_new(var)
       
       ptr_free,info.messung
       info.messung =ptr_new(var)
       
       ;; Starting simulation and correlation with given Parameters
       widget_control,/hourglass
       rmc_correlate,cormess=var,resolution=info.w,fov=info.fov,dim=info.dim, $
         cortab=cortab,shift=info.v,omegat=*info.omegat,alpha=*info.alpha,$
         radius=*info.radius
       
       ;; backup of cortab
       ptr_free,info.cortab
       info.cortab=ptr_new(cortab)
       
       ;; rotating cortab to have a correct display image
       cortab = rotate(cortab,2)
       
       ;; Resize the new correlation table
       s = size(cortab, /dimensions)
       xsize = s[0]
       ysize = s[1]
       cortab  = congrid(cortab, xsize * info.scale, $
                         ysize * info.scale)
       
       ;; backup of the correlation image
       ptr_free,info.image0
       info.image0=ptr_new(cortab)
       
       ;; set the pointer from old image to new image
       ptr_free,info.image
       info.image=ptr_new(cortab)
      
       ;; Update the displayed images
       widget_control, info.drawid, get_value=wid
       wset, wid
       tv, bytscl(cortab, top=!d.table_size-1)
   
       widget_control, info.drawid2, get_value=wid2
       wset, wid2
       rmc_omplot,*info.omegat,*info.messung
   
       ;; reset displayed information
       Widget_Control, info.xLocationID, Set_Value=''
       Widget_Control, info.yLocationID, Set_Value=''
       Widget_Control, info.valueID, Set_Value=''
       Widget_Control, info.xMaxLocationID, Set_Value=''
       Widget_Control, info.yMaxLocationID, Set_Value=''
       Widget_Control, info.maxValueID, Set_Value=''
       
       ;; Reset parameters for position
       info.xmax=-1
       info.ymax=-1
   ENDIF 
   
   widget_control, event.top, set_uvalue=info, /no_copy
   
END


