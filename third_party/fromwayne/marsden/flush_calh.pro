pro flush_calh
;********************************************************************
; Program flushes the variables from the callibration histogram 
; common blocks by setting them to zero. Common blocks set to zero 
; are chev_block, calhist_block, and save_block. For the meanings of 
; the individual variables please see calhist.pro.
; First list the common blocks:
;********************************************************************
common chev_block,dc,opt,counts,lvtme,idfs,idfe,$
                 disp,a_counts,a_lvtme,det,rt,ltime,cp,dt,num_dets,$
                 rates0,rates1,num_chns,num_spec,det_str,fnme,$
                 idf_lvtme,clstr_pos
common calhist_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait,num
common response,response,x,y,ra,dec
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
clstr_pos = 0 & response = 0 & ra = 0 & dec = 0 & x = 0 & y = 0
;********************************************************************
; That's all ffolks 
;********************************************************************
return
end

