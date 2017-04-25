;+
; Project     : SOHO - CDS     
;                   
; Name        : XRECORDER
;               
; Purpose     : Tool for recording/replaying user events.
;               
; Explanation : XRECORDER is designed to record and replay demonstration
;               sessions showing the abilities of various widget programs on
;               screen, without supervision.
;
;               BASIC USE
;
;               Make sure you have compiled the modified version of XMANAGER
;               (type ".run ymanager").
;
;               Start XRECORDER (which will just register with XMANAGER and
;               then return to the prompt).
;
;               Start any event-driven widget program. Press the "Record"
;               button and start using your widget program. Press the "Stop"
;               button to stop the recording.
;
;               Now, make sure that the same widget(s) are present as when you
;               started the recording. Press "Replay" and watch your moves
;               being copied - the cursor is moved around on the screen and
;               the widget program receives the same events as during the
;               recording session.
;
;               You can also exit the XRECORDER widget, and then restart it
;               again in another IDL session (make sure it can find the
;               recorded script file). Simply start XRECORDER, start your
;               widget program, and press "Replay".
;
;               When you press the "Record" button, all events recorded will
;               be *appended* to the current recording file. Press "Reset" to
;               delete the file and start over. Press "Select new file" to
;               change to another recording/replay file.
;               
;               MODIFYING THE SCRIPT
;               
;               The recorded "script" files may be edited. For example, two
;               kinds of text comments to the viewer may be inserted:
;
;               Script lines starting with a double quote will be inserted
;               into the message area of the XRECORDER widget.
;
;               Sequences of script lines starting with a single quote will be
;               displayed by an XTEXT widget, and then killed when the next
;               event is processed.
;
;               Each script line consists of five fields:
;
;               1. The time delay (since the last event)
;               2. The XMANAGER registered name of the top level base
;               3. An identification number (for multiple instances)
;               4. A line number identifying the widget who created the event
;               5. A text describing the event structure
;
;               Note that the separator between the various fields is NOT a
;               blank character, but a string(255b)!
;
;               You may wish to edit the *first* field to modify the time
;               delay before an event goes off. The time delay is measured
;               from the time of the execution of the previous event.
;               
;               LIMITATIONS
;
;               XRECORDER works with *almost* all event-driven programs,
;               without modification, and in such a way that the programs have
;               no idea what's going on.
;
;               It will *not* work properly with programs using the CURSOR
;               procedure to receive user input.
;
;               In addition, there are at least three known problem areas:
;
;               1. Widget programs that dynamically alter their widget
;               hierarchy to create new widgets after being realized (this
;               *may* be fixed in later versions).
;
;               2. Widget programs that (re)set the event functions/procedures
;               of their "leaf" widgets (all widgets except bases).
;
;               3. Widget programs using EV = WIDGET_EVENT(ID) to catch events
;               straight after the widget hierarchy has been created,
;               *without* first allowing the main event loop in XMANAGER
;               process pending events.
;
; Use         : XRECORDER [,FILENAME] [,/START] [,/PLAY_ONLY]
;    
; Inputs      : None.
; 
; Opt. Inputs : FILENAME : The name of the recording/playback file.
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : START : Set to make XRECORDER start the playback as soon as
;                       event processing is started (usually when the next
;                       widget program is started from the IDL prompt).
;
;               PLAY_ONLY : Set to desensitize the recording/reset buttons.
;
; Calls       : break_file, default, rd_ascii, rm_file, since_version, trim,
;               xkill, xtext
;
; Common      : Uses the MANAGED common block from XMANAGER. 
;               
; Restrictions: Will not work in IDL 5.0 or later without modification.
;               Relies on the ability of having widgets that are immune to
;               modalization, so using WIDGET_BASE(/MODAL) could be a problem.
;               
; Side effects: Not too many, I hope. (None known, actually..)
;               
; Category    : Widgets
;               
; Prev. Hist. : Requested by Dave Pike.
;
; Written     : Stein Vidar Haugan, UiO, March & May 1997
;               
; Modified    : Yes.
;
; Version     : 1, 25 May 1997
;-            

;
; We must have the right version of xmanager
;
@ymanager.pro

;
; Return an event from the text that defines it.
;
FUNCTION xrecorder_make,text
  ev = 0
  
  dummy = execute("ev="+text)
  return,ev
  
END


