;+ ***********************************************************************
; NAME:
;	CW_SWITCH
;
; PURPOSE:
;	Compound WIDGET for switch betewen different choices
;
; CATEGORY:
;	Compound Widget
;
; CALLING SEQUENCE:
;	Result = CW_SWITCH(Parent, Names)
;
; INPUTS:
;	PARENT	ID of the parent widget
;
;	NAMES	String array giving the name of each choice.
;	
; KEYWORD PARAMETERS:
;
;	VALUE	Initial texte written in the widget
;
;	UVALUE	 The "user value" to be assigned to the widget.
;
;	XSIZE	The size of the widget (pixels)
;
;	FRAME	Size of the frame around the widget
;
; OUTPUTS:
;	RESULT	ID of the created widget
;
;	On return the widget generates an event structure
;		ret = { ID:base, TOP:ev.top, HANDLER:0L, 
;				VALUE:index of the choice }
;
; COMMON BLOCKS:
;	No
;
; MODIFICATION HISTORY:	(bonmartin@obspm.fr)
;	12/11/98	Repris des programmes XHELIO (JB)
;-*******************************************************************


FUNCTION CW_SWITCH_GET_VALUE,id,value

stash = WIDGET_INFO ( id , /CHILD )

WIDGET_CONTROL, stash, GET_UVALUE = state;,/NO_COPY
ret = state.value
WIDGET_CONTROL, stash, SET_UVALUE = state;,/NO_COPY
RETURN, ret
END

;*********************************************************

PRO CW_SWITCH_SET_VALUE,id,value

stash = WIDGET_INFO ( id , /CHILD )
WIDGET_CONTROL, stash, GET_UVALUE = state;,/NOCOPY
WIDGET_CONTROL, state.info_button, SET_VALUE = state.values(value-1)
state.value = value
WIDGET_CONTROL, stash, SET_UVALUE = state;,/NOCOPY
END

;*********************************************************
FUNCTION CW_SWITCH_EVENT,ev

base = ev.handler                         ; we get back useful information 
stash = WIDGET_INFO ( base, /CHILD)       ; stored in the first child of
WIDGET_CONTROL, stash, GET_UVALUE = state;,/NO_COPY 
                                          ; the event handler ( the base of
                                          ; CW_SWITCH )

; If there is any event we make the gadget to cycle to the next
; position. If it was previously at the last position, we go
; back to the first one.

IF ( state.value EQ state.nb ) THEN BEGIN
    state.value = 1
ENDIF ELSE BEGIN
    state.value = state.value + 1                
ENDELSE

;         We display the change on the button :


WIDGET_CONTROL, state.info_button,SET_VALUE=state.values (state.value-1) 

ret = { CW_SWITCH_EVENT, ID:base, TOP:ev.top, $
        HANDLER:0L, VALUE:state.value }
WIDGET_CONTROL, stash, SET_UVALUE = state;,/NO_COPY

;       We send back an event with the new value
RETURN, ret
END

;********************************************************

; A new kind of compound widget : The Cycle Widget
;     version 1.00 by Rozier de Linage Manuel / efrei.fr

;*******************************************************
FUNCTION CW_SWITCH,parent,values,VALUE=value,UVALUE=uvalue,$
                          XSIZE=xsize,FRAME=frame

IF NOT KEYWORD_SET ( uvalue ) THEN uvalue = 0
IF NOT KEYWORD_SET ( value ) THEN value = 1
IF NOT KEYWORD_SET ( frame ) THEN frame = 0


;     bitmap of the cycle button

design =     [                $
                [000B, 000B], $
                [000B, 000B], $
                [224B, 001B], $
                [248B, 003B], $
                [252B, 007B], $
                [188B, 143B], $
                [014B, 223B], $
                [006B, 254B], $
                [006B, 252B], $
                [012B, 248B], $
                [012B, 252B], $
                [024B, 254B], $
                [000B, 240B], $
                [000B, 000B], $
                [000B, 000B], $
                [000B, 000B]  $                
                               ]

;   We declare base as the event handler
;   And we associate CW_SWITCH_GETVALUE and CW_SWITCH_SETVALUE to
;   GET_VALUE and SET_VALUE of WIDGET_CONTROL for this COMPOUND
;   WIDGET.
           

base = WIDGET_BASE ( parent,UVALUE=uvalue, $
                     EVENT_FUNC = 'CW_SWITCH_EVENT', $
                     FUNC_GET_VALUE = 'CW_SWITCH_GET_VALUE', $
                     PRO_SET_VALUE = 'CW_SWITCH_SET_VALUE', $
                     /ROW,FRAME=frame)

cycle_button = WIDGET_BUTTON ( base,VALUE = design )


nb = N_ELEMENTS(values)
IF ( (value GT nb) OR (value LT 1) ) THEN BEGIN
   print,'default value out of array range'
   RETURN, 0
ENDIF


;     We set the button with its default value

default = values(value-1)
IF NOT KEYWORD_SET(XSIZE) THEN $
info_button = WIDGET_BUTTON (base,VALUE = default)$
ELSE $
info_button = WIDGET_BUTTON (base,VALUE = default,XSIZE=xsize)





;     We store useful information in the state variable to avoid COMMONs.

state = { info_button : info_button , value : value ,values : values, $
          nb:nb }

WIDGET_CONTROL, WIDGET_INFO ( base, /CHILD ), SET_UVALUE = state;,/NO_COPY


RETURN, base      ; A compound widget always return is main base id.
END
