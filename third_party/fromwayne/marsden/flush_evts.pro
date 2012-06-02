pro flush_evts
;********************************************************************
; Program flushes the variables from the event list common
; blocks by setting them to zero. Common blocks set to zero are
; evt_block, ev_block, and save_block. For the meanings of 
; the individual variables please see evt.pro.
; First list the common blocks:
;********************************************************************
common evt_block,idf_hdr,idf,date,spectra,livetime,typ
common ev_block,idfs,idfe,dt,tlive,sp1,sp2,idf_pos,count
common save_block,spec_save,idf_save,wait
;********************************************************************
; Now set the variables equal to zero. This is equivalent to being
; undefined in IDL.
;********************************************************************
idfe = 0 & disp = 0 & idfs = 0 & tlive = 0 & sp1 = 0 & sp2 = 0  
idf = 0 & dt = 0& spectra = 0 & livetime = 0 & typ = 0 & idf_pos = 0
spec_save = 0 & idf_save = 0 & wait = 0  & count = 0
;********************************************************************
; That's all ffolks 
;********************************************************************
return
end

