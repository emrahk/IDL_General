PRO RMC_LOAD,event
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
   datname = load.datname+'.messung'   

   IF strlen(load.datname) NE 0 THEN BEGIN
       
       ;; Counts the number of Datapoints
       
       spawn,['/usr/bin/wc','-w',datname],no,/noshell

       info.messpkte = fix(no)
       
       ;; Neues OmegaT

       idx=findgen(info.messpkte)
       omegat=(idx)*360./info.messpkte
              
       ptr_free,info.omegat
       info.omegat=ptr_new(omegat)
       
       ;; Loading Datas from given file
       var = dblarr(info.messpkte)
       openr,unit,datname, /get_lun   
       readf,unit,var
       free_lun,unit
       
       ptr_free,info.messung0
       info.messung0=ptr_new(var)
       
       ptr_free,info.messung
       info.messung =ptr_new(var)
       
       ;; Starting simulation and correlation with given Parameters
       widget_control,/hourglass
       rmc_correlate,cormess=info.messpkte,resolution=info.w,fov=info.fov, $
         dim=info.dim,messpkte=info.messpkte,radgrad=*info.radgrad, $
         shift=info.v,omegat=*info.omegat,radius=*info.radius, $
         alpha=*info.alpha,cortab=cortab
       
       ;; backup of cortab
       ptr_free,info.cortab
       info.cortab=ptr_new(cortab)
       
       ;; rotating cortab for a correct display image
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


