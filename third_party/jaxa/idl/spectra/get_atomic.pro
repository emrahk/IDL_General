function get_atomic,Chan_struct,atocal=atocal,new=new,		$
	w_wave=w_wave,x_wave=x_wave,y_wave=y_wave,		$
	z_wave=z_wave,q_wave=q_wave,j_wave=j_wave,k_wave=k_wave
;+
;  NAME:
;    get_atomic
;  PURPOSE:
;    Return a data structure with atomic data parameters 
;    for requested BCS channel.
;  CALLING SEQUENCE:
;    ato_data = get_atomic(Chan)
;
;    w_wave   = get_atomic(Chan,/w_wave)		; Return wavelength of w-line
;    w_wave   = get_atomic(Chan,/z_wave)		; Return wavelength of z-line
;
;  INPUTS:
;    Chan	= BCS Channel Number or structure (Must be a scalar)
;  OPTIONAL INPUT KEYWORDS:
;    w_wave	= If set, only return the wavelength of the w line
;		  Also, x_wave, y_wave, z_wave, q_wave, j_wave, k_wave
;    atocal	= Def=Max value present.  Specifies alternative atomic calculation.
;		  If atomic data file has already been read, and atocal is
;		  NOT specified, then previously read data will be returned.
;
;		  atocal=5 and chan=4 will cause susec5.dat to be read.
;		  atocal=4 and chan=4 will cause susec4.dat to be read, etc.
;
;    new	= If /new is set, forces a read of the file even if it has been
;		  previously read.
;  OUTPUTS:
;    The functional result is structure containing the atomic data parameters
;  METHOD:
;    Reads ascii data files contained in $DIR_GEN_SPECTRA
;    The files have the following names: susec3.dat, casec3.dat, fesec3.dat, f26sec3.dat
;
;  MODIFICATION HISTORY:
;     7-oct-93, J. R. Lemen (LPARL), Written
;     8-feb-94, JRL,  Changed the way the file name is specified via the atocal parameter
;    11-mar-94, JRL,  Added x_wave,y_wave,z_wave,q_wave switches
;    15-Mar-94, DMZ,  changed to avoid file search each time
;    15-mar-94, JRL,  Additional changes to avoid file search
;    23-mar-94, JRL,  Fix bug introduced by concat_dir for VMS
;     2-jan-96, JRL,  Added the /new keyword.  Used for debugging purposes.
;-
on_error,2				; Return to caller

; Set up common for BCS ions

common atodat_comm,ato16,ato20,ato25,ato26

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Make Sure Te6 is defined
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if n_elements(chan_struct) eq 0 then message,' *** Chan is not defined'
chan = gt_bsc_chan(chan_struct)
if (chan lt 1) or (chan gt 4)   then message,' *** Chan must between 1 and 4'


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Determine if we have to read the data
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Zname = (['??','ato26','ato25','ato20','ato16'])(Chan)
if keyword_set(new) then q_read = 1 else begin	; /new -- force a read
  i = execute('ncheck = n_elements('+Zname+')')
  if ncheck eq 0 then q_read=1 else begin
     i = execute('ncal = '+Zname+'.Cal')
     if n_elements(atocal) eq 0 then cal = ncal else cal = atocal
     if ncal eq cal then q_read=0 else q_read=1   
  endelse
endelse

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Call rd_atodat to read the data
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if q_read then begin

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The base file names are set up for S, Ca, and Fe.  
; Set up default cal/filename
; (The scheme could be easily modified)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;          Chan      1       2       3       4
 FN_base = ['???','f26sec','fesec','casec','susec']
 FN_sear = concat_dir('$DIR_GEN_SPECTRA',FN_base)
 FN_sear = str_replace(Fn_sear,'.','')		; Remove trailing '.'

 FN = findfile(FN_sear(chan)+'*.*',count=count)
 if count eq 0 then message,'No atomic files found of the type: '+FN_base(chan)

 break_file, FN, disk, dir, filnam, ext
 cal_db = intarr(count)		; Possible values for archive file name
 for i=0,count-1 do cal_db(i) = (str2arr(strlowcase(filnam(i)), FN_base(chan)))(1)

 if n_elements(atocal) eq 0 then cal = max(cal_db) else cal = atocal

 ii = where(cal eq cal_db, ncount)
 if ncount eq 0 then message,'Requested atomic data file is not available'  $
   else filnam = (FN(ii))(0)

 ato_data = rd_atodat( filnam )
 ato_data.Cal = cal				; Copy the Calculation Number
 i = execute(Zname+'=ato_data')		; Copy ato_dat to common name
endif else i = execute('ato_data='+Zname)	; Copy common name to ato_data

zz =      keyword_set(w_wave)+keyword_set(x_wave)+keyword_set(y_wave)
zz = zz + keyword_set(z_wave)+keyword_set(q_wave)+keyword_set(k_wave)
zz = zz + keyword_set(j_wave)

if zz eq 0 then return,ato_data else begin
   if zz gt 1 then begin
	message,'Must ask for only one wavelength',/cont
        return,-1
   endif else begin
        wave_ret = 0
	iq = (where(strlowcase(strmid(ato_data.dr.line,0,1)) eq 'q', nq))(0)
	ik = (where(strlowcase(strmid(ato_data.dr.line,0,1)) eq 'k', nk))(0)
	ij = (where(strlowcase(strmid(ato_data.dr.line,0,1)) eq 'j', nj))(0)
        if keyword_set(w_wave) then wave_ret = ato_data.wave0(0) else	$	; Return w-line wavelength
	if keyword_set(x_wave) then wave_ret = ato_data.wave0(1) else	$	; x
	if keyword_set(y_wave) and (n_elements(ato_data.wave0) ge 3) then $
				wave_ret = ato_data.wave0(2) else	$	; y
	if keyword_set(z_wave) and (n_elements(ato_data.wave0) ge 4) then $
				wave_ret = ato_data.wave0(3) else	$	; z
	if keyword_set(q_wave) and (nq gt 0) then wave_ret = ato_data.dr(iq).wave else $ ;q
	if keyword_set(j_wave) and (nj gt 0) then wave_ret = ato_data.dr(ij).wave else $ ;j
	if keyword_set(k_wave) and (nk gt 0) then wave_ret = ato_data.dr(ik).wave	 ;k
        if wave_ret eq 0 then message,'Warning:  Requested line wavelength not available',/cont
	return,wave_ret
   endelse
endelse
end
