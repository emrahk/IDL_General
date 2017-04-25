pro ssw_expand_times,intimes, otimes, odata, $
   out_style=out_style, _extra=_extra, debug=debug, ddt=ddt
;
;+
;   Name: ssw_expand_times
;
;   Purpose: expand time vector to match sample cadence
;
;   Input Parameters:
;      intimes - structure vector with SSW compliant times
;
;   Output Parameters:
;      otimes - time vector (expanded)
;      odata  - data samples (1D)
;
;    Keyword Parameters:
;      out_style - desired output time style (see anytim.pro) DEF=INTS
;      _extra - Data Tag to extract (determines samples per structure)
;      ddt - delta-T per sample  
;      offset_ddt - optional delta-T (seonds) between intimes and 
;                   first sample   
;      
;   Calling Sequence:
;                        IN       OUT     OUT
;      ssw_expand_times, intimes, otimes, odata [,out_style=out_style], $
;                        ddt=ddt, offset_ddt=offset_ddt, $
;                          _extra=_extra
;   Calling Example:
;      [ output from 'get_solar_indicies' includes 8 KP samples/structure ]
;      IDL> ind=get_solar_indicies('1-nov-2001','1-dec-2001')
;      IDL> ssw_expand_times,ind,kptime,kpdata,/kp,ddt=(3.*3600),out='utc_int
;      IDL> help, ind, kptime, kpdata
;       IND             STRUCT    = -> MS_060814109002 Array[31]
;       KPTIME          STRUCT    = -> CDS_INT_TIME Array[248]
;       KPDATA          INT       = Array[248]
;      IDL> utplot,kptime,kpdata.... etc
;-
debug=keyword_set(debug)

if data_chk(_extra,/struct) then tag=(tag_names(_extra))(0) else tag='xxx'

val0=gt_tagval(intimes(0),tag,missing=-1,found=found)

if not found then begin 
   box_message,'Tag ' + tag(0) + ' not found'
   return
endif

nsamp=n_elements(val0)           ; number of values per structure
ntimes=n_elements(intimes)       ; 

utime=anytim(intimes)            ; structure times

timearr=dblarr(nsamp,ntimes)

case 1 of    
   n_elements(ddt) eq 1: ddtr=replicate(ddt(0),ntimes)
   n_elements(ddt) eq ntimes: ddtr=ddt
   else: begin 
      box_message,'please supply sample time via DDT=NN(secs)'
      return
   endcase
endcase

for i=0,nsamp-1 do timearr(i,*)=utime+(i*ddtr)

n1d=nsamp*ntimes

if n_elements(out_style) eq 0 then out_style='utc_int'

otimes=anytim(reform(timearr,n1d) ,out_style=out_style)

odata=gt_tagval(intimes,tag,missing=0)
if n_elements(odata) ne n1d then box_message,'Mismatch in times:data' else $
   odata=reform(odata,n1d)
if debug then stop
return
end

