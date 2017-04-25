pro mreadfits, files0, info, data, noscale=noscale, GOOD=good, $
	strtemplate=strtemplate, nodata=nodata, header=header, quiet=quiet, $
        outsize=outsize, maxx=maxx, maxy=maxy, add_standard=add_standard, $
        comsep=comsep, hissep=hissep, comments=comments, history=history, $
        ccnts=ccnts, hcnts=hcnts, nocomments=nocomments, nohistory=nohistory, $
	all_keywords=all_keywords, nofill=nofill, silent=silent, wcs=wcs, $
        _extra=_extra
;+
;   Name: mreadfits
;
;   Purpose: read multiple FITs into data cube, header-> IDL structure array
;
;   Input Parameters:
;      files - fits files to read
;
;   Keyword Parameters:
;      strtemplate - template structure for read (reccommended, not required)
;      nodata - switch, if set, dont read the data (return only structures)
;      header (output) - last fits header as string array
;      outsize - 1 or 2 element array ([nx,ny]) specifying the output size 
;                of data array - default is [max(NAXIS1),max(NAXIS2)]
;      add_standard - if set and NO template supplied, add some standard tags
;      comments (output) - concatentation of all COMMENT 
;      ccnts    (output) - counts (pointers) to map files -> COMMENT
;      history  (output) - concatentation of all HISTORY 
;      hcnts    (output) - counts (pointers) to map files -> HISTORY
;      all_keywords (input) - if set, then go through all input file and get
;			the full list of unique keywords to build the template
;			structure (rather than from the first file)
;      silent/quiet(synonyms) - less verbose
;      GOOD=	Returns index of files0 which are valid filenames (in case some 
;   	    	are not)
;                           
;      Also takes any keywords accepted by FITSHEAD2WCS.
;                           
;   Calling Sequence:
;      mreadfits, filelist, index [,data , strtemplate=structure, $
;                                   outsize=xy,  /nodata]
;
;   Calling Example:
;      mreadfits, spartan_files, index, data, strtemp=spartan_struct()  
;      mreadfits, eit_files,     index, data, strtemp=eit_struct()	
;      mreadfits,your_files, index, data, strtemp=your_template		
;
;      mreadfits, files, index, data, outsize=128     ; rebin "on the fly"
;      mreadfits, eit_files, index [,/nodata]         ; Fast (header only)
;      mreadfits, files, index, /add_standard         ; add "SSW standards"
;     
;      [note: xxx_struct.pro are functions which return template structures 
;             for instrument  XXX]
;      Serving Suggestions:
;      Leaving off DATA parameter (OR using /nodata keyword) results in 
;         HEADER-ONLY processing for speed.  
;
;      A useful sequence is:
;      --------------------------------------------------------------------
;      IDL> mreadfits, files, index                     ; headers only->struct 
;      IDL> ss=where(index.xxx ... AND index.yyy... )   ; vector filter
;      IDL> mreadfits,files(ss),index,data [outsize=xy] ; read desired->3D 
;      --------------------------------------------------------------------
;
;      --------------------------------------------------------------------
;      Example:
;      Mixture of 1024^2 512^2 256^2  128^2 can be read and displayed via:
;
;      IDL> mreadfits, files, index, data, outsize=256  ; read 3D (256x256xNN)
;      IDL> xstepper, data [,get_infox(index) ]         ; view 3D cube
;      --------------------------------------------------------------------
;
;   History:
;      21-Mar-1996 (S.L.Freeland) PROTOTYPE For EIT/SPARTAN originally
;      23-Mar-1996 (S.L.Freeland) no 'data' parameter implies /nodata
;      28-apr-1996 (S.L.Freeland) fix doc, add header keyword
;      21-oct-1996 (S.L.Freeland) allow naxis3 (3D) (see restrictions)
;      16-jan-1997 (S.L.Freeland) add OUTSIZE keyword and function
;      27-jan-1997 (S.L.Freeland) avoid problem with 3D introduced on 16-jan
;      28-jan-1997 (S.L.Freeland) remove restrictions on 2D/3D data combination
;      24-feb-1997 (S.L.Freeland) use <fitshead2struct> if no template passed
;      27-feb-1997 (S.L.Freeland) add ADD_STANDARD keyword, documentation
;      10-apr-1997 (S.L.Freeland) add COMMENTS, CCNTS, HISTORY, HCNTS
;                                 (see <mreadfits_info> to map file# -> COMMENT
;       4-jun-1997 (S.L.Freeland) call <mreadfits_fixup> if required
;                                 (adjust some tags for rebinned images)
;      29-Jul-1997 (C.E.DeForest) Accept one-dimensional data products 
;				  (patched call to make_array for the 
;				  case where NAXIS2 is 0)
;	4-Aug-1997 (C.E.DeForest) -Added nocom, nohist, and noscale options.
;				  -fixed repeating-"mreadfits temporary"
;				   bug (removed "mreadfits temporary" lines
;		 
;				  -Used "temporary" to dispose of initial-
;				   image array 
;      12-Aug-1997 (C.E.DeForest) -Fixed 1-D array reading (switched 
;				   make_array NAXIS2 check from "eq 0" 
;				   to "le 0" to handle NAXIS=1 case).
;	30-Jul-1998 (M.D.Morrison) - Added /ALL_KEYWORDS
;       18-Aug-1998 S.L.Freeland - add /NOFILL keyword
;                                  (pass to fitshead2struct)  
;       04-Aug-1999 J.S.Newmark  - change loops indices from INT -> LONG
;       19-may-2005 S.L.Freeland - add SILENT synonym for QUIET -> readfits
;       10-Jan-2006 A.Vourlidas  - Force reading of headers in
;                                  readfits calls for proper treatment
;                                  of UINT types (SECCHI images).
;       17-Feb-2006 W.T.Thompson - Support WCS_STRUCT
;   	22-Sep-2006 N.B.Rich 	 - Add _extra to fits_interp call
;       18-Jun-2010 W.T.Thompson - Update BLANK values
;   	19-Oct-2011  N.B.Rich	 - pass /SILENT to fitshead2struct; check for .gz version of file
;   	 8-Nov-2011  N.B.Rich	 - Do not exit if a file in list is missing; skip and return files that are found.
;				 
;   Restrictions:
;      use of <strtemplate> is STRONGLY RECOMMENDED for consistent output
;      (and to facilitate downline structure concatenation operations)
;      Most of the problem is due to non-conforming FITS headers
;      Improvements to <fitshead2struc> is ongoing which will help to 
;      relieve this "restriction" 
;-
files=files0
nf=n_elements(files)
quiet=keyword_set(quiet)
silent=quiet or keyword_set(silent)

IF not file_exist(files[0]) THEN BEGIN
    gzp=strpos(files,'.gz')
    wgz=where(gzp GT 0,ngz,complement=wnogz)
    IF gzp[0] GT 0 THEN BEGIN
    	IF not silent THEN message,files[0]+' not found; trying without .gz',/info
	files[wgz]=strmid(files[wgz],0,gzp[0]) 
    ENDIF ELSE BEGIN
    ; try with .gz
    	IF not silent THEN message,files[0]+' not found; trying with .gz',/info
    	files[wnogz]=files[wnogz]+'.gz'
    ENDELSE
ENDIF
    	
; ---------------------- define the template structure ----------------
if not data_chk(strtemplate,/struct) then begin
    head=headfits(files(0))		; pretty fast header-only read
    if (keyword_set(all_keywords)) then begin
	for i=1l,nf-1 do begin
	    head2 = headfits(files(i))
	    ss1 = where_arr( strmid(head2, 0, 8), strmid(head, 0, 8), /map_ss)
	    ss2 = where(ss1 eq -1, nss2)	;where head2 is not in head
	    if (nss2 ne 0) then begin
		head = [head, head2(ss2)]
	    end
	end
    end
    strtemplate=fitshead2struct(head,add_standard=add_standard, nofill=nofill,$
                               wcs=wcs, SILENT=silent, _extra=_extra)
endif
; ----------------------------------------------------------------------

; --------------------- read all headers first -------------------------
info=replicate(strtemplate,nf)

ccnts=lonarr(nf)
hcnts=lonarr(nf)

comments='' & history=''
good=-1

for i=0l,nf-1 do begin

    IF not file_exist(files[i]) THEN BEGIN
    	message,files[i]+' not found; skipping',/info
	help,i
	wait,1
    	goto,next
    ENDIF
    
   head=headfits(files(i))			 ; read header-only
   alls=lonarr(n_elements(head))+1               ; header map
   nonnull=strlen(strtrim(head,2)) ne 0          ; non-null map

;  ---------- seperate COMMENT and HISTORY records -------------
   coms=(strpos(head,'COMMENT') eq 0) 		 ; comment-only map
   hiss=(strpos(head,'HISTORY') eq 0)            ; history-only map
   comss=where(coms ,ccnt) & comss(0)=comss(0)>0  ; where COMMENT
   hisss=where(hiss,hcnt) & hisss(0)=hisss(0)>0  ; where HISTORY
   if not keyword_set(nocomments) then $
	comments=[temporary(comments),head(comss)]    ; append->output
   if not keyword_set(nohistory) then $
	history =[temporary(history), head(hisss)]    ; append->output
   ccnts(i)=ccnt & hcnts(i)=hcnt                 ; counter/pointer
;  ----------------------------------------------------------------

   head=head(where(alls and nonnull and $      
            (1-(coms*keyword_set(comsep))) and $ ; strip COMMENTS? (future use)
            (1-(hiss*keyword_set(hissep)))))     ; strip HISTORY?  (future use)

   if(total(strpos(head,'COMMENT') eq 0) eq 0) then $
	fxaddpar,head,'COMMENT','' ; force at least a blank COMMENT line (CED)

   if(total(strpos(head,'HISTORY') eq 0) eq 0) then $
	fxaddpar,head,'HISTORY','' ; force at least a blank HISTORY line (CED)

;  header->structure
   fits_interp,head,outstr,instruc=strtemplate, _extra=_extra ; convert to structure
   if tag_exist(outstr,'wcs_struct') then $
     outstr.wcs_struct = fitshead2wcs(outstr,_extra=_extra)
   info(i)=outstr   
   IF good[0] EQ -1 THEN good=i ELSE good=[good,i]
   next:
endfor

comments=comments(where(strlen(comments) gt 0) >0) ; Kill blank lines (CED)
history = history(where(strlen(history ) gt 0) >0) ; Kill blank lines (CED)

; --------------------------------------------------------------------

; -------------- Account for non-existent files ----------------------
info=info[good]
files=files0[good]
nf=n_elements(good)
; --------------------------------------------------------------------

nind=intarr(nf)+1                                    ; images/file (2D case)
pnt=[0,totvect(nind)]                                ; pointers

; ------------- handle 3D files, if applicable  ----------------------
naxis3=gt_tagval(info,/naxis3)                           ; check&extract  NAXIS3
ss3d=where(naxis3 gt 0,ss3dcnt)                          ; Any 3D files?
if ss3dcnt gt 0 then begin
   outind=replicate(info(0),total(info(ss3d).naxis3) $   ; one index/image
		 + (nf-ss3dcnt))
   nind=info.naxis3 > 1                                  ; generate 2D/3D
   pnt=[0,totvect(nind)]                                 ; pointers

;  for each 3D file, replicate the header structure X #sub images
   for i=0l,nf-1 do outind(pnt(i))=replicate(info(i),nind(i)) 	   
   info=temporary(outind)
endif
; --------------------------------------------------------
header=head					; return output
; --------------------------------------------------------

; --------- read/populate the cube unless /nodata set -----------
nodata=keyword_set(nodata) or n_params() lt 3

if not nodata then begin                ; "not nodata" is bad grammer
;  ----- determine size of output array -----

   case n_elements(outsize) of
      0: outxy=[max(gt_tagval(info,/naxis1)),max(gt_tagval(info,/naxis2))]
      1: outxy=replicate(outsize,2)
      2: outxy=outsize
      else: outxy=outsize(0:1)          ; should not happen
   endcase

                                ; get representative image data type
                                ; Force reading of header to treat
                                ; UINT types correctly
   dat=readfits(files(0),junk, noscale=noscale,silent=silent)
   data=make_array(outxy(0), outxy(1)*(outxy(1) gt 0) + (outxy(1) le 0), total(nind), type=data_chk(dat,/type))
;  ----------------------

;  ---- flag images which need rebinning ----
   sscongrid=gt_tagval(info(pnt),/naxis1) ne outxy(0) or $
             gt_tagval(info(pnt),/naxis2) ne outxy(1)

;  loop though all files, read data and insert into output array
   i=0
   if sscongrid(i) then dat=congrid(temporary(dat),outxy(0),outxy(1),nind(i))
   data(0,0,pnt(i))=temporary(dat); insert 2d/3d -> Output array
   while i lt (nf-1) do begin
      i=i+1
      dat=readfits(files(i), boo, noscale=noscale,silent=silent); read 2D or 3D files

      if sscongrid(i) then dat=congrid(temporary(dat),outxy(0),outxy(1),nind(i))
      data(0,0,pnt(i))=temporary(dat(*,*,*))	 ; insert 2d/3d -> Output array
   endwhile
   if total(sscongrid) gt 0 then mreadfits_fixup,info,data ; adjust tags
endif
; ----------------------------------------------------------------

; Unless the /NOSCALE option was selected, update the BLANK keywords to agree
; with the scaled data.  This is done to support unsigned integer data types.
; Note that the data type of the BLANK values does not change.

if ~keyword_set(noscale) and tag_exist(info,'blank') then begin
    blank = info.blank
    if tag_exist(info, 'bscale') then begin
        w = where(info.bscale ne 1, count)
        if count gt 0 then blank = blank * info.bscale
    endif
    if tag_exist(info, 'bzero') then begin
        w = where(info.bzero ne 0, count)
        if count gt 0 then begin
            bzero = info.bzero
            w = where(bzero ne long(bzero), count)
            if count eq 0 then bzero = long(bzero)
            blank = blank + bzero
        endif
    endif
    info.blank = blank
endif

return
end

