;+
; NAME:
;   cw_label
;
; PURPOSE:
;   This compound widget function handles a label and an editable text widget, with built-in Default and None
;   options. Useful for user-controlled plot labels, where there is usually a default label, a user-supplied label, or no label.
;   If a null string ('') or 'default (case-insensitive) is entered into the text string, then the 
;     value displayed is 'Default' and the value returned by the compound widget is ''.
;   If a blank string (' ') or 'none (case-insenstivie) is entered into the text string, then the 
;     value displayed is 'None', and the value returned by the compound widget is ' '.
;   Otherwise the value displayed and returned is whatever string the user typed. 
;
; CATEGORY:
;   Compound Widget.
;
; CALLING SEQUENCE:
;   Result = cw_label(Parent)
;
; INPUTS:
;   Parent: The widget ID of the widget's parent.
;
; KEYWORD PARAMETERS:
;   EVENT_FUNC:    The name of an optional user-supplied event function
;           for events. This function is called with the return
;           value structure, and
;           follows the conventions for user-written event
;           functions.
;   TITLE:  A string containing the text to be used as the label for the
;       field.  The default is "Input Field:".
;
;   VALUE:  The initial value in the text widget.  
;
;   UVALUE: A user value to assign to the field.  This value
;       can be of any type.
;
;   UNAME:   A user supplied string name to be stored in the
;       widget's user name field.
;
;   FRAME:  The width, in pixels, of a frame to be drawn around the
;       entire field cluster.  The default is no frame.
;
;RETURN_EVENTS: Set this keyword to make widget return an event when a
;       <CR> is pressed in a text field.  The default is
;       not to return events.  Note that the value of the text field
;       is always returned when the WIDGET_CONTROL, field, GET_VALUE=X
;       command is used.
;
;   ALL_EVENTS: Like RETURN_EVENTS but return an event whenever the
;       contents of a text field have changed.
;
;   COLUMN: Set this keyword to center the label above the text field.
;       The default is to position the label to the left of the text
;       field.
;
;   ROW:    Set this keyword to position the label to the left of the text
;       field.  This is the default.
;
;   XSIZE:  An explicit horizontal size (in characters) for the text input
;       area.  The default is to let the window manager size the
;       widget.  Using the XSIZE keyword is not recommended.
;
;   YSIZE:  An explicit vertical size (in lines) for the text input
;       area.  The default is 1.
;
;   FONT:   A string containing the name of the X Windows font to use
;       for the TITLE of the field.
;
;    FIELDFONT: A string containing the name of the X Windows font to use
;       for the TEXT part of the field.
;
;   NOEDIT: Normally, the value in the text field can be edited.  Set this
;       keyword to make the field non-editable.
;
; OUTPUTS:
;   This function returns the widget ID of the newly-created cluster.
;
; COMMON BLOCKS:
;   None.
;
; PROCEDURE:
;   Create the widgets, set up the appropriate event handlers, and return
;   the widget ID of the newly-created compound widget.
;
; EXAMPLE:
;   Run cw_label_example to see an example.  A small widget will pop up. Change the value of the text field and
;   press return.  (Try entering an blank string (single space), and a null string (nothing).) Press exit to end example.
;
; MODIFICATION HISTORY:
;  Kim Tolbert.  Extracted from cw_field and modified to only work for strings, and to 
;  assume that null strings mean a 'default' value for the field, and blank strings mean no value
;  'none' for the field.
;
;-

pro cw_label_example

base = WIDGET_BASE(/column)
value='Test value'
field = cw_label(base, TITLE="Label: ", value=value, uvalue='label', /return_events, /FRAME)
tmp = widget_button(base, value='exit', uvalue='exit')
WIDGET_CONTROL, base, /REALIZE
widget_control, base, set_uvalue={field: field}
xmanager, 'cw_label_example', base, /no_block
end

pro cw_label_example_event, event
widget_control,  event.top, get_uvalue=state
widget_control, event.id, get_uvalue=uvalue
if uvalue eq 'exit' then widget_control, event.top, /destroy else begin
  widget_control, state.field, get_value=value
  help, value[0]
  widget_control, state.field, set_value=value
endelse
end


;   Procedure to set the value of a cw_label
;
PRO cw_label_SET, Base, Value

    COMPILE_OPT hidden

    svalue  = value     ; Prevent alteration from reaching back to caller
    IF value eq '' THEN svalue = 'Default'
    If value eq ' ' then svalue = 'None'

    Child   = WIDGET_INFO(Base, /CHILD)
    WIDGET_CONTROL, Child, GET_UVALUE=State, /NO_COPY
    WIDGET_CONTROL, State.TextId, $
        SET_VALUE=STRTRIM(sValue,2)
    WIDGET_CONTROL, Child, SET_UVALUE=State, /NO_COPY
END

;
;   Function to get the value of a cw_label
;
FUNCTION cw_label_GET, Base

    COMPILE_OPT hidden

    Child   = WIDGET_INFO(Base, /CHILD)
    WIDGET_CONTROL, Child, GET_UVALUE=State, /NO_COPY
    WIDGET_CONTROL, State.TextId, GET_VALUE=Value

    Ret = value
    strlow_value = strlowcase(value)
    IF strlow_value eq 'default' then ret = ''
    If strlow_value eq 'none' or strlow_value eq 'blank' then ret = ' '

    WIDGET_CONTROL, Child, SET_UVALUE=State, /NO_COPY
    RETURN, Ret
