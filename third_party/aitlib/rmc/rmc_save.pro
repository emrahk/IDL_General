PRO RMC_SAVE,event
;+
; NAME: rmc_save
;
;
;
; PURPOSE: saving pictures and datasets. (Savingprocedures in
; rmc_save_data.pro) 
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: RMC_SAVE,event
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
; $Log: rmc_save.pro,v $
; Revision 1.2  2002/05/21 13:35:57  slawo
; Add comments
;
;-
   
   
   Widget_Control, event.top, Get_UValue=info,/No_Copy

   name = ''
   gui_sheet = [',base,,Row', $
                ',Base,, Column', $
                '0,Text,'+name+',LABEL_LEFT= Dateiname: ,' $
                +  'Width = 25,Tag=name', $
                  '2,Button,OK,QUIT,Tag=OK,',$
                '1,BAse,,Row']
   
   gui_error = ['1, BASE,,ROW',        $
                '1, BASE,,COLUMN',     $
                '0, LABEL, !    CAUTION     !, CENTER', $
                '0, LABEL, !Not a valid name!, CENTER', $
                '0, LABEL, ! Datas not saved!, CENTER', $
                
                '2, BUTTON, OK , QUIT ,TAG=OK ,', $
                '1, BASE,,ROW']
   
   ;; calling the CW_FORM Function to load Groupname  
   save = CW_FORM(gui_sheet, /Column)

   IF strlen(save.name) NE 0 THEN BEGIN
       
       name=info.name+'.'+save.name
       
       ;; calling saving procedure
       rmc_save_data,radius=*info.radius,alpha=*info.alpha,fov=info.fov, $
         messung=*info.messung,name=name, $ 
         dim=info.dim,resolution=info.w,shift=info.v,cortab=*info.cortab
       
       Widget_Control, event.top, Set_UValue=info, /No_Copy
       
   ENDIF ELSE BEGIN
       ;; showing error message when no name given and leaving procedure
       guierror = CW_FORM(gui_error,/Column,Title='ERROR') 
       Widget_Control, event.top, Set_UValue=info, /No_Copy
   ENDELSE
   
END















