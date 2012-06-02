;;
;; Rebin spectrum by a given factor
;; For rebinning to a given energy resolution see rebinspec
;;
PRO specrebin,spe,factor
   fac=findgen(factor)
   tmp=spe
   spec2nph,tmp
   tmp.len=spe.len/factor
   j=0
   FOR i=0,spe.len-1,factor DO BEGIN 
       tmp.e(j)=tmp.e(i)
       tmp.f(j)=total(tmp.f(i+fac))
       tmp.err(j)=total(tmp.err(i+fac))
       j=j+1
   ENDFOR 
   tmp.e(tmp.len)=tmp.e(spe.len)
   tmp.f(tmp.len:n_elements(tmp.f)-1)=0.
   tmp.err(tmp.len:n_elements(tmp.err)-1)=0.
   tmp.e(tmp.len+1:n_elements(tmp.e)-1)=0.
   spec2type,tmp,spe.flux
   spe=tmp
END 

