;+
; Project     : SOHO-CDS
;
; Name        : MK_8BIT
;
; Purpose     : scale image to 8 bit color table
;
; Category    : imaging
;
; Syntax      : mk_8bit,image,r,g,b
;
; Inputs      : IMAGE = input image
;
; Outputs     : IMAGE8 = scaled image
;               R,G,B = color table vectors
;
; Keywords    : None
;
; History     : 21-Oct-2000, Zarro (EIT) - written
;               20-Jan-2016, Zarro (ADNET) - add call to GET_TRUE_SIZE
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_8bit,image,r,g,b,_extra=extra,err=err

err=''
dims=get_true_size(image,true_index=true_index,err=err)
if is_string(err) || (true_index eq 0) then begin
 err='Input image must be 3-D array.'
 pr_syntax,'image8=mk_8bit(image,r,g,b)'
 return,null()
endif

image8 = color_quan(image,true_index, r, g, b, colors=!d.table_size, _extra=extra)

;- Sort the color table from darkest to brightest

table_sum = total([[long(r)], [long(g)], [long(b)]], 2)
table_index = sort(table_sum)
image_index = sort(table_index)
r = r[table_index]
g = g[table_index]
b = b[table_index]
oldimage = image8
image8[*] = image_index[temporary(oldimage)]

return, image8
end

