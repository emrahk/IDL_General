function ssw_sigscale, index, data, $
   missing=missing, corner_cut=corner_cut, log=log, fraction=fraction
;
;   Name: ssw_sigscale
;
;   Purpose: byte/log scale an image using several ssw routines/techniques
;
;   Input Parameters:
;      index,data - the usual ssw suspects
; 
;   Keyword Parameters:
;      missing - if supplied, upper level of image considered MISSING
;      corner_cut = if set, define MISSING from corners of image 
;      clobber - if set, its ok to clobber input data for memory savings...
;
;   History:
;      30-nov-2004 - S.L.Freeland - wrapper for Bill Thompson sigrange.pro
;
case 1 of
   keyword_set(missing):
   keyword_set(corner_cut): begin 
      if corner_cut eq 1 then cpix=round(.1*index(0).naxis1) else cpix=corner_cut
      exn=cpix-2
      exy=index(0).naxis2-exn-1
      exx=index(0).naxis1-exn-1 
      corncut=[data(0:exn,0:exn,*) , $
               data(0:exn,exy:exy+exn,*), $
               data(exx:exx+exn,0:exn,*), $
               data(exx:exx+exn,exy:exy+exn,*)]
      missing=average(corncut)
   endcase
   else: missing=min(data)
endcase
help,missing
if n_elements(fraction) eq 0 then fraction=.995
case 1 of 
   keyword_set(clobber): retval=sigrange(temporary(data>missing),missing=missing,$
      fraction=fraction, range=range)
   else: retval=sigrange(data>missing,missing=missing,range=range,fraction=fraction)
endcase

if keyword_set(log) then retval=safe_log10(index,temporary(retval)-1,/byte)
update_history,index,'Scale Min,Max = ' + arr2str(range)

return,retval
end



