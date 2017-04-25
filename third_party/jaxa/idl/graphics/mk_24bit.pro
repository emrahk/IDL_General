;+
; Project     : SOHO-CDS
;
; Name        : MK_24BIT
;
; Purpose     : Make TrueColor image 
;
; Category    : imaging
;
; Syntax      : mk_24bit,image,red,green,blue
;
; Inputs      : IMAGE = input image
;               RED,GREEN,,BLUE = color table vectors
;               BOTTOM, TOP = ranges if rescaling color table [def = 0,255]
;
; Outputs     : IMAGE24 = byte-scaled image
;
; Keywords    : TRUE_INDEX = 1,2,3 [def=1]
;               OUTSIZE = output dimensions
;
; History     : Written 11 Jan 2000, D. Zarro (SM&A)
;               Modified 16 Oct 2008, Zarro (ADNET)
;                - added LOG, TRUECOLOR, and OUTSIZE keywords
;               Modified 10 April 2015, Zarro (ADNET)
;                - forced byte scaling
;                - removed log scaling
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_24bit,image,red,green,blue,true_index=true_index,$
                outsize=outsize,no_copy=no_copy,_extra=extra,$
                top=top,bottom=bottom

dim=size(image,/n_dim)
if dim ne 2 then begin
 mprint,'Input image must be 2-d.'
 pr_syntax,'image24=mk_24bit(image,r,g,b)'
 return,''
endif

;-- usr current internal color table if one not provided

if valid_colors(red,green,blue) then begin
 ired=red & igreen=green & iblue=blue 
endif else device_colors,ired,igreen,iblue

bscaled=is_byte(image)
if keyword_set(no_copy) then scaled=temporary(image) else scaled=image

n_colors=!d.table_size
if ~is_number(bottom) then bottom=0b else bottom=bottom > 0b
if ~is_number(top) then top=n_colors-1 else top=top < (n_colors-1)
top = top < (n_elements(ired)-1)
ired=ired[bottom:top]
igreen=igreen[bottom:top]
iblue=iblue[bottom:top]

if ~bscaled then begin
 scaled=bytscl(scaled,_extra=extra,top=top-bottom,/nan)
 scaled=temporary(scaled)+byte(bottom)
endif

s = size(scaled, /dimensions)

if exist(outsize) then begin
 nx=outsize[0] & ny=nx
 if n_elements(outsize) gt 1 then ny=outsize[1]
 if (nx ne s[0]) || (ny ne s[1]) then begin
  scaled=congrid(scaled,nx,ny)
  s[0]=nx & s[1]=ny
 endif
endif

if is_number(true_index) then true_index=  (1 > true_index < 3) else true_index=1

case true_index of
 1: begin
     image24 = bytarr(3, s[0],s[1],/nozero)
     image24[0, *, *] = ired[scaled]
     image24[1, *, *] = igreen[scaled]
     image24[2, *, *] = iblue[scaled]
    end
 2: begin
     image24 = bytarr(s[0],3,s[1],/nozero)
     image24[*,0,*] = ired[scaled]
     image24[*,1,*] = igreen[scaled]
     image24[*,2,*] = iblue[scaled]
    end
 else: begin
     image24 = bytarr(s[0],s[1],3,/nozero)
     image24[*,*,0] = ired[scaled]
     image24[*,*,1] = igreen[scaled]
     image24[*,*,2] = iblue[scaled]
    end
endcase

return,image24

end


