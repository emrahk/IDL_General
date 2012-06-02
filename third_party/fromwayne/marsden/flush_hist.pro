pro flush_hist
;********************************************************************
; Program flushes the variables from the histogram bin common
; blocks by setting them to zero. Common blocks set to zero are
; hev_block, hist_block, and save_block. For the meanings of 
; the individual variables please see hist.pro.
; First list the common blocks:
;********************************************************************
common hev_block,dc,opt,int,counts,lvtme,idfs,idfe,disp,a_counts,$
                 a_lvtme,det,rt,cp,dt,num_dets,rates0,rates1,$
                 num_chns,num_spec,det_str,fnme,idf_lvtme,$
                 clstr_pos,ltime,prs
common hist_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait,num
common bary,ra,dec
common evt_parms,prms,prms_save,burst
common previous,t0,phase_shift
common oldulds,xulds_old,ulds_old,idfarr_old,arms_old,$
               trigs_old,vetos_old,alpha,beta
;********************************************************************
; Now set the variables equal to zero. This is equivalent to being
; undefined in IDL.
;********************************************************************
dc = 0 & opt = 0 & int = 0 & counts = 0 & lvtme = 0 & idfs = 0
idfe = 0 & disp = 0 & a_counts = 0 & a_lvtme = 0 & det = 0 & rt = 0
ltime = 0 & cp = 0 & dt = 0 & num_dets = 0 & rates0 = 0 & rates1 = 0
num_chns = 0 & num_spec = 0 & det_str = 0 & fnme = 0 & idf_hdr = 0
idf = 0 & date = 0 & spectra = 0 & livetime = 0 & typ = 0
spec_save = 0 & idf_save = 0 & wait = 0 & idf_lvtme = 0 
clstr_pos = 0 & ra = 0 & dec = 0 & ltime = 0 & vetos_old = 0
prs = 0 & prms = 0. & go = 0 & prms_save = 0. & burst = 0 
t0 = 0d & ulds_old = 0. & xulds_old = 0. & idfarr_old = 0.
phase_shift = 0d & alpha=0. & beta = 0. & arms_old = 0 
trigs_old = 0 & num  = 0.
;********************************************************************
; That's all ffolks 
;********************************************************************
return
end

