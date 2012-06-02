pro pev_get,a_counts_,a_lvtme_,idfs_,idfe_,det_str_,dt_,$
            idf_lvtme_,clstr_pos_
;******************************************************************
; Program gets some accumulated quantities from the
; phapsa common block.
; Variables are:
;       a_counts...........Accumulated counts
;        a_lvtme...........      "     livetime
;      idfs,idfe...........Start,stop idf #s
;        det_str...........detector string (which phoswich)
;             dt...........date string
;      idf_lvtme...........array of livetimes
;      clstr_pos...........  "    " cluster positions
; Creation date 7/12/94
; First the common block:
;******************************************************************
common pev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,chn_slice,det,rt,cp,dt,ltime,$
                 rates0,rates1,det_str,psachns,phachns,plt,$
                 num_dets,colr,fnme,idf_lvtme,clstr_pos
;******************************************************************
; Get the variables
;*****************************************************************
a_counts_ = a_counts
a_lvtme_ = a_lvtme
idfs_ = idfs
idfe_ = idfe
dt_ = dt
det_str_ = det_str
idf_lvtme_ = idf_lvtme
clstr_pos_ = clstr_pos
;*****************************************************************
; Thats all ffolks
;*****************************************************************
return
end

