;+
; Project:
;   SDAC
; Name:
;   goes_tem_old
;
; Usage:
;   goes_tem_old, fl, fs, temperature, emission_meas [, thomas=thomas, goes8=goes8]
;
;
;Purpose:
;   This procedures computes the temperature and emission measure of the
;   solar soft X-ray plasma measured with the GOES ionization chambers.
;
;Category:
;   GOES, SPECTRA
;
;Method:
;   From the ratio of the two channels the temperature is computed either
;   from the parameterized fit in Thomas et al (Solar Physics v95, 1983)
;   or by interpolating from a lookup table computed by folding the
;   GOES transfer functions with the MEWE emission line and continuum
;   spectrum calculated by MEWE_SPEC.PRO.  The responses of the GOES ionization
;   chamber were obtained from Donnelly et al 1977.  The responses for GOES8+
;   were obtained by a private communication from Howard Garcia to Hugh Hudson
;   subsequently passed along to Richard Schwartz and implemented in July 1996.
;   Tables for GOES6 and GOES7 were communicated by Garcia to Schwartz on
;   10 Oct 1996.  The most recent version, Nov 22 1996, corrects the Thomas
;   parameterization by including the change in definition for the
;   transmission-averaged short wavelength flux which occurred from GOES4 onward.
;   These are reported in the GBAR_TABLE produced by GOES_TRANSFER.PRO
;   While there are real changes in the response between versions of GOES, this
;   was a simple change of divisor from (4-0.5) to (3-0.5) and not in any real
;   difference between detectors such as a change in thickness of the beryllium
;   window.  This change of definition results in the
;   higher values found in Table 1 of Garcia, Sol Phys, v154, p275.  This issue is
;   disussed on page 284 in paragraph 2 of section 3.1 of Garcia.
;
;   An alternative interpolation table was created by Howard Garcia and reported
;   by private communication and partially published in Solar Physics v154, p275.
;   The tables for GOES2, GOES6, GOES7, and GOES8 have been renormalized to 1e49 cm-3
;   and the ratio taken the ratio of the long current divided by the short current
;   as given by Garcia.
;
;
;
;Inputs:
;   FL - GOES long wavelength flux in Watts/meter^2
;   FS - GOES short wavelength flux
;   This procedure will also work where Fl and Fs may be passed in as
;   undefined or zero with the Temperature and Emission_meas set to scalars
;   or arrays then Fl and Fs are returned.  Not valid for /thomas or /garcia!
;Keywords:
;   Thomas- if set then use the Thomas et al parameterization.
;   GARCIA - if set, interpolate on Garcia generated tables from Raymond
;       TEST- If set, a figure is plotted showing the difference in the algorithms
;   The following keywords control the choice of satellite, if not
;   selected the default is GOES6.  The choice of satellite applies
;   to all three techniques.
;   GOES10 - if set, use response for GOES10
;   GOES8  - if set, use response for GOES8
;   GOES9  - if set, use response for GOES9
;   GOES6  - Use response for GOES6
;   GOES7  - Use response for GOES7
;   SATELLITE - Alternative to GOESN keyword, supply the GOES satellite
;   number, i.e. for GOES6==> SATELLITE=6, range from 0-9
;   DATE   - ANYTIM format, used for GOES6 where the constant used to
;   scale the reported long-wavelength channel flux was changed on 28-Jun-1993
;   from 4.43e-6 to 5.32e-6, all the algorithms assume 5.32 so FL prior
;   to that date must be rescaled as FL = FL*(4.43/5.32)
;Outputs:
;   Temperature   - Plasma temperature in units of 1e6 Kelvin
;   Emission_meas - Emission measure in units of 1e49 cm-3
;   Currents      - a 2x Number_of_samples array of the currents in the
;   long and short wavelength channels, respectively.
;Common Blocks:
;   GOES_RESP_COM - Used to store response function values between calls
;
;Needed Files:
;   Stored lookup table stored in goes_resp2.dat
;   goes_resp2.dat will usually be in the same directory as goes_tem_old.pro
;   so will be found by loc_file
;
; MODIFICATION HISTORY:
;   RAS, 93/2/10
;   ras, 18-dec-1995, added loc_file for goes_resp.dat
;   ras, 22-jul-1996, added GOES8 response
;   VERSION 5, ras, 3-jul-1996, added GOES9 response
;   VERSION 6, ras, 11-sep-1996, added Garcia response tables
;   Also, output of emission_meas is 1-d vector just as for temperature
;   Version 7, ras, 22-nov-1996, corrected Thomas parameterization for the
;   GBARs for each of GOES(N).  GOES1 is very different from 6-9!!, therefore
;   the formula is better applied to current ratios to obtain temperatures,
;   then scaled to obtain emission measure. Also, returns vectors in
;   all instances even when scalar fl and fs entered
;   Version 8, ras, 25-nov-1996, SATELLITE keyword added,
;   default satellite is GOES6
;   Version 9, ras, 29-jan-1997, enable temperature and emission_meas to
;   be outputs for non-garcia and non-thomas
;   Version 10, ras, 2-feb-1997, sort the input ratio prior to interpolating
;   to markedly increase speed of interpolation algorithm
;   Version 11, RAS, 4-feb-1997, write the goes resp into a comprehensive structure
;   to increase speed when switching between responses of GOES satellites!
;     Concommitant changes implemented in MAKE_GOES_RESP.PRO
;   Version 12, RAS, 5-feb-1997, using savegen and restgen for the saved response file
;     Concommitant changes implemented in MAKE_GOES_RESP.PRO
;   Version 13, RAS, 10-feb-1997, Table 1 values from Bornmann et al 1996 SPIE have
;     been included.  This table claims that SEL has modified the GOES reported
;     fluxes over and above the transfer functions
;     reported by Garcia in Solar Phys 1994.
;     Ultimately, the Bornman table should be merged into
;     the transfer functions for GOES 8 and 9 where while the change
;     in transfer function for GOES6 is already included.  The table
;     herein doesn't include the GOES6 correction since it is already
;     included.
;   Version 14, RAS, 8-apr-1997, moved GOES6 time check until after Fl defined from Fl_in
;   Version 15, RAS, 7-may-1997, check to see if input values, fl_in/fs_in or temperature,
;    are already sorted if so, then no further sorting is performed.
;   Version 16, RAS, 22-jul-1997 added current positional argument.
;   Version 17, RAS, 3-aug-1998 added goes10 keyword argument.
;   18-May-2004, RAS, force response to GOES10 for all satellites ge 10.
;	1-apr-2008, ras, changed old goes_tem to goes_tem_old

