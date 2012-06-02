
ddir = DIALOG_PICKFILE(/directory, TITLE='Choose the lightcurve directory path') 
files = FINDFILE(ddir + '*.lc')

GET_DATA, files, xx, yy, ee, head
;;if barycenter wrote barytimes over 'TIME' column
;GET_DATA, files, xx, yy, ee, head, label = 'TIME' 

units = 'day'
sec_per_day = 86400.0d

mjd_ref = 49353.0d + 6.965740740000000E-04

xxm = (xx / sec_per_day) + DOUBLE(mjd_ref)

;
; Adjust the following parameters
;

bpc = 16   ; number of phase bins (bins per cycle)
mjd_epoch = 50337.0d
offset = 0.0
period = 5.15581568d
pdot = 8.27d-11

nu = sec_per_day/period
nudot = (-1.0d/period^2) * pdot
phase_coeff = [offset, nu, nudot/2.0d]

FOLD_CURVE, xxm, yy, ee, phase_coeff, bpc, x1, y1, e1, $
        tot_time1, epoch_time = mjd_epoch, units = units, /plot


END