END

FUNCTION cw_label_EVENT, Event

    COMPILE_OPT hidden

    StateHolder = WIDGET_INFO(Event.Handler, /CHILD)
    WIDGET_CONTROL, StateHolder, GET_UVALUE=State, /NO_COPY

    ;   At this point, we need to look at what kind of field
    ;   we have:

    Altered = 0

    ;   If the user has types <CR> then update field


    ;   All delete/add char events effect the contents of
    ;   a string. <CR> is considered special.
    IF Event.Type GE 0 AND Event.Type LE 2 THEN Altered = 1
    IF Event.Type EQ 0 THEN $
       Altered  = 1 + (Event.Ch EQ 10b)

    Ret = 0

    ;   If the entry has been modified or <CR> was hit
    ;   And the user is interested in all event or
    ;   Just <CR> AND <CR> was the cause of update then
    ;   send it
    IF State.Update NE 0 AND $
       Altered GE State.Update THEN BEGIN

    WIDGET_CONTROL, State.TextId, GET_VALUE=Value

    Ret = {         $
        ID: Event.Handler,  $
        TOP: Event.Top,     $
        HANDLER: 0L,        $
        VALUE: Value,      $        
        UPDATE: Altered - 1 $   ; 0=any,1=CR
    }
    ENDIF

    efun = State.efun
    update = State.Update

    ;   Restore our state structure
    WIDGET_CONTROL, StateHolder, SET_UVALUE=State, /NO_COPY
    if efun eq '' then $
        return, ret $
    else begin
        IF update NE 0 AND $
            Altered GE update THEN BEGIN
            ; only call event handler if we are returning an event structure
            return, CALL_FUNCTION(efun, ret)
        ENDIF ELSE return, ret
    endelse
END


FUNCTION cw_label, Parent, COLUMN=Column, ROW=Row, $
    EVENT_FUNC = efun, $    
    FONT=LabelFont, FRAME=Frame, TITLE=Title, UVALUE=UValue, VALUE=TextValueIn, $
    RETURN_EVENTS=ReturnEvents, ALL_EVENTS=AllUpdates, $
    FIELDFONT=FieldFont, NOEDIT=NoEdit, TEXT_FRAME=Text_Frame, $
    XSIZE=XSize, YSIZE=YSize, UNAME=uname, TAB_MODE=tab_mode
;   FLOOR=vmin, CEILING=vmax

    ;   Examine our keyword list and set default values
    ;   for keywords that are not explicitly set.

    Column      = KEYWORD_SET(Column)
    Row         = 1 - Column
    AllEvents       = 1 - KEYWORD_SET(NoEdit)

    ; Enum Update { None, All, CRonly }
    Update      = 0
    IF KEYWORD_SET(AllUpdates) THEN Update  = 1
    IF KEYWORD_SET(ReturnEvents) THEN Update    = 2

    IF N_ELEMENTS(efun) LE 0 THEN efun = ''
    IF N_ELEMENTS(Title) EQ 0 THEN Title='Input Field:'
    TextValue = (N_ELEMENTS(TextValueIn) gt 0) ? TextValueIn : ''
    ; Convert non-string values to strings.
    if (SIZE(TextValue, /TNAME) ne 'STRING') then $
        TextValue = STRTRIM(TextValue,2)
    IF N_ELEMENTS(YSize) EQ 0 THEN YSize=1
    IF N_ELEMENTS(uname) EQ 0 THEN uname='cw_label_UNAME'

    ;   Build Widget

    Base    = WIDGET_BASE(Parent, ROW=Row, COLUMN=Column, UVALUE=UValue, $
            EVENT_FUNC='cw_label_EVENT', $
            PRO_SET_VALUE='cw_label_SET', $
            FUNC_GET_VALUE='cw_label_GET', $
            FRAME=Frame, UNAME=uname )

    if ( N_ELEMENTS(tab_mode) ne 0 ) then $
        WIDGET_CONTROL, Base, TAB_MODE = tab_mode

    if strlen(Title) gt 0 then $
        Label   = WIDGET_LABEL(Base, VALUE=Title, FONT=LabelFont, $
            UNAME=uname+'_LABEL')
    Text    = WIDGET_TEXT(Base, VALUE=TextValue, $
            XSIZE=XSize, YSIZE=YSize, FONT=FieldFont, $
            ALL_EVENTS=AllEvents, $
            EDITABLE=(AllEvents), $
            FRAME=Text_Frame , $
            UNAME=uname+'_TEXT')

    ; Save our internal state in the first child widget
    State   = {     $
    efun: efun,         $
    TextId:Text,        $
    Title:Title,        $
    Update:Update       $
    }
    WIDGET_CONTROL, WIDGET_INFO(Base, /CHILD), SET_UVALUE=State, /NO_COPY
    RETURN, Base
END
