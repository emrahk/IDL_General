;+
; Project     : RHESSI
;
; Name        : XHOUR
;
; Purpose     : produce widget hourglass
;
; Use         : XHOUR
;
; Opt. Inputs : BASE = widget base id
;
; Outputs     : None
;
; Keywords    : None
;
; Explanation : On some devices, the command: widget_control,/hour 
;               produces device errors. 
;               This procedure protects against these using catch.
;
; Category    : Widgets
;
; Written    : Zarro (L-3Com/GSFC) 23 August 2005 - Added CATCH
;-

pro xhour,base

if (!d.name ne 'X') and (!d.name ne 'WIN') then return

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 return
endif

if xalive(base) then widget_control,base,/hour else widget_control,/hour

return
end

