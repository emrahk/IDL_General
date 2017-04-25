
;+
; NAME:
;	CW_ALOGSLIDER
;
; PURPOSE:
;	The standard slider provided by the WIDGET_SLIDER() function is
;	integer only. This compound widget provides a logarithmic floating point
;	slider.
;
; CATEGORY:
;	Compound widgets.
;
; CALLING SEQUENCE:
;	widget = CW_ALOGSLIDER(Parent)
;
; INPUTS:
;       Parent:		The ID of the parent widget.
;
; KEYWORD PARAMETERS:
;	DRAG:		Set this keyword to zero if events should only
;			be generated when the mouse is released. If it is
;			non-zero, events will be generated continuously
;			when the slider is adjusted. Note: On slow systems,
;			/DRAG performance can be inadequate. The default
;			is DRAG=0.
;       EDIT:		Set this keyword to make the slider label be
;			editable. The default is EDIT=0.
;	FORMAT:		Provides the format in which the slider value is
;			displayed. This should be a format as accepted by
;			the STRING procedure. The default is FORMAT='(G13.6)'
;	FRAME:		Set this keyword to have a frame drawn around the
;			widget. The default is FRAME=0.
;	MAXIMUM:	The maximum value of the slider. The default is 
;			MAXIMUM=100.
;	MINIMUM:	The minimum value of the slider. Must be greater than 0.
;			The default is Maximum / 1e6.
;	SUPPRESS_VALUE:	If true, the current slider value is not displayed.
;			The default is SUPPRESS_VALUE=0.
;	TITLE:		The title of slider. (The default is no title.)
;	UVALUE:		The user value for the widget.
;	VALUE:		The initial value of the slider
;	VERTICAL:	If set, the slider will be oriented vertically.
;			The default is horizontal.
;	XSIZE:		For horizontal sliders, sets the length.
;	YSIZE:		For vertical sliders, sets the height.
;
; OUTPUTS:
;       The ID of the created widget is returned.
;
; SIDE EFFECTS:
;	This widget generates event structures containing a field
;	named value when its selection thumb is moved. This is a
;	floating point value.
;
; PROCEDURE:
;	WIDGET_CONTROL, id, SET_VALUE=value can be used to change the
;		current value displayed by the widget.
;
;	WIDGET_CONTROL, id, GET_VALUE=var can be used to obtain the current
;		value displayed by the widget.
;
; MODIFICATION HISTORY:
;	April 2, 1992, SMR and AB
;		Based on the RGB code from XPALETTE.PRO, but extended to
;		support color systems other than RGB.
;	5 January 1993, Mark Rivers, Brookhaven National Labs
;		Added EDIT keyword. 
;       7 April 1993, AB, Removed state caching.
;	28 July 1993, ACY, set_value: check labelid before setting text.
;	20 FEB 1994, RAS, BASED on cw_fslider
;-


PRO alogslider_set_value, id, value

  ; Set the value of both the slider and the label
  ON_ERROR, 2						;return to caller
  value = value

  stash = WIDGET_INFO(id, /CHILD)
  WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY

;convert number to an integer
  WIDGET_CONTROL, state.slideid, $
	SET_VALUE = 1000000. * $
		alog (float(value) / state.bot) / alog(state.top / state.bot)
  IF (state.labelid NE 0) THEN $
  	WIDGET_CONTROL, state.labelid, $
		SET_VALUE = STRING(FLOAT(value), format=state.format)

  WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY
END



FUNCTION alogslider_get_value, id

  ; Return the value of the slider
  ON_ERROR, 2						;return to caller

  stash = WIDGET_INFO(id, /CHILD)
  WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY

  WIDGET_CONTROL, state.slideid, GET_VALUE = tmp
;convert the widget position, to the value, the position is log scaled
  ret = exp(tmp / 1000000. * alog(state.top / state.bot) ) * state.bot

  WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY 

  return, ret
END


;-----------------------------------------------------------------------------

FUNCTION alogslide_event, ev

  ; Retrieve the structure from the child that contains the sub ids
  parent=ev.handler
  stash = WIDGET_INFO(parent, /CHILD)
  WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY


  ; See which widget was adjusted, the slider or the label

  if (ev.id eq state.slideid) then begin
    ; Get the non-adjusted value
    WIDGET_CONTROL, state.slideid, GET_VALUE = nonadj
    ; Compute the floating point value
    value = exp(nonadj / 1000000. * alog(state.top / state.bot) )* state.bot
    drag = ev.drag
    ; Update label
    IF (state.labelid NE 0) THEN $
      WIDGET_CONTROL, state.labelid, $
           SET_VALUE=STRING(value, format=state.format)

  endif else if (ev.id eq state.labelid) then begin

    WIDGET_CONTROL, state.labelid, GET_VALUE = tmp

    value = float(tmp(0))
    value = value > state.bot
    value = value < state.top
    ;Update the slider, set new value
    WIDGET_CONTROL, state.slideid, $
	SET_VALUE = 1000000. * $
		(alog(value/state.bot)) / (alog(state.top / state.bot))
    drag = 0
    ; Update the label so it has desired format
    WIDGET_CONTROL, state.labelid, $
           SET_VALUE=STRING(value, format=state.format)
  endif

  WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY
  RETURN, { ID:parent, TOP:ev.top, HANDLER:0L, VALUE:value, DRAG:drag }
