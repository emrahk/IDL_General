function strlist2html, array, ordered=ordered, unordered=unordered, all=all, $
	maxsep=maxsep, loud=loud
;+
;   Name: strlist2html
;
;   Purpose: identify ordered/unordered lists in string array and cnvt->html
;
;   Input Parameters:
;      array - string array to search
;
;   Keyword Parameters:
;      ordered -   if set, ordered lists only (default)
;      unordered - if set, unordereed lists only 
;      all       - if set, ordered AND unordered lists (recursive)
;      maxsep - maximum seperation expected between list entries (def=3 lines)
;      loud - if set, print some diagnostics
;
;   Calling Sequence:
;      list=strlist2html(array [/ordered, /unordered, /all, maxsep=NN]
;
;   Restrictions:
;      may let some lists slip through the cracks...
;      
;   History:
;      26-jul-1995 (SLF) - 
;       5-mar-1997 (S.L.Freeland ) added /LOUD and made quiet the default
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-
loud=keyword_set(loud)
if keyword_set(all) then $				; ** recursive **
   return,strlist2html(strlist2html(array,/unordered))  ; ** order/unord **

tohtml=keyword_set(tohtml) or 1			; *** forced on for now
maxchar=([3,1])(keyword_set(unordered))		; 2digit&1 special or 1 special

split=ssw_strsplit(strtrim(array,2),' ')		; extract 1st field

case 1 of 
   keyword_set(unordered): nss=strspecial(split)  ; "special" character?
   else: nss=strspecial(split,/digit)		  ;  digit
endcase

numberss=where(strspecial(split,/last) and nss and $
   strlen(split) le (maxchar>1),ncount)

; eliminate bogus single entry "lists" (odd leading characters...)
if ncount gt 0 then begin
   if not keyword_set(maxsep) then maxsep=3
   ss=lindgen(ncount)
   badss=where((abs(numberss-shift(numberss,-1)) gt maxsep) and $
      (abs(numberss-shift(numberss,1)) gt maxsep),bcnt)
   if bcnt gt 0 then ss(badss)=-1
   good=where(ss ge 0,ncount)
endif

levcol=intarr(10)-1	; nesting depth
levn=-1

if ncount le 1 then begin
     if loud then message,/info, $
      "No "+(['','un'])(keyword_set(unordered))+ "ordered lists..."
   endif else begin
   numberss=numberss(good)
;   numbers=fix(str2number(split(numberss)))	; convert to number
   ss=strarr(80)				; track indices
   cp=[-1]
   for i=0, ncount-1 do begin
      curcol=strpos(array(numberss(i)),split(numberss(i)))
      cp=[cp,curcol]
      del=([',',''])(strlen(ss(curcol)) eq 0)
      ss(curcol)=ss(curcol) + del +  strtrim(numberss(i),2) 
      array(numberss(i))= $
         str_replace(array(numberss(i)),split(numberss(i)), '<LI>')
   endfor

   htmltag=(['ol','ul'])(keyword_set(unordered))	; select HTML tagname
   prel=strarr(ncount) + '    '				; blank fill (prettier)
   postl=strarr(ncount)+ '     '			; blank fill 
   cp=cp(1:*)						; eliminate initial
   cpss=where(cp,cpcnt)					;

   if cpcnt eq 0 then begin				; force level #1
      cp = [-1,cp] 
      mincp=min(cp) 
   endif else begin
      mincp=min(cp(where(cp)))
      cp=[-(mincp),cp]
   endelse
   dcpdx=deriv_arr(cp)					; column level changes

;  open new list if level change is positive
   openlist=[where(dcpdx gt 0,ocnt)]
   for i=0,ocnt-1 do prel(openlist(i))= $
      arr2str(replicate('<' + htmltag + '>',abs(dcpdx(openlist(i))/mincp)),'')

;  close list if level change is negative
   closelist=where(dcpdx(1:*) lt 0,ccnt)
   for i=0,ccnt-1 do postl(closelist(i))= $
      arr2str(replicate('</' + htmltag + '>',abs(dcpdx(closelist(i)+1)/mincp)),'')

   array(numberss) = prel + array(numberss) + postl

   array(numberss(ncount-1))=array(numberss(ncount-1))+'</' + htmltag + '>'

;  find "new lists" (close old and open new)
   newlist=where(deriv_arr(numberss) gt maxsep,nlcnt)
   for j=0,nlcnt-1 do begin
      array(numberss(newlist(j)))  =array(numberss(newlist(j)))    + '</'+htmltag+'>'
      array(numberss(newlist(j)+1))= '<'+htmltag+'>' + array(numberss(newlist(j)+1))  
   endfor
endelse

return,array
end
