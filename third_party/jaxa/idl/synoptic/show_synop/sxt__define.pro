;+
; Project     : HESSI
;
; Name        : SXT__DEFINE
;
; Purpose     : Define an SXT map object
;
; Category    : imaging maps
;
; Explanation : The map object is actually a structure with a pointer
;               field. The map structure is stored in this pointer.
;               The SXT object inherits MAP object properties and methods,
;               and includes a special SXT reader.
;          
; Syntax      : This procedure is invoked when a new SXT object is
;               created via:
;
;               IDL> new=obj_new('sxt')
; Examples    :
;
; Inputs      : 'SXT' = object classname (a subclass of MAP)
;
; Opt. Inputs : map = map structure created by MAKE_MAP
;
; Outputs     : A MAP object with methods: SET, GET, & PLOT
;
; History     : Written 19 May 1998, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

;----------------------------------------------------------------------------

;-- SXT reader 

pro sxt::read,file,dset,err=err,_extra=extra
 
err=''
chk=loc_file(file,err=err)
if err ne '' then return

if not exist(dset) then dset=-1
read_sxt,file,dset,index,data,_extra=extra
 
index2map,index,data,map

self->set,map,/no_copy

return & end

;----------------------------------------------------------------------------

;-- define special plotter

pro sxt::plot,index,_extra=extra                                
if not exist(index) then index=0
stc=self->get(status=status)
if status and valid_map(stc) then begin
 plot_map,stc(index),_extra=extra,/log
 self->loadct
endif

return & end

;----------------------------------------------------------------------------

pro sxt::loadct

loadct,3

return & end


;----------------------------------------------------------------------------

;-- define SXT object

pro sxt__define                 

sxt_struct={sxt, inherits fits}
return & end

