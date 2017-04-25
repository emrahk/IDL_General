;+
; Project     : RHESSI
;
; Name        : MK_COMP_MAP
;
; Purpose     : Combine up to 3 maps with color tables
;
; Category    : imaging
;
; Syntax      : image=mk_comp_map(map1,map2,map3)
;
; Inputs      : MAP1,MAP2, MAP3 = maps with RGB colors loaded via
;                                 mk_color_map
;
; Outputs     : MAP = combined map with true color 
;
; Keywords    : WEIGHT = weighting factors = [w1,w2,w3]
;               If scalar then apply equal weight to each map.
;
; Example     :
;              IDL> loadct,1
;              IDL> map1=mk_map_color(map1)
;              IDL> loadct,3
;              IDL> map2=mk_map_color(map2)
;              IDL> map=mk_comp_map(map1,map2,weight=0.5)    ;-average
;              IDL> map=mk_comp_map(map1,map2,map3,weight=[.25,.5,.25])
;
; Written     : 5-April-2015, Zarro (ADNET) - written
;               20-April-2014, Zarro (ADNET) 
;               - preserve 24 bit colors if input map is truecolor
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_comp_map,map1,map2,map3,weight=weight,_extra=extra,err=err

err='Need at least two maps with loaded colors.'

;-- need at least two maps

switch 1 of
  ~valid_map(map1): return,-1
  ~valid_map(map2): return,-1
  ~color_map(map1,true_index=true_index1): return,-1
  ~color_map(map2,true_index=true_index2): return,-1
  ~array_equal(size(map1.data),size(map2.data)): return,-1
endswitch

extra_map=0b
if valid_map(map3) then begin
 if color_map(map3,true_index=true_index3) then extra_map=array_equal(size(map3.data),size(map2.data))
endif

err=''
np=n_elements(weight)
case np of
 0: flux=[1,1,1]
 1: flux=replicate(weight,3)
 2: flux=[weight,0]
 else: flux=weight[0:2]
endcase
flux=float(flux)
if flux[2] eq 0. then extra_map=0b

;-- if input map image not truecolor, then create 24 bit images from map color tables

if (true_index1 gt 0) then cdata1=map1.data else cdata1=mk_24bit(map1.data,map1.red,map1.green,map1.blue,_extra=extra)
if (true_index2 gt 0) then cdata2=map2.data else cdata2=mk_24bit(map2.data,map2.red,map2.green,map2.blue,_extra=extra)
cdata3=0b
if extra_map then begin
 if (true_index3 gt 0) then cdata3=map3.data else cdata3=mk_24bit(map3.data,map3.red,map3.green,map3.blue,_extra=extra) 
endif

;-- make composite true color image

cdata=byte(flux[0]*fix(temporary(cdata1))+ $
           flux[1]*fix(temporary(cdata2))+ $
           flux[2]*fix(temporary(cdata3)) < 255) 

;-- convert to 8 bit color image if input map was not truecolor

omap=map1
if true_index1 then omap.data=temporary(cdata) else begin
 omap.data=color_quan(temporary(cdata),1,red,green,blue,colors=256,_extra=extra)
 omap.red=red
 omap.green=green
 omap.blue=blue
endelse

return,omap
end
