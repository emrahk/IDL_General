;+
; Project     : SOHO - CDS     
;                   
; Name        : XPLOTSCALE
;               
; Purpose     : A widget interface to control plot scaling methods
;               
; Explanation : An XPLOTSCALE object contains a description of how the
;               plotting range (normally, the YRANGE) is selected, given the
;               arrays of abscissa/ordinate values, and the abscissa range
;               (normally the XRANGE). It also contains a switch to control
;               the plot TYPE (i.e., 1 for logarithmic, 0 for linear).
;
;               Creating an XPLOTSCALE object is done by calling XPLOTSCALE
;               without any parameters. The XPLOTSCALE ID is returned.
;
;               In order to retrieve the proper user-determined plotting
;               range, call XPLOTSCALE with two parameters: the XPLOTSCALE ID
;               and an Nx2 array; [[abscissa],[ordinate]]. You may also supply
;               an abscissa range (like e.g., XRANGE). The ordinate range is
;               returned as an array with two elements (to be used e.g., like
;               YRANGE).
;
;               The XPLOTSCALE object may or may not be visible on the screen.
;               You can always force an XPLOTSCALE object to become visible by
;               using
;               
;                   dummy = xplotscale(xplotscale_id,/map,/show,iconify=0)
;
;               Making the XPLOTSCALE object invisible is done by e.g.,
;
;                   dummy = xplotscale(xplotscale_id,map=0) 
;
;               (or by setting /iconify, or setting show=0).
;               
;               If the XPLOTSCALE object is visible, the user may alter the
;               method used to decide the plot range.  The next time the
;               display program uses XPLOTSCALE to determine the plotting
;               range, the new status will be reflected in the scaling of the
;               plot. If the display program wishes to be informed about any
;               change in the scaling object right away, it should inform
;               xplotscale about it the following way:
;
;               1. Create a (usually unmapped) widget_base somewhere in the
;               display program widget hierarchy.
;
;               2. Supply the widget ID of this base to XPLOTSCALE through the
;               keyword SIGNAL, either when creating XPLOTSCALE, or at some
;               later time. If you're supplying it after the creation, you'll
;               need to specify the xplotscale ID as a parameter, e.g.,
;
;                     dummy = xplotscale(xplotscale_id,signal=base)
;
;               3. When the XPLOTSCALE object is altered by the user, an event
;               is generated and sent to the widget id's that have been hooked
;               up through the SIGNAL keyword. The event structure,
;               {XPLOTSCALE_EVENT}, contains the following tags:
;
;               ID         : The ID of the SIGNAL base (NOT the xplotscale ID).
;               HANDLER    : The ID of the event handling base.
;               TOP        : The ID of the topmost base in the hierarchy.
;               XPLOTSCALE_ID: The XPLOTSCALE ID
;
;               
; Use         : XPLOTSCALE_ID = XPLOTSCALE()
;    
; Inputs      : None reqired.
;               
; Opt. Inputs : XPLOTSCALE_ID : The ID of the XPLOTSCALE object be
;               used/modified.
;
;               VALUES : (Only as parameter number 2, after XPLOTSCALE_ID) The
;                        abscissa/ordinate values to be plotted, as an Nx2
;                        array, [[abscissa],[ordinate]].
;
;               RANGE : (Only as parameter number 3, after XPLOTSCALE_ID and
;                       VALUES). The actual abscissa range to be plotted.
;                       The user may select whether the values are to be based
;                       on the entire array of VALUES, or on just the portion
;                       inside the given RANGE.
;                       
; Outputs     : Returns the XPLOTSCALE_ID of the new scaling object when called
;               without any parameters.
;
;               Returns the ordinate range and TYPE if called with
;               XPLOTSCALE_ID and VALUES (and optionally (abscissa) RANGE).
;               The returned values are [MIN,MAX,TYPE]. MIN may be larger than
;               MAX, if the user prefers an inverted plot.
;
; Opt. Outputs: None.
;               
; Keywords    : TITLE : A title string to be displayed above the scaling
;                       program.
;
;               MISSING : The value of missing data.
;
;               COMP_MISSING : Comparison method for missing data:
;               
;                   -1 : Values less than/equal to MISSING treated as missing
;                    0 : Values exactly matching MISSING treated as missing
;                    1 : Values greater than or equal to MISSING treated as
;                        missing.
;               
;               SIGNAL : The widget ID(s) of those to be informed about
;                        changes to the scaling object.
;
;               DESTROY : Set this keyword to destroy the scaling object.
;
;               XOFFSET,
;               YOFFSET : The x/y offset of the widget showing the
;                         status of the scaling object.
;
;               GROUP_LEADER : The widget ID of the group leader.
;
;               ICONIFY : Set to 1 to make the widget showing the status
;                         become iconified. Set to 0 to de-iconify.
;
;               MAP : Set to 1 to make the widget visible. Set to 0 to make it
;                     invisible
;
;               SHOW : Set to 1 to raise the widget on top of any other
;                      window. Set to 0 to hide it behind all other windows.
;
; Calls       : xtext, default, handle_create(), handle_info(),
;               handle_killer_hookup, parcheck, since_version(), typ(),
;               widget_base(), xalive()
;
; Common      : None.
;               
; Restrictions: The user has to press enter to make program changes effective.
;               
; Side effects: None known.
;               
; Category    : Utility, Image
;               
; Prev. Hist. : Based on analogous XTVSCALE routine.
;
; Written     : Stein Vidar H. Haugan, UiO, 14 November 1996
;               (s.v.h.haugan@astro.uio.no)
;               
; Modified    : Not yet.
;
; Version     : 6, 22 August 1996
;-            


