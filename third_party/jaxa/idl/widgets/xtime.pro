;+
; Project     :	ORBITER - SPICE
;
; Name        :	XTIME
;
; Purpose     :	Widget program to edit a time string
;
; Category    :	Widgets, Time
;
; Explanation : A widget program to edit a time string.  The widget displays
;               hour, minute, second, and millisecond fields which can be
;               edited by the user.  Before the edited result can be accepted,
;               it must first be checked for validity.  Can be combined with
;               XCALENDAR to select a complete date/time specification.
;
; Syntax      :	XTIME, TIME
;
; Examples    :	TIME = '11:23:54.759'
;               XTIME, TIME
;
; Inputs      :	TIME    = A time string with the format "HH:MM:SS.mmm", or any
;                         time format supported by ANYTIM2UTC.  If the input
;                         time includes a date, then it will be stripped out of
;                         the output.
;
; Opt. Inputs :	None
;
; Outputs     :	The edited time is returned in place.
;
; Opt. Outputs:	None
;
; Keywords    :	GROUP_LEADER = Group leader ID of widget calling XTIME
;
;               MODAL   = If set, then events to the calling widget are blocked
;                         until XTIME exits.
;
; Calls       :	VALID_NUM, GET_UTC, ANYTIM2UTC, XACK, UTC2STR
;
; Common      :	None
;
; Restrictions:	None
;
; Side effects:	None
;
; Prev. Hist. :	None
;
; History     :	Version 1, 5-Jan-2015, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro xtime_event, event
;
;  If the window close box has been selected, then kill the widget.
;
if (tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST') then $
  goto, destroy
;
;  Get the current state structure.
;
widget_control, event.id, get_uvalue=uvalue
widget_control, event.top, get_uvalue=sstate, /no_copy
case uvalue of
;
;  If the check button was pressed, then check that the time fields correspond
;  to a valid time.  If there's a problem, simply skip to the end.
;
    'CHECK': begin
        widget_control, sstate.whour, get_value=hour
        if hour eq '' then hour = '00'
        if not valid_num(hour) then begin
            xack, '"' + hour + '"' + ' for HOUR is not a valid number'
            goto, exit_point
        endif
        hour = fix(hour)
        if (hour lt 0) or (hour gt 23) then begin
            xack, '"' + ntrim(hour) + '"' + $
                  ' for HOUR is not between 0 and 23'
            goto, exit_point
        endif
        widget_control, sstate.whour, set_value=string(hour, format='(I2.2)')
;
        widget_control, sstate.wminute, get_value=minute
        if minute eq '' then minute = '00'
        if not valid_num(minute) then begin
            xack, '"' + minute + '"' + ' for MINUTE is not a valid number'
            goto, exit_point
        endif
        minute = fix(minute)
        if (minute lt 0) or (minute gt 59) then begin
            xack, '"' + ntrim(minute) + '"' + $
                  ' for MINUTE is not between 0 and 59'
            goto, exit_point
        endif
        widget_control, sstate.wminute, set_value=string(minute, $
                                                         format='(I2.2)')
;
        widget_control, sstate.wsecond, get_value=second
        if second eq '' then second = '00'
        if not valid_num(second) then begin
            xack, '"' + second + '"' + ' for SECOND is not a valid number'
            goto, exit_point
        endif
        second = fix(second)
        if (second lt 0) or (second gt 60) then begin
            xack, '"' + ntrim(second) + '"' + $
                  ' for SECOND is not between 0 and 60'
            goto, exit_point
        endif
        widget_control, sstate.wsecond, set_value=string(second, $
                                                         format='(I2.2)')
;
        widget_control, sstate.wmsec, get_value=millisec
        if millisec eq '' then millisec = '000'
        if not valid_num(millisec) then begin
            xack, '"' + millisec + '"' + $
                  ' for MILLISECONDS is not a valid number'
            goto, exit_point
        endif
        millisec = fix(millisec)
        if (millisec lt 0) or (millisec gt 999) then begin
            xack, '"' + ntrim(millisec) + '"' + $
                  ' for MILLISECONDS is not between 0 and 999'
            goto, exit_point
        endif
        widget_control, sstate.wmsec, set_value=string(millisec, $
                                                       format='(I3.3)')
;
;  If no problems were encountered, then make the accept button sensitive.
;
        widget_control, sstate.wcheck, sensitive=0
        widget_control, sstate.waccept, sensitive=1
    end
;
;  If any of the fields are edited, then control the button sensitivity.
;
    'HOUR': begin
        widget_control, sstate.wcheck, sensitive=1
        widget_control, sstate.waccept, sensitive=0
    end
;
    'MINUTE': begin
        widget_control, sstate.wcheck, sensitive=1
        widget_control, sstate.waccept, sensitive=0
    end
;
    'SECOND': begin
        widget_control, sstate.wcheck, sensitive=1
        widget_control, sstate.waccept, sensitive=0
    end
;
    'MILLISEC': begin
        widget_control, sstate.wcheck, sensitive=1
        widget_control, sstate.waccept, sensitive=0
    end
;
;  If the accept button was pressed, then store the values in the state vector
;  and exit.
;
    'ACCEPT': begin
        widget_control, sstate.whour, get_value=hour
        (*sstate.pext).hour = fix(hour)
        widget_control, sstate.wminute, get_value=minute
        (*sstate.pext).minute = fix(minute)
        widget_control, sstate.wsecond, get_value=second
        (*sstate.pext).second = fix(second)
        widget_control, sstate.wmsec, get_value=millisec
        (*sstate.pext).millisecond = fix(millisec)
        goto, destroy
    end        
;
;  If the cancel button was pressed, simply exit.
;
    'CANCEL': begin
destroy:
        widget_control, event.top, /destroy
        return
    end
;
;  Handle all other events.
;
    else:                       ;Do nothing
endcase
;
exit_point:
widget_control, event.top, set_uvalue=sstate, /no_copy
;
end

;------------------------------------------------------------------------------

pro xtime, time, group_leader=group_leader, modal=modal, _extra=_extra
;
if n_elements(time) eq 0 then begin
    get_utc, time, /ccsds, /time_only
    time_orig = time
end else begin
    time_orig = time
    errmsg = ''
    time = anytim2utc(time, /ccsds, /time_only, errmsg=errmsg)
    if errmsg ne '' then begin
        time = time_orig
        xack, errmsg
        return
    endif
endelse
;
;  Set up the top base as a column widget.
;
wtopbase = widget_base(/column, group_leader=group_leader, modal=modal)
;
;  Set up buttons for accept and cancel.
;
wbutton = widget_base(wtopbase, /row)
wcheck = widget_button(wbutton, value='Check', UVALUE='CHECK', sensitive=0)
waccept = widget_button(wbutton, value='Accept', UVALUE='ACCEPT')
dummy = widget_button(wbutton, value='Cancel', UVALUE='CANCEL')
;
;  Break the time down into its separate components, and up pull-down menues
;  for the time fields.
;
ext = anytim2utc(time, /external)
wtime = widget_base(wtopbase, /row)
whour = widget_text(wtime, value=string(ext.hour, format='(I2.2)'), xsize=2, $
                    uvalue='HOUR', /EDITABLE, /ALL_EVENTS)
;
dummy = widget_label(wtime, value=':')
wminute = widget_text(wtime, value=string(ext.minute, format='(I2.2)'), $
                      xsize=2, uvalue='MINUTE', /EDITABLE, /ALL_EVENTS)
;
dummy = widget_label(wtime, value=':')
wsecond = widget_text(wtime, value=string(ext.second, format='(I2.2)'), $
                      xsize=2, uvalue='SECOND', /EDITABLE, /ALL_EVENTS)
;
dummy = widget_label(wtime, value='.')
wmsec = widget_text(wtime, value=string(ext.millisecond, format='(I3.3)'), $
                    xsize=3, uvalue='MILLISEC', /EDITABLE, /ALL_EVENTS)
;
;  Realize the widget hierarch.
;
widget_control, wtopbase, /realize
;
;  Create a pointer to the time variable--this allows the value to be returned
;  by the widget.
;
pext = ptr_new(ext)
;
;  Store the widget state in the top base.
;
sstate = {wcheck: wcheck, $
          waccept: waccept, $
          whour: whour, $
          wminute: wminute, $
          wsecond: wsecond, $
          wmsec: wmsec, $
          pext: pext}
widget_control, wtopbase, set_uvalue=sstate
;
;  Start the whole thing going.
;
xmanager, 'xtime', wtopbase, event_handler='xtime_event'
;
;  Extract the result, free the pointer, and return
;
ext = *pext
ptr_free, pext
time = utc2str(ext, /time_only)
;
return
end