END

;-----------------------------------------------------------------------------

FUNCTION cw_alogslider, parent, $
		DRAG = drag, $
                EDIT = edit, $
		FRAME = frame, $
		MAXIMUM = max, $
		MINIMUM = min, $
		SUPPRESS_VALUE = sup, $
		TITLE = title, $
		UVALUE = uval, $
		VALUE = val, $
		VERTICAL = vert, $
		XSIZE = xsize, $
		YSIZE = ysize, $
		FORMAT=format

  IF (N_PARAMS() EQ 0) THEN MESSAGE, 'Incorrect number of arguments'

  ON_ERROR, 2						;return to caller

  ; Defaults for keywords
  IF NOT (KEYWORD_SET(drag))  THEN drag = 0
  IF NOT (KEYWORD_SET(edit))  THEN edit = 0
  IF NOT (KEYWORD_SET(frame)) THEN frame = 0
  IF N_ELEMENTS(max) EQ 0     THEN max = 100.0
  IF N_ELEMENTS(min) EQ 0     THEN min = 0.001 else $
	min = min > (max / 1.e6)
  IF NOT (KEYWORD_SET(sup))   THEN sup = 0
  IF NOT (KEYWORD_SET(title)) THEN title = ""
  IF NOT (KEYWORD_SET(uval))  THEN uval = 0
  IF NOT (KEYWORD_SET(val))   THEN val = min
  IF NOT KEYWORD_SET(format)  THEN format='(G13.6)'

  state = {slideid:0L, labelid:0L, top:max, bot:min, format:format }

  ; Motif 1.1 and newer sliders react differently to XSIZE and YSIZE
  ; keywords than Motif 1.0 or OpenLook. These defs are for horizontal sliders
  version = WIDGET_INFO(/version)
  newer_motif = (version.style eq 'Motif') and (version.release ne '1.0')

  ; The sizes of the parts depend on keywords and whether or not the
  ; float slider is vertical or horizontal
  ;these are display specific and known to be inherently evil
  sld_thk = 16
  chr_wid = 7
  IF (KEYWORD_SET(vert)) THEN BEGIN
    if (newer_motif) then begin
      if (not KEYWORD_SET(xsize)) then xsize = 0
    endif else begin
      title_len = STRLEN(title) * chr_wid
      xsize = (sld_thk * 1.4) + title_len	; Take label into account
    endelse
    IF NOT (KEYWORD_SET(ysize)) THEN ysize = 100
    l_yoff = ysize / 2
  ENDIF ELSE BEGIN					;horizontal slider
    vert = 0
    tmp = not keyword_set(xsize)
    if (newer_motif) then begin
      if (tmp) then xsize = 0
      IF NOT (KEYWORD_SET(ysize)) THEN ysize = 0
    endif else begin
      if (tmp) then xsize = 100
      IF (TITLE NE '') THEN sld_thk = sld_thk + 21
      ysize = sld_thk		; Make the slider not waste label space
    endelse
    l_yoff = 0
  ENDELSE

  if (vert) then begin
    mainbase = WIDGET_BASE(parent, FRAME = frame, /ROW)
    labelbase = WIDGET_BASE(mainbase)
  endif else begin
    mainbase = WIDGET_BASE(parent, FRAME = frame, /COLUMN)
    labelbase = mainbase
  endelse
  WIDGET_CONTROL, mainbase, SET_UVALUE = uval, EVENT_FUNC = 'alogslide_event', $
	PRO_SET_VALUE='ALOGSLIDER_SET_VALUE', $
	FUNC_GET_VALUE='ALOGSLIDER_GET_VALUE'



  IF (sup EQ 0) THEN $
    ; Only build the label if suppress_value is FALSE
    state.labelid = WIDGET_TEXT(labelbase, YOFFSET = l_yoff, $
		VALUE = STRING(FLOAT(val), format=state.format), $
                edit=edit) $
  ELSE state.labelid = 0

    state.slideid = WIDGET_SLIDER(mainbase, $
		TITLE = TITLE, $
		XSIZE = xsize, $
		YSIZE = ysize, $
		/SUPPRESS_VALUE, $
		MINIMUM = 0, $
		MAXIMUM = 1000000, $
		VALUE = 1000000. * $
			alog( val / state.bot) / $
			alog(state.top / state.bot), $
		VERTICAL = vert, $
		DRAG=drag, $
		SCROLL=10000)

  
  WIDGET_CONTROL, WIDGET_INFO(mainbase, /CHILD), SET_UVALUE=state, /NO_COPY
  RETURN, mainbase

END
