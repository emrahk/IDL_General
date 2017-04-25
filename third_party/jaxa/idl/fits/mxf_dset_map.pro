function mxf_dset_map,  phead,  ss
;+
;   Name: mxf_dset_map
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
;      dsetarr=mxf_dset_map(pheaders, ss)
;      dsetarr=mxf_dset_map(files, ss)
;
;   History:
;      20-Oct-1997 - S.L.Freeland , prototype - originally for TRACE, but...
;      11-Mar-1998 - S.L.Freeland, scalarize dsetmap/filemap if only one record
;       3-Mar-1999 - S.L.Freeland - permit FILE_D$LEN in addition to EXT_NROW  
;  
;   Restrictions:
;      not much error checking  
;-  
common mfxdset_map_blk, dset_struct
if not keyword_set(dset_struct) then dset_struct={dset:0, ifile:0}

debug=keyword_set(debug)

if n_params() lt  1 then begin
   prstr,strjustify( ['Need at least one input parameter...', $
   'IDL> dset=mxf_dset_map(phead [,ss]'],/box)
   return,-1
endif   
  
silent=1-keyword_set(loud)  
retval=-1
case 1 of
   n_params() lt 2: begin
      prstr,strjustify('IDL> dset_arr=mxf_dset_map(pheaders, SS)',/box)
      return, -1
   endcase
   data_chk(phead,/struct): pheaders=phead
   data_chk(phead,/string): mreadfits, phead, pheaders
   else:
endcase

nextrows=gt_tagval(pheaders,found=found, /EXT_NROW)       ; nrows (images)

; synonms may be added to this list
case 1 of
   1-found: nextrows=gt_tagval(pheaders,found=found,/FILE_D$LEN) ; soon convention
   else:
endcase   

nhead=n_elements(phead)

trows=total(nextrows)
dsetmap=lonarr(trows)                 
filemap=dsetmap

if found then begin
   totext=total(nextrows)                              ; total
   pointers=[0,totvect(nextrows)]                      ; file pointers
   retval=replicate(dset_struct,totext)                ; define output
   for i=0,nhead-1 do begin                            ; "file" loop
       filemap(pointers(i))=replicate(i,nextrows(i))
       dsetmap(pointers(i))=indgen(nextrows(i))
   endfor
   if n_elements(retval) eq 1 then begin
      dsetmap=dsetmap(0)
      filemap=filemap(0)
   endif      
   retval.dset=dsetmap
   retval.ifile=filemap
endif else message,/info,"No EXT_NROW tag defined"

case 1 of
  n_elements(ss) eq 0: sss=lindgen(n_elements(retval))
  ss(0) eq -1: sss=lindgen(n_elements(retval))
  else: sss=ss
endcase  

return, retval(sss)
end
