pro mev_get,a_counts_,a_lvtme_,idfs_,idfe_,pha_edgs_,dt_,$
            idf_lvtme_,cluster_pos_,phz_arr_,period,tedgs
;******************************************************************
; Program gets some accumulated quantities from the
; multiscalar common block.
; Variables are:
;       a_counts...........Accumulated counts
;        a_lvtme...........      "     livetime
;      idfs,idfe...........Start,stop idf #s
;       pha_edgs...........pha edges
;             dt...........date string
;      idf_lvtme...........livetime string
; Creation date 7/12/94
; First the common block:
;******************************************************************
common mev_block,dc,opt,accum,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,det,cp,dt,num_dets,pha_edgs,$
                 num_tm_bins,pha_choice,ltime,ft,periods,fold,$
                 fnme,phz_bns,idf_lvtme,cluster_pos,phz_arr,$
                 a_tedgs
;******************************************************************
; Get the variables
;*****************************************************************
a_counts_ = a_counts
a_lvtme_ = a_lvtme
idfs_ = idfs
idfe_ = idfe
dt_ = dt
pha_edgs_ = pha_edgs
idf_lvtme_ = idf_lvtme
cluster_pos_ = cluster_pos
period = periods(0)
tedgs = a_tedgs
;*****************************************************************
; Now the painful folding loops. I don't know anyway else to 
; do this.
;*****************************************************************
if (total(phz_arr) ne 0 and periods(0) ne 0.)then begin
   sz = size(a_counts)
   num_pos = sz(1)
   num_dets = sz(2)
   num_pha = sz(3)
   num_tm = sz(4)
   time = ltime*dindgen(num_tm)
   phz_arr_ = lonarr(num_pos,num_dets,num_pha,phz_bns)
   for i = 0,num_pos-1 do begin
    for j = 0,num_dets-1 do begin
     for k = 0,num_pha-1 do begin
      fold_time_arr,time,reform(a_counts(i,j,k,*)),period,flc,$
                    np=phz_bns
      phz_arr_(i,j,k,*) = flc
     endfor
    endfor
   endfor
endif
;*****************************************************************
; Thats all ffolks
;*****************************************************************
return
end

