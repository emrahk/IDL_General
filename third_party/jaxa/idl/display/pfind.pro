;+
; Project     : SOHO - CDS     
;                   
; Name        : PFIND()
;               
; Purpose     : Find Plot Region ID corresponding to an event.
;               
; Explanation : PFIND is used to return the ID of any plot region that
;               has ben stored with PSTORE, whose clip coordinates include
;               the position of the supplied event's coordinates.
;
; Use         : PFIND, EVENT [,FOUND]
;    
; Inputs      : EVENT : A WIDGET_DRAW event.
;
; Opt. Inputs : None.
;               
; Outputs     : Return value: The Plot Region ID, or -1 if none found.
;               
; Opt. Outputs: FOUND: This is set to 1 if a region was found, 0 if not.
;               
; Keywords    : PLOT_NUMBER: Set to a named variable to return the plot number
;                            that was sent to PSTORE().
;
;               CURRENT: Set to indicate that the event only contains
;                        information ; on X/Y coordinates, and that the
;                        current plot window ; should be searched.
;
; Calls       : 
;
; Common      : WSTORE
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Utility, Graphics
;               
; Prev. Hist. : None.
;
; Written     : Stein Vidar Hagfors Haugan, May 1994
;               
; Modified    : Version 2, SVHH, 22 January 1997
;                       Removed dependency on CDSNOTIFY
;                       
; Version     : 1, May 1994
;-            


FUNCTION pfind,event,found,current=current,plot_number=plot_number
  common wstore,D,P,N,X,Y,dxx,dyy
  
  On_Error,0
  
  IF Keyword_SET(current) THEN BEGIN
      originator_window = !D.window
      xc = !P.clip(0)+1
      yc = !P.clip(1)+1
  END ELSE BEGIN
      Widget_CONTROL,event.id,Get_VALUE=originator_window
      xc = event.x
      yc = event.y
  EndELSE
  
  found=0
  
  IF N_elements(D) eq 0 THEN return,-1
  
  candidates = where(D.window eq originator_window $
                     and xc ge P.clip(0) and xc le P.clip(2) $
                     and yc ge P.clip(1) and yc le P.clip(3),count)
  
  IF count eq 0 THEN BEGIN
      found=0
      return,-1
  END
  
  IF count gt 1 THEN BEGIN
     message,'More than one window met the criteria',/continue
     print,string(7b)
     w = [candidates(count-1)]
  END ELSE w = candidates
  
  found = 1
  plot_number = N(w(0))
  return,w(0)
  
END