FUNCTION xplotscale_nonlin,frac,reverse=reverse
  
  IF frac GE 0 AND frac LE 100 THEN return,frac
  
  IF frac GT 100 THEN add = 100 $
  ELSE                add = 0
  
  
  frac = abs(frac-add)
  
  IF NOT keyword_set(reverse) THEN BEGIN 
     IF add EQ 100 THEN return,add + exp(frac*0.2)
     return,-exp(frac*0.2)
  END ELSE BEGIN
     IF add EQ 100 THEN return,(add + alog(frac)/0.2) < 150
     return,(-alog(frac)/0.2) > (-50)
  END
  
END

;
; EVENT handling
;
PRO xplotscale_event,ev
  
  WIDGET_CONTROL,ev.top,get_uvalue=stash
  handle_value,stash,info,/no_copy
  
  WIDGET_CONTROL,ev.id,get_uvalue=uval
  
  CASE uval OF 
     
  'HELP':BEGIN
     xplotscale_help,group=ev.top
     GOTO,skip_event
     ENDCASE
     
  'RESET':BEGIN
     info.ext.highfrac = 105.0
     info.ext.lowfrac = -5.0
     widget_control,info.int.highfrac_id,$
        set_value=xplotscale_nonlin(info.ext.highfrac,/reverse)
     
     widget_control,info.int.lowfrac_id,$
        set_value=xplotscale_nonlin(info.ext.lowfrac,/reverse)
     
     ENDCASE
     
  'ALL':info.ext.allpoints = 1
     
  'VISIBLE':info.ext.allpoints = 0
     
  'MISSING':BEGIN
     info.ext.missing = double(ev.value)
     widget_control,ev.id,set_value=trim(info.ext.missing)
     ENDCASE  
     
  'MISS=' :info.ext.comp_missing = 0
  'MISS>' :info.ext.comp_missing = 1
  'MISS<' :info.ext.comp_missing = -1
     
  'LINEAR':info.ext.logarithmic = 0
     
  'LOGARITHMIC':info.ext.logarithmic = 1
  
  'HIGHFRAC': BEGIN
     REPEAT new_ev = widget_event(ev.id,/nowait) UNTIL new_ev.id EQ 0
     widget_control,ev.id,get_value=value
     info.ext.highfrac = value
     ENDCASE
     
  'LOWFRAC':BEGIN
     widget_control,ev.id,/clear_events
     widget_control,ev.id,get_value=value
     info.ext.lowfrac = value
     ENDCASE
     
  'ICONIFY':BEGIN
     widget_control,ev.top,/iconify
     GOTO,skip_event
     ENDCASE
     
  'HIDE' :BEGIN
     IF xalive(info.int.group) THEN WIDGET_CONTROL,ev.top,map = 0
     GOTO,skip_event
     ENDCASE
     
  'KILL' :BEGIN
     WIDGET_CONTROL,ev.top,/destroy
     GOTO,skip_event
     ENDCASE
     
  END
  
  ;; Get ID's of those that wish to be informed.
  ;;
  handle_value,info.int.signals,eventarr ;;; No use of no-copy here
  
  ;; If we don't want to send any events, simply skip reading the list
  ;; of event catchers.
  ;; 
