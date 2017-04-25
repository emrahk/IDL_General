;+
; Project     : SOHO - CDS     
;                   
; Name        : HANDLE_KILLER
;               
; Purpose     : Kill handles hooked up with HANDLE_KILLER.
;               
; Explanation : Since unused but non-freed handles clogs up IDL's handle
;               hash table, it is important that handles used by widget
;               applications are freed when the application dies.
;
;               HANDLE_KILLER_HOOKUP stores handle ID numbers on unrealized
;               widget bases that will be killed if the supplied GROUP_LEADER
;               base is destroyed. The KILL_NOTIFY keyword is used to invoke
;               HANDLE_KILLER when the widget base is destroyed.
;               HANDLE_KILLER will free all the handles that have been hooked
;               up on that widget base.
;
; Use         : If you have to, use widget_base(kill_notify='HANDLE_KILLER')
;    
; Inputs      : ID : The base being killed, should have an array of handle IDs
;                    as its UVALUE
;               
; Opt. Inputs : None.
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
; 
; Calls       : HANDLE_INFO
;
; Common      : HANDLE_KILLER_CACHE : Shared with HANDLE_KILLER_HOOKUP, to 
;                                     keep the number of unrealized bases down.
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
; Modified    : Not yet
;
; Version     : 1, 2 August 1996
;-            

PRO handle_killer,id
  COMMON handle_killer_cache,leaders,callbacks
  
  ;; noisy = 1
  
  ;; IF noisy THEN PRINT,"Handle-killer called, BASE ID="+trim(ID)
  
  WIDGET_CONTROL,id,get_uvalue=handles
  
  IF N_ELEMENTS(handles) EQ 0 THEN BEGIN
     ;; IF noisy THEN PRINT,"No handles found!"
     RETURN
  END
  
  ;; IF noisy THEN PRINT,"Killing handles: ",FORMAT='($,A)'
  
  ;; IF noisy THEN comma = ""
  
  FOR i=0,N_ELEMENTS(handles)-1 DO BEGIN
     IF handle_info(handles(i),/valid_id) THEN BEGIN
        handle_free,handles(i)
        ;; IF noisy THEN PRINT,comma+trim(handles(i)),FORMAT='($,A)'
     END ELSE BEGIN
        ;; IF noisy THEN PRINT,comma+trim(handles(i))+"?",FORMAT='($,A)'
     END
     ;; if noisy then comma = ", "
  END
  
  ;; IF noisy THEN PRINT,""
  ;; IF noisy THEN PRINT,""
  
  ;; Clean up the common block
  
  ix = WHERE(WIDGET_INFO(callbacks,/valid_id) AND callbacks NE id,count)
  
  ;; IF noisy THEN PRINT,trim(count)+" handle callback bases are valid"
  
  IF count EQ 0 THEN handle_killer_hookup,/reset $
  ELSE IF count LT N_ELEMENTS(leaders) THEN BEGIN
     ;; IF noisy THEN PRINT,"Purging leaders/callbacks"
     leaders = leaders(ix)
     callbacks = callbacks(ix)
  END
  
  ;; IF noisy THEN PRINT
END
