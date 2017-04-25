pro ssw_lclimit_colors,inlimit,outlimit, noload=noload
;+
;   Name: ssw_lclimit_colors 
;
;   Purpose:  allow 'linecolors' and 'ssw_limit_colors' to quasi-coexist
;
;   Input Parameters:
;      inlimit - optional input to map to table (KP or AP for example)
;
;   Output Parameters:
;      outlimit - 'inlimit' adjusted to match lc-limit table  ;
;                 (input is scaled to a max of high limit color = 9)
;
;   History:
;      8-Mar-2005 - S.L.Freeland - 'linecolors.pro' is historically used for
;         many SSW graphics; this modification uses the "unpopular"
;         lincolors values to extend to a green-yellow-orange-red limit 
;         For example, plot_goesp (goes protons) and ssw latest events
;         use about 9 of the 14 linecolors; the "unused" indices are populated
;         to allow a 10 color green-to-red temperature scale to coexist      
;         (think homeland security alert-level colors w/twice the resolution..)
;         Overplot KP={0-9}  for example, the immediate requirement
;
;   Side Effects:
;      New color table "clobbers" r,g,b(0:13) - higher indices not affected 
; 

lcmap=[7,1,3,6,5,8,4,10,13,2]        ; for inlimit->outlimit mapping
lmmap=indgen(10)               

lcrep=[1,3,6,8,10,13]                ; for limit->linecolor mods
lmrep=[2,3,4,6,8,9]                  ; ditto, replacement indices

if not keyword_set(noload) then begin 
   linecolors,/nosqueeze                 ; load ssw linecolors CT
   tvlct,lcr,lcg,lcb,/get               ; read back
   ssw_limit_colors,lmr,lmg,lmb,/noload ; 10 green->yellow->orange->red scale
   for i=0,n_elements(lcrep)-1 do begin
      lcr(lcrep(i))=lmr(lmrep(i))
      lcg(lcrep(i))=lmg(lmrep(i))
      lcb(lcrep(i))=lmb(lmrep(i))
   endfor
   tvlct,lcr,lcg,lcb                     ; load modified/merged table
endif

if n_params() eq 2 and n_elements(inlimit) gt 0 then  begin
   if max(inlimit) gt 10 then outlimit=lcmap(bytscl(inlimit,top=9)) else $
      outlimit=lcmap(inlimit>0)
endif

return
end

