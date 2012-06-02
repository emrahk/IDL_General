pro flush_arch
;********************************************************************
; Program flushes the variables from the archive histogram common
; blocks by setting them to zero. Common blocks set to zero are
; archev_block, archist_block, and save_block. For the meanings of 
; the individual variables please see archist.pro.
; First list the common blocks:
;********************************************************************
common archev_block,dc,opt,counts,lvtme,idfs,idfe,$
                 disp,a_counts,a_lvtme,det,rt,ltime,cp,dt,num_dets,$
                 rates0,rates1,num_chns,num_spec,det_str,fnme,$
                 idf_lvtme,clstr_pos
common archist_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait
common evt_parms,prms,prms_save,burst
common previous,del_low,del_high,t0,phase_shift
common oldulds,xulds_old,ulds_old,idfarr_old,arms_old,$
               trigs_old,vetos_old,alpha,beta
;********************************************************************
; Now set the variables equal to zero. This is equivalent to being
; undefined in IDL.
;********************************************************************
dc = 0 & opt = 0 & counts = 0 & lvtme = 0 & idfs = 0 & idfe = 0
disp = 0 & a_counts = 0 & a_lvtme = 0 & det = 0 & rt = 0
ltime = 0 & cp = 0 & dt = 0 & num_dets = 0 & rates0 = 0 & rates1 = 0
num_chns = 0 & num_spec = 0 & det_str = 0 & fnme = 0 & idf_hdr = 0
idf = 0 & date = 0 & spectra = 0 & livetime = 0 & typ = 0
spec_save = 0 & idf_save = 0 & wait = 0 & idf_lvtme = 0 & area = 0
clstr_pos = 0 & ltime = 0 & prs = 0 & prms = 0. & go = 0 
prms_save = 0. & burst = 0 & del_low = -1 & del_high = -1 
t0 = 0d & ulds_old = 0. & xulds_old = 0. & idfarr_old = 0. 
phase_shift = 0d & alpha=0. & beta = 0. & arms_old = 0
trigs_old = 0 & vetos_old = 0
;********************************************************************
; That's all ffolks 
;********************************************************************
return
end

