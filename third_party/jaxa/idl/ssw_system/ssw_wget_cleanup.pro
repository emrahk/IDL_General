pro ssw_wget_cleanup,localdir, pattern=pattern, confirm=confirm
;
;+
;   Name: ssw_wget_cleanup
;
;   Purpose: cleanup crap left over after wgetting, primarily index.html?..=..
;
;   Input Paramters:
;      localdir - parent director(ies) to clean (recursively)
;
;  Keyword Parameter:
;     pattern - optional pattern to clean; def='index.html*=*'
;     confirm - if set, ask for confirmation before deleting
;
;   Calling Sequence:
;      IDL> ssw_wget_cleanup,localpaths [,patern=pattern]
;
;   Context:
;      IDL> ssw_wget_mirror,URLS,localpaths [... options]
;           -or- explicit % wget...
;      IDL> ssw_wget_cleanup, localpaths
;
;   History:
;      24-oct-2007 - S.L.Freeland - don't know why default wget leaves this
;                    crap around and no obvious way to override/auto-clean
;                    (If You know of a way, love to hear from you:
;                     -> freeland@lmsal.com)
;-
if n_params() eq 0 then begin 
   box_message,'Expect one or more parent paths as input...
   return
endif


if not keyword_set(pattern) then pattern='index.html*=*'

cfiles=file_search(localdir,pattern)

if cfiles(0) eq '' then begin 
   box_message,'Nothing to clean..
endif else begin 
   box_message,'Found ' + strtrim(n_elements(cfiles),2) + ' to delete...'
   dodelete=1
   if keyword_set(confirm) then yesnox,'OK to delete?',dodelete
   if dodelete then ssw_file_delete,cfiles else $
      box_message,'Not deleting...'  
endelse

return
end