;
; Finds widget_draw motion events that are in a more or less straight line and
; eliminates intermediate positions to minimize the number of events to be
; processed.
;
PRO xrecorder_minimize,book
  n = n_elements(book)
  IF n LT 20 THEN return
  
  pattern = '_DRAW,ID:0L,TOP:0L,HANDLER:0L,TYPE:2'
  ix = where(strpos(book,pattern) NE -1,nd)
  
 IF nd LT 10 THEN return
  
  ;; Non-deleted lines
  valid = make_array(/byte,n,value=1b)
  
  ;; Final indices of each line
  fx = lindgen(n)
  
  ;; Separator
  sep = string(255b)
  
  ;; We want to compare sequences of 3
  i = 0
  WHILE i LT nd-4 DO BEGIN
     iix0 = ix(i)
     iix1 = ix(i+1)
     iix2 = ix(i+2)
     ;; Are the next three lines contiguous in the shrunken version of the
     ;; book?
     fiix0 = fx(iix0)
     fiix1 = fx(iix1)
     fiix2 = fx(iix2)
     IF fiix0 EQ fiix1-1 AND fiix0 EQ fiix2-2 AND iix2 LT iix0+10 THEN BEGIN
        
        ;; Possibly take out the middle point
        
        ;;print,i
        ;;print,book(iix0),book(iix1),book(iix2),format='(A)'
        
        ;; Get constituent parts..
        chop0 = str_sep(book(iix0),sep)
        chop1 = str_sep(book(iix1),sep)
        chop2 = str_sep(book(iix2),sep)
        
        ;; Check times of the last two
        tlim = 0.05
        IF max([float(chop1(0)),float(chop2(0))]) GT tlim THEN GOTO,NO_GOOD
        ;;print,"Times good"
        
        ;; See if they're from the same widget (compare name, number, line)
        nnl0 = chop0(1)+chop0(2)+chop0(3)
        nnl1 = chop1(1)+chop1(2)+chop1(3)
        nnl2 = chop2(1)+chop2(2)+chop2(3)
        IF nnl0 NE nnl1 OR nnl0 NE nnl2 THEN GOTO,NO_GOOD
        ;;Print,"Names good"
        
        ;; Ok, check alignment... create event structures..
        e0 = xrecorder_make(chop0(4))
        e1 = xrecorder_make(chop1(4))
        e2 = xrecorder_make(chop2(4))
        
        ;; Get the movement
        v01 = [e1.x,e1.y] - [e0.x,e0.y]
        v12 = [e2.x,e2.y] - [e1.x,e1.y]
        
        ;; Calculate the angle
        theta = acos(total(v01*v12)/sqrt(total(v01^2)*total(v12^2)))
        ;;print,theta
        IF theta GT 0.2 THEN GOTO,NO_GOOD
        
        ;; We're through with testing, loose the middle point.
        valid(iix1) = 0b
        ;; The following lines will decrease their final index
        fx(ix(i+1):*) = fx(ix(i+1):*)-1
        ix = [ix(0:i),ix(i+2:*)]
        nd = n_elements(ix)
     END ELSE BEGIN
NO_GOOD:
        ;;print,"No good"
        IF fiix1 EQ fiix2 THEN i = i+1 $;; It's worth checking the next three
        ELSE                   i = i+2  ;; It's no sense...
     END 
     nd = n_elements(ix)
     ;;print
  END 
  book = book(where(valid))
END



PRO xrecorder_calibrate_mbar,status,topid,mbarheight
  
  oldwin = !d.window
  
  draw_id = widget_draw(topid,xsize=1,ysize=1)
  widget_control,draw_id,get_value=draw
  xrecorder_findpos,draw_id,x,y
  xrecorder_moveto,status,x,y,wave=0,/now
  
  wset,draw
  cursor,xx,yy,/device,/nowait
  mbarheight = 0
  
  WHILE xx EQ -1 AND mbarheight LT 500 DO BEGIN
     mbarheight = mbarheight+1
     xrecorder_moveto,status,x,y+mbarheight,wave=0
     wset,draw
     cursor,xx,yy,/device,/nowait
  END
  IF mbarheight EQ 500 THEN mbarheight = 0
  widget_control,draw_id,/destroy
  IF oldwin GE 0 THEN wset,oldwin
END


;; Get the handle ID containing the xwidump results for a given top-level
;; widget base.

PRO xrecorder_cache,status,topid,hid
  
  handle_value,status.tids_h,tids,/no_copy
  handle_value,status.hids_h,hids,/no_copy
  
  IF n_elements(tids) EQ 0 THEN BEGIN
     tids = [topid]
     hids = [handle_create()]
     tix = 0L
  END ELSE BEGIN
     tix = (where(tids EQ topid))(0)
     IF tix EQ -1 THEN BEGIN
        validix = where(widget_info(tids,/valid_id))
        IF validix(0) NE -1 THEN BEGIN
           tids = [tids(validix),topid]
           hids = [hids(validix),handle_create()]
           tix = n_elements(tids)-1
        END ELSE BEGIN
           tids = [topid]
           hids = [handle_create()]
           tix = 0
        END
     END
  END
  
  handle_value,hids(tix),value,/no_copy
  
  IF n_elements(value) EQ 0 THEN BEGIN
     ;; print,"Making new playline chache entry"
     xwidump,topid,text,id
     fchild = widget_info(topid,/child)
     
     mbarheight = 0
     IF fchild NE 0L THEN BEGIN 
        fchild_geo = widget_info(fchild,/geometry)
        IF fchild_geo.scr_xsize EQ 0 AND fchild_geo.scr_ysize EQ 0 THEN $
           xrecorder_calibrate_mbar,status,topid,mbarheight
     END
     
     value = {mbarheight:mbarheight,$
              xpos:0L,ypos:0l,oldxpos:0L,oldypos:0L,text:text,id:id}
  END
  
  value.oldxpos = value.xpos
  value.oldypos = value.ypos
  widget_control,topid,tlb_get_offset=offset
  value.xpos = offset(0)
  value.ypos = offset(1)
  
  handle_value,hids(tix),value,/set,/no_copy
  
  hid = hids(tix)
  
  handle_value,status.tids_h,tids,/set,/no_copy
  handle_value,status.hids_h,hids,/set,/no_copy
  
END


;
; Generate a text defining a (basic) widget event.
;
function xrecorder_event_text,ev
  
  name = tag_names(ev,/structure_name)
  
  stx = '{'+name+',ID:0L,TOP:0L,HANDLER:0L,'
  
  CASE STRMID(name,7,100) OF
     
     'BUTTON':tx = 'SELECT:'+trim(ev.select)
     
     'DRAW':tx = 'TYPE:'+trim(ev.type)+',X:'+trim(ev.x)+',Y:'+trim(ev.y)+$
        ',PRESS:'+ntrim(ev.press)+'B,RELEASE:'+ntrim(ev.release)+'B'
     
     'DROPLIST':tx = 'INDEX:'+trim(ev.index)+'L'
     
     'LIST':tx = 'INDEX:'+trim(ev.index)+'L,CLICKS:'+trim(ev.clicks)+'L'
     
     'SLIDER':tx = 'VALUE:'+trim(ev.value)+'L,DRAG:'+trim(ev.drag)
     
     'TEXT_CH':tx = 'TYPE:0L,OFFSET:'+trim(ev.offset)+'L,CH:'+ntrim(ev.ch)+'B'
     
     'TEXT_STR':tx = 'TYPE:1L,OFFSET:'+trim(ev.offset)+'L,STR:"'+ev.str+'"'
     
     'TEXT_DEL':tx = 'TYPE:2L,OFFSET:'+trim(ev.offset)+'L,' + $
        'LENGTH:'+trim(ev.length)+'L'
     
     'TEXT_SEL':tx = 'TYPE:3L,OFFSET:'+trim(ev.offset)+'L,' + $
        'LENGTH:'+trim(ev.length)+'L'
     
     ELSE: BEGIN
        print,name+" - event ignored"
        return,""
        END
  END
  
  text = stx+tx+'}'
  return,text
  
