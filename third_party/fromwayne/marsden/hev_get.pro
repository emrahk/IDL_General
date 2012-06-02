pro hev_get,a_counts_,a_lvtme_,idfs_,idfe_,dt_,idf_lvtme_,$
            clstr_pos_
;******************************************************************
; Program gets some accumulated quantities from the
; histogram bin common block.
; Variables are:
;       a_counts...........Accumulated counts
;        a_lvtme...........      "     livetime
;      idfs,idfe...........Start,stop idf #s
;             dt...........date string
;      idf_lvtme...........array of livetime/idf
;      clstr_pos...........cluster position vs idf
;       response...........HEXTE collimator response
;            x,y...........collimator caalib. (deg.)
;         ra,dec...........Eq. coordinates of src.
; Creation date 7/12/94
; 11/10/95 Added accumulated livetime/IDF array
; 12/6/95 Added area & cluster position accumulation
; First the common blocks:
;******************************************************************
common hev_block,dc,opt,int,counts,lvtme,idfs,idfe,disp,a_counts,$
                    a_lvtme,det,rt,cp,dt,num_dets,rates0,$
                    rates1,num_chns,num_spec,det_str,fnme,$
                    idf_lvtme,clstr_pos,ltime
common response,response,x,y,ra,dec
;******************************************************************
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

