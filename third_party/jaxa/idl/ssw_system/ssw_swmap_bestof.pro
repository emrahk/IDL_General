pro ssw_swmap_bestof, bestfiles, outfile=outfile, debug=debug
;+
;
;   Name: ssw_swmap_bestof
;
;   Purpose: generate 'bestof' subset of SSW one-liner/category map file
;
;   Input Parameters:
;      bestfiles - files to search (default $SSW_SITE_SETUP/bestof.USERNAME
;   History:
;       9-sep-1998 - S.L.Freeland 
;      14-Oct-1998 - S.L.Freeland - look in $SSW_SITE_SETUP  for 'bestof'
;                                   files if not supplied
;-

debug=keyword_set(debug)
gen=1
defmap=concat_dir((['$SSW_SITE_SETUP','SSW_GEN_SETUP'])(keyword_set(gen)),'ssw_map.dat')
smap=str_replace(defmap,'_map','_info_map')
omap=str_replace(smap,'_info_','_bestof_')

if not data_chk(bestfiles,/string) then begin
   bestfiles=file_list('$SSW_SITE_SETUP','bestof.*',/cd)
   if bestfiles(0) eq '' then begin
      box_message,'Need to supply file(s) containing "best of" routine names'
      return
   endif
endif

box_message,'Writing bestof map file>> ' + omap
pr_status,txt,/idldoc
file_append,omap,txt,/new

routines=strtrim(strlowcase(rd_tfiles(bestfiles,nocomment=';')),2)
break_file,routines,ll,pp,ff,ee,vv            ; remove path and .pro
routines=ff+'.pro'                             ; 1 and only 1
routines=routines(uniq(routines,sort(routines)))     ; uniq subset
nbest=n_elements(routines)                           ; number

file_append, omap, ['; Includes input files: ',';   ' + bestfiles, $
                    '; Number of uniq routines: ' + strtrim(nbest,2)]

for i=0,nbest-1 do begin 
   print,'Routine>> ' + routines(i)
   gcmd=['grep', '-i', '/'+routines(i),smap]
   spawn,gcmd,matches,/noshell
   file_append, omap, matches
   if debug then stop
endfor

return
end
