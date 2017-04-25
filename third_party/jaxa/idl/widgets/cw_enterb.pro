;+
; Project     : SOHO - CDS     
;                   
; Name        : CW_ENTERB
;               
; Purpose     : A button with user editable content
;               
; Explanation : This compound widget produces a button with a label that can
;               be changed by the user by pressing it. For IDL 4.0.1 and on
;               it's a nice way of having a very compact entry field.
;
;               Supply the original string VALUE, plus an INSTRUCT(ion) to
;               prompt the user when he alters the VALUE. The UVALUE of the
;               widget may be used in the usual way.
;
; Use         : ID = CW_ENTERB(BASE,VALUE=<text>,INSTRUCT=<text>)
;    
; Inputs      : BASE : The base to put the button on.
;               
; Opt. Inputs : None.
;               
; Outputs     : Returns the compound widget ID.
;               
; Opt. Outputs: None.
;               
; Keywords    : VALUE : Original (text) value of the button.
;
;               INSTRUCT : Prompt text for the user when editing the VALUE
;
; Calls       : xinput, default, since_version()
;
; Common      : None.
;               
; Restrictions: Only single-line texts may be used as the VALUE.
;               
; Side effects: None?
;               
; Category    : 
;               
; Prev. Hist. : None.
;
; Written     : S. V. H. Haugan, UiO, 4 January 1997
;               
; Modified    : Not yet.
;
; Version     : 1, 4 January 1997
;-            

FUNCTION cw_enterb_getv,id
  storage = widget_info(id,/child)
  widget_control,storage,get_uvalue=info
  return,info.value
END

PRO cw_enterb_setv,id,val
  storage = widget_info(id,/child)
  widget_control,storage,get_uvalue=info
  info.value = val
  widget_control,storage,set_uvalue=info
  widget_control,info.txt_id,set_value=val
END

FUNCTION cw_enterb_event,ev
  
  widget_control,ev.id,get_uvalue = info
  
  value = info.value
  xinput,value,info.instruct,/modal,status=status,group=ev.top,$
     /accept_enter
  IF status THEN BEGIN 
     info.value = value
     widget_control,ev.id,set_uvalue=info
     ev = {id:ev.handler,top:ev.top,handler:0L,$
           value:value}
     return,ev
  END
END


FUNCTION cw_enterb,on_base,value=value,uvalue=uvalue,$
                   instruct=instruct,pixy=pixy
  
  default,pixy,25
  
  default,value,''
  default,frame,0
  default,uvalue,'CW_ENTERB'
  default,instruct,'Enter value'
  
  IF since_version('4.0') THEN sml = 1 ELSE sml = 0
  small = {xpad:sml,ypad:sml,space:sml}
  
  base = widget_base(on_base,uvalue=uvalue,$
                     event_func='cw_enterb_event',$
                     pro_set_value='cw_enterb_setv',$
                     func_get_value='cw_enterb_getv')
  
  txt_id = widget_button(base,value=value,xoffset=0,yoffset=0)
  IF since_version('4.0') THEN widget_control,txt_id,scr_ysize = pixy
  storage = txt_id
  
  info = {txt_id:txt_id,instruct:instruct,value:value}
  
  IF since_version('4.0.1') THEN widget_control,txt_id,/dynamic_resize
  widget_control,storage,set_uvalue=info,/no_copy
  
  return,base
  
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'cw_enterb.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
