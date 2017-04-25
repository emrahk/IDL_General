;+
; Project     : SOHO - CDS     
;                   
; Name        : CW_INFILTRATE
;               
; Purpose     : Infiltrate a widget hierarchy to tap into its events.
;               
; Explanation : CW_INFILTRATE allows a widget program to "listen in" on the
;               events processed by all other widget hierarchies. This is used
;               by XRECORDER to record all "native" events of all widgets into
;               a script file, and as a help to replay the events as a
;               demonstration.
;
;               CW_INFILTRATE uses timer events to periodically check for
;               newly created widget hierarchies. It will find both registered
;               and unregistered widgets. As a "free" service, the list of
;               unregistered top level widgets is pointed to by the handle
;               returned through the keyword ROGUE. If the value of that
;               handle is undefined, no existing unregistered top level
;               widgets have been found.
;
;               For each widget hierarchy found, CW_INFILTRATE goes through
;               all of its constituent widgets (buttons, lists, texts, draw
;               windows etc, but *not* bases) and inserts a special event
;               function (or procedure).
;
;               Every time a "native" event is generated (one for which
;               event.id EQ event.handler), the special event handler function
;               will call yoour "agent" procedure, with the event and the ID
;               of the CW_INFILTRATE widget as parameters. You may use the
;               UVALUE of the CW_INFILTRATE widget at your discretion.
;
;               Your agent procedure may alter the event, or set it equal to
;               anything except a structure, which will result in the event
;               "disappearing".
;
;               Since TIMER events cannot be scheduled on unrealized widgets,
;               it is the calling program's responsibility to set up the first
;               timer event after the widget hierarchy to which CW_INFILTRATE
;               belongs has been realized.
;
; Use         : ID = CW_INFILTRATE(BASE,AGENT_PROC [,/LIST] [,ROGUE=ROGUE])
;    
; Inputs      : BASE : The base on which to put the compound widget.
;
;               AGENT_PROC : String with the name of the "agent"
;                            procedure. This procedure should take two
;                            arguments: the event being snatched and the ID of
;                            the CW_INFILTRATE widget.
; 
; Opt. Inputs : None.
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : LIST : Set to make CW_INFILTRATE show a listing of all
;                      XMANAGER-registered widgets (like XMTOOL), and allow
;                      the user to XWIDUMP the contents of that widget
;                      hierarchy to the TTY.
;
; Calls       : None.
;
; Common      : CW_INFILTRATE_STORE : Keeps the ID of the CW_INFILTRATE
;                                     widget.
;               
; Restrictions: Pretty special.... uses XMANAGER common block, and will
;               therefore not work in IDL 5.0 or later.
;
;               Only one copy of CW_INFILTRATE may exist at any time.
;               
; Side effects: Catches all basic events generated in the infiltrated widget
;               hierarchies. 
;               
; Category    : Widgets
;               
; Prev. Hist. : 
;
; Written     : Stein V. H. Haugan, UiO, March 1997
;               
; Modified    : Version 1, SVHH, May 1997
;                       Cleaned up.
;
; Version     : 1, 26 May 1997
;-            




FUNCTION cw_infiltrate_efunc,ev
  
  ;; These functions don't have the luxury of their own uvalue
  COMMON cw_infiltrate_store,cw_infiltrate_id
  
  
  ;; Simply return non-original events.
  IF ev.handler NE ev.id THEN return,ev
  
  widget_control,widget_info(cw_infiltrate_id,/child),get_uvalue=status
  
  on_error,0
  
  call_procedure,status.agent,ev,0L+cw_infiltrate_id
  
  ;; Make the original call...or pass on
  
  i = -1L
  
  ;; Only pass on structure events.
  sz = size(ev)
  IF sz(sz(0)+1) EQ 8 THEN BEGIN 
     handle_value,status.ids_h,ids,/no_copy
     i = (where(ids EQ ev.id))(0)
     handle_value,status.ids_h,ids,/set,/no_copy
  END
  IF i EQ -1L THEN return,ev
  
  handle_value,status.func_h,func,/no_copy
  funct = func(i)
  handle_value,status.func_h,func,/set,/no_copy
  
  IF funct NE '' THEN return,call_function(funct,ev) $
  ELSE BEGIN
     return,ev
  END
  
  
END

  
  