END



;
; Find the true screen position of the center of a widget.
; Sets menubar=1 for menubar buttons
; 
PRO xrecorder_findpos,id,x,y,menubar
  
  geo = widget_info(id,/geometry)
  x = geo.xoffset + geo.margin
  y = geo.yoffset + geo.margin
  
  x = x + geo.scr_xsize/2
  y = y + geo.scr_ysize/2
  last_center_used = 1
  last = id
  
  next = widget_info(id,/parent)
  WHILE next NE 0 DO BEGIN
     geo = widget_info(next,/geometry)
     
     ;; For pulldown menu buttons (with size, offset set to zero) we have to
     ;; find the center position of the "root" button, i.e., the first parent
     ;; that has nonzero size.
     
     IF x EQ 0 AND y EQ 0 THEN BEGIN
        x = geo.scr_xsize/2
        y = geo.scr_ysize/2
        last_center_used = 1
     END ELSE last_center_used = 0
     
     x = x + geo.xoffset + geo.margin
     y = y + geo.yoffset + geo.margin
     last = next
     next = widget_info(next,/parent)
  END
  
  menubar = 0
  
  ;; This deals with menu bars - for which the top level base is the
  ;; first one with nonzero size reported { alpha OSF unix 4.0.1}!
  ;; So, the center position of the top level base has been used -
  ;; which is not correct.
  
  IF last_center_used THEN BEGIN 
     y = y - geo.scr_ysize/2
     menubar = 1
  END
END


;
; "wave" the mouse cursor centered on (x,y) - RELATIVE coordinates..
;
PRO xrecorder_wave,x,y
  
  default,xsize,10
  default,ysize,10
  
  FOR i = 0,300 DO BEGIN
     delt = (randomu(seed,2)-0.5)*[xsize,ysize]
     tvcrs,x+delt(0),y+delt(1)
  END
END


; 
; Move the mouse cursor smoothly to the true coordinates (x,y)
;
PRO xrecorder_moveto,status,x,y,wave=wave,now=now,keep_on_top=id
  
  xrecorder_findpos,status.pointer_id,xoffset,yoffset
  
  oldwin = !d.window
  
  wset,status.pointer_draw
  
  xx = x-xoffset
  yy = -(y-yoffset)
  
  xn = status.lastx-xoffset
  yn = -(status.lasty-yoffset)
  
  delta = long([xx-xn,yy-yn])
  msteps = max(abs(delta))
  
  tvcrs,xn,yn
  
  ;; print,"Moving to ",x,y
  
  IF msteps LE 2 THEN now = 1
  
  IF n_elements(id) EQ 1 THEN keeptop = widget_info(id,/valid_id) $
  ELSE                        keeptop = 0
  
  IF NOT keyword_set(now) THEN BEGIN
     IF msteps GT 2 THEN BEGIN 
        FOR step = 0,msteps,2 DO BEGIN
           wait,.001
           tvcrs,xn + step*delta(0)/msteps,yn + step*delta(1)/msteps
           IF step MOD 6 EQ 0 AND keeptop THEN $
              widget_control,id,/show
        END
     END
  END ELSE tvcrs,xx,yy
  
  
  default,wave,1
  
  IF keyword_set(wave) THEN xrecorder_wave,xx,yy
  status.lastx = x
  status.lasty = y
  
  IF oldwin GE 0 THEN wset,oldwin
END

;
; Menu bar buttons/menus don't report positions correctly through
; widget_info(/geometry), so we have to treat it a bit special..
;
; Lastparent is the ID of the "root" button of a pulldown menu,
; ID is the ID of the chosen menu item.
;
PRO xrecorder_flick_mbar,lastparent,id

  since_401 = since_version('4.0.1')
  
  ;; This is the menu bar itself..
  mbar = widget_info(lastparent,/parent)
  
  ;; Get the original text of the root button
  widget_control,lastparent,get_value=parent_org_text
  widget_control,id,get_value=id_text
  
  next_top = widget_info(mbar,/child)
  widget_control,next_top,get_value=mbartop_text
  
  mbartop_ids = [next_top]
  mbartop_txt = [mbartop_text]
  
  next_top = widget_info(next_top,/sibling)
  WHILE next_top NE 0L DO BEGIN
     widget_control,next_top,get_value=mbartop_text
     mbartop_ids = [mbartop_ids,next_top]
     mbartop_txt = [mbartop_txt,mbartop_text]
     next_top = widget_info(next_top,/sibling)
  END
  
  ntop = n_elements(mbartop_ids)
  IF since_401 THEN widget_control,mbar,update=0
  FOR i = 0,ntop-1 DO BEGIN
     str = string(replicate(120b,strlen(mbartop_txt(i))))
     widget_control,mbartop_ids(i),set_value=str
  END
  widget_control,lastparent,set_value=parent_org_text
  IF since_401 THEN widget_control,mbar,/update
  
  wait,1.5
  widget_control,lastparent,set_value=id_text
  
  IF ntop GT 1 AND mbartop_ids(i-1) NE lastparent THEN BEGIN
     widget_control,mbartop_ids(i-1),set_value=str+' '
  END
  
  wait,1.5
  
  IF since_401 THEN widget_control,mbar,update = 0
  
  FOR i = 0,ntop-1 DO BEGIN
     widget_control,mbartop_ids(i),set_value=mbartop_txt(i)
  END
  
  IF since_401 THEN widget_control,mbar,/update
  
