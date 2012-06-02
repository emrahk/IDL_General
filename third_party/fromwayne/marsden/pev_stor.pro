pro pev_stor,dc_,opt_,counts_,lvtme_,idfs_,idfe_,disp_,$
                a_counts_,a_lvtme_,chn_slice_,det_,rt_,cp_,dt_,ltime_,$
                rates0_,rates1_,det_str_,psachns_,phachns_,plt_,num_dets_,$
                colr_,fnme_
;***************************************************************************
; Program loads the Pha Psa data variables into the 
; common block necessary for program execution. First the common
; block.
; 5/11/94 Eliminate 'Update' variable
;***************************************************************************
common pev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,chn_slice,det,rt,cp,dt,ltime,$
                 rates0,rates1,det_str,psachns,phachns,plt,num_dets,$
                 colr,fnme
;***************************************************************************
; Now assign the variables
;***************************************************************************
dc = dc_
opt = opt_
counts = counts_
lvtme = lvtme_
idfs = idfs_
idfe = idfe_
disp = disp_
a_counts = a_counts_
a_lvtme = a_lvtme_
det = det_
rt = rt_
ltime = ltime_
cp = cp_
dt = dt_
num_dets = num_dets_
rates0 = rates0_
rates1 = rates1_
psachns = psachns_
phachns = phachns_
plt = plt_
colr = colr_
det_str = det_str_
fnme = fnme_
;***************************************************************************
; Thats all ffolks
;***************************************************************************
return
end
