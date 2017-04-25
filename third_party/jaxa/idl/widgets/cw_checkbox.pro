;+
; Project     : SOHO - CDS     
;                   
; Name        : CW_CHECKBOX()
;               
; Purpose     : "Checkbox" or "cross-box" widget (status on/off).
;               
; Explanation : Generates a small widget_draw window showing an on/off status
;               as either a "checkmark" or a cross.
;
;               To set the status, use:
;
;               WIDGET_CONTROL,CHECK_ID,SET_VALUE=STATUS
;
;               You can also modify other properties (CROSS, THICK, BGCOLOR,
;               and FGCOLOR) by using e.g.:
;
;               WIDGET_CONTROL,CHECK_ID,SET_VALUE={THICK:2,BGCOLOR:3}
;
;               To read the status, use:
;
;               WIDGET_CONTROL,CHECK_ID,GET_VALUE=VAL
;
;               after which VAL will contain a structure:
;
;               { value : value,$
;                 cross : cross,$
;                 boxed : boxed,$
;                 thick : thick,$
;                 bgcolor : bgcolor,$
;                 fgcolor : fgcolor }
;
;               The VALUE tag contains the on/off status.
;  
;               Event structures (generated when the user switches the status
;               by clicking on the draw window) are as follows:
;
;               {CW_CHECKBOX,id:ev.handler,top:ev.top,handler:0L,
;               value:0/1}
;               
; Use         : CHECK_ID = CW_CHECKBOX( BASE )
;    
; Inputs      : BASE : The widget base to put the checkbox on.
; 
; Opt. Inputs : See keywords
;
; Outputs     : Returns the ID of the compound widget.
;               
; Opt. Outputs: None.
;               
; Keywords    : BGCOLOR : Background color (default 0)
;               
;               FGCOLOR : Foreground color (default !D.TABLE_SIZE)
;               
;               THICK : Thickness of the line used to draw the
;                       checkmark/cross.
;               
;               CROSS : Set to 1 to use a cross instead of a checkmark.
;
;               BOXED : Set to draw a box around the edge of the draw window,
;                       using the foreground color. The edge will be drawn
;                       with line thickness equal to the value of BOXED. Odd
;                       values give best results.
;               
;               XSIZE,YSIZE: Size of draw window, default 20 pixels
;
;               UVALUE : The uvalue associated with the compound widget.
; Calls       : 
;
; Common      : None
;               
; Restrictions: ...
;               
; Side effects: ...
;               
; Category    : Widgets
;               
; Prev. Hist. : None
;
; Written     : SVH Haugan, UiO, 25 September 1997
;               
; Modified    : Version 2, William Thompson, GSFC, 8 April 1998
;			Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit
;			displays
;               Version 3, SVHH, 19 November 2003
;                       Fixed problem of cw_checkbox_realize being called
;                       before info structure had been put in place (IDL
;                       seems not to honor the widget_control,id,update=0/1
;                       very well).
;
; Version     : Version 3, 19 November 2003
;-            
PRO cw_checkbox_showstat,info
  
  tempwin = !d.window
  
  IF info.int.window EQ -1 THEN return
  
  IF info.ext.fgcolor EQ -1 THEN info.ext.fgcolor = !d.table_size-1
  IF info.ext.bgcolor EQ -1 THEN info.ext.bgcolor = !d.table_size-1
  
  wset,info.int.window
  
  erase,info.ext.bgcolor
  
  IF info.ext.value THEN BEGIN
     IF info.ext.cross THEN BEGIN 
        plots,[0,info.int.xsize-1],[0,info.int.ysize-1],$
           color=info.ext.fgcolor,/device,thick=info.ext.thick
        plots,[info.int.xsize-1,0],[0,info.int.ysize-1],$
           color=info.ext.fgcolor,/device,thick=info.ext.thick
     END ELSE BEGIN 
        xx = [0.25,0.5,0.9]*info.int.xsize-1
        yy = [0.7,0.3,1]*info.int.ysize-1
        plots,xx,yy,color=info.ext.fgcolor,/device,thick=info.ext.thick
     END 
  END
  
  IF info.ext.boxed NE 0 THEN $
     plots,[0,info.int.xsize-1,info.int.xsize-1,0,0],$
     [0,0,info.int.ysize-1,info.int.ysize-1,0],/device,$
     color=info.ext.fgcolor,thick=info.ext.boxed
     
     
  IF tempwin GE 0 THEN wset,tempwin
  
END


PRO cw_checkbox_setv,id,value
  stash = widget_info(id,/child)
  widget_control,stash,get_uvalue=info,/no_copy
  
  IF datatype(value) EQ 'STC' THEN BEGIN
     ext = info.ext
     copy_tag_values,ext,value
     info.ext = ext
  END ELSE BEGIN 
     info.ext.value = value
  END
  
  cw_checkbox_showstat,info
  
  widget_control,stash,set_uvalue=info,/no_copy
END


FUNCTION cw_checkbox_getv,id
  stash = widget_info(id,/child)
  widget_control,stash,get_uvalue=info,/no_copy
  
  ext = info.ext
  
  widget_control,stash,set_uvalue=info,/no_copy
  
  return,ext
END


