pro mxf_read_header,  infiles,  outstruct, dset_arr , $
     extension=extension, primary=primary, ss=ss, loud=loud, $
     phead=phead
;+
;   Name: mxf_read_header
;
;   Purpose: read headers from mxf files
;  
;   Input Parameters:
;      infiles - list of mxf files
;
;   Output Paramters:
;      outstruct - output structure (primary or extension IDL structures)
;      dset_arr  - output full dset array (via mxfdset_map)
;
;   Keyword Parameters:
;      extension - if set, outstruct are extented headers
;      primary   - if set, outstruct are primary headers (1:1 with infiles)  
;  
;   Calling Sequence:
;     mxfread, infiles, pheaders [,dset_arr]              ; primary struct
;     mxfread, infiles, eheaders,[,dset_arr],  /extension ; extension struct
;
;   History:
;      28-oct-1997  - S.L. Freeland (written)
;	4-Dec-1997  - MDM Corrected reading primary header and passing it out
;      25-Mar-1998  - S.L. Freeland (add PHEAD output keyword)
;  
;   Calls:
;      mxfread, mxfdset_map
;  
;   TODO:
;      ?? make this an optional mreadfits.pro function ??  
;      Combine unlike output structures
;-  
debug=keyword_set(debug)
if n_params() lt 1 then begin
  box_message,['need to supply file list...', $
	       'IDL> mxf_read_headers,files [,phead] [,ehead,/exten]']
  return
endif  
  

silent=1-keyword_set(loud)  
nf=n_elements(infiles)

extension=keyword_set(ss) or keyword_set(extension)    ; extension?
primary=1-extension                                    ; default

mreadfits, infiles, phead
if n_params() gt 2 then dset_arr=mxf_dset_map(phead,ss)
if extension then mxfread, infiles, outstruct, /extension
if primary then outstruct = phead

return
end
