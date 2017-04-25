;+
; Project     : RHESSI
;
; Name        : MK_COLOR_MAP
;
; Purpose     : Add RGB color information to a map
;
; Category    : imaging
;
; Syntax      : map=mk_color_map(map,red,green,blue)
;
; Inputs      : MAP = image 
;               RED, GREEN, BLUE = color table arrays
;               (if not entered, read from color table)
;
; Outputs     : CMAP= map with RGB color arrays appended as fields
; 
; Keywords    : NO_COPY = throw away original map.
;               LOG_SCALE = log scale the data.
;               BYTE_SCALE = byte scale the data.
;               FUNCT = function to process data (e.g. sqrt).
;               DMIN, DMAX = data limits include. Data outside these
;               limits set to these values.
;               TRUE_INDEX = 1,2,3 to load colors into map data array
;               as interleaved images. Data will be byte-scaled
;
; Example     : IDL> loadct,1
;               IDL> cmap=mk_map_color(map,/log)
;               IDL> plot_map,cmap
;
; Written     : 23-Dec-2010, Zarro (ADNET) - written
;               20-Aug-2013, Zarro (ADNET) 
;               - added capability to override existing colors
;               3-Apr-2015, Zarro (ADNET)                
;               - added /NO_BYTE_SCALE
;               20-Apr-2015, Zarro (ADNET)
;               - added TRUE_INDEX keyword
;               30-Aug-2015, Zarro (ADNET)
;               - added check for current map colors
;                 
; Contact     : dzarro@solar.stanford.edu
;-

function mk_color_map,map,red,green,blue,no_copy=no_copy,log_scale=log_scale,$
                      byte_scale=byte_scale,_extra=extra,$
                      funct=funct,dmin=dmin,dmax=dmax,true_index=true_index

if ~valid_map(map) then begin
 mprint,'Undefined or Invalid input map.'
 pr_syntax,'cmap=mk_map_color(map)'
 return,-1
endif

do_log=keyword_set(log_scale)
do_byte=keyword_set(byte_scale)
no_copy=keyword_set(no_copy)
if no_copy then cmap=temporary(map) else cmap=map
bscaled=is_byte(cmap.data)
if have_tag(cmap,'log_scale') then lscaled=cmap.log_scale else lscaled=0b

if do_log && lscaled then begin
 mprint,'Map image already log-scaled.'
 do_log=0b
endif

if do_byte && bscaled then begin
 mprint,'Map image already byte-scaled.'
 do_byte=0b
endif
 
cdata=cmap.data
if is_number(dmin) then cdata=temporary(cdata) > dmin
if is_number(dmax) then cdata=temporary(cdata) < dmax

;-- user supplied function?

if is_string(funct) then begin
 if have_proc(funct) then cdata=call_function(funct,cdata)
endif

;-- log scale?

if do_log && ~bscaled then cdata=alog_scale(cdata,/no_copy)

;-- colors input?

map_colors=color_map(map)
input_colors=valid_colors(red,green,blue)

case 1 of 
 input_colors: begin
  ired=red & igreen=green & iblue=blue
 end
 map_colors: begin
  ired=map.red & igreen=map.green & iblue=map.blue
 end
 else: device_colors,ired,igreen,iblue
endcase

;-- remove old colors

cmap=rem_tag(cmap,['red','green','blue'])

;-- make True_Index map
 
if is_number(true_index) then begin
 if true_index gt 0 then begin
  cdata=mk_24bit(cdata,ired,igreen,iblue,/no_copy,true_index=true_index,_extra=extra)
  cmap=rep_tag_value(cmap,cdata,'data',/no_copy)
  return,cmap
 endif
endif

;-- byte scale

if do_byte then cdata=bytscl(cdata,_extra=extra,/nan)
t1=size(cmap.data,/type)
t2=size(cdata,/type)
if t1 eq t2 then cmap.data=temporary(cdata) else $
 cmap=rep_tag_value(cmap,cdata,'data',/no_copy)

;-- add colors

cmap=create_struct(temporary(cmap),'red',ired,'green',igreen,'blue',iblue)

if do_log then begin
 if have_tag(cmap,'log_scale') then cmap.log_scale=1b else $
  cmap=create_struct(cmap,'log_scale',1b)
endif

return,cmap
end
