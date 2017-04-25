function mxf_decomp_data, structure, stream, comp_code=comp_code, $
			  infile=infile
;+
;   Name: mxf_decomp_data
;
;   Purpose: convert fits extension header and byte stream to image
;
;   Input Parameters:
;      structure - mxf style structure
;      stream    - compressed stream
;
;   History:
;      1-Nov-1997 - S.L.Freeland - originally for TRACE, but ~generic
;      2-Mar-1998 - S.L.Freeland - enable standard 12 bit jpeg decoder
;      4-Mar-1998 - S.L.Freeland - eliminate some debug, documentation...
;      5-Jan-2000 - S.L.Freeland - fix bug pointed out by Harry Warren
;  
;   TODO - allow comp_code as keyword (dont require structure?)
;
;   Codes Allowed (append as new features added):
;      0  - no compression
;      1  - 12 bit JPEG (per TRACE implementation)
;     [2] - [hcompress] - [not yet implemented]
;-

if not data_chk(structure,/struct) or n_params() lt 2 then begin
   prstr,strjustify(["Need structure and stream data..",$
	  "IDL> image=mxf_decomp_data(structure,stream)"],/box)
   return,-1
endif

; ------- check verify fields required by decomp routines -------
if keyword_set(comp_code) then compcode = comp_code else $
        compcode=gt_tagval(structure,/comp_code,found=ccf)
dtype   =gt_tagval(structure,/data_type,found=dtf)
nxout   =gt_tagval(structure,/nx_out,found=nxf)
nyout   =gt_tagval(structure,/ny_out,found=nyf)
; ----------------------------------------------------------------
ok= keyword_set(comp_code) or (ccf and dtf and nxf and nyf)

if not ok then begin
   prstr,strjustify(["Structure requires tags: ",$
	   "   COMP_CODE, DATA_TYPE, NX_OUT, and NY_OUT"],/box)
   return,-1
endif
; ----------------------------------------------------------------

case compcode of
  0: begin
         image=stream
         host_to_ieee, image, idltype=dtype
      endcase
  1: image=trace_jpeg_decomp(structure,stream)
  else: image=make_array(nxout,nyout,type=dtype)+fix(structure.img_max)
endcase   

return,image
end
