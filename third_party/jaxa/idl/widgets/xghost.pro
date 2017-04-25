;+
; Project     : SOHO - CDS
;
; Name        : XGHOST
;
; Purpose     : to get IDs of widgets that have the same event handler
;
; Category    : widgets
;
; Explanation : examines XMANAGER common for registered ID's
;
; Syntax      : IDL> ghosts=xghost(id)
;
; Inputs      : ID = widget id or widget event handler name
;
; Opt. Inputs : None
;
; Outputs     : GHOSTS = IDs of widgets with same event handler
;
; Opt. Outputs: NGHOSTS = # of ghost widgets found
;
; Keywords    : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  22-Aug-1996,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function xghost,id,nghosts

ghosts=-1

if datatype(id) eq 'STR' then wid=get_handler_id(id,ghosts=ghosts) else $
 wname=get_handler_name(id,ghosts=ghosts)

nghosts=n_elements(ghosts)
if nghosts eq 1 then ghosts=ghosts(0)

return,ghosts       & end

