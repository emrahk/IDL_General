pro load_var,dc_,opt_,update_,int_,counts_,lvtme_,idfs_,idfe_,disp_,$
 a_counts_,a_lvtme_,det_,cp_,dt_,num_dets_,rates0_,rates1_,num_chns_,$
 num_spec_,det_str_,idf_hdr_,idf_,date_,spectra_,livetime_
;*****************************************************************************
; Program loads the variables into the variable header
; First the common block:
;*****************************************************************************
common var_block,dc,opt,update,int,counts,lvtme,idfs,idfe,disp,a_counts,$
 a_lvtme,det,cp,dt,num_dets,rates0,rates1,num_chns,num_spec,det_str,$
 idf_hdr,idf,date,spectra,livetime
;*****************************************************************************
; Now load the variables
;*****************************************************************************
dc = dc_
opt = opt_
update = update_
int = int_
counts = counts_
lvtme = lvtme_
idfs = idfs_
idfe = idfe_
disp = disp_
a_counts = a_counts_
a_lvtme = a_lvtme_
det = det_
cp = cp_
dt = dt_
num_dets = num_dets_
rates0 = rates0_
rates1 = rates1_
num_chns = num_chns_
num_spec = num_spec_
det_str = det_str_
idf_hdr = idf_hdr_
idf = idf_
date = date_
spectra = spectra_
livetime = livetime_
;************************************************************************
; Thats all ffolks
;************************************************************************
return
end
