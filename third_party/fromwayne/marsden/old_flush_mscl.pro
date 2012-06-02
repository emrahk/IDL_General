pro flush_mscl
;********************************************************************
; Program flushes the variables from the multiscalar bin 
; common blocks by setting them to zero. Common blocks set to zero 
; are mev_block, msclr_block, and save_block. For the meanings of 
; the individual variables please see msclr.pro.
; First list the common blocks:
;********************************************************************
common msclr_block,idf_hdr,idf,date,spectra,livetime,typ
common mev_block,dc,opt,accum,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,det,cp,dt,num_dets,pha_edgs,$
                 num_tm_bins,pha_choice,ltime,ft,periods,fold,fnme,$
                 phz_bns,idf_lvtme,cluster_pos,phz_arr
common save_block,spec_save,idf_save,wait
common nai,arr,nai_only
common bary,ra,dec
common evt_parms,prms,prms_save,burst
common events,idf0,times,phasave
common oldulds,xulds_old,ulds_old,idfarr_old
;********************************************************************
; Delete the variables 
;********************************************************************
dc = 0 & opt = 0 & counts = 0 & lvtme = 0 & idfs = 0 & idfe = 0
disp = 0 & a_counts = 0 & a_lvtme = 0 & det = 0 & accum = 0
cp = 0 & dt = 0 & num_dets = 0 & ph_edgs = 0 & ft = 0 & ltime = 0
num_tm_bins = 0 & pha_choice = 0 & fnme = 0 & idf_hdr = 0
idf = 0 & date = 0 & spectra = 0 & livetime = 0 & typ = 0
spec_save = 0 & idf_save = 0 & wait = 0 & fold = 0 & periods = 0
phz_bins = 10 & idf_lvtme = 0 & cluster_pos = 0 & arr = 0
nai_only = 0 & phz_arr = 0 & ra = 0. & dec = 0. 
prms = 0. & go = 0 & prms_save = 0. & burst = 0 & ulds_old = 0. 
old_xulds = 0. & idfarr_old = 0.
;********************************************************************
; That's all ffolks 
;********************************************************************
return
end

