;+
; Project     : SOHO - CDS     
;                   
; Name        : CW_MOUSE()
;               
; Purpose     : Controlling the "Mouse button action" selection & display
;               
; Explanation : In order to make more than three types of actions available
;               for the mouse buttons, a "Mouse button action" display with a
;               pulldown menu for each mouse button is created.
;
;               The pulldown menus have the following appearance when it is
;               not pulled down:
;
;                1:<btext1>      2:<btext2>     3:<btext3>
;               
;               where <btext1>, <btext2>, and <btext3> corresponds to the
;               currently chosen options for mouse buttons 1, 2, and 3,
;               respectively.
;
;               The user may select what type of action is to be hooked to the
;               different mouse buttons at any time by selecting from the 3
;               pulldown menus corresponding to the different mouse buttons.
;
;               For each selectable action (each pulldown menu item), there
;               are four entities that should be specified:
;
;               Button text (btext): Text to be displayed when an option is
;                                    selected.
;               Menu text (mtext)  : Text to appear on the pulldown menu
;               Action (action)    : Any string that identifies the menu
;                                    item (much like a normal UVALUE).
;
;               Availability(avail): A bit-coded mask for availability.
;
;                   Bit 1 set (value 1) means this option should be available
;                   for mouse button 1.
;
;                   Bit 2 set (value 2) means this option should be available
;                   for mouse button 2
;
;                   Bit 3 set (value 4) means option should be available for
;                   mouse button 3.
;                   
;                   Bit 4 set (value 8) means that this option is sensitive to
;                   drag operations.  
;
;               The <btext> display field on the buttons is changed according
;               to the selected action automatically.
;
;               DURING EVENT PROCESSING:
;               
;               Upon reciept of a WIDGET_DRAW event, the main program calls
;               CW_TMOUSE(ID,EVENT) in order to translate the event into an
;               "action" string corresponding to the event and the current
;               status of the cw_mouse widget.
;
;               If the event is a button press, the action string
;               corresponding to the pressed button is returned. If it is a
;               drag sensitive action, the status variable PRESS will be
;               updated to reflect the pressed button. See below for a
;               discussion of status variables.
;               
;               If the event is a motion event with no button pressed, or if
;               the current action for the button is not drag sensitive, the
;               value of the MOTION status variable is returned (default
;               value "MOTION"). See below for a discussion of status
;               variables.
;
;               If the event is a motion event with a drag sensitive action
;               button pressed down, the corresponding action string will be
;               returned as if the button was pressed again. (NOTE: There's no
;               distinction between a PRESS and a DRAG for drag sensitive
;               actions, other than in the original WIDGET_DRAW event
;               structure).
;
;               If the event is a button release, a value from the 3-element
;               string array status variable RELEASE is returned. RELEASE(0)
;               is returned for button 1 and so on. The default value of
;               RELEASE is ['RELEASE1','RELEASE2','RELEASE3']. See below for a
;               discussion of status variables.
;
;               ALTERING MENU SELECTIONS
;
;               The main program may control the selection of actions by
;               setting the compound widget "value" equal to an array of 3
;               action strings e.g.:
;
;               WIDGET_CONTROL,CW_ID,SET_VALUE=['ACTION1','ACTION2','ACTION3']
;
;               which will make button 1 correspond to the action "ACTION1",
;               button 2 correspond to "ACTION2" etc. The action strings must
;               match action values supplied in the creation of the compound
;               widget.  The displayed <btext>s will be altered
;               automatically. An empty string means don't touch the current
;               selection for that mouse button.
;
;               STATUS VARIABLES:
;               
;               There are some status variables that may be set by the main
;               program, either through keywords when creating the compound
;               widget or through the SET_VALUE keyword in WIDGET_CONTROL. The
;               status variables are:
;
;               RELEASE: A 3-element string array with the action texts to
;                        be returned upon button release events.
;                        Default value ['RELEASE1','RELEASE2','RELEASE3']
;
;               MOTION: A scalar string with the action text to be returned
;                       for non-drag motion events. Default value "MOTION".
;
;               PRESS: During DRAG operations, this status variable contains
;                      the mouse button ID (1,2, or 4) of the pressed mouse
;                      button. This status variable is not settable through
;                      a keyword.
;                       
;               The main program controls the status variables of the compound
;               widget by assigning a structure value to the the "widget
;               value" of the compound widget. The tags of the structure
;               should be corresponding to the status variables, e.g.:
;
;               WIDGET_CONTROL,CW_ID,SET_VALUE={MOTION:'TRACKING'}
;
;               will set the MOTION status variable to "TRACKING". Motion
;               events will return this text from CW_TMOUSE after this
;               operation.
;
;               It is also possible for the main program to read the status
;               variables through:
;
;               WIDGET_CONTROL,CW_ID,GET_VALUE=STATUS
;               
;               This will return a structure in the variable STATUS, with
;               tags corresponding to the different status variables.
;
;               (DE)SENSITIZING MENU OPTIONS
;
;               The main program may also control which actions should be
;               available at any time to the user by using e.g.:
;
;               WIDGET_CONTROL,CW_ID,SET_VALUE={INSENSITIVE:["AA","BB"],$
;                                                 SENSITIVE:["CC","DD"]}
;
;               This will ensure that the menu choices corresponding to
;               action strings "AA" and "BB" will be desensitized (grayed
;               out), and the choices corresponging to actions "CC" and "DD"
;               will be sensitized. Other choices will not be affected.
;
; Use         : CW_ID = CW_CMOUSE(BASE,MENU)
;    
; Inputs      : BASE:   The widget base to place the display on.
;               
;               MENU: An array of {CW_MOUSE_S} (see below) with a 
;                     description of the available mouse keyclick actions.
;
;               The options has the structure
;
;               {CW_MOUSE_S, btext:'', mtext:'', action:'', avail:0,flags:0}
;
;               btext is the "button text", i.e., the text that is to be
;               displayed on the pulldown menu if this option is selected.
;
;               mtext is the menu text, i.e., the text to be shown in the
;               pulldown menu.
;
;               action is the text to be returned by CW_TMOUSE when an event
;               corresponding to this menu entry occurs.
;
;               flags is used as in cw_pdmenu in order to construct
;               multi-level pulldown menus. See CW_PDMENU for details.
;
;               The field "avail" is used as a bit field:
;               Bit 0 (value 1) : This option available for button 1
;               Bit 1 (value 2) : This option available for button 2
;               Bit 2 (value 4) : This option available for button 3
;               Bit 4 (value 8) : (Repeat) Pass on motion events when 
;                                 button is pressed continuously.
;
;               See  also "Explanation" above.
;               
; Opt. Inputs : None
;               
; Outputs     : Returns widget ID of the compound widget.
;               
; Opt. Outputs: None.
;               
; Keywords    : MOTION: Scalar text to be returned from CW_TMOUSE during
;                       a non-drag motion. Default "MOTION".
;
;               RELASE: 3-element text array with the texts to be returned
;                       from CW_TMOUSE upon a button release event.
;
;               DISABLE: An array of strings matching those action strings
;                        that are to be made unavailable initially.
;
; Calls       : copy_tag_values cw_mouse_enable cw_mouse() cw_mouse_one_b
;               default parcheck since_version() typ() widget_base()
;
; Common      : None.
;               
; Restrictions: The ACTIONS must be strings.
;               
; Side effects: None known.
;               
; Category    : Utility, Display
;               
; Prev. Hist. : Based on CMOUSE
;
; Written     : Stein Vidar H. Haugan, UiO, 13 June 1996
;               
; Modified    : Version 2, SVHH, 16 October 1996
;                       Modified IDL v 4.0(.1) widgets to save space.
;
; Version     : 2, 16 October 1996
;-            