END


;
; Flicks the displayed (root) value of a pulldown menu to
; show the selected choice
;
PRO xrecorder_flick_button,status,id,event
  
  ;; This is the text of the chosen button
  widget_control,id,get_value=val
  choicetext = val
  
  ;; Find the root button
  parent = widget_info(id,/parent)
  WHILE widget_info(parent,/type) EQ 1 DO BEGIN
     widget_control,parent,get_value=thisval
     val = thisval+':'+val
     lastparent = parent
     parent = widget_info(parent,/parent)
  END
  
  widget_control,status.text_id,set_value='Button:'+val,/append
  
  IF n_elements(lastparent) GT 0 THEN BEGIN
     ;; If IDL version 4.0.1 or later, make sure dynamic_resize is set
     ;; properly.
     IF since_version('4.0.1') THEN BEGIN
        dyn_resize = widget_info(lastparent,/dynamic_resize)
        update = widget_info(lastparent,/update)
        widget_control,lastparent,/dynamic_resize
        widget_control,lastparent,/update
     END
     
     ;; Check if we're dealing with a menu bar..
     geo = widget_info(lastparent,/geometry)
     
     IF geo.xsize EQ 0 THEN xrecorder_flick_mbar,lastparent,id ELSE BEGIN
        
        widget_control,lastparent,get_value=oldval
        widget_control,lastparent,set_value=choicetext
        wait,1.5
        widget_control,lastparent,set_value=oldval
        
     END
     
     IF since_version('4.0.1') THEN BEGIN
        widget_control,lastparent,dynamic_resize=dyn_resize
        widget_control,lastparent,update=update
     END
  END ELSE BEGIN
     wait,1
  END
  
END


;
; Send event to widget, and do other necessary stuff like moving the
; cursor etc..
;
PRO xrecorder_do_event,status,id,event
  
  ;; Kill any existing displayed message
  
  IF widget_info(status.message_id,/valid_id) THEN $
     widget_control,status.message_id,/destroy
  
  widget_control,id,/show,iconify=0,/map
  type = widget_info(id,/type)
  
  ;; Smooth move to the (approximate) position of the widget.
  
  xrecorder_findpos,id,xx,yy,mbarflag
  
  ;; Correct for menu bar
  yy = yy + status.pending_mbarheight
  IF mbarflag THEN yy = yy - status.pending_mbarheight/2
  
  ;; Correct the position if it's a draw widget
  IF type EQ 4 THEN BEGIN
     widget_control,event.id,get_value=win
     wset,win
     xx = xx - !D.x_size/2
     yy = yy + !D.y_size/2 ;; Lower left corner
     xx = xx + event.x
     yy = yy - event.y ;; Things go the other way...
  END
  
  xrecorder_moveto,status,xx,yy,keep_on_top=event.top,$
     wave = (type NE 4 AND type NE 3 AND NOT mbarflag)
  
  ;; If the cursor has moved from a draw window to another widget, we should
  ;; make sure that the cursor is reset (even if the button release event has
  ;; not been recorded properly)
  
  IF type NE 4 THEN device,/cursor_crosshair
  
  CASE type OF 
     
  0:BEGIN & END ;; shouldn't happen !
     
  1:BEGIN  ;;; button
     ;; Make sure that (non)exclusive buttons reflect the right status.
     widget_control,id,set_button=event.select
     ;; Flick text of the root button if a pulldown menu 
     xrecorder_flick_button,status,id,event
     ENDCASE
     
  2:BEGIN  ;;; slider - set value
     
     widget_control,id,set_value=event.value
     
     ENDCASE
     
  3:BEGIN  
     ;; Ugh.. text - make sure the text is correct, and hope that nobody
     ;; actually uses the event contents to keep track of the text content
     ;; instead of reading it.
     ;; 
     handle_value,status.playbook_h,playbook,/no_copy
     nlines = fix(playbook(status.i))
     text = playbook(status.i+1:status.i+nlines)
     widget_control,id,set_value=text
     status.i = status.i+nlines+1
     handle_value,status.playbook_h,playbook,/no_copy,/set
     ENDCASE
     
  4:BEGIN  ;;; Draw window event.
     
     
     wset,win
     tvcrs,event.x,event.y

     IF event.press GT 0 THEN BEGIN
        cursortext = (["","Left","Middle","","Right"])(event.press)
        widget_control,status.text_id,$
           set_value=cursortext+" mouse button",/append
        cursor = ([0,74,82,0,100])(event.press)
        FOR jjj=0,2 DO BEGIN 
           device,cursor_standard=cursor
           wait,.3
           device,cursor_standard=84
           wait,.01
        END
        device,cursor_standard=cursor
     END ELSE IF event.release GT 0 THEN device,/cursor_crosshair

     
     ENDCASE 
     
  5:BEGIN   ;; Label - shouldn't happen
     ENDCASE 
     
  6:BEGIN ;; List - set the correct selection
     widget_control,id,set_list_select=event.index
     ENDCASE
     
  8:BEGIN ;; droplist - set the correct selection
     widget_control,id,set_droplist_select=event.index
     ENDCASE
     
  END 
  
END


