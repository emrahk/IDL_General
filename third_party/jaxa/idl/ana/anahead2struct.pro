function anahead2struct, anaheader, strtemp=strtemp
;
;+
;   Name: anahead2struct
;
;   Purpose: convert an ana header (per lapalma) -> SSW structure
;  
;-
  
common anahead2struct_blk, stemplate

case 1 of
   data_chk(strtemp,/struct): retval=strtemp
   data_chk(stemplate,/struct): retval= stemplate
   else: retval=sswfits_struct(/addfits)         ; SSW standard
endcase

retval.date_obs=anytim(strmid(anaheader,0,24),/ccsds)
retval.wavelnth=strmid(anaheader,56,12)
retval.exptime=float(strmid(anaheader,50,4))/1000.
retval=struct2ssw(retval,/nopointing)                        ; fill in alternate times

return,retval
end
