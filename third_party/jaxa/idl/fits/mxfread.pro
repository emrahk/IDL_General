pro mxfread, infiles, outstruct, outdata, filemap=filemap,             $
	     primary=primary, extension=extension,                     $
	     match_records=match_records, ss=ss,                       $
	     loud=loud, debug=debug
;+
;   Name: mxfread
;
;   Purpose: Multi-Fits-Extension READer 
;  
;   Input Parameters:
;      infiles - filelist
;
;   Output Paramters:
;      oustruct - output structure (primary or extension IDL structures)
;      outdata  - optional output data array  
;
;   Keyword Parameters:
;      ss      (input)  - subset indices to read (data only)
;      loud    (input)  - if set, print some diagnostics 
;      filemap (output) - lonarr map - maps files:outstruct 
;  
;   Calling Sequence:
;     mxfread, infiles, pheaders                   ; return primary struct
;     mxfread, infiles, eheaders,  /extension      ; return extension struct
;
;   History:
;      17-Oct-1997 - S.L.Freeland - originally for TRACE, but...
;      12-Mar-1998 - S.L.Freeland - protect against different structure
;      10-dec-2003 - S.L.Freeland - change mrdfits2 reference -> mrdfits   
;                                   (ancient requirement for mrdfits2
;                                    has passed)
;  
;   Calls:
;      mreadfits, mrdfits,
;  
;   TODO:
;      ?? make this an optional mreadfits.pro function ??  
;      Combine unlike output structures
;-  
debug=keyword_set(debug)
if n_params() lt  2 then begin
   prstr,strjustify( ['Need filelist and at least one output parameter', $
   'IDL> mxfread,filelist,outstruct [,data] [,/primary] [,/extension]'],/box)
   return
endif   
  
silent=1-keyword_set(loud)  
nf=n_elements(infiles)
if n_elements(ss) eq 0 then ss=lindgen(nf)

extension=keyword_set(extension)                          ; extension?
primary=1-extension                                       ; default
mreadfits, infiles, outstruct                             ; primary->out

if extension then begin
   nextrows=gt_tagval(outstruct,found=found, /EXT_NROW)   ; nrows (images)
   if found then begin
      totext=total(nextrows)                              ; total
      pointers=[0,totvect(nextrows)]                      ; file pointers
      extstruct=mrdfits(infiles(0),1,silent=silent)      ; first exten.
      outstruct=temporary(extstruct)
      if nf gt 1 then begin
         filemap=lonarr(totext)
         for i=1,nf-1 do begin                             ; file loop
               extstruct=mrdfits(infiles(i),1,silent=silent) ; next EXT
               outstruct=str_concat(outstruct,temporary(extstruct))
               filemap(pointers(i))=replicate(i,nextrows(i)>1)
         endfor     
      endif
   endif else message,/info,"No EXT_NROW tag defined, returning Primary"

endif else filemap=lindgen(nf)             ; primary? filemap is 1:1 w/files

; ----------------------- data read ---------------------------------------

if n_params() gt 2 then begin              ; dont bother if no output request
   nout=n_elements(outstruct)
   if n_elements(ss) eq 0 then ss=lindgen(nout)
endif   

return
end