;
; Setup to play one line from the playbook
;
; In order to make the replay work for programs using the
; WIDGET_EVENT(SPECIAL_WIDGET_ID) form to catch events directly, the
; WIDGET_TIMER events have to be sent to the widgets that are supposed to
; receive the next event.
;
; The xrecorder_agent will (hopefully) catch the WIDGET_TIMER event and
; substitute it with the pending event.
;
; Two things (at least) will cause this to break:
;
; a: If a button press spawns a new widget, the receiving widget ID is not
;    known at this point, and a "retry" timer event (on the status.timer_id
;    widget of this application) will have to be used - this event will be
;    processed when the new widget creates a new XMANAGER event loop or when
;    control "falls through" to the existing event loop. If, however, the new
;    widget *starts off* with a WIDGET_EVENT(SPECIAL_ID) call straight away,
;    there's *no way* cw_infiltrate will ever manage to place our agent onto
;    the new widget(s), and we won't get our timer "retry" event processed
;    either. This is also the case during the recording session, BTW.
;
; b: Any program changing the event handling procedure/function for it's
;    elementary "leaf" widgets (bases are OK!), will not have the events
;    recorded, and neither will they be replayed.
; 
PRO xrecorder_playline,status,reftime
  COMMON MANAGED, ids, names, nummanaged, inuseflag, backroutines, $
     backids, backnumber, nbacks, validbacks, blocksize, cleanups, outermodal

  IF status.stopped THEN return
  

LOOP_NEXTLINE:
  
  ;; If we're at the end of the script, just stop.
  
  IF status.i GE status.playbook_size THEN BEGIN
     widget_control,status.text_id,set_value='Replay ended',/append
     widget_control,status.pause_id,sensitive=0
     widget_control,status.pause_id,set_value='Pause'
     device,/cursor_crosshair
     return
  END 
  
  ;; Get the playbook, extract the line, advance the counter, and put it back
  
  handle_value,status.playbook_h,playbook,/no_copy
  line = playbook(status.i)
  status.i = status.i+1
  handle_value,status.playbook_h,playbook,/no_copy,/set
  
  ;; Display a message in the text_id window?
  IF strmid(line,0,1) EQ '"' THEN BEGIN
     widget_control,status.text_id,set_value=strmid(line,1,100),/append
     ;; Keep moving...
     GOTO,LOOP_NEXTLINE
  END
  
  ;; Display a message through xtext?  XTEXT will be killed when the next
  ;; event is processed, so the delay for the next event controls the length
  ;; of time that the text will be visible.
  ;; 
  IF strmid(line,0,1) EQ "'" THEN BEGIN
     handle_value,status.playbook_h,playbook,/no_copy
     message = [strmid(line,1,100)]
     go = status.i LT status.playbook_size
     WHILE go DO BEGIN
        line = playbook(status.i)
        IF strmid(line,0,1) EQ "'" THEN BEGIN
           message = [message,strmid(line,1,100)]
           status.i = status.i+1
           go = status.i LT status.playbook_size
        END ELSE BEGIN
           go = 0
        END
     END
     handle_value,status.playbook_h,playbook,/set,/no_copy
     xtext,message,/just_reg,wbase=wbase
     ;; Move the cursor to the center of the text.
     xrecorder_findpos,wbase,x,y
     xrecorder_moveto,status,x,y,wave=0,/now
     status.message_id = wbase
     ;; Keep moving...
     GOTO,LOOP_NEXTLINE
  END
  
  
  ;; Separate the playline into its constituents..
  chunk = str_sep(line,string(255b))
  
  IF n_elements(chunk) NE 5 THEN BEGIN
     print,"Malformed line in Xplayer script, skipping:"
     GOTO,LOOP_NEXTLINE
  END
  
  thisdelay = float(chunk(0))
  thisname = chunk(1)
  thisnum = fix(chunk(2))
  thisix = fix(chunk(3))
  
  IF thisname EQ 'xrecorder' AND status.ignoreself THEN BEGIN
     print,"Ignoring xrecorder lines during playback"
     GOTO,LOOP_NEXTLINE
  END
  
  ;; Repositioning events have the form "@ x y"
  
  reposition = (strmid(chunk(4),0,1) EQ '@')
  
  IF NOT reposition THEN event = xrecorder_make(chunk(4)) $
  ELSE BEGIN
     pos = [0L,0L]
     reads,strmid(chunk(4),1,100),pos
  END
  
  ;; Now, find the top_id of the widget hierarchy to be called on...
  notfound = 0
  IF thisname NE '-' THEN BEGIN 
     candidatix = where(names EQ thisname,count)
     IF thisnum GE count THEN notfound = 1 $
     ELSE top_id = ids(candidatix(thisnum))
  END ELSE BEGIN
     
     ;; Anonymous, non-managed widget..
     handle_value,status.rogue_h,rogues
     
     IF thisnum GE n_elements(rogues) THEN notfound = 1 $
     ELSE top_id = rogues(thisnum)
     
     handle_value,status.rogue_h,rogues
  END
  
  ;; Schedule a retry if we haven't yet figured out who's around...
  ;; 
  IF notfound THEN BEGIN
     mess = "Couldn't find "+thisname+" no. "+chunk(2)
     
     ;; Keep moving... this could be halted by WIDGET_EVENT(ID)
     widget_control,status.timer_id,timer=0
     IF status.retry GE 2 THEN BEGIN
        message,mess + " -skipping",/continue
        status.retry = 0
     END ELSE BEGIN 
        message,mess + " -retrying",/continue
        status.i = status.i-1
        status.retry = status.retry + 1
     END
     return
  END 
  
  ;; No more retry - reset counter
  status.retry = 0
  
  ;; If it's a repositioning event then do it
  ;;
  IF reposition THEN BEGIN
     wait,thisdelay
     widget_control,top_id,tlb_set_xoffset=pos(0),tlb_set_yoffset=pos(1)
     GOTO,LOOP_NEXTLINE
  END
  
     
  ;; Get the xwidump results for the top base.
  ;;
  ;; Note down the widget ID to send the event to, and put the xwidump result
  ;; back
  
  xrecorder_cache,status,top_id,handle
  handle_value,handle,value,/no_copy
  id = value.id(thisix)
  mbarheight = value.mbarheight
  handle_value,handle,value,/set,/no_copy
  
  ;; Set the pending event...
  
  event.id = id
  handle_value,status.pending_event_h,event,/set,/no_copy
  
  ;; Inform about the pending event's menu bar height correction
  status.pending_mbarheight = mbarheight
  
  ;; If it's a draw widget, store the DRAW_BUTTON/MOTION_EVENTS status
  ;; and set them to zero to avoid overrunning events..
  thistype = widget_info(id,/type)
  IF thistype EQ 4 THEN BEGIN
     last_was_draw = (status.pending_motion NE -1)
     IF last_was_draw THEN empty
     status.pending_motion = widget_info(id,/draw_motion_events)
     status.pending_button = widget_info(id,/draw_button_events)
     widget_control,id,draw_motion_events=0,draw_button_events=0
     ;;
     ;; For some reason IDL sometimes kills off timer events on draw widgets
     ;; if they're set with timer=0....
     ;;
     ;; This seems to be happening whenever programs *start* calling
     ;; WIDGET_EVENT(WIDGET_ID) directly (maybe because the timer event was
     ;; flagged as "expired" at the time of registration, and thus flagged for
     ;; processing during the *return* to the current XMANAGER WIDGET_EVENT()
     ;; call...?). Such sequences usually involves pressing a button or
     ;; something to start off a special mode calling WIDGET_EVENT(WIDGET_ID),
     ;; and is "cured" by not allowing TIMER=0, but instead setting e.g.,
     ;; TIMER=0.001. We apply this restriction for the *start* of widget_draw
     ;; event sequences only, however, because having nonzero TIMER delays
     ;; somehow  disrupts the "flow" when dealing with long motion-event
     ;; sequences.
     ;;
     ;; Of course, it's always possible that some program uses a widget-draw
     ;; event to start off a WIDGET_EVENT(WIDGET_ID) event call, and if the
     ;; timer delay for the event that's supposed to be caught by that call
     ;; becomes zero, there *might* be problems....
     IF last_was_draw THEN timelimit = 0 $
     ELSE                  timelimit = 0.0001
  END ELSE BEGIN
     status.pending_motion = -1
     status.pending_button = -1
     timelimit = 0.0
  END
  
  ;; Subtract processing time from the delay
  newtime = systime(1)
  process_time = newtime - status.playtime
  status.playtime = newtime
  thisdelay = (thisdelay - process_time) > timelimit
  ;; Let's hope the infiltrated event_func gets this...
  widget_control,id,timer=thisdelay
  ;;IF widget_info(id,/type) EQ 4 THEN BEGIN
  ;;   print,line
  ;;END 
