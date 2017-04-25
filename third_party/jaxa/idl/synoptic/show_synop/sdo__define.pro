;+
; Project     : SDO
;
; Name        : SDO__DEFINE
;
; Purpose     : Class definition for SDO
;
; Category    : Objects
;
; History     : 30 August 2012, Zarro (ADNET) - written
;               23 August 2013, Zarro (ADNET)
;               - defined HOME (if not defined)
;               8 October 2014, Zarro (ADNET)
;               - moved RICE-decompression to FITS parent class 
;               30 September 2015, Zarro (ADNET)
;               - added AIA_ and HMI_PREP branches
;               2 November 2015, Zarro (ADNET)
;               - fixed bug where prepped file was crashing read_sdo
;
; Contact     : dzarro@solar.stanford.edu
;-
;---------------------------------------------------

function sdo::init,_ref_extra=extra

if ~self->fits::init(_extra=extra) then return,0
if is_blank(chklog('HOME')) then mklog,'HOME',get_temp_dir()

return,1

end

;--------------------------------------------------
pro sdo::cleanup

if obj_valid(self.aia) then obj_destroy,self.aia
if obj_valid(self.hmi) then obj_destroy,self.hmi

return & end

;---------------------------------------------------

function sdo::search,tstart,tend,_ref_extra=extra

return,vso_files(tstart,tend,_extra=extra,window=30)

end

;----------------------------------------------------------------
pro sdo::read,file,index,data,_ref_extra=extra,err=err

err=''

self->getfile,file,local_file=rfile,err=err,_extra=extra,count=count
if (count eq 0) || is_string(err) then return

self->empty
have_sdo_path=self->sdo::have_path(_extra=extra)
k=0
for i=0,count-1 do begin
 if ~self->is_valid(rfile[i],prepped=prepped) then begin
  mprint,'Not a valid SDO file.'
  continue
 endif
 if ~have_sdo_path || prepped then mreadfits,rfile[i],index,data,_extra=extra else $
  read_sdo,rfile[i],index,data,/noshell,/use_shared,_extra=extra
 self->sdo_prep,k,index,data,filename=rfile[i],status=status,_extra=extra
 if status then k=k+1
endfor

return & end

;-----------------------------------------------------------------------

function sdo::is_prepped,index
 
prepped=0b
if ~is_struct(index) then return,0b
if ~have_tag(index,'history') then return,0b
chk=where(stregex(index.history,'(aia_prep|hmi_prep)',/bool),count)
prepped=count gt 0

return,prepped
end

;------------------------------------------------------------------------

function sdo::is_valid,file,prepped=prepped

prepped=0b
if is_blank(file) then return,0b
mrd_head,file,header,err=err
if is_string(err) then return,0b
s=fitshead2struct(header)
prepped=self->is_prepped(s)
if have_tag(s,'origin') then if stregex(s.origin,'SDO',/bool,/fold) then return,1b
if have_tag(s,'telescop') then if stregex(s.telescop,'SDO',/bool,/fold) then return,1b
return,0b
end

;--------------------------------------------------------------------------
 
pro sdo::sdo_prep,k,index,data,_ref_extra=extra,status=status,filename=filename

status=0b
if ~is_struct(index) then return
if ~is_number(k) then k=0

case 1 of
 stregex(index.instrume,'AIA',/bool,/fold): self->aia_prep,k,index,data,status=status,_extra=extra
 stregex(index.instrume,'HMI',/bool,/fold): self->hmi_prep,k,index,data,status=status,_extra=extra
 else: begin
  mprint,'Unsupported SDO image type.'
  return
 end
endcase

if is_string(filename) then begin
 index=self->get(k,/index)
 index=rep_tag_value(index,file_basename(filename),'filename')
 self->set,k,index=index
endif

return & end

;----------------------------------------------------------------------------

pro sdo::aia_prep,k,index,data,_ref_extra=extra,status=status

status=1b
if ~obj_valid(self.aia) then self.aia=obj_new('aia')
self.aia->prep,index,data,map,_extra=extra,/no_copy
self->set,k,map=map,/no_copy
self->set,k,/log_scale,grid=30,/limb,index=index
if self.aia->have_colors(index,red,green,blue) then self->set,k,red=red,green=green,blue=blue,/has_colors

return & end

;--------------------------------------------------------------------------

pro sdo::hmi_prep,k,index,data,_ref_extra=extra,status=status

status=1b
if ~obj_valid(self.hmi) then self.hmi=obj_new('hmi')
self.hmi->prep,index,data,map,_extra=extra,/no_copy
self->set,k,map=map,/no_copy
self->set,k,index=index,grid=30,/limb

return & end

;-----------------------------------------------------------------------------
;-- check for SDO branch in !path

function sdo::have_path,err=err,verbose=verbose

err=''
if ~have_proc('read_sdo') then begin
 ssw_path,/ontology,/quiet
 if ~have_proc('read_sdo') then begin
  err='VOBS/Ontology branch of SSW not installed.'
  if keyword_set(verbose) then message,err,/info
  return,0b
 endif
endif

return,1b
end

;------------------------------------------------------
pro sdo__define,void                 

void={sdo, inherits fits,aia:obj_new(),hmi:obj_new(), inherits prep}

return & end