SKIP_EVENT:
  
  ;; Put back the info structure so the event handlers we're dialing up are
  ;; allowed to call xplotscale without crashing.
  
  handle_value,stash,info,/no_copy,/set
  
  IF N_ELEMENTS(eventarr) gt 0 THEN BEGIN
     event = {XPLOTSCALE_EVENT,ID:0L,TOP:0L,HANDLER:0L,XPLOTSCALE_ID:stash}
     FOR call = 0L,N_ELEMENTS(eventarr)-1 DO BEGIN
        event.id = eventarr(call)
        WIDGET_CONTROL,event.id,send_event = event,bad_id = bad
        IF bad NE 0 THEN MESSAGE,"BAD widget ID encountered",/continue
     END
  END
  
END

;
; Perform a scaling
;
FUNCTION xplotscale_scale,info,idata,range
  
  sz = size(idata)
  
  IF sz(0) LT 1 OR sz(0) GT 2 THEN $
     message,"Supplied data must be 1- or 2-dimensional"
  
  IF sz(0) EQ 1 THEN BEGIN
     x = findgen(sz(1))
     y = idata
  END ELSE BEGIN
     x = reform(idata(*,0),/overwrite)
     y = reform(idata(*,1),/overwrite)
  END
  
  ;; We should take out missing values first.
  ;;
  
  ;; Missing above, below, or exact.
  ;; 
  CASE 1 OF
     info.ext.comp_missing EQ  0: test = y EQ info.ext.missing
     info.ext.comp_missing EQ  1: test = y GE info.ext.missing
     info.ext.comp_missing EQ -1: test = y LE info.ext.missing
  END
  
  goodix = where(test-1,ngood)
  IF ngood EQ 0 THEN BEGIN
     return,[1,10,info.ext.logarithmic]
  END
  
  x = x(goodix)
  y = y(goodix)
  
  ;; Check inside range
  
  IF NOT info.ext.allpoints AND n_elements(range) NE 0 THEN BEGIN
     IF n_elements(range) NE 2 THEN $
        message,"RANGE must have 2 values"
     
     rangehi = range(1)
     rangelo = range(0)
     
     IF rangelo GT rangehi THEN BEGIN
        rangehi = range(0)
        rangelo = range(1)
     END
     
     insidix = where(x GE rangelo AND x LE rangehi,ninside)
     
     IF ninside GT 0 THEN y = y(insidix)
  END
  
  maxval = max(y,min=minval)
  
  span = maxval-minval
  
  IF span EQ 0 THEN BEGIN
     IF maxval NE 0 THEN return,[maxval*1.1,maxval*0.9,info.ext.logarithmic] $
     ELSE return,[-1,1,0]
  END 
  
  IF widget_info(info.int.lowfrac_id,/valid_id) THEN BEGIN
     widget_control,info.int.lowfrac_id,get_value=lowfrac,/clear_events,$
        bad_id=bad
     info.ext.lowfrac = xplotscale_nonlin(lowfrac)
  END
  
  IF widget_info(info.int.lowfrac_id,/valid_id) THEN BEGIN
     widget_control,info.int.highfrac_id,get_value=highfrac,/clear_events,$
        bad_id=bad
     info.ext.highfrac = xplotscale_nonlin(highfrac)
  END
  
  loval = minval + span * info.ext.lowfrac * 0.01d
  hival = minval + span * info.ext.highfrac * 0.01d
  
  IF info.ext.logarithmic THEN BEGIN
     loval = loval > 1e-30
     hival = hival > 1e-30
  END
  
  IF info.ext.logarithmic THEN BEGIN
     ;;  Idl's not very good at coping without this:
     
     IF loval GT hival THEN BEGIN
        swap = loval
        loval = hival
        hival = swap
     END
     
     loexp = fix(alog10(abs(loval))) ;; Truncation's ok...
     hiexp = fix(alog10(abs(hival))+0.99999999) ;; NO truncation
     
     loval = 10^FIX(loexp)
     hival = 10^FIX(hiexp)
     
     IF n_elements(swap) NE 0 THEN BEGIN
        swap = loval
        loval = hival
        hival = swap
     END
     
  END
  
  return,[loval,hival,info.ext.logarithmic]
  
END

