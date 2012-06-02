pro mu_xspec,nu,power,power_err,outputname,xspec=xx
;+
; NAME:
;      MU_XSPEC
; PURPOSE:
;      Outputs a PDS to an XSPEC file and optionally it starts XSPEC
; EXPLANATION:
;      This procedure takes a PDS in memory and produces an XSPEC
;      file (with associated response). If the xspec keyword is set,
;      it also launches xspec with the output file.
;
; CALLING SEQUENCE:
;       MU_XSPEC,NU,POWER,POWER_ERR,OUTPUTNAME[,/XSPEC]
; INPUTS:
;       NU       = Frequency array
;       POWER    = Power array
;       POWER_ERR    = Power error array
;       OUTPUTNAME   = Basename for the .pha and .rmf files
;
; OUTPUTS:
;       NONE
;
; KEYWORDS:
;       XSPEC    = If set, xspec will be automatically launched with the pha
;                  file. In this case, an XCM file with the same time will
;                  also be created [not working under Windows!]
;
; EXAMPLE:
;       NONE
;
; COMMON BLOCKS:
;       None
; ROUTINES USED:
;       MU_PHA: Produces a pha file
;       MU_RMF: Produces a (diagonal) rmf file
; NOTES:
;       NONE
; MODIFICATION HISTORY:
;       T. Belloni  20 Aug 2001  implementation
;       T. Belloni   9 Nov 2001  /xspec keyword added
;       T. Belloni  15 Nov 2003  Windows version, no xspec keyword available
;-
;--------------------------------------------------------------------------
;
;
   nfreq=n_elements(nu)
   delta_nu=nu*0.0
   a = (nu(1)-nu(0))/2.0    ;  a is half an original bin
   delta_nu(0) = a
   for i=1,nfreq-1 do begin
      delta_nu(i)=(nu(i)-nu(i-1))-a
      a = delta_nu(i)
   endfor
;
;  prepare output in power/bin
;
   power=power*delta_nu*2.0
   power_err=power_err*delta_nu*2.0
   f1 = nu-delta_nu
   f2 = nu+delta_nu
;
;  output
;
   output_pha=outputname+'.pha'
   output_rmf=outputname+'.rmf'

   mu_pha,power,power_err,output_pha,output_rmf
   mu_rmf,f1,f2,output_rmf

   if(keyword_Set(xx)) then begin
      opsys = !version.os_family
      if (opsys eq 'Windows') then begin
         massage,'XSPEC spawn option not available under windows!'
         return
        endif else begin


         output_xcm=outputname+'.xcm'
;        Create xcm file in temp area
         openw,unit,output_xcm,/get_lun
         printf,unit,'data '+outputname
         printf,unit,'setp ene'
         printf,unit,'pl lda'
         close,unit
         spawn,'xspec - '+output_xcm
      endelse
   endif
end
