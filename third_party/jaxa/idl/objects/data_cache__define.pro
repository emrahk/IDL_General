;+
; Project     : HESSI
;
; Name        : CACHE__DATA
;
; Purpose     : create a cache object, whose contents persist
;               in memory even after object is destroyed. 
;               Yes, it uses common blocks, but their names are
;               dynamically created so there is never a conflict.
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('data_cache')
;
; Properties  : NAME = cache name
;
; History     : Written 8 Apr 2000, D. Zarro, SM&A/GSFC
;               Modified 5 Nov 2006, Zarro (ADNET/GSFC)
;                - removed EXECUTE
;
; Contact     : dzarro@solar.stanford.edu
;-

;---------------------------------------------------------------------------
;-- constructor

function data_cache::init,name

self->set,name=name

return,1

end

;--------------------------------------------------------------------------
;-- destructor

pro data_cache::cleanup

dprint,'% DATA_CACHE: cleaning up...'
return & end 


;--------------------------------------------------------------------------
;-- set properties

pro data_cache::set,name=name,verbose=verbose

if is_number(verbose) then self.verbose= 0b > byte(verbose) < 1b

;-- remove any problematic characters from name

if is_string(name) then begin
 id=trim(name)
; weird=['-','*','.',',','/','\','+','&','%','$','_']
; for i=0,n_elements(weird)-1 do id=str_replace(id,weird[i],'')
 self.name=id
endif

return & end

;---------------------------------------------------------------------------
;-- show properties

pro data_cache::show

print,''
print,'CACHE properties:'
print,'----------------'
print,'% cache name: ',self.name

return & end
               
;---------------------------------------------------------------------------
;-- validate name

function data_cache::valid_name,err

valid=1b & err=''
if ~is_string(self.name) then begin
 err='cache name must be non-blank'
 message,err,/info
 valid=0b
endif

return,valid & end
      
;--------------------------------------------------------------------------
;-- save in common

pro data_cache::save,data

if ~exist(data) then return
id=self.name
if self.verbose then message,'saving in "cache - '+id+'"',/info

common data_cache,fifo
if ~obj_valid(fifo) then fifo=obj_new('fifo')
fifo->set,id,data,verbose=self.verbose
                                 
return & end

;---------------------------------------------------------------------------

function data_cache::has_data

id=self.name
if self.verbose then message,'checking "cache - '+id+'"',/info

common data_cache,fifo
if ~obj_valid(fifo) then return,0b
fifo->get,id,data,status=status,verbose=self.verbose
return,status                               

end

;--------------------------------------------------------------------------
;-- restore from common

pro data_cache::restore,data
            
common data_cache,fifo
if ~obj_valid(fifo) then return

id=self.name                               

fifo->get,id,data,status=status,verbose=self.verbose

if status and self.verbose then message,'restoring from "cache - '+id+'"',/info
return & end

;------------------------------------------------------------------------------
;-- define cache object

pro data_cache__define                 

temp={data_cache,name:'',verbose:0b}

return & end


