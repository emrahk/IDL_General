pro difference_movie, index, data,  oindex, odata, $
		      interest=interest, second_diff=second_diff, $
		      debug=debug, recurse=recurse

;+
;   Name: difference_movie
;
;   Purpose: difference a data cube and provide some statistics
;
;   Input Parameters:
;      index - structure vector of input
;      data  - associated 3D cube
;
;   Output Parameters:
;      oindex - output structure vector (n_elements(index)-1)
;      odata  - the difference movie (nimages=nimages(data)-1)
;
;   History:
;      10-Nov-1998 - S.L.Freeland
;      23-Nov-1998 - call <update_history> to update OINDEX
;  
;-

debug=keyword_set(debug)
nx=data_chk(data,/nx)
ny=data_chk(data,/ny)
dtype=data_chk(data,/typ)

nimgs=data_chk(data,/nim)
if nimgs lt 2 then begin
   box_message,'Need at least 2 images to difference (duh!)'
   return
endif

odata=make_array(nx,ny,nimgs-1,type=dtype)     ; preformat the output

oindex=index(1:*)

for i=0,nimgs-2 do begin
  odata(0,0,i)=float(data(*,*,i+1))-float(data(*,*,i))
endfor

update_history,oindex,/caller,version='1.0
hline=anytim(index(1:*),/ecs) + ' - ' + anytim(index(0:nimgs-1),/ecs)
update_history,oindex,/caller,hline,/mode

if keyword_set(second_diff) then begin            ; recurse
   box_message,'Doing second differences...'
   tindex=index
   tdata=data
   difference_movie, oindex, odata, oind, odat
   delvarx,oindex,odata
   odata=temporary(odat)
   oindex=temporary(oind)
   index=temporary(tindex)
   data=temporary(tdata)  
endif

; calculate statisics
nvals=data_chk(odata,/nim)
dtotals=total(abs(odata))

if debug then stop

return
end
  
  
