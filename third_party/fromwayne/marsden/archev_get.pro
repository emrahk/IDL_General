pro archev_get,a_counts_,a_lvtme_,idfs_,idfe_,dt_,idf_lvtme_,$
               clstr_pos_
;*****************************************************************
; Program gets some accumulated quantities from the
; archive histogram common block.
; Variables are:
;       a_counts...........Accumulated counts
;        a_lvtme...........      "     livetime
;      idfs,idfe...........Start,stop idf #s
;             dt...........date string
; Creation date 7/12/94
; 11/10/95 Gets livetime array
; First the common block:
;*****************************************************************
common archev_block,dc,opt,counts,lvtme,idfs,idfe,disp,a_counts,$
                    a_lvtme,det,rt,ltime,cp,dt,num_dets,rates0,$
                    rates1,num_chns,num_spec,det_str,fnme,$
                    idf_lvtme,clstr_pos
common response,response,x,y,ra,dec
;*****************************************************************
; Get the variables
;*****************************************************************
a_counts_ = a_counts
a_lvtme_ = a_lvtme
idfs_ = idfs
idfe_ = idfe
dt_ = dt
idf_lvtme_ = idf_lvtme
clstr_pos_ = clstr_pos
;*****************************************************************
; Calculate the effective area toward the source direction for 
; each idf.
;*****************************************************************
;if (ks(ra) ne 0 and ks(dec) ne 0)then begin  
;   calc_area,idfs,idfe,ar
;   area_ = ar
;   area = ar
;endif else begin
;   ar = replicate(200.,num_dets,n_elements(idf_lvtme(0,0,0,*)))
;   area_ = ar
;   area = ar
;endelse
;*****************************************************************
; Thats all ffolks
;*****************************************************************
return
end

