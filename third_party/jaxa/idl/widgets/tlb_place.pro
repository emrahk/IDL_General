;+
; Project     : SOHO - CDS     
;                   
; Name        : TLB_PLACE()
;               
; Purpose     : Find the "optimal" coordinates of a new top level base
;               
; Explanation : Given the (approximate) size of a new widget, and either
;		a widget EVENT or a SERTS window descriptor, the "best"
;		upper-left position of a new widget base is returned.
;
;		The position is either above, right, below or to the 
;		left of the calling DRAW-window, the SERTS display window,
;		or the window's top level base. To force the position
;		outside the top level base, use /OUTSIDE. To align the
;		new window with the position of the cursor (only for
;		DRAW EVENTS) use /CURSOR.
;               
; Use         : POS = TLB_PLACE(XSIZE,YSIZE,EVENT=EVENT)
;		or
;		POS = TLB_PLACE(XSIZE,YSIZE,SERTSW=SERTSW)
;    
; Inputs      : XSIZE,
;		YSIZE = The (approximate) size of the new widget
;
; Opt. Inputs : 
;               
; Outputs     : 
;               
; Opt. Outputs: 
;               
; Keywords    : EVENT : For a WIDGET_DRAW event, the new position
;			will be outside the DRAW window, /OUTSIDE is
;			not set. If the EVENT.X/Y point is inside
;			a SERTS display, the display CLIP coordinates 
;			are taken as the area that shouldn't be marked.
;			For any other event type, the new position 
;			will be outside the EVENT.ID's top level base.
;
;	       	PWINDOW: Specifies the plot window region to keep
;			outside of.
;
;		SERTSW : Specify the SERTS window that the new base
;			should be placed outside of.
;
;		CURSOR : Set to align the new window position with the
;			cursor.
;
;		OUTSIDE : Set to always place the new window outside the
;			top level base area.
;
;		PRIORITY: Specify the most-wanted positions in an
;			array of integers, 0 means above, 1=right
;			2=below, 3=left. That is, PRIORITY=[2,3] means
;			"try to fit this in below, or if that's not
;			possible, on the left".
;
; Calls       : CDSNOTIFY,FIND_SERTSW(),SETWINDOW,SET_SERTSW,TLB_PLACE()
;		TRIM()
;
; Common      : None.
;               
; Restrictions: Needs a valid EVENT or SERTS window.
;               
; Side effects: None known.
;               
; Category    : CDS, QL, DISPLAY, UTILITY
;               
; Prev. Hist. : Extracted from the QLZOOM/QLPROFILE routines.
;
; Written     : Stein Vidar Hagfors Haugan, 16 Dec. 1993
;               
; Modified    : 
;
; Version     : 1.0
;-            

;
; Determine where to place top level base....
;
FUNCTION tlb_place,xsize,ysize,event=event,sertsw=sertsw,$
	cursor=cursor,outside=outside,priority=priority,pwindow=pwindow
  
  IF NOT Keyword_SET(event) and	NOT Keyword_SET(sertsw)	$
	and N_elements(pwindow)	eq 0 THEN BEGIN
      cdsnotify,group=0L,'TLB_PLACE must have either EVENT, PWINDOW or SERTSW'
      return,[0,0]
  EndIF
  
  
  IF N_elements(priority) eq 0 THEN priority=[0,1,2,3] $
					  $ ; Above, left, below, right
  ELSE priority	= [priority,0,1,2,3]
  
;
; First determine the box that we have to keep outside of...
;
  
  c_offset = [0,0]  ; Offset due to cursor position
  
  DEVICE,get_screen_size = screen_size
  
  
  IF Keyword_SET(event)	THEN BEGIN
      type = Widget_INFO(event.id,/type)
      IF type ne 4 or Keyword_SET(outside) THEN	BEGIN
	  Widget_CONTROL,event.id,tlb_get_offset=upleft
	  Widget_CONTROL,event.id,tlb_get_size=tlb_size
	  lowright = upleft + tlb_size
	  IF type eq 4 and Keyword_SET(cursor) THEN c_offset=[event.x,event.y]
      END ELSE BEGIN