PRO cw_mouse_event,ev
  
  WIDGET_CONTROL,ev.handler,get_uvalue=status,/no_copy
  
  ;; There's not much going on here, is there?
  
  WIDGET_CONTROL,ev.id,get_uvalue=uvalue
  
  CASE ev.id OF 
     status.select1: BEGIN
        ix = (WHERE(status.psel_menu1(*).uvalue EQ uvalue))(0)
        status.current(0) = ix
     END
     
     status.select2: BEGIN
        ix = (WHERE(status.psel_menu2(*).uvalue EQ uvalue))(0)
        status.current(1) = ix
     END
     
     status.select3: BEGIN
        ix = (WHERE(status.psel_menu3(*).uvalue EQ uvalue))(0)
        status.current(2) = ix
     END
  END
  
  status.disp.press = 0
  
  WIDGET_CONTROL,ev.handler,set_uvalue=status,/no_copy
END


PRO cw_mouse_enable,status,enable,disable
  value = {sensitive:enable,insensitive:disable}
  WIDGET_CONTROL,status.select1,set_value=value
  WIDGET_CONTROL,status.select2,set_value=value
  WIDGET_CONTROL,status.select3,set_value=value
END


PRO cw_mouse_set_value,id,value
  
  WIDGET_CONTROL,id,get_uvalue=status,/no_copy
  
  CASE datatype(value) OF 
     'STC': BEGIN
        disp = status.disp
        copy_tag_values,disp,value
        IF tag_exist(value,'enable',/top_level) THEN $
           cw_mouse_enable,status,value.enable,''
        IF tag_exist(value,'disable',/top_level) THEN  $
           cw_mouse_enable,status,'',value.disable
        status.disp = disp
     END
     
     'STR': BEGIN
        IF N_ELEMENTS(value) NE 3 THEN BEGIN
           PRINT,"CW_MOUSE ERROR OCCURED"
           CRASH = 2*CRASH
        END
        
        ;;
        ;; Find out what selection was made, store it in status
        ;; and update the cw_pselect menu
        ;;
        IF value(0) NE '' THEN BEGIN
           ix = (WHERE(status.psel_menu1(*).uvalue EQ value(0)))(0)
           IF ix NE -1 THEN begin
              status.current(0) = ix
              WIDGET_CONTROL,status.select1,set_value=value(0)
           END
        END
        IF value(1) NE '' THEN BEGIN
           ix = (WHERE(status.psel_menu2(*).uvalue EQ value(1)))(0)
           IF ix NE -1 THEN BEGIN
              status.current(1) = ix
              WIDGET_CONTROL,status.select2,set_value=value(1)
           END
        END
        IF value(2) NE '' THEN BEGIN
           ix = (WHERE(status.psel_menu3(*).uvalue EQ value(2)))(0)
           IF ix NE -1 THEN BEGIN
              status.current(2) = ix
              WIDGET_CONTROL,status.select3,set_value=value(2)
           END
        END
        ;;
        ;; The meaning of a pressed button may have changed, so we
        ;; don't want motion events until the press is repeated, or
        ;; explicitly set through set_value.
        status.disp.press = 0
     END
     
     ELSE: RETURN
  END
  
  WIDGET_CONTROL,id,set_uvalue=status,/no_copy
