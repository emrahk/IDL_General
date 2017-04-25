;+
; Project     : SOHO - CDS
;
; Name        : GET_HANDLER_NAME
;
; Purpose     : to get name of event handler for widget ID.
;
; Category    : widgets
;
; Explanation : examines XMANAGER common for registered ID's
;
; Syntax      : IDL> handler = get_handler_name(widget_id)
;
; Inputs      : WIDGET_ID = widget id 
;
; Opt. Inputs : None
;
; Outputs     : HANDLER = event handler name for WIDGET_ID 
;               (blank string if undefined)
;
; Opt. Outputs: None
;
; Keywords    : GHOSTS = other widget ID's related to handler name
;
; Common      : None
;
; Restrictions: WIDGET_ID should be a main base
;
; Side effects: None
;
; History     : Version 1,  22-Aug-1996,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
    
function get_handler_name,widget_id,ghosts=ghosts
handler=''

if not xalive(widget_id) then return,handler
xmanager_com,ids,names,status=status
if not status then return,handler


wlook=where(widget_id eq ids,cnt)
if cnt gt 0 then begin
 handler=names(wlook(0))
 glook=where( (handler eq names) and (widget_id ne ids),gcnt)
 if gcnt gt 0 then ghosts=ids(glook)
endif

return,handler
end