;
; Contact     : Richard.Schwartz@gsfc.nasa.gov
;
;-
pro goes_tem_old, fl_in, fs_in, temperature, emission_meas, currents, thomas=thomas, goes8=goes8, $
    goes9=goes9, goes6=goes6, goes7=goes7, goes10=goes10, satellite=satellite, date=date, $
    verbose=verbose, garcia=garcia, test=test, xtype=xtype, ytype=ytype


;Make sure the default satellite is GOES6, which has the longest database at the SDAC
;on 26 Nov 1996
key_test=[keyword_set(goes6),keyword_set(goes7),keyword_set(goes8),keyword_set(goes9)]
if  total( [key_test,n_elements(satellite)]) eq 0 then satellite=6

reverse_in= not keyword_set( total(abs( fcheck(fl_in,0.0)) + abs( fcheck(fs_in,0.0)))) and $
   keyword_set( total(abs( fcheck(temperature,0.0)) + abs( fcheck(emission_meas,0.0)))) $
   and not keyword_set(garcia) and not keyword_set(thomas)


;
;;common goes_resp_com2, te6, gresp_mewe, gresp_readme, whichgoes
;common goes_resp_com2, gresp, whichgoes
    checkvar, whichgoes, 0
;    if not keyword_set(satellite) then begin
;       satellite  = [intarr(6),key_test]
;       satellite = (where(satellite))(0) > 0
;    endif
    gsel = satellite

;
; Table 1 of Bornmann et al states that these additional factors were applied
; to GOES8 and GOES9.  Removing them here because they are not said to be
; in the transfer function reported by Garcia in 1994.  To recover the Fl
; and Fs consistent with the Garcia transfer functions, the Fl and Fs
; values must be DIVIDED by these numbers.
;
    if gsel lt 8 then scl89= fltarr(2)+1. else scl89 = [0.790, 0.920]
    fl=fcheck(fl_in,1e-7) / scl89(0)
    fs=fcheck(fs_in,2e-8) / scl89(1)

    ;On 28-Jun-93 the constant used to convert current to flux in
    ;the long wavelength channel of GOES6 was changed!
    ;
    if anytim( fcheck(date, 4.5722880e+08),/sec) lt 4.5722880e+08 $
    and satellite eq 6 then fl=fl*(4.43/5.32)

    if n_params() eq 5 then begin
    goes_transfer, gbar=gbar
    currents = [[transpose(fl)]*gbar(gsel-1).long,[transpose(fs)]*gbar(gsel-1).short]
    endif


