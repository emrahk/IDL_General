pro mxf_read_data, infiles, dset_arr, outstruct, outdata, $
     match_records=match_records, loud=loud, debug=debug, $
     outsize=outsize, mag_factor=mag_factor, rotate=rotate, dtype=dtype, $
		   phead=phead, subfield=subfield
;+
;   Name: mxf_read_data
;
;   Purpose: Multi-Xtension-Fits data reader
;  
;   Input Parameters:
;      infiles  - filelist
;      dset_arr - subset of data sets to read (-1 implies all)
;
;   Output Parameters:
;      oustruct - output structure (extended headers as IDL structures)
;      outdata  - optional output data cube - padded/embedded to largest
;                 image and optionally rebinned by OUTSIZE or MAG_FACTOR
;
;   Keyword Parameters:
;      outsize    - optional rebinned output array
;      mag_factor - another way to specify output size 
;  
;   Keyword Parameters:
;      loud    (input)  - if set, print some diagnostics 
;  
;   Calling Sequence:
;     mxf_read_data, infiles, dset_arr, eheaders     ; binary headers only
;     mxf_read_data, infiles, dset_arr, ehead, dcube ; also data cube
;
;   History:
;        4-Nov-1997 - S.L.Freeland - 4-November-1997 - originally for TRACE, but generic
;       12-Feb-1998 - MDM - Put in protection for data not fitting in the 
;                           output data cube
;        2-mar-1998 - SLF - dont rebin to max unless outsize or mag_fact
;                        explicitly set
;       10-mar-1998  - SLF - add ROTATE keyword & logic for .ROT_OUT field
;       15-mar-1998  - SLF - add DTYPE (override structure.DATA_TYPE
;                            (for recovery from bad values only - careful)  
;       25-mar-1998  - SLF - add PHEAD output keyword
;	22-aug-2001  - TDT - fix bug for nonsquare, non-compressed images
;
;   Calls:
;      mxf_read_header, mxf_decomp_data, mreadfits
;  
;   TODO:
;      ?? make this an optional mreadfits.pro function ??  
;      Combine unlike output structures
;      Optimize - avoid rereads, etc.  
;-  
debug=keyword_set(debug)

if n_params() lt  3 then begin
   prstr,strjustify( ['No output parameters specified...', $
   'IDL> mxf_read_data,filelist,dset, outheaders [,outdata]'],/box)
   return
endif   
  
loud=keyword_set(loud)
silent=1-loud
nf=n_elements(infiles)

extension=keyword_set(extension)                          ; extension?
primary=1-extension                                       ; default

; ----------------------- data read ---------------------------------------
case 1 of
   data_chk(dset_arr,/struct): darr=dset_arr
   dset_arr(0) eq -1: mxf_read_header,  infiles,  outstruct,  darr, /extension, phead=phead
   else: begin
      mreadfits, infiles,phead
      darr=mxf_dset_map(phead,dset_arr)
      mxf_read_header,  infiles,  outstruct,  darr, /extension
      outstruct=outstruct(dset_arr)
      darr=darr(dset_arr)
  endcase
endcase   

if n_params() gt 3 then begin                      ; data array              
   nimg=n_elements(outstruct)                      ; number of output img/items
   nx_out=gt_tagval(outstruct,/nx_out)
   ny_out=gt_tagval(outstruct,/ny_out)
   mnx=max(nx_out)                                 ; size for maximum
   mny=max(ny_out)                                 ; ditto
;  -------- determine output array size (logic from mreadfits.pro) ------
   case n_elements(outsize) of
      0: outxy=[mnx,mny]
      1: outxy=replicate(outsize(0),2)
      2: outxy=outsize
      else: outxy=outsize(0:1)          ; should not happen
   endcase
   if keyword_set(mag_factor) then outxy=outxy*mag_factor

   sscongrid=(nx_out ne outxy(0) or ny_out ne outxy(1)) and $
	      (n_elements(outsize) gt 0 or keyword_set(mag_factor) )
   
;  determine rotation
   rotval=gt_tagval(outstruct,/rot_out,found=rotfound)           ; .ROT_OUT
   case 1 of
      n_elements(rotate) eq nimg: rotval=rotate                  ; user vector
      n_elements(rotate) eq 1:    rotval=replicate(rotate,nimg)  ; user scalar
      rotfound:                                                  ; structure
      else: rotval=replicate(0,nimg)                             ; NONE
   endcase

;  -----------------------------------------------------------------------   
   if n_elements(dtype) eq 0 then dtype=max(gt_tagval(outstruct,/data_type))      ; ditto
   if n_elements(subfield) eq 4 then outxy=[subfield(2),subfield(3)]
   
   outdata=make_array(outxy(0),outxy(1),nimg,type=dtype)
   ufile=uniq(darr.ifile)                          ; uniq files (for later)
   lastfile =''
   for i=0,nimg-1 do begin                             
      thisfile=infiles(darr(i).ifile)
      newfile=thisfile ne lastfile
      openr,xx,/get_lun,thisfile                    ; *** TODO - only if NEW
      case gt_tagval(outstruct(i),/comp_code) of
	 0:  begin
		tdata=make_array($
               gt_tagval(outstruct(i),/nx_out), gt_tagval(outstruct(i),/ny_out), $
	       type=gt_tagval(outstruct(i),/data_type) )
		tsize=size(tdata)
; Nonsquare images which will be rotated must be transposed in size  TDT 22-Aug-01
		if (tsize(1) ne tsize(2)) and ((rotval(i) eq 6) or (rotval(i) eq 4) $
		   or (rotval(i) eq 3) or (rotval(i) eq 1)) then $
		tdata=make_array($
               gt_tagval(outstruct(i),/ny_out), gt_tagval(outstruct(i),/nx_out), $
	       type=gt_tagval(outstruct(i),/data_type) )
	     end
         else: tdata=bytarr(outstruct(i).n_bytes)   ; byte stream 
      endcase
      point_lun,xx,outstruct(i).start_byte           ; point to data start
      readu,xx,tdata                                 ; read data or stream
      tempdata=mxf_decomp_data(outstruct(i),tdata,$  ; stream->image
			       infile=thisfile)      ; TEMPORARY
      tempdata=rotate(temporary(tempdata),rotval(i)) ; apply rotation 
      if rotval(i) ne 0 and loud then box_message,'applied de-rotation, value: ' + strtrim(rotval(i),2)
      if sscongrid(i) then $
	  tempdata=congrid(temporary(tempdata),outxy(0),outxy(1))
      
      if n_elements(subfield) eq 4 then $
	  tempdata=tempdata(subfield(0):subfield(0)+subfield(2)-1,$
			    subfield(1):subfield(1)+subfield(3)-1)
      if (n_elements(tempdata(*,0)) gt outxy(0)) or (n_elements(tempdata(0,*)) gt outxy(1)) then begin
          message, 'Data read does not match index information.  Data read is larger', /info
	  message, 'Data not being put into the output array', /info
	  print, 'Infile: ' + thisfile + '  Dset: ', dset_arr(i)
          help, tempdata, nx_out(i), ny_out(i)
      end else begin
          outdata(0,0,i)=tempdata                      ; insert -> output
      end
      delvarx,tdata,tempdata                       ; memory cleanup
      free_lun,xx                                  ; *** TODO Only if NEW
   endfor     
endif   

return
end

