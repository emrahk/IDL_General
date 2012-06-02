pro fit_stor,num_lines_,mdl_,mdln_,a_,sigmaa_,chisqr_,iter_,$
            astring_,nfree_,rt_,idfs_,idfe_,dt_,cp_,ltime_,$
            opt_,det_,typ_,strtbin_,stpbin_,fttd_,det_str_
;************************************************************************
; Program stores the fit variables in the fit common block
; Functions:
;            ks................short for idl command keyword_set
; 9/21/94 Print statement axed
;************************************************************************
common fitblock,num_lines,mdl,mdln,a,sigmaa,chisqr,iter,astring,$
               nfree,rt,idfs,idfe,dt,cp,ltime,opt,det,typ,strtbin,$
               stpbin,fttd,asave,mdlnsave,det_str
if (ks(a_) and not(ks(a)))then a = a_
if (not(ks(a_)) and not(ks(a)))then a = [0.,0.,0.]
if (ks(sigmaa_) and not(ks(sigmaa)))then sigmaa = sigmaa_
if (not(ks(sigmaa_)) and not(ks(sigma)))then sigmaa = [0.,0.,0.]
if (ks(iter_) and not(ks(iter)))then iter = iter_
if (not(ks(iter_)) and not(ks(iter)))then iter = 1
if (ks(astring_) and not(ks(astring)))then astring = astring_
if (not(ks(astring_)) and not(ks(astring)))then $
    astring = ['LINE 1 : NORMALIZATION','CENTROID','SIGMAA']
if (ks(mdl_))then mdl = mdl_
if (not(ks(mdl)) and not(ks(mdl_)))then mdl = 'N GAUSSIAN LINES'
if (ks(mdln_))then mdln = mdln_
if (not(ks(mdln)) and not(ks(mdln_)))then mdln = '1 GAUSSIAN LINES'
if (ks(typ_) and not(ks(typ)))then typ = typ_
if (not(ks(typ)) and not(ks(typ_)))then typ = 'HIST'
if (ks(nfree_) and not(ks(nfree)))then nfree = nfree_
if (not(ks(nfree)) and not(ks(nfree_)))then nfree = 253
if (not(ks(num_lines)) and ks(num_lines_))then num_lines = num_lines_
if (not(ks(num_lines)) and not(ks(num_lines_)))then num_lines = 1 
if (ks(num_lines))then num_lines_ = num_lines
if (ks(ltime_))then ltime = ltime_
if (ks(rt_))then rt = rt_
if (ks(idfs_))then idfs = idfs_
if (ks(idfe_))then idfe = idfe_
if (ks(dt_))then dt = dt_
if (ks(cp_))then cp = cp_
if (ks(opt_))then opt = opt_
if (ks(det_))then det = det_
if (ks(typ_))then typ = typ_
fttd = fttd_
if (ks(strtbin_) and not(ks(strtbin)))then begin
   strtbin = strtbin_
endif
if (not(ks(strtbin)) and not(ks(strtbin_)))then begin
   strtbin = 0 
endif
if (ks(stpbin_) and not(ks(stpbin)))then begin
   stpbin = stpbin_
endif
if (not(ks(stpbin)) and not(ks(stpbin_)))then begin
   if (ks(rt) ne 0)then stpbin = n_elements(rt) - 1 else $
   stpbin = 255
endif
if (not(ks(asave)))then asave = [0.,0.,0.]
if (not(ks(mdlnsave)))then mdlnsave = ''
if (ks(det_str_))then det_str = det_str_
if (not(ks(det_str_)))then det_str = ''
;***********************************************************************
; Thats all ffolks
;***********************************************************************
return
end