;	  pwindow = pfind(event,found)
;	  IF NOT found THEN BEGIN
	  Widget_CONTROL,event.id,Get_VALUE=window
	  SetWindow,window
	  DEVICE,get_window_position=upleft
	  ; From low-left to top-left
	  upleft(1) = screen_size(1) - upleft(1) - !D.y_Vsize
	  lowright = upleft + [!D.X_VSIZE,!D.Y_VSIZE]
	  IF Keyword_SET(cursor) THEN c_offset = [event.x,event.y]
;	  END  ELSE BEGIN
;	      prestore,pwindow
;	      DEVICE,get_window_position=upl
;	      ; From low-left to top-left
;not yet      upl(1) = screen_size(1) -	upl(1) - !D.y_Vsize
;	      upleft = upl + [!P.CLIP(0),!D.Y_vsize-!P.CLIP(3)]
;	      lowright = upl + [!P.CLIP(2),!D.Y_vsize-!P.CLIP(1)]
;	      IF Keyword_SET(cursor) THEN $
;		      c_offset = [event.x-!P.CLIP(0),!P.CLIP(3)-event.y]
;	  END
      END
  END ELSE IF N_elements(pwindow) gt 0 THEN BEGIN
      prestore,pwindow
      DEVICE,get_window_position=upl
      ; From low-left to top-left
      upl(1) = screen_size(1) -	upl(1) - !D.y_Vsize
      upleft = upl + [!P.CLIP(0),!D.Y_VSIZE-!P.CLIP(3)]
      lowright = upl + [!P.CLIP(2),!D.Y_VSIZE-!P.CLIP(1)]
      IF Keyword_SET(cursor) and Keyword_SET(event) THEN $
	      c_offset = [event.x-!P.CLIP(0),!P.CLIP(3)-event.y]
  END ELSE BEGIN ; We must have a SERTS window
      set_sertsw,sertsw
      DEVICE,get_window_position=upl
      ; From low-left to top-left
      upl(1) = screen_size(1) -	upl(1) - !D.y_Vsize
      upleft = upl + [!P.CLIP(0),!D.Y_VSIZE-!P.CLIP(3)]
      lowright = upl + [!P.CLIP(2),!D.Y_VSIZE-!P.CLIP(1)]
      IF Keyword_SET(cursor) and Keyword_SET(event) THEN $
	      c_offset = [event.x-!P.CLIP(0),!P.CLIP(3)-event.y]
  END
  
;
; Now we should find a place outside the box [ upleft, lowright ]
;
  
  FOR i=0,N_elements(priority)-1 DO BEGIN
      CASE priority(i) OF
	  
	  0 :$ ; above
	  IF upleft(1) gt ysize	THEN BEGIN
	      xpos = upleft(0) + c_offset(0)
	      ypos = upleft(1) - ysize
	      return,[xpos,ypos]
	  END
	  
	  1 :$ ; right
	  IF screen_size(0)-lowright(0)	gt xsize THEN BEGIN
	      xpos = lowright(0)
	      ypos = upleft(1) + c_offset(1)
	      return,[xpos,ypos]
	  END
	  
	  2 :$ ; below
	  IF screen_size(1)-lowright(1)	gt ysize THEN BEGIN
	      xpos = upleft(0) + c_offset(1)
	      ypos = lowright(1)
	      return,[xpos,ypos]
	  END
	  
	  3 :$ ; right
	  IF upleft(0) gt xsize	THEN BEGIN
	      xpos = upleft(0)-xsize
	      ypos = upleft(1)+c_offset(1)
	      return,[xpos,ypos]
	  END
      EndCASE
  EndFOR
  
  return,[0,0] ; No solution found - dump in the upper left corner
  
END


