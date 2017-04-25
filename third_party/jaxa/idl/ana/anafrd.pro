
;**************************************************************************
FUNCTION rice, name,ftype,hdr, $
               DELETE=del, nodelete=nodelete

;read rice compressed files or uncompressed fits files
;
; 12-November-1998 - S.L.Freeland - generate a uniq /tmp file name
;                                   ; use file_delete.pro (system/shell independent)
;                                   ; use ssw_bin path for decrunch binary
;                                   ; use /noshell in decruncher spawn
;                                   
; 25-feb-1998 - S.L.Freeland - remove 'is_lendian' code (ssw conflict)
;                              will use ssw gen version
;  4-may-1998 - S.L.Freeland - made DELETE the default
;  2-may-2000 - S.L.Freeland - dont call file_delete if no TEMPNAME
; 14-May-2000 - S.L.Freeland - fixed typo in case staement (missing ')

noend=1
nh=0
dflag=0
sflag=is_lendian()
delete=1-keyword_set(nodelete)

path = ['/tmp',get_logenv('HOME'), curdir()]      ; possible output dirs
wherepath=where(file_exist(path),pcnt)   ;

if pcnt gt 0 then begin
  path=path(wherepath(0))   
endif else box_message,['Cannot find a scratch file path',path]  

;if compressed data, decrunch it

if ftype eq 2 then begin
  dflag=1
  decruncher=ssw_bin('decrunch',found=found)    ; find system dependent version
  if not found then begin
     box_message,'Cannot find ana decruncher for this OS/Arch'
     return,-1
  endif
  user=strmid(get_user(),0,4)
  uname='dc'+user+strcompress(time2file(reltime(/now)))
  tempname=strcompress(concat_dir(path,uname),/remove)
  spcmd=[decruncher,name,tempname]
  spawn,spcmd,/noshell             
end

if ftype eq 1 then OPENR,unit,name,/GET_LUN else $
  OPENR,unit,tempname,/GET_LUN

r=ASSOC(unit,BYTARR(2880))
hdr=r[0]
dims=LONARR(8)

while noend eq 1 do begin
  
    for i=0,2880-1,80 do begin

        ss=hdr[i:i+79]
        ;look for end
        if STRING(hdr[i:i+3]) eq 'END ' then noend=0
        ;look for axes and fill in dimensions
        test=STRPOS(ss,'NAXIS')
        if test eq 0 then begin
            sq=STRMID(ss,5,1)
            if sq ne ' ' then begin
                iq=FIX(sq)
                if iq ge 0 or iq le 9 then $
                  dims(iq-1)=FIX(STRMID(ss,STRPOS(ss,'=')+1,50))
            endif else naxis=FIX(STRMID(ss,STRPOS(ss,'=')+1,50))
                                ;end of dimensions loop
        end                     ;of test for naxis loop
        ;look for data type
        test=STRPOS(ss,'BITPIX')
        if test eq 0 then begin
            iq=fix(STRMID(ss,STRPOS(ss,'=')+1,50))
            case iq of
                8   : datyp = 0
                16  : datyp = 1
                32  : datyp = 2
               -32  : datyp = 3
               -64  : datyp = 4
            end
        end                     ;of test for datatype loop
    end                         ;of for i loop

    nh=nh+1
    hdr=r[nh]

end                             ;of while loop

CLOSE,unit
FREE_LUN,unit
dims=dims[0:(naxis-1)]
if ftype eq 1 then OPENR,unit,name,/GET_LUN else OPENR,unit,tempname,/GET_LUN

;load header for return
ns=nh*2880		;number of header characters
nl=nh*36		;number of header lines
r=ASSOC(unit,BYTARR(ns))
hdr=r[0]
hdr=REFORM(hdr,80,nl)
hdr=STRING(hdr)

nq=1L
for i=0,naxis-1 do nq=nq*dims[i]

case datyp of
  0:	begin
	nfh=ns
        r=assoc(unit,BYTARR(nq+nfh))
	a=r[0]
	a=a[ns:*]
	end
  1:	begin
	nfh=ns/2
        r=assoc(unit,intarr(nq+nfh))
	a=r[0]
	a=a[nfh:*]
        if (sflag eq 1 and dflag eq 0) then byteorder,a
	end
  2:	begin
	nfh=ns/4
	r=assoc(unit,lonarr(nq+nfh))
	a=r[0]
	a=a[nfh:*]
	if (sflag eq 1 and dflag eq 0) then byteorder,/lswap,a
	end
  3:	begin
	nfh=ns/4
	r=assoc(unit,fltarr(nq+nfh))
	a=r[0]
	a=a[nfh:*]
        if sflag eq 1 then byteorder,/lswap,a
	end
end

x=REFORM(a,dims)
CLOSE,unit
FREE_LUN,unit

if delete and data_chk(tempname,/string) then file_delete, tempname

RETURN,x

END	;rice function


;**************************************************************************

FUNCTION f0read, name,hdr,lendian,sflag,dflag,datyp,ndim,nhd, $
                 DELETE=del, nodelete=nodelete

;puts decompressed results in a temporary file, then reads from this file

;**************************************************************************
delete=1-keyword_set(nodelete)

if dflag then begin

   path = ['/tmp',get_logenv('HOME'), curdir()]      ; possible output dirs
   wherepath=where(file_exist(path),pcnt)   ;

   if pcnt gt 0 then begin
     path=path(wherepath(0))   
   endif else box_message,['Cannot find a scratch file path',path]  

  decruncher=ssw_bin('decrunch',found=found)    ; find system dependent version
  if not found then begin
     box_message,'Cannot find ana decruncher for this OS/Arch'
     return,-1
  endif
  user=strmid(get_user(),0,4)
  uname='dc'+user+strcompress(time2file(reltime(/now)))
  tempname=strcompress(concat_dir(path,uname),/remove)
  spcmd=[decruncher,name,tempname]
  spawn,spcmd,/noshell             

    OPENR,unit,tempname,/GET_LUN
                                ;re-read the header if decrunched

    r=ASSOC(unit,BYTARR(512))
    hdr=r(0)                    ;get ho (original header) to check
    nhd=hdr(6)                  ;number of header records, may have changed!

end else OPENR,unit,name,/GET_LUN


;get entire header string, even if multiple header blocks
r=ASSOC(unit,BYTARR(512*nhd))
hdr=r[0]
ho=hdr[256:*]

; Get dimensions, only need first header block here
r=ASSOC(unit,INTARR(256))
d=r[0]
BYTEORDER,d
if lendian then begin
;some intermediate steps for swapping bytes and words
    ie=INDGEN(128)
    io=ie+1
    c=INTARR(256)
    c[ie]=d[io]
    c[io]=d[ie]
    BYTEORDER,/lswap,c
    d=LONG(c,0,128)
    dims=d[48:48+ndim-1]
end else begin
    de = d(INDGEN(128)*2)
    dims=de[48:48+ndim-1]
end 
;PRINT,dims

sz=1L
for i=0,ndim-1 do sz=sz*dims[i]
case datyp of
0:	begin
	nfh=512*nhd
	r=ASSOC(unit,BYTARR(sz+nfh))
	a=r[0]
	a=a[nfh:*]
	end
1:	begin
	nfh=256*nhd
	r=ASSOC(unit,INTARR(sz+nfh))
	a=r[0]
	a=a[nfh:*]
        if (sflag eq 1 and dflag eq 0) then BYTEORDER,a
	end
2:	begin
	nfh=128*nhd
	r=ASSOC(unit,LONARR(sz+nfh))
	a=r[0]
	a=a[nfh:*]
	if (sflag eq 1 and dflag eq 0) then BYTEORDER,/lswap,a
	end
3:	begin
	nfh=128*nhd
	r=ASSOC(unit,FLTARR(sz+nfh))
	a=r[0]
	a=a[128:*]
        if sflag eq 1 then BYTEORDER,/lswap,a
	end
end
x=REFORM(a,dims)
CLOSE,unit
FREE_LUN,unit

;Construct header string and replace CR with CR/LF if necessary.
hdr = hdr[256:*]
ncr = 0                         
nnlf = 0
cr = WHERE(hdr eq 13B,ncr)
if ncr ne 0 then nlf = WHERE(hdr[cr+1] ne 10B,nnlf)
if nnlf ne 0 then for i=0,nnlf-1 do hdr = [hdr[0:cr[nlf[i]]-1],13B,10B,hdr[cr[nlf[i]]+1:255]]

if delete and data_chk(tempname,/string) then file_delete,tempname

;if KEYWORD_SET(del) then SPAWN,'rm '+path+'decrunch_temp'

RETURN,x
END

;
;**************************************************************************
;

FUNCTION anafrd, name, hdri

;+
;NAME:
;	ANAFRD
;PURPOSE:
;	for reading various types of image files written by ana
;SAMPLE CALLING SEQUENCES:
;	x=anafrd('jan97hr_0686.mags',h)
;INPUT:
;	NAME = filename of image to be read
;OUTPUT:
;	x will contain the image array
;	h will contain the file header; for FITS files, the header is
;	returned as a string array of n strings of 80 characters.
;NOTE:
;	Rice and F0 decompression uses decrunch.c and associated files
;	(crunchstuff.c, anarw.c) and will write decompressed results to
;	a temporary file, then read from this file.  To use this routine
;	on outside systems, the C code executables must be present and
;	pathnames for locating them may need to be changed in the IDL
;	code.  The user may also wish to change the location of the
;	temporary file.  
;HISTORY:
;	Z. Frank 3/97, based on R. Shine's writing and decompression routines
;          puts decompressed results in a temporary file, then reads from this file.
;       T. Berger 3/98: IDL. v5.0 update and various mods in f0read for speed increase.
;
;**************************************************************************
;

ON_ERROR,2

;Read the header for file typing:
OPENR,unit,name,/GET_LUN,ERROR=err
if err ne 0 then begin
    PRINTF,-2,!ERR_STRING
    RETURN,-1
end
r=ASSOC(unit,BYTARR(512))
hdr=r[0] 

;sflag tests if either data or machine is little endian
lendian=is_lendian()
subf = hdr[4]
sflag = lendian xor (subf lt 128)
;dflag tests for compression:
dflag = subf mod 128 gt 0
;Data type (byte, word, etc.):
datyp=hdr[7]
;number of dimension of data array:
ndim=hdr[8]
;Number of 512-byte header blocks (may change if compressed!):
nhd=hdr[6]

if (hdr[0] eq 170) and (hdr[1] eq 170) and (hdr[2] eq 85) and (hdr[3] eq 85) then ftype = 0
test=STRTRIM(STRING(hdr[29:50]))

if STRING(hdr[0:5]) eq 'SIMPLE' then $
  case STRMID(test,0,1) of
    'T': begin
        PRINT,'Simple FITS file'
        ftype=1
    end
    'F': begin
        PRINT,'Rice compressed FITS file'
        ftype=2
    end
    else: begin 
        box_message,'Unkown file type'
        ftype=1
    endcase
  end

CLOSE,unit
FREE_LUN,unit

case ftype of
  0 : xfile=f0read(name,hdr,lendian,sflag,dflag,datyp,ndim,nhd)
  1 : xfile=rice(name,ftype,hdr)
  2 : xfile=rice(name,ftype,hdr)
  else: stop,'no such ftype'
endcase

if N_PARAMS() eq 1 then PRINT,STRING(hdr) else hdri = STRING(hdr)


RETURN,xfile
END

