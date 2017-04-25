function ssw_getdst, time0, time1, ace=ace  , $
   quiet=quiet, debug=debug
;+
;   Name: ssw_getdst 
;   
;   Purpose: return DST index for user time range
;
;   Input Parameters:
;      time0 - start time
;      time1 - stop time
;
;   Output:
;      function returns utplot ready time series structure of format:
;          {mjd:0L, time:0L, DST:0.d}
;
;   Keyword Parameters:
;      ace - (switch) - if set, read/use ACE data via get_acedata.pro
;
;   Calling Example:
;      dst = ssw_getdst(reltime(days=-30), reltime(/now)) ; last 30 days 
;
;   History:
;      25-Feb-2004 - S.L.Freeland coded using reference:
;         http://sprg.ssl.berkeley.edu:80/dst_index/estimate.html 
;      26-Feb-2004 - NRT Kyoto hooks
;      27-Feb-2004 - use ssw_kyoto2dst function
;                    Permit older Povisional 
;       8-Mar-2005 - S.L.Freeland - extend to Final Dst@kyoto
;;      4-aug-2005 - S.L.Freeland - extend Provisional
;                    (need to auto-update that eventually...)
;
;   Restrictions:
;      Kyoto access via sockets so requires IDL V >=5.4
;-
common ssw_getssw_kyotoq, clastm, clastm2, clastm3  ; cache
debug=keyword_set(debug)
loud=1-keyword_set(quiet)

if n_params() lt 2 then begin 
   box_message,'IDL> dst=ssw_getdst(starttime, stoptime )
   return,-1
endif

ace=keyword_set(ace)
if not ace then begin 
   box_message,'Using Kyoto WWW dbase'
   if not since_version('5.4') then begin 
     box_message,'Sorry, http access requires IDL version >= 5.4'
     return,-1   ;   unstructured error return....
  endif
endif

ss=-1
case 1 of 
   ace: begin 
   endcase
;  ========================== Kyoto NRT =====================
   ssw_deltat(time0,reltime(/now),/day) lt 90: begin 
      kyototop='http://swdcdb.kugi.kyoto-u.ac.jp/dstdir/dst1/q/' ; nrt queue
      months=str2arr('lastm3,lastm2,lastm,thism')
      delvarx,retval
      for i=0,n_elements(months)-1 do begin 
         chkq=execute('done=n_elements(c'+months(i)+') gt 0')
         murl=kyototop+ 'Dstq' + months(i) + '.html'
         if not done then begin
            box_message,'getting> ' + murl
            mretval=ssw_kyoto2dst(murl)
            estat=execute('c'+months(i)+'=mretval')  ; data -> cache
         endif else begin 
            if loud then box_message,['Using cached data for url..',murl] 
            estat=execute('mretval=c'+months(i))
         endelse
         if n_elements(retval) eq 0 then retval=temporary(mretval) else $
            retval=concat_struct(retval,temporary(mretval))
         endfor
   endcase 
;  ==============================================================
;  =================== Kyoto Provisional =======================
;  =================== Extend to Final 8-mar-2005, SLF ====
   ssw_deltat(time0,ref='1-apr-2006',/min) lt 0 : begin  ; prov->nrt transition 
      kyotoparent='http://swdcdb.kugi.kyoto-u.ac.jp/dstdir/dst1/'
      provt0='1-jan-2003'   ; Final->provisional transition
      case 1 of
         ssw_deltat(time1,ref=provt0,/days) lt 0: begin ; all final
            prefix='dstfinal'
            kyototop=kyotoparent+'/f/'
         endcase 
         ssw_deltat(time0,ref=provt0,/days) ge 0: begin ; all provincial 
            prefix='dstprov'
            kyototop=kyotoparent+'/p/'
         endcase
         else: begin ; span final/provisional transition - recurse...
            final=ssw_getdst(time0,reltime(provt0,hours=-.001)) ; final piece
            prov= ssw_getdst(provt0,time1)                  ; prov piece
            case 1 of 
               data_chk(final,/struct) and data_chk(prov,/struct): $
                  retval=concat_struct(final,prov)
               data_chk(final,/struct): retval=temporary(final)
               data_chk(prov,/struct):  retval=temporary(prov)
               else: retval=-1
            endcase
            return, retval
         endcase
      endcase      
      mt0=anytim(time0,/vms,/date_only)
      mt0='1'+strmid(mt0,2,9)   
      mt1=anytim(time1,/vms,/date_only)
      mt1='1'+strmid(mt1,2,9)
      mgrid=timegrid(mt0,mt1,/month,/quiet)
      months=strmid(time2file(mgrid,/date_only),0,6)
      knames=prefix+months+'.html'
      for i=0,n_elements(months)-1 do begin 
         box_message,'Getting Kyoto Final/Provisional Data>> ' + knames(i)
         dstm=ssw_kyoto2dst(kyototop+knames(i))   ; kyoto www->structure
         if data_chk(dstm,/struct) then begin 
            if n_elements(retval) eq 0 then retval=temporary(dstm) else $
              retval=concat_struct(retval,temporary(dstm))
         endif else box_message,'Hit extremes of Kyoto Provisional data queue' 
      endfor
   endcase
   else: begin 
      box_message,'Sorry, not yet implemented, ; use /ACE keyword'
      return,-1
   endcase
endcase
if data_chk(retval,/struct) then begin 
   ss=sel_timrange(anytim(retval,/int),time0,time1)
   if ss(0) eq - 1 then begin 
      box_message,'No DST available within your time range
      retval=-1
   endif else begin 
      retval=retval(ss)
    endelse
   return,retval
endif else begin
   box_message,'No Dst available, returning...'
   return,-1
endelse 

swepam=get_acedata(time0,time1,/SWEPAM)
   mag=get_acedata(time0,time1,/MAG)

if not data_chk(swepam) then begin 
   box_message,'No ACE data for input times, returning...
   return,-1
endif

; constants   per Burton et al. [1975]
a=3.6e-5     ; ring current decay 1/s
b=.20         ; Dst reponse to dynamic pressure nT/sqrt(eV/cm^3)
c=20          ; quiet time current nT
d=1.2e-3     ; response of injection rate to Ey

bspeed=gt_tagval(swepam,/B_SPEED)     ; Bulk speed km/s
pdensity=gt_tagval(swepam,/P_DENSITY) ; p Density p/cc
bz=gt_tagval(mag,/BZ)                 ; Bz component nT

Ey=-(bspeed*bz)                       ; y GSM comp. of interplanetary e-field
Pdyn=(pdensity*bspeed^2.)             ; dynamic pressure 
 
 
Ring_inj=(d*(Ey-0.5)) * (Ey > .5)     ; ie, 0.0 for Ey < .5 mV/m
; ucb mods per Murayam [1982]
d=-1.2e-3   ;
Ring_inj=((d*Pdyn)^1/3)*(Ey-0.5)

dst_ast=-b * sqrt(pdyn) + c

dst=Ring_inj - (a*dst_ast)


stop
return,dst
end