PRO xplotscale_help,group=group
  
  txt = $
     ['XPLOTSCALE is a widget allowing the user to control the scaling of',$
      'IDL plots. ',$
      '',$
      'The "main" program sends the data to be plotted to XPLOTSCALE, and',$
      'a plotting range is returned according to the current status of the',$
      'widget.',$ 
      '',$
      'The plotting range is calculated either on the basis of either',$
      'all the data, or just the data currently visible. You may switch',$
      'between the two by pressing the button labeled "all points" or ',$
      '"visible points".',$
      '',$
      'In addition, there are two sliders on the right hand side of the',$
      'widget. They control the "fine tuning" of the upper and lower ',$
      'plotting limits.',$
      '',$
      'MISSING pixels are left out of the range calculation.',$
      '',$
      'You may select between LINEAR and LOGARITHMIC plots by pressing the',$
      'button labeled "Type: LINEAR" (or "Type: LOGARITHMIC")']
  
  xtext,txt,/just_reg,group=group
END



PRO xplotscale_makebase,info,onbase
  
  IF since_version('4.0') THEN sml = 1 ELSE sml = 0
  tight = {xpad:sml,ypad:sml,space:sml}
  
  row_base = widget_base(onbase,/row)
  
  base1 = widget_base(row_base,/column)
  
  ;;
  ;; HELP, RESET buttons
  ;;
  row_1 = widget_base(base1,/row)
  help = widget_button(row_1,value='Help',uvalue='HELP')
  reset = widget_button(row_1,value='Reset sliders',$
                        uvalue='RESET')
  ;;
  ;; Range based on *visible* values or *all* values?
  ;;
  
  range_b = widget_base(base1,/column,/frame)
  
  label = widget_label(range_b,value='Range calculation based on:')
  rangerow = widget_base(range_b,/row)
  dummy = widget_label(rangerow,value=' ')
  rangeon = cw_flipswitch(rangerow,value=['all points','visible points'],$
                          uvalue=['ALL','VISIBLE'])
  IF NOT info.ext.allpoints THEN widget_control,rangeon,set_value='VISIBLE'
  
  ;;
  ;; Missing
  ;;
  
  mib = widget_base(base1,/column,/frame)
  label = widget_label(mib,value='MISSING pixels')
  mib_row = widget_base(mib,/row)
  label = widget_label(mib_row,value='  Value:')
  missb = cw_enterb(mib_row,value=trim(info.ext.missing),uvalue='MISSING',$
                    instruct='Enter value for MISSING pixels')
  
  mib_row2 = widget_base(mib,/row)
  label = widget_label(mib_row2,value='  Comparison:')
  comps = ['=','<','>']
  miss_comp = cw_flipswitch(mib_row2,value=comps,uvalue='MISS'+comps)
  
  ;;
  ;; Linear/Log/exponential scale
  ;; 
  
  types = ['LINEAR','LOGARITHMIC']
  
  log_id = cw_flipswitch(base1,value='Type: '+types,uvalue=types)
  
  IF info.ext.logarithmic THEN widget_control,log_id,set_value='LOG'
  
  ;;
  ;; Range sliders
  ;;
  
  slib_hi = widget_base(row_base,/column)
  dummy = widget_label(slib_hi,value='High')
  slid_hi = widget_slider(slib_hi,/vertical,/drag,ysize=400,/suppress_value,$
                          maximum=150,minimum=-50,uvalue='HIGHFRAC')
  widget_control,slid_hi,$
     set_value=xplotscale_nonlin(info.ext.highfrac,/reverse)
  info.int.highfrac_id = slid_hi
  
  slib_lo = widget_base(row_base,/column)
  dummy = widget_label(slib_lo,value='Low')
  slid_lo = widget_slider(slib_lo,/drag,/vertical,ysize=400,/suppress_value,$
                          maximum=150,minimum=-50,uvalue='LOWFRAC')
  widget_control,slid_lo,$
     set_value=xplotscale_nonlin(info.ext.lowfrac,/reverse)
  
  info.int.lowfrac_id = slid_lo
  
  
END

