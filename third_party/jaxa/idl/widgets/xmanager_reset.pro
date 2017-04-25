;+
; Project     : SOHO - CDS     
;                   
; Name        : XMANAGER_RESET
;               
; Purpose     : Reset XMANAGER after a widget application crashes
;               
; Category    : widgets
;               
; Explanation : Useful to restart XMANAGER after a widget application
;               crashes and restarting the application fails.
;               Call this immediately after the first XMANAGER call
;               
; Syntax      : IDL> xmanager_reset
;    
; Examples    : 
;
; Inputs      : None.
;               
; Opt. Inputs : None.
;               
; Outputs     : None.
;
; Opt. Outputs: None.
;               
; Keywords    : GROUP = widget group leader
;               MODAL = if widget was called with MODAL
;               JUST_REG = if widget is just being registered
;               CRASH = name of procedure to recover from in case of crash
;               RETALL = set to not RETALL after a crash
;               
; History     : Version 1,  17-May-1997,  D M Zarro -  Written
;             : Version 2,  22-Sept-1998,  D M Zarro - Added version 5
;                                                      checks
;             : Modified, 27 February 2007, Zarro - Deprecated
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro xmanager_reset,base,group=group,just_reg=just_reg,modal=modal,$
                   no_block=no_block,crash=crash,retall=retall

;-- just bail out since this routine does more damage than good in 
;   > IDL 5

return

;----------------------------------------------------------------
modal=keyword_set(modal)
no_block=keyword_set(no_block)

;-- bring widget application and leader to foreground in case they are
;   hidden behind other applications.

if modal then xshow,base else begin
 if xalive(base) then xshow,base else xshow,group
endelse

;-- don't reset if just registering or calling from another widget app (i.e,
;   group is set) since in both cases widget events are not being directly
;   handled by current routine.

if keyword_set(just_reg) then return
if xalive(group) then return

if datatype(crash) eq 'STR' then begin
 break_file,crash,dsk,dir,cname
 cname=trim(strupcase(cname))
endif else cname=''

caller=get_caller(prev=prev)
dprint,'% prev,caller:',prev,',',caller

if (prev ne caller) and (caller ne cname) then return

;-- only reset current application if following conditions are met
;   first call to XMANAGER failed and app fails to restart (in this case
;   XMANAGER returns but event handler does not respond to events)

if xalive(base) then begin
 dprint,'% modal, no_block: ',modal,no_block
 dprint,'% fell thru to XMANAGER_RESET'
 dprint,'% called by: '+caller
 if (cname ne '') then dprint,'% last caller was: ',cname
 if (prev eq '') or (prev eq caller) or (caller eq cname) then reset=1 else reset=modal
 if reset then begin
  if xalive(base) then name=get_handler_name(base)
  if (name eq '') and (cname ne '') then name=cname
;  if xalive(base) and (name ne '') then xmanager,name,base else $
   xmanager
  if keyword_set(retall) then begin
   dprint,'% retalling...'
   retall
  endif
 endif
endif

return & end