;test showing comparison plot between different methods for given satellite
if keyword_set(test) then begin
    fl   = 1.0e-6 * scl89(0)
    fs   = 10.^(findgen(100)*.018)*.01*fl* scl89(1)
    goes_tem, fl, fs, t1, e1, satellite=satellite
    linecolors
    plot, fs/fl, t1, xtitle='FLUX RATIO (Short/Long)',ytitle='TEMP (MegaKelvin)',   $
       xtype=fcheck(xtype,1),ytype=fcheck(ytype,1)
    oplot, fs/fl, t1, color=9
    goes_tem, fl, fs, t1, e1, satellite=satellite,/thomas
    oplot, fs/fl, t1, color=2
    goes_tem, fl, fs, t1, e1, satellite=satellite,/garcia
    oplot, fs/fl, t1, color=5
    legend, textcolor=[9, 2, 5],['MEWE-MAKE_GOES_RESP','THOMAS et al.','GARCIA-RAYMOND']
    return
endif
case 1 of

 keyword_set(THOMAS): begin
    goes_transfer, gbar=gbar
    ;Convert from GOESN fluxes to GOES1 fluxes
    fl = fl* gbar(where(gsel eq gbar.sat)).long / gbar(0).long
    fs = fs* gbar(where(gsel eq gbar.sat)).short / gbar(0).short
    ratio = fs/(fl)

    q = where ((ratio lt .02) or (ratio gt .7), k)
    if k gt 0 then ratio(q) = 0.

    te = 3.15 + 77.2*ratio - 164.*ratio^2 + 205.*ratio^3
    q = where (te le 4.63, k)
    if k gt 0 then te(q) = 4.2

    q = where(te lt 4.2, k)
    temperature = te
    if k gt 0 then temperature(q) = 0.

    q = where (fl eq 1., k)
    if k gt 0 then fl(q) = 0.
    emission_meas = (( fl / (-3.86 + 1.17*temperature - $
         .0131*temperature^2 + .000178*temperature^3) ) $
         * 1e6) > 1.e-9 ;units of 1e49 cm-3
    emission_meas = emission_meas
    temperature = temperature + fltarr(n_elements(temperature))
