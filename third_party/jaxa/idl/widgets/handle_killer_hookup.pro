;+
; Project     : SOHO - CDS     
;                   
; Name        : HANDLE_KILLER_HOOKUP
;               
; Purpose     : Hook up handles for automatic freeing when widget dies.
;               
; Explanation : Since unused but non-freed handles clogs up IDL's handle
;               hash table, it is important that handles used by widget
;               applications are freed when the application dies.
;
;               This routine stores handle ID numbers on unrealized widget
;               bases that will be killed if the supplied GROUP_LEADER
;               base is destroyed. It uses the KILL_NOTIFY keyword to invoke
;               the routine HANDLE_KILLER when the widget base is destroyed.
;               HANDLE_KILLER will free all the handles that have been hooked
;               up on that widget base.
;
;               If no group leader is supplied, an unrealized widget without a
;               group leader will be used as group leader, and the cleanup
;               operation will be invoked whenever WIDGET_CONTROL,/RESET is
;               performed.
;                
;               
; Use         : HANDLE_KILLER_HOOKUP,HANDLE [,GROUP_LEADER=GROUP_LEADER]
;    
; Inputs      : HANDLE : The handle(s) to be automatically freed.
;               
; Opt. Inputs : None.
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : GROUP_LEADER : Normally the (top base of) widget that
;                              creates the handle. When GROUP_LEADER dies,
;                              HANDLE will be freed automatically.
;
; Calls       : DEFAULT, DELVARX, HANDLE_KILLER (indirectly).
;
; Common      : HANDLE_KILLER_CACHE : Shared with HANDLE_KILLER, to keep the
;                                     number of unrealized bases down.
;               
; Restrictions: Works best with widget applications, slightly dangerous
;               when used for stuff you don't want to loose in case of
;               a crash etc.
;
;               Needs to be able to use widgets.
;               
; Side effects: Generates some unrealized widget bases.
;               
; Category    : Utility, Handles
;               
; Prev. Hist. : None.
;
; Written     : s.v.h.haugan@astro.uio.no, UiO, 2 August 1996
;               
; Modified    : Version 2, SVHH, 17 September 1997
;                       HANDLE may be an array of handles.
;
; Version     : 2, 17 September 1997
;-            

PRO handle_killer_hookup,handle,group_leader=group_leader,reset=reset
  
  ;; LEADERS is an array of widget ID's who have registered one or
  ;; more handles to be killed when they die.
  ;;
  ;; CALLBACKS are widget bases created with their corresponding LEADERS as
  ;; group leaders, so they will die whenever their leader dies. The callback
  ;; bases have an array of handles as their uvalues. When the callback bases
  ;; are killed - their callback routines will free all valid handles in that
  ;; array.
  COMMON handle_killer_cache,leaders,callbacks
  
  ;; Debug variable...
  noisy = 0
  
  IF noisy THEN PRINT,"HOOK: ",FORMAT='($,A)'
  
  ;; Reset the system if requested
  
  IF KEYWORD_SET(reset) THEN BEGIN
     IF noisy THEN PRINT,"RESET -- ", FORMAT='($,A)'
     delvarx,leaders,callbacks
     IF N_ELEMENTS(handle) EQ 0 THEN BEGIN
        IF noisy THEN PRINT,"DONE"
        RETURN
     END
  END 
  
  ;; Initialize data structure if necessary
  
  IF N_ELEMENTS(leaders) EQ 0 THEN BEGIN
     IF noisy THEN PRINT,"INIT - ",FORMAT='($,A)'
     leaders = [WIDGET_BASE()]
     callbacks = [WIDGET_BASE(group_leader=leaders(0),$
                              kill_notify='handle_killer')]
  END 
  
  ;; Check to see if anonymous group leader is alive
  IF NOT widget_info(leaders(0),/valid_id) THEN BEGIN
     leaders(0) = widget_base()
     callbacks(0) = WIDGET_BASE(group_leader=leaders(0),$
                                kill_notify='handle_killer')
  END
  
  ;; Clean up to avoid growing too big.
  
  leaders = leaders(where(widget_info(leaders,/valid_id)))
  
  ;; If no group leader is supplied -- hang it onto a loose base
  ;; This base will be killed if e.g., a widget_control,/reset
  ;; is issued
  
  default,group_leader,leaders(0)
  
  IF noisy THEN IF group_leader EQ leaders(0) THEN $
     PRINT,"Default base - ",FORMAT='($,A)'
  
  IF noisy THEN PRINT,"Leader="+trim(group_leader)+" -- ",FORMAT='($,A)'
  
  ;; Find out if the group leader already has a kill_notify base
  ;; dangling from it.
  
  ix = (WHERE(leaders EQ group_leader,count))(0)
  
  ;; If not -- make a new entry
  
  IF count EQ 0 THEN BEGIN
     IF noisy THEN PRINT,"New entry -- ",FORMAT='($,A)'
     leaders = [leaders,group_leader]
     callbacks = [callbacks,WIDGET_BASE(group_leader=group_leader,$
                                        kill_notify='handle_killer')]
     ix = N_ELEMENTS(leaders)-1
  END
  
  IF noisy THEN PRINT,"Entry #"+trim(ix)+" - ",FORMAT='($,A)'
  
  ;; Get the existing list of handles for the current base
  
  WIDGET_CONTROL,callbacks(ix),get_uvalue=handles,/no_copy
  
  ;; Add the current handles(s) to that list (or start new list)
  
  IF N_ELEMENTS(handles) EQ 0 THEN handles = [handle] $
  ELSE                             handles = [handles,handle]
  
  ;; Put the list back in place
  WIDGET_CONTROL,callbacks(ix),set_uvalue=handles,/no_copy
  
  IF noisy THEN BEGIN 
     PRINT,"Stored, HANDLE=",format='($,A)'
     print,trim(handle,'(I)'),format='('+trim(n_elements(handle))+'(A,:,","))'
     print
  END

END
