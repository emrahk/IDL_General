PRO RMC_help,event
;+
; NAME:  rmc_help
;
;
;
; PURPOSE:  Just a small joke
;
;
;
; CATEGORY:  IAAT RMC tools
;
;
;
; MODIFICATION HISTORY:
; $Log: rmc_help.pro,v $
; Revision 1.2  2002/05/17 09:40:11  slawo
; Added comments
;
;-
   
   version=['1, BASE,,COLUMN',     $
            '0, LABEL, You should contact your assitant., CENTER', $
            '0, LABEL, The instruction should , CENTER', $
            '0, LABEL, be clear enough. , CENTER', $
            '0, LABEL, Maybe you want to make , CENTER', $
            '0, LABEL, an other appointment for this lab. , CENTER', $
            '2, BUTTON, OK , QUIT ,TAG=OK ,', $
            '1, BASE,,ROW']
   
   widget_control,event.top,sensitive=0
   help=cw_form(version,Title='Version')
   widget_control,event.top,sensitive=1
END 
