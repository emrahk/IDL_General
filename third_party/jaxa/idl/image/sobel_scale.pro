function sobel_scale, index, data, mode=mode,debug=debug, $
   lowcut=lowcut, hicut=hicut, minpercent=minpercent, maxpercent=maxpercent, $
   sobel_weight=sobel_weight, deriv_hist=deriv_hist
;+
;   Name: sobel_scale
;
;   Purpose: auto scale image  with edge enhancment
;
;   Input Parameters:
;      index, data - the usual - floating , long or integer
;
;   Keyword Parameters:
;      sobel_weight - weight applied to sobel portion ( default=.05)
;      minpercent   - scale low   cutoff (reject this % of low end pixels)
;      maxpercent   - scale hight cutoff (reject this % of high end pixels)
;      deriv_hist   - if set, use derivitive of histogram for low/high cut
;      hicut        - absolute hi data cutoff (ignore pixels > in scaling)
;      lowcut       - absolute low data value cutoff  (ignore pixels < in scaling)
;
;   Calling Sequence:
;      sdata=sobel_scale(index,data,sobel_weight=xx, deriv_hist=nn)
;      sdata=sobel_scale(index,data,sobel_weight=xx, minper=yy, maxper=zz)
;      sdata=sobel_scale(index,data,sobel_weight=xx, low=nn, high=mm)
;
;   Calling Example:
;      sdata=sobel_scale(index,data,sobel=.1, deriv_hist=3)
;      ; this example:
;          add a sobel component
;          determine low and high data range from derivitive of histogram
;  
;   History:
;      19-October-1998 - S.L.Freeland - eit/trace/sxt - auto scale/enhance->WWW
;      25-October-1998 - S.L.Freeland - allow 3D input
;      28-October-1998 - S.L.Freeland - add MAXPERCENT, add DERIV_HIST
;      12-November-1998 - S.L.Freeland - assume MAX is really HICUT if
;                                        number > 100. (to make it agree w/doc)
;       8-march-1999 - S.L.Freeland - histogram subscript range protection
;-
debug=keyword_set(debug)
nimg=data_chk(data,/nimage)
dtype=data_chk(data,/type)

if 1-(data_chk(index,/struct) and dtype gt 1 and dtype lt 7) then begin
  box_message,['IDL> sdata=sobel_scale(index,data,sobel_weight=NPERCENT, minpercent=NPERCENT)',$
               '     Data expected non-byte']
  return,-1
endif

; initialize defaults
if keyword_set(maxpercent) then begin
   if maxpercent(0) gt 100 then begin
      box_message,'MAXPERCENT is > 100, assuming this is really HICUT'
      hicut=maxpercent
      delvarx,maxpercent
   endif
endif

if n_elements(lowcut) gt 0 then minh=lowcut else minh=0
if n_elements(hicut)  gt 0 then maxh=hicut  else maxh=max(data)            
if n_elements(mode) eq 0 then mode =1
if n_elements(sobel_weight) eq 0 then sobel_weight=.05

npix=n_elements(data)
hdata=histogram(data)
nhist=n_elements(hdata)

if n_elements(deriv_hist) gt 0 then begin
  box_message,'Using dHIST/dx for limits'
  dhist=deriv_arr(hdata)
  limits=where(abs(dhist) gt deriv_hist,dhcnt)
  if dhcnt gt 0 then begin
     minh=limits(0)
     maxh=last_nelem(limits)
  endif  
endif  

; if minh/maxh keywords, establish cutoffs as percentage of pixels
if n_elements(minpercent) gt 0 then begin 
  low1000=totvect(hdata(0:(999<(npix-1)<(nhist-1))))
  ss=where(low1000 gt (minpercent*npix*.01) ,lowper) ; percent under
  minh=ss(0)>0
endif 

if n_elements(maxpercent) gt 0 then begin 
  hi=totvect(reverse(hdata))                      ; last piece of histogram
  ss=where(hi lt (maxpercent*npix*.01) ,hiper)    ; percent over
  maxh=ss(0)>0
endif

box_message,'Scale range: ' + strtrim(minh,2) + ' to ' + strtrim(maxh,2)

outdata=make_array(data_chk(data,/nx),data_chk(data,/ny),nimg,/byte)

for i =0,nimg-1 do begin 
   sobeit=sobel(data(*,*,i)>minh<maxh)          ; compute sobel
   case mode of                                 ; assume future MODEs/algorithms
      1: begin
	 outx=sqrt(data(*,*,i)>minh<maxh)
         outdata(0,0,i)=bytscl( (sobel_weight*alog10((sobeit>.01)^.2))+(outx^.1))
      endcase
      else: begin
         box_message,'Unexpected MODE'
         return,data
      endcase
   endcase
endfor

if debug then stop
return, outdata
end

   
