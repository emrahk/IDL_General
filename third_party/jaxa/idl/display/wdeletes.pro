pro wdeletes, nwindows, setx=setx, x=x
;+
;   Name: wdeletes
;
;   Purpose: delete multiple (or all) windows
;
;   Input Parameters:
;      nwindows - number of windows to delete (default is all)
;
;   Calling Sequence
;      IDL> wdeletes                 ; delete all window
;      IDL> wdeletes, nn             ; delete most recent NN windows
;      IDL> wdeletes,/setx           ; force X first (if in non-X mode, like
;                                    ; PS or Z, default is return w/nocation)
;
;   History:
;      Circa 1993 - S.L.Freeland - wrote the one liner utility
;      4-mar-1997 - S.L.Freeland - document, add Nwindows parameter, X check
;     11-jun-1997 - S.L.Freeland - add SETX keyword (set plot to X - overrides
;                                  default to return w/no action if PS, Z etc.)
;     12-jul-2001 - S.L.Freeland - work on WINdows also
;
;   Side Effects:
;      If /SETX is set, plot device is set to X
;-
if n_elements(nwindows) eq 0 then nw=1000  else nw=nwindows  ; ie, all of them

if keyword_set(setx) then set_plot,'X'            ; Force X
if is_member(!d.name,'x,win',/IGNORE_CASE) then begin           ; otherwise, makes no sense
   while !d.window ne -1 and nw gt 0 do begin
      wdelete
      nw=nw-1
   endwhile
endif

return
end
