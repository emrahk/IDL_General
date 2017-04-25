pro mk_pix, filenm, image, Ri, Gi, Bi, text=text, notext=notext, $
	moon=moon, mercury=mercury, misc=misc, other=other, norgb=norgb, $
	replace=replace, subdir=subdir, opath=opath, $
	filename=filename, newcaption=newcaption, nodist=nodist, index=index, $
	http=http
;+
;   Name: mk_pix
;
;   Purpose: make a genx file of image or current window for display by show_pix
;
;   Calling Sequence:
;      mk_pix [image, r, g, b, filename='filename', text=text, /replace]
;
;   Calling Examples:
;      mk_pix 		         	      ; read image and r/g/b from current window
;      mk_pix, /norgb			      ; dont include r/g/b vectors
;      mk_pix,image,r,g,b,filename='name'     ; user supplied image and r/g/b
;      mk_pix,'filename'	              ; pass filename  (will prompt otherwise) 
;      mk_pix,image,R,G,B, text=text          ; image and colors  passed 
;      mk_pix,/notext		 	      ; dont prompt for text description
;      mk_pix,img,r,g,b, subdir='calibration' ; subdir = showpix subdirectory 
;      mk_pix,'filename', /replace	      ; replace (overwrite) an existing file
;      mk_pix,'filename', opath=curdir()      ; write file to current directory
;      mk_pix,'filename', text='filename'     ; if text=file, read text from file
;      mk_pix,'filename', text='filename', /newcaption ; update text of existing file
;      mk_pix,im,r,g,b,/http			; update HTTP (mosaic) area
;
;   Keyword Parmaeters:
;      filename - filename to use (scaler string)
;      norgb - if set, dont save R/G/B vectors
;      notext - switch if set, dont prompt for text
;      moon OR eclipse - if set, use moon directory
;      mercury -       if set, use mercury directory
;      misc OR other - if set, use misc(ellaneous) directory
;      opath - path for output (default is showpix common area)
;      subdir - specify subdirectory under showpix common area)
;      newcapt - if set, update text (only) from existing file
;      text - string or string array desrcribing image (prompts if not passed)
;	      (text may be name of file which contains the desired text)
;      nodist - if set, do not send mail to ysserver (triggers distribution)
;
;   History:
;      13-Nov-1993 (SLF)
;      17-Nov-1993 (SLF) - fix bug with text 
;	7-Dec-1993 (SLF) - add replace switch
;       1-Mar-1994 (SLF) - add opath keyword, allow text to be file name
;      15-Mar-1994 (SLF) - add subdir keyword
;      18-Mar-1994 (SLF) - use $DIR_GEN_SHOWPIX instead of $DIR_SITE_GENPIX
;      26-Jun-1994 (SLF) - filename logic and document, add FILENAME keyword
;      14-Jul-1994 (SLF) - send mail to ysserver account (trigger distribution)
;      22-Jul-1994 (ETB/SLF) - add index keyword
;      12-oct-1994 (SLF) - fix potential scaler/array mismatch
;       7-Dec-1994 (SLF) - make dummy file to prevent distribution of 
;                          'replaced' files...
;      14-Feb-1995 (SLF) - add HTTP keyword and function
;      10-apr-1995 (SLF) - insure that subdir is defined
;      23-Feb-1998 (SLF) - permit ...fname,image,r,g,b
;      26-Feb-1998 (SLF) - fix problem with 23-feb update
;-

replace=keyword_set(replace)
topenv=get_logenv('DIR_GEN_SHOWPIX')
if not file_exist(topenv) then begin
   message,/info,"Cannot find showpix files..."
   message,/info,"Please define files under $DIR_GEN_SHOWPIX, teturning"
   return
endif

allpix=file_list(concat_dir(topenv,'*'),'*.genx')
break_file,allpix,apl,app,apf,ape,apv

case 1 of 
   keyword_set(mercury): opath=concat_dir(topenv,'merc')
   keyword_set(moon) or keyword_set(eclipse): opath=concat_dir(topenv,'moon')
   keyword_set(misc) or keyword_set(other):   opath=concat_dir(topenv,'misc')
   keyword_set(subdir): opath=concat_dir(topenv,subdir)
   else: subdir='misc'
endcase

newcapt=0
if n_elements(image) ne 0 and n_elements(opath) eq 0 then begin
   which=wc_where(apf,image,cnt)
   if cnt eq 1 and replace then begin
      opath=app(which)
      oldfile=allpix(which(0))
      newcapt=1
    endif
endif

otext=''
case (data_chk(text,/type))(0) of
   0: if not keyword_set(notext) then begin
         line=''
         read,'Enter Text: <CR to quit>: ',line
         while (line ne '') do begin
            otext=[otext,line]   
            read,'Next Line:  <CR to quit>: ',line
         endwhile
         if n_elements(otext) gt 1 then otext=otext(1:*)
        endif
   7: begin
         if n_elements(text) eq 1 and file_exist(text(0)) then begin
           message,/info,'Reading text from file: ' + text(0)
           otext=rd_tfile(text(0))      
         endif  else otext = text
      endcase
   else: message,/info,"Text should be string, string array, or filename"
