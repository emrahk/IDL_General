;+
; Function to strip the panel description(s) and return the main description.
; The part before the comma and the panel creation time part of the description are removed.
; Current time in description is in parentheses at end of description, e.g.
;    efz20091031.010608 soho eit 195 31-oct-2009 01:06:08.549 (16:29:38)
; 
; Keywords:
; current - if set, strip current panel description.  Overridden by panel_desc keyword.
; panel_desc - if set, panel description(s) to strip
; time_only - if set, only strip the time
; 
; If panel_desc isn't set, or is set to 'self', then gets current panel desc and strips it.
; So current keyword isn't really used, but can be specified in call just to make it clear which
; panel we want.
;
; Kim Tolbert 8-May-2007
; Modifications:
; 13-Jan-2011, Kim. Changed keyword name from ov_panel_desc to panel_desc, since isn't exclusive
;   to overlay panel descriptions.  And added time_only keyword.
;   Also, made more robust.  Previously assumed only one ',' and only one '(' in string, now looks for first
;   ',', and last '('  in case there are more than one.
;   Made to work on panel_desc array as well as scalar.
; 01-Mar-2012, Kim. Failed if the time stamp ((nn:nn:nn) at end) was not in string, but other
;   parens were.  Made more robust, now looks explictly for (nn:nn:nn) at end, and removes it
;----

function plotman::strip_panel_desc, current=current, panel_desc=panel_desc, time_only=time_only

current = keyword_set(current)
time_only = keyword_set(time_only)

desc = exist(panel_desc) ? panel_desc : 'self'

; for panel descriptions of 'self' replace those with the current panel desc
q = where (desc eq 'self', count)
if count gt 0 then desc[q] = self -> get(/current_panel_desc)

desc = strtrim(desc,0) ; remove trailing blanks

; Strip whatever's before the first comma from desc
if ~(time_only) then begin
  tmp = ssw_strsplit(desc,',', /head, tail=tail)
  desc = tail
endif

;; Strip time of panel creation from desc 
;; find last occurrence of '(' and puts everything in front of that into head
;tmp = ssw_strsplit(desc, '(', /tail, head=head)
;
;; for any head elements that are blank, means didn't find any '(', so set to corresponding desc
;q = where (head eq '', count)
;if count gt 0 then head[q] = desc[q]
;desc = head

; Find position in each desc of time at end in format (nn:nn:nn) ($ anchors it to end).
; time_pos will be position in string, -1 if desc doesn't contain the time.
; For all desc elements that have the time, extract from 0 to start of time (and 
; trim to remove trailing blank)
time_pos = stregex(desc, '\([0-9][0-9]:[0-9][0-9]:[0-9][0-9]\)$')
q = where (time_pos ne -1, count)
if count gt 0 then desc[q] = strtrim(strmids(desc[q],0,time_pos[q]),0) 

; return scalar if only one element, otherwise array
return, n_elements(desc) eq 1 ? desc[0] : desc
end