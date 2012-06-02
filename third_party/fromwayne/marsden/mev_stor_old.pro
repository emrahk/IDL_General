pro mev_stor,dc_,opt_,accum_,counts_,lvtme_,idfs_,idfe_,disp_,$
                a_counts_,a_lvtme_,det_,cp_,dt_,num_dets_,$
                pha_edgs_,num_tm_bins_,pha_choice_,ltime_,ft_,$
                periods_,fold_,fnme_
;***************************************************************************
; Program loads the Multiscalar data variables into the 
; common block necessary for program execution. First the common
; block:
; 5/11/94 Eliminate 'Update' variable
;***************************************************************************
common mev_block,dc,opt,accum,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,det,cp,dt,num_dets,pha_edgs,$
                 num_tm_bins,pha_choice,ltime,ft,periods,fold,fnme
;***************************************************************************
; Now assign the variables
;***************************************************************************
dc = dc_
opt = opt_
counts = counts_
lvtme = lvtme_
idfs = idfs_
idfe = idfe_
accum = accum_
disp = disp_
a_counts = a_counts_
a_lvtme = a_lvtme_
det = det_
ltime = ltime_
cp = cp_
dt = dt_
num_dets = num_dets_
fnme = fnme_
num_tm_bins = num_tm_bins_
pha_edgs = pha_edgs_
pha_choice = pha_choice_
ft = ft_
periods = periods_
fold = fold_
;***************************************************************************
; Thats all ffolks
;***************************************************************************
return
end
