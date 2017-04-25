pro sswloc, pattern, matches, nmatch, $
	mapfile=mapfile, quiet=quiet, refresh=refresh, $
	_extra=_extra, gen=gen, site=site, more=more, instrument=instrument, $
        limit=limit, all=all, except=except
;+
;
;   Name: sswloc
;
;   Purpose: use SSW mapfile to see online SSW routines
;
;   Input Paramters:
;      pattern - pattern to match (if not defined, all routines returned)
;
;   Output Paramters
;      matches - full SSW pathname of matches
;      nmatch  - number of matches
;
;   Keyword Parameters:
;      mapfile - optional mapfile (default=$SSW/site/setup/ssw_map.dat)
;      quiet   - if set, dont print (ex: called by programs)
;      refresh - if set, re-read mapfile (default is only read 1st call)
;      more    - if set, display first occurence to terminal
;      limit   - (terminal use) - cutoff limit on number displayed (def=10)
;      all     - (switch - terminal use) - if set, display all nomatter how many
;      except - optional pattern to ignore 
;   
;   Calling Sequence:
;      sswloc,'pattern' [, matches, /more]
;      sswloc,/PATTERN ,[, matches, /more]   ;use Keyword Inherited pattern 
;
;   Calling Example:
;      sswloc,/sswloc,/more        ; find and display THIS routine
;      sswloc,'zzz',/more,/instr   ; find and display 'xxx.pro'
;                                  ; insterms of $SSW_XXX (instrument tree)
;      sswloc,'find',/all          ; show all to terminal 
;      sswloc,/xxx,/limit          ; same as LIMIT=1, only 1st 'xxx' match
;      sswloc,/xxx,except='goes/sxig12/'  ; ingore a particular branch
;
;   History:
;       1-Oct-1996 - S.L.Freeland
;      29-Oct-1996 - S.L.Freeland - use GEN version if SITE not available 
;      11-Dec-1996 - S.L.Freeland - add /MORE switch
;       8-sep-1998 - S.L.Freeland - add /INSTRUMENT switch
;      12-nov-1998 - S.L.Freeland - always use the GEN version
;      27-Apr-1999 - S.L.Freeland - add LIMIT and /ALL
;      13-May-2003 - S.L.Freeland - add EXCEPT keyword and function
;                               
;-
common sswloc_blk, swmap

site=keyword_set(site) or get_logenv('SSW_SITE') eq 'GSFC' ; master site?
gen=keyword_set(gen) or (1-keyword_set(site)) ; make gen the default
gen=1   ; *** ALWAYS USE THE GEN VERSION, slf,12-nov-1998

defmap=concat_dir((['$SSW_SITE_SETUP','SSW_GEN_SETUP'])(keyword_set(gen)),'ssw_map.dat')

if keyword_set(instrument) then $
   defmap=str_replace(defmap,'_map','_instr_map')

if not keyword_set(mapfile) then mapfile=defmap   
readmap=n_elements(swmap) eq 0 or (mapfile ne defmap) or keyword_set(refresh) 

if readmap then begin
   message,/info,"Reading SSW Mapfile: " + mapfile
   map=rd_tfile(mapfile)
   if mapfile eq defmap then swmap=map
endif else map=swmap

if data_chk(except,/string,/scalar) then begin 
   map=map(where(strpos(map,except) eq -1))
endif

case 1 of
   keyword_set(pattern): 
   data_chk(_extra,/struct): pattern=(tag_names(_extra))(0)
   else: pattern=""
endcase

ss=wc_where(map,'*'+pattern+ '*',nmatch,/case_ignore)

case 1 of
   keyword_set(limit): 
   keyword_set(all): limit=nmatch
   else: limit=10
endcase

if nmatch eq 0 then begin
   matches='' 
   mess="No SSW routines matching pattern: " + pattern
endif else begin
   matches=map(ss)
   mess=["Matches...","   " + map(ss(0:limit<nmatch-1))]
   mess=[mess, (["", "   (..." + strtrim(nmatch-limit,2) + " more...)"])(nmatch gt limit)]
endelse

if not keyword_set(quiet) then prstr,mess(where(mess ne ""))

if keyword_set(more) and nmatch gt 0 then $
             more,[strjustify(map(ss(0)),/box),rd_tfile(map(ss(0)))]

return
end

