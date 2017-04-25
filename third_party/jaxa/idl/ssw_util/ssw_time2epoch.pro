function ssw_time2epoch, sswtimes, epoch_starts, epoch_stops, $
   append_index=append_index
;+
;   Name: ssw_times2epoch
;
;   Purpose: return epoch for all times/index;optionally append EPOCH tag->index
;
;   Input Parameters:
;      sswtimes - ssw standard times (index, catalogs, times.. per anytim.pro)
;      epoch_starts - start time of EPOCH(s) - vector ok   
;      epoch_stops  - optional end time of EPOCH(s) (def=Next epoch Start)
;
;   Output Parameters:
;      Function returns EPOCH# for all index (-1 if not in Any EPOCH)
;   
;   Keyword Parameters:
;      append_index - if switch, append index.EPOCH  = EPOCH
;                     if string, append index.<append_index> = EPOCH
;
;   History:
;      23-oct-2007 - S.L.Freeland 
;
;   Method:
;      vectorized version of index in {timerange0, timerange2, timerange3...}
;-

nout=n_elements(sswtimes) > 1
epoch=replicate(-1,nout)  ; default=not in any epoch
case 1 of
   n_params() lt 2: begin 
      box_message,'Need at least INDEX and one or more EPOCH_STARTs...'
      return,epoch
   endcase
   n_params() eq 2: begin 
      estop=[anytim(epoch_starts(1:*)),anytim(reltime(/now))]
   endcase
   else: begin 
      estart=anytim(epoch_starts)
      estop=anytim(epoch_stops)
   endcase
endcase 

if n_elements(estart) ne n_elements(estop) then begin 
   box_message,'#epoch_starts must = #epoch_stops'
   return,epoch
endif

itimes=anytim(sswtimes)  ; all values=anytim 

neps=n_elements(estart)

for e=0,neps-1 do begin 
   epoch=epoch +  (e+1)*(itimes ge estart(e) and itimes le estop(e)) 
endfor

retval=epoch

case 1 of
   data_chk(append_index,/string): index=add_tag(index,epoch,append_index(0))
   keyword_set(append_index): index=add_tag(index,epoch,'epoch')
   else:
endcase

return,retval

end

