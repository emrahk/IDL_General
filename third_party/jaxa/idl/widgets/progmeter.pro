;+
; NAME:
;     PROGMETER
; PURPOSE:
;     A widget that displays a progress meter with a color bar
;     that grows horizontally to indicate what percentage of a task has
;     been completed.  The percentage is also written as text.  The
;     window title can be set, and an optional cancel button with
;     settable text may be shown.
; CATEGORY:
;     OVRO SPAN UTILITY
; CALLING SEQUENCE:
;     id     = progmeter(/INIT,[GROUP=group][,LABEL=label]$
;                         [,BUTTONTEXT=buttontext])
;     status = progmeter(id,value)
;     status = progmeter(id,/DESTROY)
; INPUTS:
;     id	the widget ID returned by a previous, initializing
;                  call to PROGMETER (that used the /INIT switch).
;                  This input is ignored if INIT keyword is set.
;     value	the new value to set the widget to, ranging from
;                  0 to 1 (0=0% complete, 1=100% complete).
;                  This input is ignored if INIT keyword is set.
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
;     init      a keyword switch that governs which of two calling
;                  sequences is being used.  If set, a new widget is
;                  created.  If not set, an existing widget is to be
;                  updated.
;     destroy	a keyword switch that destroys the widget created by
;                  a previous call to PROGMETER (that used the /INIT switch)
;     group     the top base id of the calling program, so that the widget
;                  will be destroyed if the calling program exits.
;                  This input is ignored if INIT keyword is not set.
;     label     an optional title for the progress meter window.  If
;                  omitted, the title "Percent Complete" is used.
;                  This input is ignored if INIT keyword is not set.
;     buttontext
;               an optional text for a button, such as a cancel button
;                  to interrupt the process whose progress is being shown.
;                  If omitted, no button is present.  If set and the user
;                  clicks on the button an event is generated.  To detect
;                  the event, call WIDGET_EVENT as discussed below.
;                  This input is ignored if INIT keyword is not set.
;     colorbar  an optional color for bar other than white
; ROUTINES CALLED:
; OUTPUTS:
;     id	the widget id of the compound widget (only when INIT
;                  keyword is set).
;     status	the status of the cancel button (only when INIT keyword
;                  is not set).  If the cancel button has been pressed,
;                  status='Cancel' and if not an empty string ('') is returned.
;                  If an error in calling sequence occurs (ID or VALUE
;                  is not supplied) then status='Cancel' also.  NB: If
;                  the widget is initialize without a button, status
;                  will always be an empty string ('')
; COMMENTS:
;     To use the routine, call it with the /INIT switch to create the
;     widget, then call it repeatedly without the /INIT switch to update
;     it.  When done with the widget, it should be destroyed.  Here is
;     an example:
;
;          id = progmeter(/INIT,label='Progress Meter',button='Abort')
;          val = 0
;          for i = 0, n do begin
;             <Do something useful here>
;             val = i/(1.0*n)      ; Fraction of loop completed
;             if (progmeter(id,val) eq 'Cancel') then goto,escape
;          endfor
;          escape: status = progmeter(id,/DESTROY)
;
; SIDE EFFECTS:
; RESTRICTIONS:
;     The progress meter widget must be explicitly destroyed.
; MODIFICATION HISTORY:
;     Written 28-Feb-1997 by Dale E. Gary
;-

;-----------------------------------------------------------------
; This is a helper procedure called by PROGMETER when setting the
; value of the widget.  It actually draws the proportional bar and
; writes a label in XOR mode onto the bar.

pro progmeter_setvalue, id, value

   ; Make sure value is only between 0 and 1
   per = value<1>0

   ; Get state variables so that draw window id is known
   stash = WIDGET_INFO(id,/CHILD)
   WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY

   ; Set the draw window as the current window, erase it and draw
   ; the bar using normalized coordinates
   wset,state.win
   erase

   ; Handle some annoying differences between UNIX and PC behavior.
   ; For UNIX, set font to default hardware font.  I have found by
   ; trial and error that XOR only works for vector fonts on Win NT,
   ; so cannot use hardware default font on PC.  Also, setting color=0
   ; in XOR mode gives white on UNIX, but black on PC, so the color
   ; must be set differently on the two -- ARRGH.

   old_font = !p.font
   !p.font = 0
   white=!d.table_size-1
   if n_elements(color) eq 0 then color=white
   if (strlowcase(os_family()) eq 'shit') then begin
      ; Set graphics mode to XOR and draw bar (XOR will make it contrast with bgnd)
      device,set_gr=6

      polyfill,[0,per,per,0], [0,0,1,1], /norm,color=0

      ; Write out the percent complete in the appropriate font.  I have found
      ; that vector fonts look lousy in XOR mode unless the font is decently
      ; large, so set charsize to 2.  In UNIX, this is ignored because we are
      ; using the default hardware font.

      xyouts, 0.5,0.2,/norm,charsize=2,$
          strcompress(fix(per*100))+'%',align=0.5,color=0
      device,set_gr=3

   endif else begin

      polyfill,[0,per,per,0], [0,0,1,1], /norm, color=white

      ; Write out the percent complete in the appropriate font.  I have found
      ; that vector fonts look lousy in XOR mode unless the font is decently
      ; large, so set charsize to 2.  In UNIX, this is ignored because we are
      ; using the default hardware font.

      if per lt 0.5 then color = white else color = 0
      xyouts, 0.5,0.2,/norm,charsize=2,$
          strcompress(fix(per*100))+'%',align=0.5,color=color
   endelse

   !p.font=old_font

   ; Resave state variables
   WIDGET_CONTROL,stash,SET_UVALUE=state,/NO_COPY
