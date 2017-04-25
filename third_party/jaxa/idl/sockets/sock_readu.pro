;+
; Project     : VSO
;
; Name        : SOCK_READU
;
; Purpose     : read and (optionally) write unformatted data from socket to file
;
; Category    : utility system
;
; Syntax      : IDL> sock_readu,ilun,data,[file=file]
;
; Inputs      : ILUN = socket unit to read from
; 
; Outputs     : OUTPUT = returned byte array [if not writing to FILE]
;
; Keywords    : MAXSIZE = max size in bytes to read (if known) 
;               BUFFSIZE = buffer size to read/write (def = 1 MB)
;               COUNTS = bytes actually read/written
;               ERR = error string
;               PROGRESS = set for progress meter
;               CANCELLED = 1 if reading was cancelled
;               SLURP = read without buffering
;               OMESSSAGE = output message (if /DEBUG)
;               CHUNKED = read using chunked-encoding
;               ASCII = set to convert data to ASCII
;               FILE = named file to write data
;
; History     : Written, 6 May 2002, D. Zarro (L-3Com/GSFC)
;             : Modified, 20 Sept 2003, D. Zarro (L-3Com/GSFC) 
;               - added extra error checks
;               Modified, 26 Dec 2005, Zarro (L-3Com/GSFC) 
;               - improved /VERBOSE output
;               Modified, 12 Nov 2006, Zarro (ADNET/GSFC)
;               - moved X-windows check into CASE statement
;               Modified, 21 Jan 2007, Zarro (ADNET/GSFC)
;               - fixed /PROGRESS
;               Modified, 1 Dec 2007, Zarro (ADNET)
;               - support reading files when maxsize is not known
;               Modified, 7 Sep 2012, Zarro (ADNET)
;               - added additional progress message showing
;                 number of bytes copied.
;               Modified, 30 Dec 2012, Zarro (ADNET)
;               - added support for reading chunked-encoded data
;               Modified, 24 Nov 2013, Zarro (ADNET)
;               - renamed from RD_SOCKET
;               Modified, 6 Mar 2015, Zarro (ADNET)
;               - changed /VERBOSE to /DEBUG
;               Modified  4-Dec-2015, Zarro (ADNET)
;               - added check for zero byte files on server
;               - added check if socket using RAWIO
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_readu,ilun,output,file=file,maxsize=maxsize,buffsize=buffsize,counts=counts,err=err,$
               _extra=extra,omessage=omessage,chunked=chunked,ascii=ascii,$
               cancelled=cancelled,slurp=slurp,progress=progress,$
               debug=debug

cancelled=0b & err='' & counts=0l & writing=0b

;-- input checks

if ~is_socket(ilun,rawio=rawio) then return

if is_string(file) then begin
 openw,olun,file,/get_lun,error=error
 if error ne 0 then begin 
  err=err_state()
  mprint,err
  return
 endif
 writing=1b 
endif

;-- if max size of data is unknown, we read in buffsize units until
;   EOF

if ~is_number(maxsize) then maxsize=0l
if ~is_number(buffsize) then buffsize=100000L

;-- show progress bar if file size greater than buffsize

if keyword_set(slurp) && (maxsize ne 0l) then buffsize=maxsize
debug=keyword_set(debug)
progress=keyword_set(progress)
chunked=keyword_set(chunked)
show_progress=progress &&(maxsize ne 0l) && ~chunked 

if show_progress then begin
 if allow_windows() then begin
  if (buffsize lt maxsize) then $
   pid=progmeter(/init,button='Cancel',_extra=extra,input=omessage) else begin
    xtext,omessage,/just_reg,wbase=wbase
    xkill,wbase
  endelse
 endif
endif

if debug then begin
 if is_string(omessage) then begin
  for i=0,n_elements(omessage)-1 do mprint,omessage[i],noname=(i gt 0)    
 endif
endif

err_flag=1b
icounts=0l
ocounts=0l
istart=0l

on_ioerror,bail
repeat begin

 if chunked then begin
  chunk=''
  readf,ilun,chunk
  if is_string(chunk) then begin
   chunk=strtrim(chunk,2)
   chk=strpos(chunk,';')
   if chk gt -1 then chunk=strmid(chunk,0,chk)
   bsize=hex2decf(chunk)
   if bsize gt 0 then data=bytarr(bsize,/nozero) else continue
  endif else continue 
 endif else begin
  iend=(istart+buffsize-1) 
  if maxsize gt 0l then iend = iend < (maxsize-1)
  bsize=iend-istart+1l
  if ~exist(data) then data=bytarr(bsize,/nozero) 
  if exist(old_bsize) then if bsize lt old_bsize then data=data[0:bsize-1]
 endelse

 if show_progress then begin
  val = float(icounts)/float(maxsize)
  if val lt 1 then begin
   if widget_valid(pid) then begin
    if (progmeter(pid,val) eq 'Cancel') then begin
     xkill,pid
     mprint,'Downloading cancelled'
     cancelled=1b
     on_ioerror,null
     message,/reset
     close_lun,olun
     return
    endif
   endif
  endif
 endif

;-- read data bytes 

 readu,ilun,data,transfer=icount

 icounts=icounts+icount
 if writing then begin
  writeu,olun,data,transfer=ocount 
  ocounts=ocounts+ocount
 endif else begin
  if exist(temp) then temp=[temporary(temp),temporary(data)] else temp=temporary(data)
 endelse
 istart=istart+icount
 old_bsize=bsize
 if (maxsize eq 0) then quit=0b else quit=(iend eq (maxsize-1))
 if rawio then bail_out=quit else bail_out=quit || eof(ilun)
endrep until bail_out
err_flag=0b

;-- check if bailed out too early

bail:
if err_flag then begin
 icount=(fstat(ilun)).transfer_count
 if icount gt 0 then begin
  icount=icount < n_elements(data)
  if icount ne n_elements(data) then data=data[0:icount-1]
  icounts=icounts+icount
  if writing then begin
   writeu,olun,data,transfer=ocount
   ocounts=ocounts+ocount
  endif else begin
   if exist(temp) then temp=[temporary(temp),temporary(data)] else temp=temporary(data)
  endelse
  if (maxsize eq 0l) then begin
   if eof(ilun) then err_flag=0b
  endif else begin
   if writing && (maxsize eq ocounts) then err_flag=0b
  endelse
 endif
endif

on_ioerror,null

message,/reset
close_lun,olun

if err_flag then begin
 err='Download failed - Zero size or partially downloaded file.'
 mprint,err
 counts=0l
 output=''
 return
endif

counts=icounts
if ~writing then begin
 output=temporary(temp)
 if keyword_set(ascii) then output=byte2str(output,newline=10)
endif

xkill,wbase
xkill,pid
delvarx,data

return

end
