;+
; Project     : SOHO - CDS     
;                   
; Name        : XSELECT
;               
; Purpose     : Force the user to select from a list or abort.
;               
; Explanation : A menu with the supplied options is generated, as
;		well as a DONE-button (to signal completion of the selection)
;		and a QUIT-button (to signal abortion of the selection).
;               
;		Menus can be either nonexclusive or exclusive.
;		A default selection can be supplied.
;
; Use         : XSELECT,OPTIONS,STATUS,ABORT (all 3 parameters needed)
;    
; Inputs      : OPTIONS:
;			A text array containing the possible selections.
;
;		STATUS:	An integer array containing the default selection,
;			STATUS( i ) eq 1 signifies that OPTION( i ) is
;			selected by default. Must have same dimensions as
;                       OPTIONS parameter.
;               
; Opt. Inputs : None.
;               
; Outputs     : STATUS:	The resulting selection array. OPTION( i ) eq 1
;			signifies selection of option no. i.
;
;		ABORT:	Set to 1 if the user aborted the selection.
;               
; Opt. Outputs: None.
;               
; Keywords    : TITLE:	String with the title of the window with the menu.
;			(default: 'Select options below')
;		
;		QUIT:	String with the text to go on the QUIT button.
;			(default: 'Quit')
;
;		DONE:	String with the text to go on the DONE button.
;			(default: 'Done')
;
;		GROUP_LEADER:
;			Standard Xmanager/Widget meaning.
;
;		X/YOFFSET: The position of the upper left corner of the
;			new base.
;
;		EXCLUSIVE/
;		NONEXCLUSIVE:
;			The type of base showing the selection buttons.
;			Default: NONEXCLUSIVE
;
;		MODAL:	Set to make the selection widget modal. 
;			See Side effects.
;
; Calls       : DATATYPE
;
; Common      : XSELECT
;               
; Restrictions: None.
;               
; Side effects: The use of the MODAL keyword causes all widget
;		DRAW windows to be blanked out.... Might be fixed
;		in later versions of IDL...? (Depending on whether
;		they see it as a bug or a feature :-)
;               
; Category    : CDS, QuickLook, General
;               
; Prev. Hist. : None.
;
; Written     : Stein Vidar Hagfors Haugan, 18 November 1993
;               
; Modified    : SVHH, Version 1.5, 3 June 1994
;			Added MODAL and X/YOFFSET keywords.
;		PB,   Version 1.6, 24 Aug 1994  
;		        Changed button 'Done' to 'Continue'
;               CDP,  Upgraded header info and set default xoffset 
;                     and yoffset.  14-Feb-95
;
; Version     : Version 2, 14-Feb-95
;-            

PRO xselect_event,ev
  common Xselect,selection,quit
  
  Widget_CONTROL,ev.top,Get_UVALUE=selection
  
  Widget_CONTROL,ev.id,Get_UVALUE = index
  IF datatype(index) eq	'INT' THEN selection(index) = (selection(index)	eq 0) $
  ELSE BEGIN
      Widget_CONTROL,ev.id,Get_UVALUE=uvalue
      IF uvalue	eq 'DONE' THEN quit = 0	$
      ELSE			   quit	= 1
      Widget_CONTROL,ev.top,/destroy
      return
  END
  
  Widget_CONTROL,ev.top,Set_UVALUE=selection
  
END




PRO Xselect,options,status,abort,$
                title=title,$
		quit=quit,group_leader=group_leader,$
		exclusive=exclusive,Nonexclusive=nonexclusive,$
		done=done,modal=modal,xoffset=xoffset,yoffset=yoffset
  common Xselect,selection,quitted
  
  IF N_params()	lt 3 THEN return
  
  IF N_elements(options) ne N_elements(status) THEN return
  
  IF N_elements(group_leader) eq 0 THEN	group_leader=0L
  IF N_elements(title) eq 0 THEN title='Select options below'
  IF N_elements(quit) eq 0 THEN	quit='Quit'
  IF N_elements(done) eq 0 THEN	done='Continue'
  
  IF NOT Keyword_SET(exclusive)	$
	  and NOT Keyword_SET(nonexclusive) THEN nonexclusive =	1
  IF NOT Keyword_set(xoffset) THEN xoffset=0
  IF NOT Keyword_set(yoffset) THEN yoffset=0
 
 
  base = Widget_BASE(title=title,group_leader=group_leader,/column,$
			xoffset=xoffset,yoffset=yoffset)
  
  dummy	= Widget_LABEL(base,value=title)
  xmenu,options,base,buttons=buttons,exclusive=exclusive,$
			  nonexclusive=nonexclusive
  
  FOR i=0,N_elements(status)-1 DO BEGIN
      IF status(i) THEN	Widget_CONTROL,buttons(i),set_button=1
      Widget_CONTROL,buttons(i),Set_UVALUE=i
  EndFOR
  
  lowerbase = Widget_BASE(base,/row)
  
  button = Widget_BUTTON(lowerbase,value=quit,uvalue='QUIT')
  button = Widget_BUTTON(lowerbase,value=done,uvalue='DONE')
  
  Widget_CONTROL,base,Set_UVALUE=status
  Widget_CONTROL,base,/realize
  quitted = -1
  Xmanager,'xselect',base,modal=modal
  IF NOT Keyword_SET(modal) THEN $
	WHILE quitted eq -1 DO event=Widget_EVENT(base,bad_id=bad_id)
  abort=quitted
  status=selection
END

; -----------------------------------------------------------------