end

;-----------------------------------------------------------------
; This is a helper function called by PROGMETER when getting the
; widget ID of the button widget.

function progmeter_getvalue, id

   stash = WIDGET_INFO(id,/CHILD)
   WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY

   ; Set the return value to the current state of the button
   ret = state.buttonid
   WIDGET_CONTROL,stash,SET_UVALUE=state,/NO_COPY

return,ret
end

;-----------------------------------------------------------------
; This is the main routine.  It consists of three separate routines,
; actually, separated by if-then clauses, one routine for each of
; the three calling sequences.  If the /INIT switch is set, the
; widget is created.  If neither /INIT nor /DESTROY switches are
; set, the value of the widget is updated and the button state is
; checked.  If the /DESTROY switch is set, the widget is destroyed.
;

function progmeter,id,value,INIT=init,DESTROY=destroy,GROUP=group,$
                   LABEL=label,BUTTONTEXT=buttontext,color=color,$
                   INPUT_TEXT=input_text

   ; Section of code to be run if /INIT keyword is *not* set

   if (not keyword_set(init)) then begin

      ; First verify that an ID was given

      if (n_elements(id) eq 0) then begin
         msg = ['No widget ID specified in call to PROGMETER.',$
                'Must first call PROGMETER with /INIT to obtain ID.']
         xack,msg
         ;ans = widget_message(msg,/error)
         return,'Cancel'
      endif

      ; ID was given, so see if /DESTROY keyword is set.  If so, destroy
      ; the widget and return

      if (keyword_set(destroy)) then begin
         xkill,id
         return,'Cancel'
      endif

      ; Neither /INIT nor /DESTROY were set, so set the value of
      ; the widget and check the status of the button (if any),
      ; then return.

      if (n_elements(value) eq 0) then begin
         msg = ['No value specified in call to PROGMETER.',$
                'Must supply a value.  See documentation.']
         xack,msg
         ;ans = widget_message(msg,/error)
         return,'Cancel'
      endif

      ; Set value and get button ID

        
      if not xalive(id) then return,'Cancel'
   ;   xshow,id
      WIDGET_CONTROL,id,SET_VALUE=value
      WIDGET_CONTROL,id,GET_VALUE=buttonid
      ret = ''

      ; If the button ID is not zero, the button exists, so check state
      ; and return 'Cancel' if it has been pressed.

      if not xalive(buttonid) then return,'Cancel'

      if (buttonid ne 0L) then begin
         quit = WIDGET_EVENT(buttonid,/nowait)
         if (quit.id eq buttonid) then ret = 'Cancel'
      endif
      return,ret
   endif

   ; If /INIT keyword was not set, the program returns to caller before
   ; reaching this point.  This is the cection of code to be run if /INIT
   ; keyword *is* set.

   ; Set some defaults if not given in calling sequence

   if (not keyword_set(label)) then label = 'Percent Complete'
   if (not keyword_set(group)) then group = 0

   ; Set the base widget, specifying my own routines to be run
   ; if WIDGET_CONTROL,GET_VALUE or SET_VALUE are called.

   mk_dfont,lfont=lfont,bfont=bfont

   base = WIDGET_BASE(/COLUMN, TITLE=label,GROUP = group, $
                      FUNC_GET_VALUE='progmeter_getvalue', $
                      PRO_SET_VALUE ='progmeter_setvalue',tlb_frame=8)
  
   if is_string(input_text) then begin
    temp=widget_base(base,/row,/align_center)
    text=widget_text(temp,font=lfont,$
     value=['    ',input_text,'   '],ysize=2+n_elements(input_text),$
     xsize=max(strlen(input_text))+2)
   endif 

   ; Set up the draw widget and optionally the button widget

   temp=widget_base(base,/row,/align_center)
   draw = WIDGET_DRAW(temp,xsize=300,ysize=25)

   if (keyword_set(buttontext)) then begin

      ; The widget button is in its own base (bbase) so that it
      ; can be smaller width than full width of main base.  Its
      ; width will be automatically adjusted to the length of the
      ; text string.

      bbase = WIDGET_BASE(base,/ROW,/ALIGN_CENTER,ysize=25)
      button = WIDGET_BUTTON(bbase,value=buttontext,UVALUE='BUTTON',font=bfont)
   endif else button = 0L      ; This signifies that button is undefined

   ; Realize (draw) them
   xrealize, base,group=group,/center

   ; Get the window id of the draw widget
   WIDGET_CONTROL,draw,GET_VALUE=win

   ; Save some info that will be needed in the other functions
   state = {win:win, buttonid:button}
   WIDGET_CONTROL, WIDGET_INFO(base, /CHILD), SET_UVALUE=state, /NO_COPY

   ; The widget is created and drawn to the screen, so return the base
   ; ID so that the widget can be accessed by later calls to update it
   ; or destroy it.

   return,base

end