end
keyword_set(GARCIA): begin

    isat = ([2,1,2,2,6,6,6,7,8,9,9])(gsel) ;[isat = gsel-6 > 0 < 2 ;from 0 to 2
        rescale = ([1.4,1.0])(gsel gt 3)
    ;Here we use rescale with the opposite sense, since the tables are
    ;defined for GOES6+
    ;ratio = fs*(rescale)/(fl)
    path = [curdir(),break_path(!path),chklog('SSWDB_GOES')]

    goes_resp = loc_file('goes_garcia_tables.sav',path=path)
       ;initialize data arrays prior to restore
    g=1
    readme=''
    restore,goes_resp, verbose=keyword_set(verbose)  ;jmm, 11-15-95
    goes_transfer, gbar_table=gbar
    wsat = gbar.sat
        ibar = (where(isat eq wsat,nsat))(0)>0
        wsat = g.sat
        isat = ([2,2,2,2,6,6,6,7,8,8])(isat)
        iresp = (where(isat eq wsat,nsat))(0)>0

    cratioi= g(iresp).ratio
    wv=where(cratioi gt 0, nv)
    cratioi= cratioi(wv)
        ;This ratio is in currents, so multiply the flux by the average transfer function
    ;The reported fluxes are currents divided by the average transfer function for each channel
    ratio = fl*gbar(ibar).long / (fs*gbar(ibar).short) > min(cratioi) < max(cratioi)

    ;interpolate on the calculated values to get the measured Temp.
    ;
    ; We don't want to sort if the ratio is already sorted for large arrays.
    ;
    needsort=1
        if n_elements(ratio) gt 1000 then begin
       diffg = ratio(1:*) - ratio
       wnz  = where( diffg ne 0.0, nnz)
       if nnz gt 1 then sorted = where( diffg(wnz)/diffg(wnz(0)) lt 0, needsort) $
         else needsort=0
    endif
    if needsort ge 1 then begin
       wsort = sort( ratio)
       wback = sort( wsort)
       endif else begin
       wsort = lindgen(n_elements(ratio))
       wback = wsort
       endelse
    temperature = interpol( g(iresp).t6(wv), cratioi, ratio(wsort))
        ;help,iresp,ibar
    ;SCALE THE OBSERVED LONG WAVELENGTH FLUX BY THE VALUE AT THE
    ;MEASURED TEMPERATURE TO GET THE EM IN UNITS OF 1E49 CM-3

    emission_meas = fl(wsort)*gbar(ibar).long / interpol( g(iresp).lcurrent(wv) , cratioi, ratio(wsort))
    temperature  = temperature(wback)
    emission_meas = emission_meas(wback)

end
else: begin

;Which version of GOES?
    if gsel ne whichgoes or n_elements(te6) eq 0 then begin
;Set the logical to find the file with the temperatures and channel fluxes
       if n_elements(gresp) eq 0 then begin
       ;
       ; Read in the stored data files for each GOESN
         path = [curdir(),break_path(!path),chklog('SSWDB_GOES')]

         goes_resp = loc_file('goes_resp.genx',path=path)
       ;initialize data arrays prior to restore

         gresp   = 0.0
         restgen,gresp, file=goes_resp ;using savegen and restgen, ras, 5-feb-1997
       endif
       te6 = gresp.te6
       case (gsel<10) of
       4: gresp_mewe = gresp.goes(1).resp
       5: gresp_mewe = gresp.goes(1).resp
       6: gresp_mewe = gresp.goes(1).resp
       7: gresp_mewe = gresp.goes(2).resp
       8: gresp_mewe = gresp.goes(3).resp
       9: gresp_mewe = gresp.goes(4).resp
       10: gresp_mewe= gresp.goes(5).resp
       else: gresp_mewe = gresp.goes(0).resp
       endcase
       whichgoes = gsel
;-- Since we will be using the INTERPOL function, check for monotonicity
;
       rat =  gresp_mewe(1,*)/gresp_mewe(0,*)
       w = where(rat(1:*) lt rat, nw)
       if nw ge 1 then begin
         w=(indgen(n_elements(te6)))(w(nw-1)+1:*)
         te6 = te6(w)
         gresp_mewe = gresp_mewe(*,w)
       endif

       endif
    if not reverse_in then begin
    ;input ratio is set to maximum excursion of the calculated ratio

    cratio= (gresp_mewe(1,*)/gresp_mewe(0,*))(*)

    ratio = ((fs/fl) > min(cratio)) < max(cratio)
    ;Sort the input by their ratio to increase interpolation algorithm speeds!!!!!
    ;
    ; We don't want to sort if the ratio is already sorted for large arrays.
    ;
    needsort=1
        if n_elements(ratio) gt 1000 then begin
       diffg = ratio(1:*) - ratio
       wnz  = where( diffg ne 0.0, nnz)
       if nnz gt 1 then sorted = where( diffg(wnz)/diffg(wnz(0)) lt 0, needsort) $
         else needsort=0
    endif
    if needsort ge 1 then begin
       wsort = sort( ratio)
       wback = sort( wsort)
       endif else begin
       wsort = lindgen(n_elements(ratio))
       wback = wsort
       endelse
    ;interpolate on the calculated values to get the measured Temp.
       temperature = interpol( te6, cratio, ratio(wsort) )
    ;SCALE THE OBSERVED LONG WAVELENGTH FLUX BY THE VALUE AT THE
    ;MEASURED TEMPERATURE TO GET THE EM IN UNITS OF 1E49 CM-3

       emission_meas = fl(wsort) / interpol((gresp_mewe(0,*))(*), cratio, ratio(wsort))
       temperature  = temperature(wback)
       emission_meas = emission_meas(wback)
    endif else begin
       t_in = temperature(*)
       em_in= emission_meas(*)
       sizet=(size(t_in))(0)
       sizee=(size(em_in))(0)
       case 1 of
         sizet eq 0 and sizee gt 0: t_in = t_in+fltarr(n_elements(em_in))
         sizet gt 0 and sizee eq 0: em_in= em_in+fltarr(n_elements(t_in))
         else:
       endcase
       ix = alog10(t_in)*100.
       fs_in   = interpolate( (gresp_mewe(1,*))(*), ix)*em_in * scl89(1)
       fl_in   = interpolate( (gresp_mewe(0,*))(*), ix)*em_in * scl89(0)
       if anytim( fcheck(date, 4.5722880e+08),/sec) lt 4.5722880e+08 $
       and satellite eq 6 then fl_in=fl_in / (4.43/5.32)
    endelse

end
endcase

end




