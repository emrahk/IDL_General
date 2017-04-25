;+
; Project     : SOHO - CDS     
;                   
; Name        : XUPDATE
;               
; Purpose     : Hassle-free (hopefully) widget_control,id,update=0/1 
;               
; Explanation : IDL v 5.0 (and 5.0.2) has some weird idea about how to handle
;               update on/off on widgets, causing e.g., bases to "blank out"
;               parts that have been added to them after they were first
;               realized (as in e.g. XCFIT).
;
;               This is an attempt to rectify that behaviour.
;
;               The intended mode of use is e.g.,
;
;
;               XUPDATE, ID, 0
;
;               <Do updates, and call routines that may modify children of ID>
;
;               XUPDATE, ID, 1
;
;               The idea is that whenever a *parent* widget has been frozen,
;               xupdate will have no effect, hopefully avoiding any clashes.
;
;               This is achieved by checking the status of the widget at the
;               time of the FREEZE operation. If UPDATE is 0 for the widget
;               that's being frozen, *nothing* will happen during the freeze
;               operation, and the widget ID is noted, so that the subsequent
;               THAW operation is also nulled (leaving the UPDATE status to be
;               controlled by the parent hierarchy).
;
;               And of course, if it's before IDL v 4.0.1, no action will ever
;               be taken....
;               
; Use         : See above.
;    
; Inputs      : Widget ID.
; 
; Opt. Inputs : None.
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
; 
; Calls       : since_version()
;
; Common      : XUPDATE_STATUS_COMMON
;               
; Restrictions: ...
;               
; Side effects: ...who knows, probably several when the next IDL version comes
;               out :-( ...
;               
; Category    : Widgets
;               
; Prev. Hist. : Lots of wasted time.
;
; Written     : Stein V. H. Haugan, 15 September 1997
;               
; Modified    : Not yet.
;
; Version     : 1, 15 September 1997
;-            
PRO xupdate,id,status
  
  COMMON XUPDATE_STATUS_COMMON,BANNED_IDS
  
  IF NOT since_version('4.0.1') THEN return
  IF n_params() NE 2 THEN message,"Use: XUPDATE,ID,STATUS"
  
  IF n_elements(banned_ids) EQ 0 THEN banned_ids = replicate(-1L,10)
  
  nexttop = id
  REPEAT BEGIN
     topbase = nexttop
     nexttop = widget_info(topbase,/parent)
  END UNTIL nexttop EQ 0L
  
  IF NOT keyword_set(status) THEN BEGIN
     IF widget_info(topbase,/update) EQ 0 THEN BEGIN
        ;; We must ban this widget from being thawed, once!
        freeix = where(banned_ids EQ -1L)
        IF freeix(0) NE -1L THEN freeix = freeix(0) $
        ELSE BEGIN 
           freeix = n_elements(freeix)
           banned_ids = [banned_ids,replicate(-1L,10)]
        END
        ;; It *should* be banned even if it's already banned.
        banned_ids(freeix) = id
     END ELSE BEGIN
        widget_control,id,update=0
     END
  END ELSE BEGIN
     
     ix = where(banned_ids EQ id)
     
     ;; If the ID is banned - ignore the update=1 operation, but lift the ban.
     
     IF ix(0) NE -1 THEN banned_ids(ix(0)) = -1L $
     ELSE                widget_control,id,update=1
     
  END
END

