pro flush_phap
;********************************************************************
; Program flushes the variables from the phapsa common
; blocks by setting them to zero. Common blocks set to zero are
; pev_block, phapsa_block, and save_block. For the meanings of 
; the individual variables please see phapsa.pro.
; First list the common blocks:
;********************************************************************
common pev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,chn_slice,det,rt,cp,dt,ltime,$
                 rates0,rates1,det_str,psachns,phachns,plt,num_dets,$
                 colr,fnme,idf_lvtme,clstr_pos
common phapsa_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait
common nai,arr,nai_only
common oldulds,xulds_old,ulds_old,idfarr_old,alpha,beta
;********************************************************************
; Now set the variables equal to zero. This is equivalent to being
; undefined in IDL.
;********************************************************************
dc = 0 & opt = 0 & counts = 0 & lvtme = 0 & idfs = 0 & chn_slice = 0
idfe = 0 & disp = 0 & a_counts = 0 & a_lvtme = 0 & det = 0 & rt = 0
ltime = 0 & cp = 0 & dt = 0 & num_dets = 0 & rates0 = 0 & rates1 = 0
det = 0 & det_str = 0 & psa_chns = 0 & pha_chns = 0 & fnme = 0
idf = 0 & date = 0 & spectra = 0 & livetime = 0 & typ = 0
spec_save = 0 & idf_save = 0 & wait = 0 & plt = 0 & colr = 0
arr = 0 & nai_only = 0 & xulds_old = 0. & ulds_old = 0.
idfarr_old = 0. & alpha = 0. & beta = 0. & clstr_pos = 0
idf_lvtme = 0.
;********************************************************************
; That's all ffolks 
;********************************************************************
return
end

