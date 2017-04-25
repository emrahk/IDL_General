;+
; Project     : RHESSI
;
; Name        : ADD_COLOR_MAP
;
; Purpose     : Add two color maps
;
; Category    : imaging
;
; Syntax      : cmap=add_color_map(map1,map2)
;
; Inputs      : MAP1,MAP2 = maps with RGB colors loaded via
;                                 mk_color_map
;
; Outputs     : CMAP = combined map 
;
; Keywords    : WEIGHTS = weighting factors = [w1,w2]
;               If vector: cmap = weights[0] * map1 + weights[1] * map2
;               If scalar: cmap = (1-weights) * map1 + weights * map2
;               If undefined (not entered):  weights = 0.5
;               XRANGE = only pixels within XRANGE are added
;               YRANGE = only pixels within YRANGE are added
;               THRESHOLD = only pixels above threshold value are added
;
; Example     :IDL> loadct,1
;              IDL> map1=mk_map_color(map1)
;              IDL> loadct,3
;              IDL> map2=mk_map_color(map2)
;              IDL> cmap=add_color_map(map1,map2)                 ;-- -average map1 and map2
;              IDL> cmap=add_color_map(map1,map2,weights=[.2,.8]  ;-- add 20% map1 and 80% map2
;
; Written     : Written 5-April-2015, Zarro (ADNET) 
;               20-April-2015, Zarro (ADNET) 
;               - preserve 24 bit colors if input map is truecolor
;               3-September-2015, Zarro (ADNET)
;               - added XRANGE,YRANGE
;               17-January-2016, Zarro (ADNET)
;               - added THRESHOLD
;
; Contact     : dzarro@solar.stanford.edu
;-

function add_color_map,map1,map2,weights=weights,_extra=extra,err=err,$
                     drotate=drotate,threshold=threshold

err='Need at least two equally-sized and -spaced maps with loaded colors.'

;-- need at least two maps

rescale=0b
switch 1 of
 ~valid_map(map1): return,null()
 ~valid_map(map2): return,null()
 ~color_map(map1,true_index=true_index1): return,null()
 ~color_map(map2,true_index=true_index2): return,null()
 else: begin
  dim1=get_map_size(map1) & dim2=get_map_size(map2) 
  res1=[map1.dx,map1.dy] & res2=[map2.dx,map2.dy]
  rescale= ~array_equal(dim1,dim2) || ~array_equal(res1,res2)
 end
endswitch

err=''

if rescale || keyword_set(drotate) then rmap=coreg_map(map2,map1,/rescale,/keep_limb,drotate=drotate,err=err)
if is_string(err) then return,null()

np=n_elements(weights)
case np of
 0: flux=[0.5,0.5]
 1: begin 
     f2=(weights < 1.0) & f1=1.0-f2 & flux=[f1,f2] 
    end
 else: flux=[weights[0:1]]
endcase
flux=float(flux)

;-- if input map image not truecolor, then create 24 bit images from map color tables

if (true_index1 gt 0) then cdata1=map1.data else cdata1=mk_24bit(map1.data,map1.red,map1.green,map1.blue,_extra=extra,/no_copy)

tcount=0l
if valid_map(rmap) then rdata=rmap.data else rdata=map2.data
if is_number(threshold) then begin
 if threshold gt 0 then tsub=where(rdata le threshold,tcount)
endif

if (true_index2 gt 0) then cdata2=temporary(rdata) else cdata2=mk_24bit(rdata,map2.red,map2.green,map2.blue,_extra=extra,/no_copy)

;-- extract subranges

xrange=get_map_xrange(map2) & yrange=get_map_yrange(map2)
sub=get_map_sub(map1,xrange=xrange,yrange=yrange,count=count,irange=a,/no_data,_extra=extra)

if count eq 0 then begin
 err='Input maps do not overlap.'
 mprint,err
 return,null()
endif

;-- make composite true color image

dprint,'% Flux: ',flux
dprint,'% Count: ',count

cdata=cdata1
if tcount gt 0 then begin
 dims=size(cdata1,/dimensions)
 nx=dims[1] & ny=dims[2]
 cold=reform(cdata1,3,nx*ny)
endif

if count lt n_elements(map1.data) then begin
 cdata[*,a[0]:a[1],a[2]:a[3]]=byte(flux[0]*fix(cdata1[*,a[0]:a[1],a[2]:a[3]])+ $
           flux[1]*fix(temporary(cdata2[*,a[0]:a[1],a[2]:a[3]])) < 255)
endif else begin
 cdata=byte(flux[0]*fix(temporary(cdata1))+ $
            flux[1]*fix(temporary(cdata2)) < 255)
endelse

if tcount gt 0 then begin
 cdata=reform(cdata,3,nx*ny)
 cdata[*,tsub]=cold[*,tsub]
 cdata=reform(cdata,3,nx,ny)
endif
 
;-- convert to 8 bit color image if input map was not truecolor

omap=map1
if (true_index1 gt 0) then omap.data=temporary(cdata) else begin
 eight_bit=mk_8bit(cdata,red,green,blue,_extra=extra,err=err,/no_copy)
 if is_string(err) then return,null()
 if size(omap.data,/type) eq 1 then omap.data=temporary(eight_bit) else $ 
  omap=rep_tag_value(omap,eight_bit,'data',/no_copy)
 omap.red=red
 omap.green=green
 omap.blue=blue
endelse

return,omap
end