END


;;
;; Take note of an event.. if a recording is going on...
;;

PRO xrecorder_register,status,ev
  COMMON MANAGED, ids, names, nummanaged, inuseflag, backroutines, $
     backids, backnumber, nbacks, validbacks, blocksize, cleanups, outermodal
  
  on_error,0
  IF status.lun EQ -1 THEN return
  
  ;; We don't record widget timer events...
  IF tag_names(ev,/structure_name) EQ 'WIDGET_TIMER' THEN return
  
  ;; Get the xwidump results for the top base of this event
  
  xrecorder_cache,status,ev.top,handle
  handle_value,handle,value,/no_copy
  
  ;; Find which widget (in the xwidump) made this event
  line_no = (where(value.id EQ ev.id))(0)
  
  ;;print,"The event came from this widget:"
  ;;print,value.text(line_no)
  
  ;; Has the top level base moved?
  ;;
  IF value.oldxpos NE value.xpos OR value.oldypos NE value.ypos THEN BEGIN
     newpos = [value.xpos,value.ypos]
  END
  
  ;; Now we don't need the xwidump anymore..
  handle_value,handle,value,/set,/no_copy
  
  ;; Find out the name and number of this particular event's top base
  
  ix = where(ids EQ ev.top)
  
  IF ix(0) NE -1 THEN BEGIN
     name = names(ix(0))
     candidatix= where(names EQ name)
     number = (where(ids(candidatix) EQ ev.top))(0)
  END ELSE BEGIN
     name = "-" ;; Anonymous
     handle_value,status.rogue_h,rogues
     number = (where(rogues EQ ev.top))(0)
  END
  
  ;; Separator.. because we could have multi-character string insertion
  ;; events from text widgets..
  sep = string(255b)
  
  ;; This identifies the top-level ID
  ;; (..except the *order* of registration in xmanager, perhaps..)
  first = name + sep + trim(number)
 
  first = first + sep + string(line_no,'(I4.4)')
  
  ;; Get the time since last event
  
  IF status.lasttime EQ 0 THEN status.lasttime = systime(1)
  oldtime = status.lasttime
  status.lasttime = systime(1)
  deltime = status.lasttime - oldtime
  
  evtext = xrecorder_event_text(ev)
  IF evtext NE '' THEN BEGIN 
     etext = string(deltime,'(f6.2)')+sep+first+sep+evtext
  
     IF status.lun GT 0 THEN BEGIN
        IF n_elements(newpos) GT 0 THEN BEGIN
           printf,status.lun,'0.2'+sep+first+sep+'@',newpos,$
              format = '(A,I6,I6)'
        END
        IF status.lun GT 0 THEN printf,status.lun,etext
        IF widget_info(ev.id,/type) EQ 3 THEN BEGIN
           widget_control,ev.id,get_value = ttext
           printf,status.lun,n_elements(ttext)
           printf,status.lun,ttext,format='(A)'
        END 
     END
  END 
END