PRO cw_infiltrate_eproc,ev
  
  ;; These functions don't have the luxury of their own uvalue
  COMMON cw_infiltrate_store,cw_infiltrate_id
  
  on_error,0
  
  widget_control,widget_info(cw_infiltrate_id,/child),get_uvalue=status
  
  
  ;; Give original events to the agent
  IF ev.handler EQ ev.id THEN $
     call_procedure,status.agent,ev,0L+cw_infiltrate_id
  
  ;; Make original call..
  
  i = -1L
  
  ;; Only pass on structure events.
  sz = size(ev)
  IF sz(sz(0)+1) EQ 8 THEN BEGIN 
     handle_value,status.ids_h,ids,/no_copy
     i = (where(ids EQ ev.id))(0)
     handle_value,status.ids_h,ids,/set,/no_copy
  END
  
  IF i EQ -1L THEN return ;;?
  
  handle_value,status.proc_h,proc,/no_copy
  proce = proc(i)
  handle_value,status.proc_h,proc,/set,/no_copy
  
  IF proce NE '' THEN call_procedure,proce,ev
END



;; 
PRO cw_infiltrate_thisone,status,base
  
  handle_value,status.ids_h,ids,/no_copy
  handle_value,status.func_h,func,/no_copy
  handle_value,status.proc_h,proc,/no_copy
  
  IF n_elements(ids) GT 0 THEN BEGIN
     IF (where(ids EQ base))(0) NE -1 THEN BEGIN
        ;; Already infiltrated
        GOTO,finish
     END
  END
  
  xwidump,base,dummy,nid,/no_text
  n = n_elements(nid)
  
  nfunc = strarr(n)
  nproc = strarr(n)
  FOR i = 0L,n-1 DO BEGIN
     nfunc(i) = widget_info(nid(i),/event_func)
     nproc(i) = widget_info(nid(i),/event_pro)
     wtype = widget_info(nid(i),/type)
     IF wtype NE 0 THEN BEGIN 
        IF nproc(i) EQ '' THEN $
           widget_control,nid(i),event_func='cw_infiltrate_efunc' $
        ELSE $
           widget_control,nid(i),event_pro='cw_infiltrate_eproc'
     END
  END
  
  IF n_elements(ids) EQ 0 THEN BEGIN
     ids = nid
     func = nfunc
     proc = nproc
  END ELSE BEGIN
     validix = where(widget_info(ids,/valid_id))
     IF validix(0) EQ -1 THEN BEGIN
        ids = nid
        func = nfunc
        proc = nproc
     END ELSE BEGIN
        ids = [ids(validix),nid]
        func = [func(validix),nfunc]
        proc = [proc(validix),nproc]
     END 
  END
  
finish:
  handle_value,status.ids_h,ids,/set,/no_copy
  handle_value,status.func_h,func,/set,/no_copy
  handle_value,status.proc_h,proc,/set
END


PRO cw_infiltrate_checkup,status,ev
  ;; We need the XMANAGER common block for this.
  COMMON MANAGED, ids, names, nummanaged, inuseflag, backroutines, $
     backids, backnumber, nbacks, validbacks, blocksize, cleanups, outermodal
  
  ;; Set up next event straight away..
  widget_control, ev.id, timer = 1
  
  ;; Get the last list of infiltrated widgets
  handle_value,status.mylast_h,mylast
  
  newids = ids(where(ids NE 0))
  
  update = 1
  IF n_elements(mylast) GT 1 THEN BEGIN
     ;; if there are *no* differences between old and new 
     ;; lists, update is not necessary
     IF n_elements(mylast) EQ n_elements(newids) AND $
        total([mylast] NE [newids]) EQ 0 THEN update = 0
  END
  
  IF update THEN BEGIN
     ;; Update list, if it exists..
     IF status.list NE 0L THEN $
        widget_control, status.list,set_value=names(where(names NE ''))
     
     mylast = newids
     
     handle_value,status.mylast_h,mylast,/set,/no_copy
     
     ;; Make sure we've infiltrated all currently managed applications
     validix = where(ids NE 0)
     FOR s=0L,n_elements(validix)-1 DO BEGIN
        cw_infiltrate_thisone,status,ids(validix(s))
     END
  END
  
  ;; Finding rogue widgets
  
  ;; Find next ID in line..
  test = widget_base()
  widget_control,test,/destroy
  
  handle_value,status.ids_h,infiltrated_ids,/no_copy
  handle_value,status.rogue_h,rogue,/no_copy
  IF n_elements(rogue) NE 0 THEN BEGIN
     validix = where(widget_info(rogue,/valid_id),nrogue)
     IF nrogue GT 0 THEN rogue = rogue(validix) $
     ELSE                dummy = temporary(rogue)
  END ELSE nrogue = 0
  
  FOR id = status.lastcheck_id+1,test-1 DO BEGIN
     infiltrated = ((where(id EQ infiltrated_ids))(0) NE -1)
     IF NOT infiltrated THEN BEGIN
        IF widget_info(id,/valid_id) THEN BEGIN
           IF widget_info(id,/type) EQ 0 THEN BEGIN
              IF widget_info(id,/parent) EQ 0 THEN BEGIN
                 print,"Rogue widget found"
                 IF nrogue EQ 0 THEN rogue = [id] $
                 ELSE                rogue = [rogue,id]
                 nrogue = nrogue+1
                 handle_value,status.ids_h,infiltrated_ids,/set,/no_copy
                 cw_infiltrate_thisone,status,id
                 handle_value,status.ids_h,infiltrated_ids,/no_copy
              END 
           END 
        END
     END
  END 
  
  status.lastcheck_id = test
  
  IF n_elements(rogue) NE 0 THEN $
     handle_value,status.rogue_h,rogue,/set,/no_copy
  
  handle_value,status.ids_h,infiltrated_ids,/set,/no_copy