FUNCTION cw_checkbox_event,ev
  
  IF ev.press EQ 0 THEN return,0
  
  stash = widget_info(ev.handler,/child)
  
  widget_control,stash,get_uvalue=info,/no_copy
  
  info.ext.value = info.ext.value XOR 1b 
  
  tempwin = !d.window
  
  ;; If this is the self-generated event to make sure the display
  ;; is correct even if we have been generated (after 
  
  IF info.int.window EQ -1 THEN BEGIN
     widget_control,info.int.window_id,get_value=win
     info.int.window = win
     ;; Get colors if not set
     ;;
     IF info.ext.fgcolor EQ -1 THEN info.ext.fgcolor = !d.table_size-1
     IF info.ext.bgcolor EQ -1 THEN info.ext.bgcolor = !d.table_size-1
     
     ;; The status shouldn't have been flipped
     ;; 
     info.ext.value = info.ext.value XOR 1b 
     ;; Instead - we should show the status.
     cw_checkbox_showstat,info
     
     ;; Then, gobble up event and return
     widget_control,stash,set_uvalue=info,/no_copy
     return,0
  END
  
  cw_checkbox_showstat,info

  event = {CW_CHECKBOX,id:ev.handler,top:ev.top,handler:0L,$
           value:info.ext.value}
  
  widget_control,stash,set_uvalue=info,/no_copy
  
  
  return,event
  
END

PRO cw_checkbox_realize,id
  stash = widget_info(id,/child)
  widget_control,stash,get_uvalue=info,/no_copy
  
  widget_control,info.int.window_id,get_value=win
  info.int.window = win
  IF info.ext.fgcolor EQ -1 THEN info.ext.fgcolor = !d.table_size-1
  
  cw_checkbox_showstat,info
  
  widget_control,stash,set_uvalue=info,/no_copy
END


FUNCTION cw_checkbox,base,value=value,bgcolor=bgcolor,fgcolor=fgcolor,$
                     thick=thick,xsize=xsize,ysize=ysize,cross=cross,$
                     display_only=display_only,$
                     uvalue=uvalue,no_copy=no_copy,column=column,label=label
  
  default,value,0
  default,bgcolor,0
  default,fgcolor,-1
  default,thick,1
  default,cross,0
  default,boxed,0
  
  default,xsize,20
  default,ysize,xsize
  
  IF keyword_set(label) THEN default,row,1 $
  ELSE                       default,row,0
  
  default,column,0
  IF column THEN row = 0
  
  button_events = 1-keyword_set(display_only)
  
  notify_realize = 'cw_checkbox_realize'
  
  IF widget_info(base,/realized) THEN notify_realize = ''
  
  IF NOT keyword_set(label) THEN BEGIN  
     mybase = widget_base(base,scr_xsize=xsize,scr_ysize=ysize,$
                          event_func='cw_checkbox_event',$
                          pro_set_value='cw_checkbox_setv',$
                          func_get_value='cw_checkbox_getv',$
                          notify_realize=notify_realize)
  END ELSE BEGIN
     mybase = widget_base(base,row=row,column=column,$
                          event_func='cw_checkbox_event',$
                          pro_set_value='cw_checkbox_setv',$
                          func_get_value='cw_checkbox_getv',$
                          notify_realize=notify_realize)
  END
  
  IF keyword_set(label) THEN BEGIN
     label = widget_label(mybase,value=label)
  END
  
  IF exist(uvalue) THEN BEGIN
     default,no_copy,0
     widget_control,mybase,set_uvalue=uvalue,no_copy=no_copy
  END
  
  window_id = widget_draw(mybase,xsize=xsize,ysize=ysize,$
                          button_events=button_events)
  
  ;; If the hierarchy is already ralized, we won't get the notification
  ;; Instead, send an event.
  IF widget_info(base,/realized) THEN BEGIN
     widget_control,window_id,$
        send_event = {id:0L,top:0L,handler:0L,press:1}
  END
  
  int = { window_id:window_id,$
          window   :-1L,$
          xsize    :xsize,$
          ysize    :ysize }
  
  ext = { value : value,$
          boxed : boxed,$
          cross : cross,$
          thick : thick,$
          bgcolor : bgcolor,$
          fgcolor : fgcolor }
          
  info = {int:int,ext:ext}
  
  stash = widget_info(mybase,/child)
  widget_control,stash,set_uvalue=info
  
  IF notify_realize EQ '' THEN cw_checkbox_realize,mybase
  
  return,mybase
END

PRO testcheckbox_event,ev
  widget_control,ev.id,get_uvalue=uvalue
  
  help,uvalue,ev,/str
  
  IF uvalue EQ 'QUIT' THEN widget_control,ev.top,/destroy
END



PRO testcheckbox
  
  base = widget_base(/column)
  
  quit = widget_button(base,value='Quit',uvalue='QUIT')
  
  checkbox = cw_checkbox(base,value=1,uvalue='CHECKBOX',xsize=13,thick=2)
  
  widget_control,base,/realize
  
  new = cw_checkbox(base,value=0,uvalue='CHECKBOX',xsize=13,thick=2,/cross)
  
  xmanager,'testcheckbox',base,/modal
END