;
; Convert WIDGET_TIMER events into pending events
;
PRO xrecorder_treat,status,ev
  reftime = systime(1)
  type = tag_names(ev,/structure_name)
  
  IF type EQ 'WIDGET_TIMER' THEN BEGIN
     handle_value,status.pending_event_h,pending,/no_copy
     IF n_elements(pending) EQ 1 THEN BEGIN
        IF pending.id EQ ev.id THEN BEGIN
           ;; print,"Switching"
           pending.top = ev.top
           pending.handler = ev.handler
           ev = temporary(pending)
           
           IF status.pending_motion NE -1 THEN BEGIN
              widget_control,ev.id,draw_motion_events=status.pending_motion,$
                 draw_button_events=status.pending_button
           END
           
           IF status.stopped THEN BEGIN
              ;; Discard if replay has been paused (it will be replayed when
              ;; resumed.
              ev = 0 
           END ELSE BEGIN
              
              ;; Do the cursor movements/button clicks etc..., 
              xrecorder_do_event,status,ev.id,ev
              
              ;; Sets the next pending event.. (or maybe not..if impossible)
              xrecorder_playline,status,reftime
           END
           
        END
     END
     ;; Ah, is not the one - Zathras knows :-)
     IF n_elements(pending) EQ 1 THEN $
        handle_value,status.pending_event_h,pending,/set,/no_copy
  END ELSE BEGIN
     ;; Moving the cursor (with TVCRS) across a draw-motion-enabled window
     ;; causes events to be generated.. lots of them... Here we gobble up all
     ;; widget_draw events not generated directly by the replay when replay is
     ;; in action.
     handle_value,status.pending_event_h,pending,/no_copy
     IF n_elements(pending) EQ 1 THEN BEGIN 
        IF type EQ 'WIDGET_DRAW' THEN ev = 0
     END
     handle_value,status.pending_event_h,pending,/set,/no_copy
  END
END

;
; Start a replay session
;
PRO xrecorder_start,status
  playbook = rd_ascii(status.file)
  
  status.playbook_size = n_elements(playbook)
  status.i = 0
  status.stopped = 0
  status.lasttime = 0
  
  handle_value,status.playbook_h,playbook,/set,/no_copy
  widget_control,status.text_id,set_value='Replay started',/append
  
  widget_control,status.pause_id,set_value='Pause'
  widget_control,status.pause_id,/sensitive
  widget_control,status.timer_id,timer=0.0
END


;
; This is the "agent" that cw_infiltrate places as the event manager on all
; widget "leafs" - i.e., everything but bases. The supplied ID is the ID of
; the cw_infiltrate, whose uvalue we've got control of.
;
PRO xrecorder_agent,ev,id
  
  widget_control,id,get_uvalue=top_id ;; This is *my* top...
  widget_control,top_id,get_uvalue=status
  
  ;; In case recording of a replayed session goes on we should *first*
  ;; transform the event into the pending event.
  
  xrecorder_treat,status,ev
  ;; Allow xrecorder_treat to set ev=0 to gobble up events.
  sz = size(ev)
  IF sz(sz(0)+1) EQ 8 THEN xrecorder_register,status,ev
  
  widget_control,top_id,set_uvalue=status
END

;
; Close any ongoing recording and send a message about it.
;
PRO xrecorder_close,status
  IF status.lun NE -1 THEN BEGIN
     close,status.lun
     free_lun,status.lun
     status.lun = -1
     mess = 'Recording closed: '+status.fnam_ext
     widget_control,status.text_id,set_value=mess,/append
     widget_control,status.record_id,set_value='Record'
  END
END

;
; Open a recording file and send a message about it.
;
PRO xrecorder_open,status
  openw,lun,status.file,/append,/get_lun
  status.lun = lun
  mess = "Recording started, filename "+status.fnam_ext
  print,mess
  widget_control,status.text_id,set_value=mess,/append
  widget_control,status.record_id,set_value='Stop'
END 

;
; This handles events from the xrecorder widget itself..
;
PRO Xrecorder_event, event
  on_error,0
  
  widget_control,event.top,get_uvalue=status
  WIDGET_CONTROL, event.id, GET_UVALUE = evntval
  
  CASE evntval OF
     
  "PLAYTIMER":BEGIN
     ;; Either a "start", or a "retry" event
     xrecorder_playline,status
     ENDCASE
     
  "IGNORESELF":BEGIN
     status.ignoreself = event.select
     ENDCASE 
  
  "PAUSE":BEGIN
     IF NOT status.stopped THEN BEGIN
        status.stopped = 1
        status.i = (status.i-1) > 0
        widget_control,status.pause_id,set_value='Resume'
        widget_control,status.text_id,set_value='Replay paused',/append
        device,/cursor_crosshair
     END ELSE BEGIN
        status.stopped = 0
        widget_control,status.pause_id,set_value='Pause'
        widget_control,status.text_id,set_value='Replay resumed',/append
        xrecorder_playline,status
     END
     ENDCASE
     
  "REPLAY":BEGIN
     IF status.lun NE -1 THEN BEGIN
        xrecorder_close,status
        widget_control,status.text_id,set_value='Resuming',/append
        xrecorder_open,status
     END
     xrecorder_start,status
     ENDCASE
     
  "RESET":BEGIN
     xrecorder_close,status
     rm_file,status.file
     mess = "File "+status.fnam_ext+" erased"
     widget_control,status.text_id,set_value=mess,/append
     print,mess
     widget_control,status.record_id,set_value='Record'
     ENDCASE
     
  "FILE":BEGIN
     xrecorder_close,status
