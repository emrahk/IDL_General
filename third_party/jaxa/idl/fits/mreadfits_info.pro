function mreadfits_info, mrftext, counts, which
;
;+
;   Name: mreadfits_info
; 
;   Purpose: extract COMMENT and HISTORY info from mreadfits output variables
;
;   Input Parameters:
;      mrftext - text array (COMMENT or HISTORY) output from mreadfits
;      counts  - corresponding count vector output from mreadfits
;      which   - file number desired
;
;   Calling Sequence:
;      info=mreadfits_info(mfrtest, counts, which)
;
;   Calling Example:
;      mreadfits,files,index,comments=comm, history=hist, ccnts=ccnts, hcnts=hcnts
;      commentsx=mreadfits_info(comm,ccnts,10)   ; comments from file#10
;
;   History:
;      11-apr-1997 - S.L.Freeland 
;-

if n_params() ne 3 then begin
   message,/info," IDL> info=mreadfits_info(mfrtest, counts, which)"
   return,''
endif

fss=(which)(0)
cnts=counts

if n_elements(which) ne 1 then begin
   messasge,/info,"'WHICH' must be a scalar
   return,''
endif

stops =(totvect(cnts)-1) 
starts=(stops-cnts+1) 
 
fss= fss > 0 < (n_elements(cnts)-1) 


return, mrftext(starts(fss):stops(fss))

end