END


;;
;; Return status.disp
;;

FUNCTION cw_mouse_get_value,id
  WIDGET_CONTROL,ID,GET_UVALUE=status,/no_copy
  
  value = status.disp
  
  WIDGET_CONTROL,id,set_uvalue=status,/no_copy
  RETURN,value
END


;;
;; Find what menu options are allowed for button number "number", and
;; construct the correct CW_PSELECT menu for it.
;; 

PRO cw_mouse_one_b,buttonbase,menu,avoid,$
                       number,curr,ix,psel_menu,repet,select,ids
  
  pselect_s = {PSELECT_S, btext:'',mtext:'',uvalue:'',flags:0}
  
  avail = ([1,2,4])(number-1)
  title = (['1:','2:','3:'])(number-1)
  
  ix = WHERE((menu(*).avail AND avail) NE 0,N)
  IF N EQ 0 THEN $
     MESSAGE,"There MUST be an option for every button (use dummy values)"
  
  psel_menu = REPLICATE({pselect_s},N)
  psel_menu(*).btext = menu(ix).btext
  psel_menu(*).mtext = menu(ix).mtext
  psel_menu(*).uvalue = menu(ix).action
  psel_menu(*).flags = menu(ix).flags
  
  repet = [(menu(ix).avail AND 8) EQ 8]
  
  ;; The default  one is the first selectable
  selectable = WHERE(NOT psel_menu(*).flags,count)
  IF count EQ 0 THEN BEGIN
     MESSAGE,"No options are selectable for mouse button "+trim(number)+$
        ".  Use dummy values."
  END
  
  curr = selectable(0)
  IF total(curr EQ avoid) NE 0 THEN curr = (SHIFT(selectable,-1))(0)
  IF total(curr EQ avoid) NE 0 THEN curr = (SHIFT(selectable,-2))(0)
     
  select = cw_pselect(buttonbase,title,psel_menu,IDS=IDS,initial=curr)
  
  ids = ids(1:*)
