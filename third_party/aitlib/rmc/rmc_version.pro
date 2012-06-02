PRO RMC_VERSION,event
   
   
   
   version=['1, BASE,,COLUMN',     $
            '0, LABEL, most of it is Version 1.2, CENTER', $
            '0, LABEL, Programmed by Slawomir Suchy, CENTER', $
            '0, LABEL, and  a lot ( I MEAN REALLY A LOT ) ,center',$
            '0, Label, help of Joern Wilms, CENTER', $
            '2, BUTTON, OK , QUIT ,TAG=OK ,', $
            '1, BASE,,ROW']
   widget_control,event.top,sensitive=0
   help=cw_form(version,Title='Version')
   widget_control,event.top,sensitive=1 
END 
