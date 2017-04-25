;+
; Project     : HESSI
;
; Name        : SHOW_SYNOP
;
; Purpose     : widget interface to Synoptic data archive
;
; Category    : HESSI, Synoptic, Database, widgets, objects
;
; Syntax      : IDL> show_synop
;
; Keywords    : See SHOW_SYNOP::INIT
;
; History     : 12-May-2000,  D.M. Zarro (SM&A/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


 pro show_synop,_ref_extra=extra

 obj=obj_new('show_synop',_extra=extra)

;-- try to recover created object

 if not obj_valid(obj) then begin
  id=get_handler_id('show_synop::setup')
  if xalive(id) then begin
   widget_control,id[0],get_uvalue=tobj
   if obj_valid(tobj) then obj=tobj
  endif
 endif

 if obj_valid(obj) then begin
  info=obj->get_info()
 endif

 return & end

