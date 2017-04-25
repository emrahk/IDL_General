pro ssw_composite, index, data, cindex, cdata, mode=mode
;+
;   Name: ssw_composite
;
;   Purpose: form composite of 2 or more images
;
;   Input Parameters:
;      index, data - standard SSW 'index,data' - 3D, assumed pre-aligned
;
;   Output Parameters:
;      cindex - index - w/history record of component image times 
;      cdata - the composite image
;
;   Keyword Parameters:
;      mode - type of compositing
;             Mode 1 -> greatest valued pixel
;             Mode 2 -> least valued pixel    [continum images for example]
;             Mode 3 -> total of all images   [just does total(data,3) ]
;-
  
nimg=data_chk(data,/nimage)

if nimg lt 2 then begin
   box_message,['3D cube expected...',$
		'IDL> ssw_composite, index, data, cindex, cdata']
endif

nx=data_chk(data,/nx)
ny=data_chk(data,/ny)
dtype=data_chk(data,/type)

if n_elements(mode) eq 0 then mode=1
maxvalue=([0.d, 255.d,32767.d,2.14748d+09, 1.d38, 1.d308])(dtype < 6)
cdata=make_array(nx,ny,type=dtype, value=([0.d,maxvalue])(mode eq 2)) 

case mode of
   1: for i=0,nimg-1 do cdata= data(*,*,i) > cdata
   2: for i=0,nimg-1 do cdata= data(*,*,i) < cdata
   3: cdata=total(data,3)
   else: box_message,'Mode not yet defined
endcase

cindex=index(0)                                  ; use 1st template
update_history,cindex,anytim(index,/ccsds) ; add compenent times

return
end
