pro ssw_set_instr,instrlist, _extra=_extra, check_only=check_only, loud=loud, $
   debug=debug, remove=remove, prepend=prepend, save=save, restore=restore, $
   reset=reset 
;+
;   Name: ssw_set_instr
;
;   Purpose: update $SSW_INSTR (add or remove from environmental)
;
;   History:
;      12-Feb-1998 - S.L.Freeland - useful SSW system-level utility
;-
common set_ssw_instr_blk, current
check_only=keyword_set(check_only)
loud=keyword_set(loud) or check_only
debug=keyword_set(debug)
reset=keyword_set(reset)

current=get_logenv('SSW_INSTR')
 
if keyword_set(reset) then begin
   box_message,'Clearing $SSW_INST'
   current=''
endif

case 1 of 
   data_chk(instrlist,/string,/scalar): ilist=str_replace(instrlist,',',' ') 
   data_chk(instrlist,/string):         ilist=arr2str(instrlist,' ')
   data_chk(_extra,/struct):            ilist=arr2str(tag_names(_extra),' ')
   check_only or reset: ilist=current
   else: begin
      box_message,'Need Instruments via string via keywords
      return
   endcase
endcase

ilist=strlowcase(strcompress(ilist)) 
ilistarr=str2arr(ilist,' ')

currarr=str2arr(current,' ')

case 1 of 
   keyword_set(remove): begin
      outarr=''
      sskeep=rem_elem(currarr, ilistarr, count)
      if count gt 0 then outarr=currarr(sskeep)
   endcase
   keyword_set(prepend): outarr=[ilistarr,currarr]
   else: outarr=[currarr,ilistarr]
endcase

outarr=['gen',outarr]
outarr=outarr(uniqo(outarr))
 
new=strcompress(arr2str(outarr,' '))

if not check_only then set_logenv,'SSW_INSTR', new

if loud then box_message, $
            ['Old $SSW_INSTR: ' + current, $
             'New $SSW_INSTR: ' + new, $
            (['','(Testing, nothing changed)'])(check_only)]

if debug then stop
return
end

