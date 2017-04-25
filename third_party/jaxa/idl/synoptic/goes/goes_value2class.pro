function goes_value2class, gvalues
;
;+
;   Name: goes_value2class
;
;   Purpose: convert GOES low energy values -> GOES XRay Class
;
;   Input Parameters:
;      gvalues - GOES low energy channel values (or GXD structures)
;
;   History:
;      20-sep-2002 - S.L.Freeland - must be out there already, but...
;      20-oct-2003 - S.L.Freeland - fix long standing X+ problem
;                    (override ids/rsi default string formats since
;                     different for values > 1e-4 (X flares)
;
;-

case data_chk(gvalues,/type) of 
   8: begin
         gvals=gt_tagval(gvalues,/lo,missing=0.,found=found)
         if not found then begin 
            box_message,'Input structures must include TAG = LO (gxd)
            return,-1
         endif
   endcase
   0: begin 
         box_message,'Need to supply GOES Low Energy vector or GXD structure
         return,-1
   endcase
   else: begin 
      gvals=float(gvalues)
   endcase
endcase

invalid=where(gvals lt 1.e-8 or gvals gt 1.e-3,invcnt)
if invcnt gt 0 then begin 
   box_message,'One or more inputs out of expected GOES range, returning...'
   return,-1
endif

smant=ssw_strsplit(strupcase(string(gvals,format='(E7.1)')),'E-',tail=exp)
fexp=fix(exp)
fexp=fexp-([0,1])(smant eq '***')
gclass=str2arr('A,B,C,M,X')
ssroll=where(smant eq '***',rcnt)
if rcnt gt 0 then smant(ssroll)='1.0'
 
return,gclass(8-fexp)+smant
end
