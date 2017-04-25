function slfmt, value
return, strtrim(string(value,format='(f6.1)'),2)
end

function safe_log10, index, data, $
		   bytescale=bytescale, minimum=minimum, maximum=maximum, $
		   clobber=clobber, background=background
;+
;   Name: safe_log10
;
;   Purpose: apply 'safe' log10  via alog10((data+1.)>1.), optionally bytscl
;
;   Input Parameters:
;      index - if structure, append history record including alorithm/values
;      data -  data array to scale
;  
;   Calling Sequence:
;      result=safe_log10(data [,/bytescale, min=xx, max=yy , backg=zz]) 
;      -OR-
;      result=safe_log10(index, data [,/bytescale, min=xx, max=yy , backg=zz])
;
;   Calling Examples:
;      sdata=safe_alog10(data,/bytescale)             ; log/bytescale
;      sdata=safe_alog10(index, data, maximum=3.0 )   ; bytscale log to        
;
;      -- note: is index structures supplied, history is updated ---
;      IDL> out=safe_log10(index,data,back=865.,max=2.5)
;      IDL> print,index.history
;      safe_log10  result=bytscl(alog10( ((indata-865.0)+1.)>1.),min=0.0,max=2.5)  
;      
;   Keyword Parameters:
;     bytescale - if set, bytscale               (after alog10 applied) 
;     minimum  -  if set, minimum used in bytscl (implies BYTESCALE)
;     maximum  -  if set, maximum used in bytscl (implies BYTESCALE)
;     clobber  - if set, clobber input data (for memory management)
;     background - if set, subtract this "pedastal" from data prior to
;                  applying algorithim
;
;   History:
;      22-March-1999 - S.L.Freeland - generic version of sxt/ypop/eit routine
;-
clobber=keyword_set(clobber)
bytescale=keyword_set(bytescale) or keyword_set(minimum) or keyword_set(maximum)

case 1 of
   n_params() eq 2: if clobber then idata=temporary(data)  else  idata=data
   n_params() eq 1: if clobber then idata=temporary(index) else idata=index
   else: begin
      box_message,['Need some data...',$
		   'IDL> compdata=sxt_scc_comp(index,data [,/bytscale]'] 
      return,-1
   endcase
endcase

if keyword_set(background) then $
    idata=temporary(idata)-background else background=0.

retval=alog10((temporary(idata) + 1.)>1.)      

; ------ if index structure(s) are input, update .HISTORY tag -------
if data_chk(index,/struct) and get_tag_index(index,'HIS') eq -1 then begin
   hstring='alog10( (indata+1.)>1.)'
   if bytescale then begin
      if n_elements(minimum) eq 0 then minimum=min(retval)
      if n_elements(maximum) eq 0 then maximum=max(retval)
      hstring='bytscl(' + hstring + ',min=' + slfmt(minimum) + $
		      ',max=' + slfmt(maximum)+')
   endif    
   hstring='result='+hstring
   if background ne 0. then hstring= $
       str_replace(hstring,'indata','(indata-'+ slfmt(background) +')')
   update_history,index, /caller, hstring
endif

; Now apply optional bytscale
if keyword_set(bytescale) then $
    retval=bytscl(temporary(retval), min=minimum, max=maximum)
    
return,retval
end