END



PRO cw_infiltrate_event,ev
  ;; We need the XMANAGER common block for this.
  COMMON MANAGED, ids, names, nummanaged, inuseflag, backroutines, $
     backids, backnumber, nbacks, validbacks, blocksize, cleanups, outermodal
     
  storage = widget_info(ev.handler,/child)
  widget_control,storage,get_uvalue=status,/no_copy
  
  IF ev.id EQ ev.handler THEN BEGIN
     ;; This means it was a timer event.
     cw_infiltrate_checkup,status,ev
  END ELSE BEGIN
     widget_control,ev.id,get_uvalue = uval
  
     IF uval EQ "DUMP" THEN BEGIN
        select = widget_info(status.list,/list_select)
        IF select NE -1 THEN BEGIN
           ix = where(ids GT 0)
           xwidump,ids(ix(select))
        END
     END 
  END
  
  widget_control,storage,set_uvalue=status,/no_copy
END

PRO cw_infiltrate_clean,id
  widget_control,id,get_uvalue=status,/no_copy
  IF n_elements(status) NE 0 THEN BEGIN 
     tags = tag_names(status)
     ix = where(strpos(tags,'_H') EQ strlen(tags)-2,nhandles)
     FOR i = 0L,nhandles-1 DO BEGIN
        IF handle_info(status.(ix(i)),/valid_id) THEN BEGIN
           handle_free,status.(ix(i))
        END 
     END 
  END
  
END


FUNCTION cw_infiltrate,base,agent,list=list,rogue=rogue
  
  ;; The event functions don't have the luxury of their own uvalue
  COMMON cw_infiltrate_store,cw_infiltrate_id
  
  IF n_elements(cw_infiltrate_id) EQ 1 THEN BEGIN
     IF widget_info(cw_infiltrate_id,/valid_id) THEN BEGIN
        message,"Another CW_INFILTRATE widget is already present"
     END
  END
  
  mybase = widget_base(base,/column,event_pro='cw_infiltrate_event') 
  cw_infiltrate_id = mybase
  
  storage_base = widget_base(mybase,map=0,kill_notify='cw_infiltrate_clean')
  
  IF keyword_set(list) THEN BEGIN
     listlabel = WIDGET_LABEL(mybase,VALUE = "Managed Widgets")
     list = WIDGET_LIST(mybase, YSIZE = 10,UVALUE = "LIST")
     rowbase = WIDGET_BASE(mybase,/ROW)
     dumper = widget_button(rowbase,value='Dump',uvalue='DUMP')
  END ELSE BEGIN
     list = 0L
  END
  
  rogue = handle_create()
  
  status = {ids_h : handle_create(),$
            func_h : handle_create(),$
            proc_h : handle_create(),$
            mylast_h : handle_create(),$
            lastcheck_id : 0L,$
            rogue_h : rogue,$
            agent : agent,$
            selected:-1L,$
            list:list}
  
  widget_control,storage_base,set_uvalue=status
  return,mybase
  
END


PRO test_infiltrate_event,ev,id
  
  help,ev,id,/str
  
END


PRO test_infiltrate
  base = widget_base(/column)
  
  infilt = cw_infiltrate(base,'test_infiltrate_event',/list)
  
  widget_control,base,/realize
  
  widget_control,infilt,timer=1
  
  print,infilt
  xmanager,'test_infiltrate',base,/immune,/just_reg
 
END