;?     widget_control,event.top,set_uvalue=status
     file = pickfile(/write,filter='*.rec',/fix_filter,get_path=path)
     IF file NE '' THEN BEGIN 
        break_file,file,disk,dir,fnam,ext
        status.fnam_ext = fnam+ext
        widget_control,status.file_id,set_value='File: '+status.fnam_ext
        status.file = path + fnam + ext
     END 
     ENDCASE 
     
  "RECORD":BEGIN
     IF status.lun NE -1 THEN xrecorder_close,status $
     ELSE xrecorder_open,status
     ENDCASE
     
  "MINIMIZE":BEGIN
     oldlun = status.lun
     xrecorder_close,status
     book = rd_ascii(status.file)
     nl = n_elements(book)
     xrecorder_minimize,book
     openw,lun,status.file,/get_lun
     printf,lun,book,format='(A)' 
     close,lun & free_lun,lun
     nnl = n_elements(book)
     widget_control,status.text_id,/append,set_value=$
        "File minimized, from "+trim(nl)+" lines to "+trim(nnl)+" lines"
     IF oldlun NE -1 THEN xrecorder_open,status
     ENDCASE
     
     
  "DONE":BEGIN
     xrecorder_close,status
     xkill,/all
  END 
  ELSE:
  ENDCASE
  
  IF evntval NE 'DONE' THEN widget_control,event.top,set_uvalue=status
END

PRO xrecorder_cleanup,id
  widget_control,id,get_uvalue=status
  IF n_elements(status) NE 0 THEN BEGIN 
     tags = tag_names(status)
     ix = where(strpos(tags,'_H') EQ strlen(tags)-2,nhandles)
     FOR i = 0L,nhandles-1 DO BEGIN
        IF handle_info(status.(ix(i)),/valid_id) THEN BEGIN
           handle_free,status.(ix(i))
        END 
     END
     
     ;; Close any recording...
     IF status.lun NE -1 THEN BEGIN
        close,status.lun
        free_lun,status.lun
     END
  END
END

;-----------------------------------------------------------------------------

PRO Xrecorder,file,start=start,play_only=play_only

  default,file,'xrecorder.rec'
  
  stopped = NOT keyword_set(start)
  
  IF (xregistered("xrecorder")) THEN BEGIN
     print,"A copy of Xrecorder is already running"
     RETURN
  END
  
  recbase = widget_base(TITLE = "Xrecorder",/column,xoffset=1,yoffset=1)
  
  buttonbase = widget_base(recbase,/row)
  donebase = widget_button(buttonbase,menu=2,value='Exit')
  recdone = widget_button(donebase,value="Exit (kills all widgets)",$
                          uvalue="DONE")
  
  ;; This one keeps me informed...
  infiltrator = cw_infiltrate(buttonbase,'xrecorder_agent',$
                              rogue=rogue_h)
  widget_control,infiltrator,set_uvalue=recbase
  
  ;; Widget base used to (re-)start replay sessions
  timer = widget_base(buttonbase,map=0,uvalue="PLAYTIMER")
  
  ;; Draw base to move cursor around from.
  
  pointer = widget_draw(buttonbase,xsize=1,ysize=1)
  
  ;; Self-events ignored during playback?
  excl = widget_base(buttonbase,/row,/nonexclusive)
  ignore = widget_button(excl,value='Ignore XRECORDER events in playback',$
                         uvalue='IGNORESELF')
  widget_control,ignore,/set_button
  irecbase = widget_base(recbase,/row)
  
  ;; File section base
  fbase = widget_base(irecbase,/column,/frame)
  file_id = widget_label(widget_base(fbase),value='File: '+file)
  file_b = widget_button(fbase,value='Select new file',uvalue='FILE')
  
  ;; Recorder section
  nbase = widget_base(irecbase,/column,/frame,space=1,ypad=1)
  label = widget_label(widget_base(nbase),value='Recording')
  nbase = widget_base(nbase,/row,ypad=1)
  recorder = widget_button(nbase,value='Record',uvalue='RECORD')
  reset = widget_button(nbase,value='Reset',uvalue='RESET')
  minimize = widget_button(nbase,value='Minimize',uvalue='MINIMIZE')
  IF keyword_set(play_only) THEN widget_control,nbase,sensitive=0
  
  ;; Player section
  pbase = widget_base(irecbase,/column,/frame,space=1,ypad=1)
  label = widget_label(widget_base(pbase),value='Replay')
  nbase = widget_base(pbase,/row,ypad=1)
  player = widget_button(nbase,value='Start',uvalue='REPLAY')
  pause = widget_button(nbase,value='Pause',uvalue='PAUSE')
  
  textid = widget_text(recbase,value='Messages',xsize=70,ysize=4,/scroll)
  
  IF since_version('4.0.1') THEN BEGIN
     widget_control,pause,/dynamic_resize
     widget_control,file_id,/dynamic_resize
     widget_control,recorder,/dynamic_resize
  END
  
  
  widget_control,recbase,/realize
  
  ;; This *has* to be done after the widget's realized
  widget_control, infiltrator, timer = 0
  
  widget_control,pointer,get_value=pointer_draw
  
  IF stopped THEN widget_control,pause,sensitive=0
  
  break_file,file,disk,dir,fnam,ext
  
  status = { file_id : file_id,$
             record_id : recorder,$
             pause_id : pause,$
             text_id : textid,$
             timer_id : timer,$
             message_id : 0L,$
             file : file,$
             fnam_ext : fnam+ext,$
             lasttime : 0.0d,$
             playtime : 0.0d,$
             ignoreself : 1,$
             pointer_id : pointer,$
             pointer_draw : pointer_draw,$
             lastx : 0L, lasty : 0L,$
             playbook_size : -1L,$
             i : 0L,$
             retry : 0,$
             stopped : stopped,$
             playbook_h : handle_create(),$
             pending_event_h : handle_create(),$
             pending_mbarheight : 0L,$
             pending_motion : -1,$
             pending_button : -1,$
             rogue_h : rogue_h,$
             tids_h : handle_create(),$
             hids_h : handle_create(),$
             menubar_h : handle_create(),$
             lun : -1L $
           }
  
  IF NOT stopped THEN xrecorder_start,status
  
  widget_control,recbase,set_uvalue=status
  
  xmanager, "xrecorder",recbase,/just_reg,/immune,cleanup="xrecorder_cleanup"

END
