function sort_index,i1, i2, ss=ss, negtim=negtim, loud=loud, uniq=uniq,$
      out_style=out_style
;
;+
;   Name: sort_index
;
;   Purpose: return time sorted array of merged structures
;
;   Input Paramters:
;      index1, index2 -  vectors of SSW times to sort
;   
;   Keyword Parameters
;      ss - is set, return sorted indices, not sorted/merged structures
;      negtim - indices where time runs backwards (-1 if none)
;      loud - report on number of records where time is backwards
;
;   Calling Sequnce:
;      newindex=sort_index(index1, index2)	; return merged index records
;						;    (structures)
;      sortss=sort_index(index1, index2, /ss)   ; return ssvector 
;						;    (longword array)
;      sortindex=sort_index(index1,/loud)	; sort single vector & report
;
;   Calling Example:
;      info=get_info(sort_index(findex,pindex))	; merge SXT FFI and PFI records
; 						;  (index or roadmap)
;   History:
;      5-Nov-1993 S.L.Freeland
;     10-Feb-1994 S.L.Freeland - allow single input, /loud keyword
;     12-Dec-1994 S.L.Freeland - add uniq switch
;     12-Sep-1998 S.L.Freeland - made it SSW compliant via anytim -> $SSW/gen
;     22-Oct-1998 S.L.Freeland - return complete strcuts,not just time parts
;      2-Oct-2001 S.L.Freeland - sped up a little (via anytim)
;-  

uniq=keyword_set(uniq)
ss=keyword_set(ss)
loud=keyword_set(loud)
retval=-1

if not data_chk(i1,/struct) then begin 
   box_message,'IDL> merged=sort_index(index [,index2] [,/ss], /loud] )
   return,retval
endif

case n_params() of 
   1: allind=i1
   2: allind=concat_struct(i1,i2)		; merge
   else: begin
      box_message,['IDL> outind=sort_index(ind2 [,ind2] [,/ss])']
      return,retval
   endcase     
endcase

secs=anytim(allind)
ssecs=sort(secs)
usecs=uniq(secs,ssecs)

negtim=where(deriv_arr(secs) lt 0,negcnt)
dupes=n_elements(secs)-n_elements(usecs)
if keyword_set(loud) then begin		; report on records out of order
  if dupes gt 0 then box_message,'Number of duplicate times: ' + strtrim(dupes,2) else $
       box_message,'No dupliate times'
  if negcnt eq 0 then box_message,'No times were out of order' else $
      box_message,'Times out of order, nsequences=' + strtrim(negcnt,2)
endif

if uniq then order=usecs else order=ssecs
if ss then retval=order else retval=allind(order)
if keyword_set(out_style) then retval=anytim(retval,out_style=out_style)

return,retval			

end