END



FUNCTION cw_mouse,base,menu,release=release,motion=motion,enable=enable,$ $
                  disable=disable,title=title
  ;;        
  ;; Usage.
  ;;
  IF N_PARAMS() LT 2 THEN MESSAGE,"Use: ID=CW_MOUSE(BASE,MENU)"
  
  ;;
  ;; Defaults
  ;;
  default,release,['RELEASE1','RELEASE2','RELEASE3']
  default,motion,'MOTION'
  default,disable,''
  default,enable,''
  default,title,'Editable mouse buttons'
  
  ;;
  ;; Parameter type checking
  ;; 
  parcheck,base,1,typ(/lon),0,'BASE'
  parcheck,menu,1,typ(/stc),1,'MENU'
  parcheck,release,0,typ(/str),1,'RELEASE'
  parcheck,motion,0,typ(/str),0,'MOTION'
  parcheck,disable,0,typ(/str),[0,1],'DISABLE'
  parcheck,enable,0,typ(/str),[0,1],'ENABLE'
  
  IF tag_names(menu,/struct) NE 'CW_MOUSE_S' THEN $
     MESSAGE,"OPTIONS must be an array of {CW_MOUSE_S}"
  
  IF N_ELEMENTS(release) EQ 1 THEN  $
     release = REPLICATE(release(0),3)
  
  IF N_ELEMENTS(release) NE 3 THEN  $
     MESSAGE,"RELEASE array must have 3 elements"
  
  ;; Internal base
  IF since_version('4.0') THEN sp = 1 ELSE sp = 0
  
  cw_id = Widget_BASE(base,/column, $
                      event_pro     ='cw_mouse_event',$ 
                      pro_set_value ='cw_mouse_set_value',$
                      func_get_value='cw_mouse_get_value',$
                      space=sp, xpad=sp, ypad=sp, frame=1)  
  
  label = Widget_LABEL(cw_id,value=title)
  
  buttonb = WIDGET_BASE(cw_id,/row,space=sp,xpad=sp,ypad=sp,frame=0)
  
;
; Which options are available on each mouse button
;
  
  ;;
  ;; BUTTON 1
  ;;
  cw_mouse_one_b,buttonb,menu,[-1], $
     1,curr1,ix1,psel_menu1,repeat1,select1,button1
  
  ;;
  ;; Button 2
  ;; 
  cw_mouse_one_b,buttonb,menu,[curr1], $
     2,curr2,ix2,psel_menu2,repeat2,select2,button2
  
  ;;
  ;; Button 3
  ;;
  cw_mouse_one_b,buttonb,menu,[curr1,curr2], $
     3,curr3,ix3,psel_menu3,repeat3,select3,button3
  
  ;; Never trust the user to make sane moves :-)
  maxn = MAX([N_ELEMENTS(menu),N_ELEMENTS(enable),N_ELEMENTS(disable)])
  
  disp = { release:release,$    ; These are alterable through set_value
           motion :motion,$     ; Return value for MOTION events
           enable:STRARR(maxn),$ ; Enable dummy -- avoid
                                ; copy_tag_values problem
           disable:STRARR(maxn),$; Disable dummy
           press:0 $            ; Currently pressed button.
         }                      
  
  disp.enable(0:N_ELEMENTS(enable)-1) = enable
  disp.disable(0:N_ELEMENTS(disable)-1) = disable

  status = {current:[curr1,curr2,curr3],$  ; Current selection
            disp : disp,$                     ; Alterable values
            psel_menu1:psel_menu1,$
            repeat1:repeat1,$
            select1:select1,$
            button1:button1,$
            psel_menu2:psel_menu2,$
            repeat2:repeat2,$
            select2:select2,$
            button2:button2,$
            psel_menu3:psel_menu3,$
            repeat3:repeat3,$
            select3:select3,$
            button3:button3 $
           }
  
  cw_mouse_enable,status,enable,disable
  
  Widget_CONTROL,cw_id,Set_UVALUE=status
  RETURN,cw_id
END


