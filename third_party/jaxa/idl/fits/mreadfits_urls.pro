pro mreadfits_urls, fitsurls,index, data, outsize=outsize, nodata=nodata, $  
   server=server, verbose=verbose, gateway=gateway, $
   status=status, success=success
;+
;   Name: mreadfits_urls
;
;   Purpose: read one/multiple FITS urls -> "index,data" via sockets
;
;   Input Parameters:
;      fitsurls - list of one or more fits file urls
;
;   Output Parameters:
;      index [,data] - ssw standards: index->FITS header as structure vector
;                                     data ->2D or 3D data
;
;   Keyword Parameters:
;      server - desired server (default derived from FITSURLs input)   
;      gateway - (switch) if server/fitsurls are via gateway 
;      status (output) - boolean vector of read success (1:1 w/fitsurls) - read ok?
;      success (output) - boolean scalar - 1 if all reads ok, 0 if at least one problem
;
;   Calling Examples:
;      mreadfits_urls,fitsurls, index [,server=server] [,/gateway] ; header only->index
;      mreadfits_urls,fitsurls, index, data                        ; headers+data    
;
;   Calling Context/Example : (sxi multi image example )
;
;      IDL> sxiurls=sxi_files('1-dec-2001 02:20','1-dec-2001 02:50',/ngdc,/full) ; time->urls
;      IDL> mreadfits_urls,sxiurls,index,server=sxi_server(),/GATEWAY,/VERBOSE   ; headers ->index
;
;      IDL> help,sxiurls,index                                                   ; show what I got
;           SXIURLS         STRING    = Array[32]
;           INDEX           STRUCT    = -> MS_097097004001 Array[32]             ; header/struct vector 
;
;      IDL> more,get_infox(index,'date_obs,exptime,wavelnth,crpix1,crpix2')      ; index summaries   
;         2001-12-01T02:19:14.004      3.0005     OPEN    224.0391    260.5744   ; (get_infox.pro)
;         2001-12-01T02:20:00.865      0.0155     OPEN    222.9005    259.9301
;         2001-12-01T02:21:15.507      3.0005  P_MED_A    221.9841    260.8560
;         2001-12-01T02:22:02.352      0.0255  P_MED_A    221.6006    261.2311
;         (...etc)
;
;      ; filter on above index, and read 3D subset
;      IDL> ss=where(index.exptime gt 2 and index.wavelnth eq 'OPEN')       ; desired subset  
;      IDL> mreadfits_urls,sxiurls(ss),index,data,server=sxi_server(),/GATE ; now read data  
;                          ===========                                      ; (only subset)
;      IDL> help,index,data                                                 ; filtered subset -> 3D
;         INDEX           STRUCT    = -> MS_097107956001 Array[8]
;         DATA            FLOAT     = Array[512, 512, 8]
;
;      IDL> more,get_infox(index,'date_obs,exptime,wavelnth,img_mean,img_med') ; check filtered output
;           2001-12-01T02:19:14.004      3.0005  OPEN     19.0213      9.4895
;           2001-12-01T02:23:13.629      3.0005  OPEN     18.9202      9.4304
;           2001-12-01T02:27:13.254      3.0005  OPEN     18.9639      9.4521
;           2001-12-01T02:31:12.879      3.0005  OPEN     18.9814      9.4751
;           2001-12-01T02:35:12.503      3.0005  OPEN     18.9521      9.4481
;           2001-12-01T02:39:15.495      3.0005  OPEN     18.9335      9.4547
;           2001-12-01T02:43:15.121      3.0005  OPEN     18.9578      9.4715
;           2001-12-01T02:47:14.746      3.0005  OPEN     18.9019      9.4565
;     
;   Calls:
;      ssw standards, fitshead2struct etc..
;      DMZarro hfits__define object (socket read)
;
;   History:
;      14-Jan-2003 - S.L.Freeland  ; socket/url analog of 'mreadfits.pro'
;      21-Jan-2003 - S.L.Freeland header-only socket reads & copy->local options
;      22-Jan-2003 - S.L.Freeland added STATUS and SUCCESS output indicators
;;
;   Restrictions:
;      At least for today, assumes all files same  naxis1&naxis2
;      OUTSIZE not yet implemented 
;      Assumes same server for a given call
;      Use of underlying RSI <socket> implies only Versions >= 5.4
;-

if not since_version('5.4') then begin 
   box_message,'Sorry, this routine requires IDL Version >= 5.4'
   return
endif

if not data_chk(fitsurls,/string) then begin 
   box_message,'Requires url list...'
   return
endif

case 1 of 
   data_chk(server,/string):                       ; user supplied
   else: begin 
      server=ssw_strsplit(fitsurls(0),'/',/head)   ; from 1st input element
   endcase
endcase
server=server(0)
nimg=n_elements(fitsurls)
nodata=keyword_set(nodata) or n_params() lt 3
verbose=keyword_set(verbose)
copy_local=keyword_set(copy_local) or data_chk(outdir,/string)
needdata=(1-nodata) or copy_local

if n_elements(outdir) eq 0 then outdir=get_temp_dir()

nii=-1                                                         ; current file subscript 

sread=(['http->hread,fitsurls(nii),header0',$                  ; header only socket read
        'http->read ,fitsurls(nii),data0,header0'])(needdata)  ; header+data

; sread=([sread,'sock_copy,fitsurls(nii),data0,header0,outdir=outdir'])(copy_local)

if not copy_local then begin 
   http=obj_new('hfits')
   http->open,server,gateway=gateway
endif

status=lonarr(nimg)
while not data_chk(index0,/struct) and nii lt nimg do begin 
   nii=nii+1
   estat=execute(sread)
   if n_elements(header0) gt 1 then index0=fitshead2struct(header0)
   status(nii)=data_chk(index0,/struct)
endwhile 

case 1 of 
   not data_chk(index0,/struct): begin 
      box_message,'No files read properly, returning...
   endcase
   nii eq (nimg-1): begin                          ; all done 
      estat=execute((['','data=temporary(data0)'])(needdata))
      index=temporary(index0)
   endcase
   else: begin                                     ; more to do  
      if needdata then begin  
         data=make_array(data_chk(data0,/nx),data_chk(data0,/nx), nimg-(nii),$
                         type=data_chk(data0,/type),/nozero)
         data(0,0,0)=temporary(data0)
      endif
      index=replicate(index0,nimg) 
      for nii=nii+1,nimg-1 do begin
         delvarx,data0,header0
         estat=execute(sread)
         status(nii)=n_elements(header0) gt 1
         if verbose then print,(['PROBLEM','Just read> '])(status(nii)) + fitsurls(nii)
         if status(nii) then begin 
            estat=execute((['','data(0,0,nii)=temporary(data0)'])(needdata)) ; 2D->3D
            index(nii)=temporary( fitshead2struct(header0,index(0)))         ; index
         endif
      endfor
   endcase 
endcase

if not copy_local then obj_destroy,http

readok=where(status,okcnt)
success=okcnt eq nimg                 ; All reads ok?
 
if not success then box_message,'Warning: ' + strtrim(nimg-okcnt,2) +' problem reads, check STATUS output'
   
return
end