endcase   


;
; ------------ check positional input and assign parameters ----------------
; ------ (messy due to allowing 1st param to be image or filename) ----
case data_chk(filenm,/type) of   
   7: begin
        filename=filenm
        if n_params() ge 2 then imagein=image
      endcase
   0: begin
         if not keyword_set(filename) then begin
            tbeep
            filename=''
            read,'Enter filename: ' ,filename
         endif
      endcase
   else:begin				; some numeric
      imagein=filenm
   endcase
endcase
; ----------------------------------------------------------------

rdimg=n_elements(imagein) eq 0			; not defined, read from screen

if n_elements(filename) eq 0 then begin		; spagetti which 
   filename=''					; results from not
   read,'Enter filename: ' ,filename		; restricting input parmeters
endif						; let this be a lesson to you
						; use keywords, not flexible
						; positional parameters...


if n_elements(opath) eq 0 then begin
   break_file,filename,log,opath,file,ext,ver
   filename= file + ext + ver
endif

if opath(0) eq '' then begin
   ppixgen=curdir()
   if topenv ne '' then ppixgen=dir_list(topenv)
   if n_elements(ppixgen) gt 1 then begin
      message,/info,'SELECT OUTPUT DIRECTORY...'
      which = wmenu_sel(ppixgen,/one)
      if which(0) ne -1 then opath=ppixgen(which) else $
	 opath=curdir()
   endif
endif

ofile=concat_dir(opath, filename)

ofile=str_replace(ofile,'.genx', '') + '.genx'

; ------------------- update text for existing file -------------
newcapt=keyword_set(newcaption)
if newcapt then begin			; unstructured afterthought!!!
   message,/info,'Updating caption in file: ' + filename
   restgen,file=ofile,struct=struct
   if data_chk(struct,/struct) then begin
      file_delete,ofile
      file_append,ofile,'',/new		; dummy 'touch' of the file
      savegen,file=ofile,struct=struct,text=otext,/replace
   endif else message,/info,'Problem, not replacing file...'
      return				; !!!!!!!!!!!!! unstructured exit !!!
endif
; ----------------------------------------------------------------

case n_params() of 
   4: begin 		        ; Assume image,r,g,b - (shift R/G/B)
      R=image
      G=Ri
      B=Gi
   endcase	
   5: begin
     R=Ri
     B=Bi
     G=Gi
   endcase
   else: begin
     box_message,'no R,G,B supplied; Using Colar Table 0'    
     ct2rgb,0,r,g,b
   endcase
endcase   
   
; if image not passed in , read from current window (flag errors
if rdimg then begin
   if !d.name ne 'X' and !d.name ne 'Z' then begin
	tbeep
	message,/info,'Need X windows or Z buffer for read, returning'
	return
   endif
   if !d.name eq 'X' and !d.window eq -1 then begin
	tbeep
        message,/info,'No window to read from, must display something or supply image.
        return
   endif

   message,/info,'Reading image and color table from current window...'
   imagein=tvrd()
   if n_elements(r) eq 0 and (1-keyword_set(norgb)) then tvlct,r,g,b,/get
endif   
if file_exist(ofile) then begin
   if not keyword_set(replace) then begin
      tbeep
      message,/info,'File name exists (and you did not use /replace switch)'
      yesnox,'Do you want to replace it?',resp,'yes'
      if 1-resp then return				;** unstructured exit
   endif
   file_delete,ofile
   file_append,ofile,'',/new			; dummy 'touch' of the file
endif

message,/info,'Writing file: ' + ofile

if data_chk(index,/struct) then begin
   if n_elements(r) eq 0 or keyword_set(norgb) then  $
      savegen,file=ofile, imagein, index, text=otext $
	   else savegen,file=ofile, imagein,r,g,b, index, text=otext
   endif else begin
   if n_elements(r) eq 0 or keyword_set(norgb) then  $
      savegen,file=ofile, imagein, text=otext $
	 else savegen,file=ofile, imagein,r,g,b, text=otext
endelse

; ------ on request (or for new isas data), update the HTTP server areas. ---
if n_elements(subdir) eq 0 then subdir=''
http=keyword_set(http) or $
   ( (subdir eq 'new_data') and (get_logenv('DIR_SITE_SITENAME') eq 'ISAS'))

if http then $
   genx2html, ofile, /thumbnail,/addlink
; -------------------------------------------------------------------------

if not keyword_set(nodist) then $
   mail,'mk_pix update request', subj="SHOWPIX: Export New",   $
      user='ysserver@isass0.solar.isas.ac.jp'

return
end
