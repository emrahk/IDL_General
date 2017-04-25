;-- Unit test for EIS

pro eis_test,_ref_extra=extra

file='http://umbra.nascom.nasa.gov/hinode/eis/level0/2008/05/01/eis_l0_20080501_154014.fits.gz'

vso_prep_test,file,_extra=extra,inst='EIS',img=0

return & end