;
; Main program
;
FUNCTION xplotscale,SCALE_ID,DATA,RANGE,$
                    title=title,$
                    allpoints=allpoints,highfrac=highfrac,lowfrac=lowfrac,$
                    missing=missing,comp_missing=comp_missing, $
                    logarithmic=logarithmic,$
                    signal=signal,destroy=destroy, $
                    xoffset=xoffset,yoffset=yoffset,$
                    group_leader=group_leader,$
                    $ ;; These only have defaults when creating the compound.
                    iconify=iconify,map=map,show=show 
  
  ON_ERROR,2
  IF !debug NE 0 THEN ON_ERROR,0
  
  ;; 
  ;; Defaults (MISSING/COMP_MISSING is handled later)
  ;; 
  default,title,'XPLOTSCALE'
  default,allpoints,0
  default,highfrac,105.0
  default,lowfrac,-5.0
  
  default,logarithmic,0
  
  default,signal,0L
  
  default,xoffset,0L
  default,yoffset,0L
  default,group_leader,0L
  
  ;;
  ;; Parameter checking
  ;;
  parcheck,title,        0,typ(/str),0,    'TITLE'
  parcheck,highfrac,     0,typ(/rea),0,    'HIGHFRAC'
  parcheck,lowfrac,      0,typ(/rea),0,    'LOWFRAC'
  parcheck,signal,       0,typ(/lon),[0,1],'SIGNAL'
  
  logarithmic = KEYWORD_SET(logarithmic)
  allpoints = keyword_set(allpoints)
  
  IF n_params() LT 2 THEN BEGIN 
     ;;
     ;; These defaults should not be effective if we're doing a scaling
     ;;
     default,missing,-1L
     default,comp_missing,0
     parcheck,missing,      0,typ(/rea),0,    'MISSING'
     parcheck,comp_missing, 0,typ(/nat),0,    'COMP_MISSING',MINVAL=-1,MAXVAL=1
  END
  
  ;; What to do?
  
  IF N_PARAMS() GT 0 THEN BEGIN
     ;; This means we have to do a job.
     
     ;; Check ID
     parcheck,SCALE_ID,1,typ(/lon),0,'SCALE_ID'

     IF handle_info(SCALE_ID,/valid_id) EQ 0 THEN  $
        MESSAGE,"Invalid SCALE_ID passed to xplotscale"
     
     handle_value,SCALE_ID,info,/no_copy
     IF N_ELEMENTS(INFO) EQ 0 THEN  $
        MESSAGE,"SCALE_ID doesn't point to a scale_info structure"
     
     ;; Here we definitely have a valid ID
     
     IF KEYWORD_SET(destroy) THEN BEGIN
        ;; Destroy toplevel widget if it's still alive
        WIDGET_CONTROL,info.int.wid,/destroy,bad_id=bad
        
        ;; Fetch tucked-away data, free handles
        handle_value,info.int.signals,dummy,/no_copy
        handle_free,info.int.signals
        handle_free,SCALE_ID
        RETURN,bad
     END
     
     IF N_PARAMS() GE 2 THEN BEGIN
        ;;
        ;; Two parameters -- do a scaling and  return
        ;;
        IF n_elements(missing) EQ 1 THEN info.ext.missing = missing
        scale = xplotscale_scale(info,data,range)
        missing = info.ext.missing
        handle_value,SCALE_ID,info,/set,/no_copy
        RETURN,scale
     END
     
     ;;
     ;; One parameter - possibly adding an event hook
     ;;
     
     IF signal(0) NE 0L THEN BEGIN
        ;;
        ;; Add event hook(s)
        ;; 
        handle_value,info.int.signals,eventarr,/no_copy
        IF N_ELEMENTS(eventarr) EQ 0 THEN eventarr = [signal] $
        ELSE                              eventarr = [eventarr,signal]
        handle_value,info.int.signals,eventarr,/set,/no_copy
        
        ;; Don't do anything more, put back status and return
        handle_value,SCALE_ID,info,/set,/no_copy
        RETURN,0
     END
     
     ;; adjust show/map/iconfiy status and
     ;; exit if no problem
     
     bad = 0L
     
     IF NOT xalive(info.int.wid) THEN GOTO,new_widget
     
     IF N_ELEMENTS(show) NE 0 THEN $
        WIDGET_CONTROL,info.int.wid,show=show,bad_id=bad
     IF bad NE 0 THEN GOTO,NEW_WIDGET
     
     IF N_ELEMENTS(map) NE 0 THEN $
        WIDGET_CONTROL,info.int.wid,map=map,bad_id=bad
     IF bad NE 0 THEN GOTO,NEW_WIDGET
     
     IF N_ELEMENTS(iconify) NE 0 THEN $
        WIDGET_CONTROL,info.int.wid,iconify=iconify,bad_id=bad
     
     IF bad EQ 0L THEN BEGIN
        handle_value,SCALE_ID,info,/set,/no_copy
        RETURN,0
     END
     
     ;; Since there was a problem with our widget, we'll regenerate it:
     GOTO,NEW_WIDGET
  END
  
  ;; If we ever get here, we need to create a...
  ;;
  ;; NEW XPLOTSCALE object
  ;; 
  
  IF N_ELEMENTS(SCALE_ID) EQ 0 THEN BEGIN
     SCALE_ID = HANDLE_CREATE()
     handle_killer_hookup,scale_id,group_leader=group_leader
  END
  
  handle_value,SCALE_ID,info,/No_copy
  
  IF N_ELEMENTS(info) EQ 0 THEN BEGIN 
     ;;
     ;; Create new info structure -- new scaling object
     ;; 
     ext = {$ ;; xplotscale_ext
            allpoints        : allpoints,$
            highfrac         : double(highfrac),$
            lowfrac          : double(lowfrac),$
            missing          : double(missing), $           ;;
            comp_missing     : comp_missing, $
            logarithmic      : logarithmic $
           }
     
     int = {$ ;; xplotscale_internal
            group       : group_leader,$
            title       : title,$
            wid         : 0L, $               ;; Widget ID of TLB
            missing_id  : 0L, $               ;; WID of missing value
            missingmenu : 0L, $               ;; Menu with Exact/above/below
            highfrac_id : 0L, $               ;; High fraction slider id
            lowfrac_id  : 0L, $               ;; Low fraction slider id
            log_id      : 0L,$                ;; ID of LOGARITHMIC button
            signals     : handle_create() $   ;; Where to send events
           }
     handle_killer_hookup,int.signals,group_leader=group_leader
     
     info = {$ ;; 
             int : int,$                     ;; Internal
             ext : ext $                     ;; Editable
            }
  END
  
  ;; If we got a (list of) signal base(s) to inform, we should store
  ;; their ID's
  
  IF signal(0) NE 0L THEN BEGIN
     handle_value,info.int.signals,eventarr,/no_copy
     IF N_ELEMENTS(eventarr) EQ 0 THEN eventarr = [signal] $
     ELSE                              eventarr = [eventarr,signal]
     handle_value,info.int.signals,eventarr,/set,/no_copy
  END
  
  ;; We have created the scaling object. If the widget is supposed to be
  ;; unmapped then we should not construct it anyway.
  ;; 
  ;; Slightly spaghetti....
  ;; 
  
  ;; Default  is to actually show it...
  ;; 
  default,MAP,1
  
  IF NOT KEYWORD_SET(map) THEN GOTO,DONT_REGISTER
  
