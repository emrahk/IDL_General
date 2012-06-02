PRO CCD_WSEL, names, index, TITLE=title
;+
; NAME:
;	CCD_WSEL
;
; PURPOSE:
;	Simple widget for choosing sources.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE
;	CCD_WSEL, names, [ index, TITLE=title ]
;
; INPUTS:
;	NAMES : Vector of source names.
; 
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;		
; OPTIONAL KEYWORDS:
;	TITLE : Title of widget.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;       INDEX : Index of choosen source.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


on_error,2                      ;Return to caller if an error occurs

col=long(sqrt(n_elements(names)))>1

if not EXIST(title) then title='Select Source'

XMENU,CCD_CBOX(names),base=base,buttons=b,column=col,title=title

WIDGET_CONTROL,/realize,base

event=WIDGET_EVENT(base)
index=where(b eq event.id)

WIDGET_CONTROL,base,/destroy


RETURN
END
