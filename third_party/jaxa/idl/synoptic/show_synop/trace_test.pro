
;-- Unit test for TRACE

pro trace_test,_ref_extra=extra

file='http://sdac2.nascom.nasa.gov/data/trace/week20080323/tri20080325.1800'

vso_prep_test,file,inst='trace',_extra=extra

return & end
