pro init,start,idf,date,spectra,idfs,dt,num_spec,num_dets,num_chns,$
         a_counts,a_lvtme,counts,lvtme,idf_lvtme,area=area,prs=prs
;*********************************************************************
; Program initializes the counts and livetime arrays.
; Input variables are:
;       start..................first(=0) 
;         idf..................current idf # of data
;     spectra..................spectral array
;        date..................date string of current idf
; Output variables:
;       start..................first idf (1)
;        idfs..................starting idf #
;          dt..................array of start,stop dates,times
;    num_spec..................# of spectra/detector/idf
;    num_dets..................# of detectore/idf
;    num_chns..................# of pha channels/idf
;    a_counts..................accumulated counts
;     a_lvtme..................      "     livetime
;      counts.................. single idf counts
;       lvtme..................    "    "  livetime
;   idf_lvtme..................array of livetimes
;        area..................effective area vs idf
;         prs..................phase resolved spectroscopy flag
;********************************************************************
start = 0
idfs = idf
dt = strarr(2,2)
dt(0,*) = [strmid(date,0,9),strmid(date,10,18)]
dt(1,*) = dt(0,*)
num_spec = n_elements(spectra(0,*,0))
num_chns = n_elements(spectra(0,0,*))
num_dets = n_elements(spectra(*,0,0))
if (ks(prs) eq 1)then begin
   a_counts = lonarr(4,num_dets,num_spec,num_chns) 
   a_lvtme = fltarr(4,num_dets,num_spec)
endif else begin
   a_counts = lonarr(4,num_dets,num_chns)
   a_lvtme = fltarr(4,num_dets)
endelse
counts = lonarr(4,num_dets,num_spec,num_chns)
lvtme = fltarr(4,num_dets,num_spec)
counts = reform(counts,4,num_dets,num_spec,num_chns)
idf_lvtme = fltarr(4,num_dets,num_spec,1)
area = fltarr(num_dets)
;*********************************************************************
; Thats all ffolks
;*********************************************************************
return
end