NEW_WIDGET:
  
  IF since_version('4.0') THEN sml = 1 ELSE sml = 0
  tight = {xpad:sml,ypad:sml,space:sml}
  
  ;;
  ;; Ok, so we (re-)generate the widget.
  ;;
  
  IF xalive(info.int.group) THEN group_leader = info.int.group $
  ELSE group_leader = 0L
  
  base = WIDGET_BASE(/column,title=title,uvalue=SCALE_ID, $
                     xoffset=xoffset,yoffset=yoffset, $
                     group_leader=group_leader)
  info.int.wid = base
  
  xplotscale_makebase,info,base
  
  ;;
  ;; Bottom row buttons
  ;;
  
  row = WIDGET_BASE(base,/row)
  
  ;; This way of making a pulldown menu is just as easy as the blasted
  ;; cw_pdmenu
  
  dummy = WIDGET_BUTTON(row,value='Iconify',uvalue='ICONIFY')
  dummy = WIDGET_BUTTON(row,value='Hide window',uvalue='KILL')
  
  ;; This has to be done in the right order...
  
  default,map,1
  default,show,1
  default,iconify,0
  
  WIDGET_CONTROL,base,/realize  ;,map=map,show=show,iconify=iconify
  
  WIDGET_CONTROL,base,iconify=iconify
  WIDGET_CONTROL,base,show=show
  WIDGET_CONTROL,base,map=map
  
  XMANAGER,'XPLOTSCALE',base,/just_reg
  
DONT_REGISTER:
  
  handle_value,SCALE_ID,info,/set,/no_copy
  IF N_PARAMS() EQ 0 THEN RETURN,SCALE_ID
  RETURN,0
  
END



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'xplotscale.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
