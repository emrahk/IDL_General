;+
; Project     : HESSI
;
; Name        : MESOLA__DEFINE
;
; Purpose     : Define a MESOLA data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('mesola')
;
; History     : Written 20 Dec 1999, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function mesola::init,_ref_extra=extra

ret=self->site::init(_extra=extra)
                     
if ~ret then return,ret

ret=self->fits::init(_extra=extra)
           
self->setprop,rhost='ftp://ftpbass2000.obspm.fr',org='month',_extra=extra

return,1

end

;-----------------------------------------------------------------------------

pro mesola::cleanup

self->fits::cleanup
self->site::cleanup

return & end

;-----------------------------------------------------------------------------
;-- parse file names into time

function mesola::parse_time,file,_ref_extra=extra

pref='([^\.\\/]+)'
dd='([0-9]{2})'
regex=pref+dd+dd+dd+'\.'+dd+dd+dd+dd+'?'+'\.(.+)'
return,parse_time(file,regex=regex,_extra=extra)

end

;------------------------------------------------------------------------------
;-- Mesola site structure

pro mesola__define                 

self={mesola,inherits site, inherits fits}

return & end
