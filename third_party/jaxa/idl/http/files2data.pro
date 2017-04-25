function files2data, files, r, g, b, $
	   outsize=outsize, diffsize=diffsize, eightbit=eightbit
;+
;   Name: files2data
;
;   Purpose: read multiple files->3D cube w/optional congrid
;
;   Input Parameters:
;      files - vector of gif file names
;
;   Output:
;      function returns 3D data (1 image per <files>)
; 
;   Output Parameters:
;     r,g,b - R,G,B (taken from last file read) - only valid for 
;             verified formats
;
;   Keyword Parameters:
;     outsize - optional 1 or 2 element vector - desired [NX,NY] output
;     diffsize - (switch) - if set, size NX,NY from larges image 
;     [default size is relative to first image in list]
;     eightbit=eightbit - set if true colors -> 8 bit desired
;   
;   Calling Sequence:
;      IDL> cube=files2data(files [,outsize=[nx,ny] ] [,/DIFFSIZE ]
;
;   History:
;      17-Feb-2000 - S.L.Freeland - probably done before...
;      Circa 1-Jan-2003 - add eightbit, use read_trueimage if applicable
;      20-May-2003 - S.L.Freeland - merge W.Thompson 8-May mod w/above mod
;                                   (strsplit -> ssw_strsplit)
;
;       4-apr-2006 - S.L.Freeland - fix typo in read_image piece
;       3-apr-2008 - S.L.Freeland - mv png read_image -> read_png
;
;   Method:
;      GIF and TIFF are only "verified" readers for now.
;      This uses execute statement for automatic extension to 
;      other 'read_xxx' readers but "user beware" for those.
;-

if not data_chk(files,/string) then begin 
   box_message,['Need file list input',$
       'IDL> cube=files2data(files [,outsize=[nx[,ny]] [,/DIFFSIZE]']
endif

nimg=n_elements(files)  
if n_elements(outsize) eq 1 then outsize=replicate(outsize(0),2)  

outparam=',img,r,g,b'

exten=(strlowcase(ssw_strsplit(files(0),'.',/tail,/last)))(0)
case 1 of 
   is_member(exten,'BMP,JPEG,PPM,SRF,DICOM',/ignore): rdcmd='read_image,'
   is_member(exten,'gif'): rdcmd='read_'+exten +',' ; verified formats
   is_member(exten,'png'): rdcmd='read_'+exten +',' ; verified formats
   is_member(exten,'tiff'):     rdcmd='read_trueimage,eightbit=eightbit,'
   else: begin
       rdcmd='read_'+exten+','          ; "Dangerous" assumption
       outparam=',img'                  ; Safer unknown Interface bet
       box_message,['Warning:', $
         'File type: <' + exten + '> not explicitly verified',$
         'Assuming a read routine = '+rdcmd +' exists!']
   endcase
endcase

rcommand=rdcmd+'files(i)'+outparam

i=0
estat=execute(rcommand)               ; read 1st (template)

x0=data_chk(img,/nx)
y0=data_chk(img,/ny)

; ---------- create output array ----------------
case 1 of         
   keyword_set(outsize): $                                  ; user supplied
	retval=make_array(outsize(0),outsize(1),nimg,/byte)
   keyword_set(diffsize): begin
      for i=1,nimg-1 do begin                  ; size to largest
         estat=execute(rcommand)               ; read image(i)
         x0=x0>data_chk(img,/nx)
	 y0=y0>data_chk(img,/ny)
      endfor 
      retval=make_array(x0,y0,nimg,/byte)
    endcase
   else: retval=make_array(x0,y0,nimg,/byte)     ; else size to first 
endcase

x0=data_chk(retval,/nx)                          ; output size NX
y0=data_chk(retval,/ny)                          ; output size NY

for i=0,nimg-1 do begin
   estat=execute(rcommand)                                   ;Read 1
   if data_chk(img,/nx) gt x0 or data_chk(img,/ny) gt y0  $  ;Resize?
       then img=congrid(img,x0,y0)                           ;Resize 1
   retval(0,0,i)=img                                         ;Insert 1
endfor 

return,retval                                                ; return 3D
end
