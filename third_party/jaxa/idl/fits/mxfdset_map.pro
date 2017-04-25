function mxfdset_map,  phead,  ss
;+
;   Name: mxfdset_map
;
;   Purpose: map Multi-Fits-Extension user SS -> "dset array"
;  
;   Input Parameters:
;      phead - primary header structures - assume tag "EXT_NROW"
;      ss    - subscripts of desired elements 
;
;   Output Paramters:
;      function returns dset structure array {dset:xx, ifile:}
;  
;   Calling Sequence:
;      dsetarr=mxfdset_map(pheaders, ss)
;      dsetarr=mxfdset_map(files, ss)
;
;   History:
;      20-Oct-1997 - prototype - originally for TRACE, but...
;  
;   Restrictions:
;      not much error checking  
;-  
common mfxdset_map_blk, dset_struct
if not keyword_set(dset_struct) then dset_struct={dset:0, ifile:0}

debug=keyword_set(debug)
if n_params() lt  2 then begin
   prstr,strjustify( ['Need filelist and at least one output parameter', $
   'IDL> mxfread,filelist,outstruct [,data] [,/primary] [,/extension]'],/box)
   return,-1
endif   
  
silent=1-keyword_set(loud)  
retval=-1
case 1 of
   n_params() lt 2: begin
      prstr,strjustify('IDL> dset_arr=mxfdset_map(pheaders, SS)',/box)
      return, -1
   endcase
   data_chk(phead,/struct): pheaders=phead
   data_chk(phead,/string): mreadfits, phead, pheaders
   else:
endcase

nextrows=gt_tagval(pheaders,found=found, /EXT_NROW)       ; nrows (images)
nhead=n_elements(phead)

dsetmap=lonarr(total(nextrows))                 
filemap=dsetmap

if found then begin
   totext=total(nextrows)                              ; total
   pointers=[0,totvect(nextrows)]                      ; file pointers
   retval=replicate(dset_struct,totext)                ; define output
   for i=0,nhead-1 do begin                            ; "file" loop
       filemap(pointers(i))=replicate(i,nextrows(i))
       dsetmap(pointers(i))=indgen(nextrows(i))
   endfor
   retval.dset=dsetmap
   retval.ifile=filemap
endif else message,/info,"No EXT_NROW tag defined"

return, retval(ss)
end
