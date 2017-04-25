;+
; Project     : HESSI
;                                                                                                 
; Name        : MAP__DEFINE                                                                       
;                                                                                                 
; Purpose     : Define a MAP object                                                               
;                                                                                                 
; Category    : imaging objects                                                                   
;                                                                                                 
; Syntax      : IDL> new=obj_new('map')                                                           
;                                                                                                 
; History     : Written 22 Nov 1999, D. Zarro, SM&A/GSFC                                          
;             : Modified 18 Sept 2001, D. Zarro (EITI/GSFC) - improved                            
;               memory management                                                                 
;               Modified 5 Oct 2002, Zarro (LAC/GSFC) - added object                              
;               to store plot properties                                                          
;               Modified 2 Oct 2003, Zarro (GSI/GSFC) - added correction                          
;               for 180 degree rolled images                                                      
;               Modified 7 Feb 2004, Zarro (L-3Com/GSFC) - fixed bug with                         
;               plotting grid/limb                                                                
;               Modified 17 Mar 2004, Zarro (L-3Com/GSFC) - added FOV keyword                     
;               Modified 9 May 2006, Zarro (L-3Com/GSFC) 
;                - added COLOR support                    
;               Modified 23 November 2007, Zarro (ADNET) 
;                - preserve current value of DECOMP
;               Modified 20 August 2008, Zarro (ADNET)
;                - added TRANS_MAP call 
;               Modified 13 May 2008, Zarro (ADNET)
;                - switched to using mwrfits to support multiple image maps
;                Modified 12 Jun 2009, Kim Tolbert
;                - added plotman method
;                Modified 27-Aug-2009, Kim TOlbert
;                - init status to 0 in plot, in case returns with
;                  error (but not in catch)
;                Modified 13-Oct-2009, Zarro (ADNET)
;                - added capability to send multiple images to plotman
;                29-Oct-2009, Zarro (ADNET)
;                - made plot property into a structure instead of object to
;                  avoid memory leaks when updating.
;                1-November-2009, Zarro (ADNET)
;                - replaced LINKED_LIST object with FIFO object which
;                  has better memory management.
;                20-Jan-2010, Zarro (ADNET)
;                - added /no_restore
;                8-April-2010, Zarro (ADNET)
;                - added HISTORY methods
;                11-Jun-2010, Kim
;                - if plotman called with /colors, get colors and set
;                  them into plotman obj
;                17-Dec-2010, Zarro (ADNET)
;                 - added support for new IDL 8 '.' property syntax
;                30-August-2011, Zarro (ADNET)
;                 - added support for returning arbitrary map
;                   properties, including rtime.
;                19-Feb-2012, Zarro (ADNET)
;                 - changed message,/cont to message,/info because
;                   /cont was setting !error_state
;                24-Feb-2012, Zarro (ADNET)
;                 - added /ADD to ::SET to add map to last map
;                 position
;                6-June-2012, Zarro (ADNET)
;                - moved translation and rotation logic into plot_map
;                27-September-2012, Zarro (ADNET)
;                - changed COLORS keyword to USE_COLORS to avoid
;                  conflict with plot keywords and moved color
;                  keywords from PLOTMAN call since MAP object
;                  contains them.
;                30-October-2012, Zarro (ADNET)
;                - added _extra to ::save_ct to support passing
;                  external colors
;                16-August-2013, Zarro (ADNET)
;                - set HAS_COLORS property when saving colors
;                23-August-2013, Zarro (ADNET)
;                - restored passing DATA explicitly in ::SETMAP
;                26-May-2014, Zarro (ADNET)
;                - ensured map angles written to FITS file
;                16-Oct-2014, Zarro (ADNET)
;                - added searching INDEX for additional properties.
;                20-Apr-2015, Zarro (ADNET)
;                - added /GET_COLORS to GETMAP method to return color table
;                  in map.
;                28-Jul-2015, Zarro (ADNET)
;                - added NO_TIMESTAMP
;                14-Aug-2015, Zarro (ADNET)
;                - moved all color handling in ::PLOT and ::PLOTMAN to
;                  PLOT_MAP 
;                31-Aug-2015, Zarro (ADNET)
;                - added FLAG to ::GET (1 if property found, 0
;                  otherwise)
;                26-Dec-2015, Zarro (ADNET)
;                - added call to DEF_FILE in ::WRITE
;                7-Feb-2016, Zarro (ADNET)
;                - fixed bug in CLONE method where input angle to roll
;                  map was being confused with map roll_angle
;                  property. Fixed typo with NO_TIMESTAMP.
;                22-Feb-2016, Zarro (ADNET)
;                 - fixed bug in ::GETMAP where index was not initializing.
;                                                                                                 
; Contact     : dzarro@solar.stanford.edu                                                         
;-                                                                                                
                                                                                                  
;-------------------------------------------------------------------------                        
                                                                                                  
function map::init,_extra=extra                                                                   
                                                                                                  
dprint,'% MAP::INIT'                                                                              
self.plot_type='image'                                                                            
self.omap=obj_new('fifo')        ;-- store map structures                                  
self.oindex=obj_new('fifo')      ;-- store data index structures                           
self.oprop=obj_new('fifo')       ;-- store plot property structures

return,1                                                                                          
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------                          
;--destroy map object                                                                             
                                                                                                  
pro map::cleanup                                                                                  
                                                                                                  
dprint,'% MAP::CLEANUP'                                                                           
self->free_var                                                                                    
return                                                                                            
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------                          
;--empty map object                                                                               
                                                                                                  
pro map::empty                                                                                    
                                                                                                  
if ~obj_valid(self.omap) then return                                                           
self.omap->empty                                                                           
self.oindex->empty                                                                          
self.oprop->empty
                                                                                                  
return & end                                                                                      
                                                                                                  
;-----------------------------------------------------------------------                          
;-- copy map object (function)                                                                    
                                                                                                  
function map::clone,k,_ref_extra=extra                                                            
                                                                                                  
self->clone,cobj,k,_extra=extra                                                                   
                                                                                                  
return,cobj                                                                                       
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------                          
;-- copy map object (procedure)                                                                   
                                                                                                  
pro map::clone,cobj,k,err=err,_ref_extra=extra,all=all                                                
                                                                                                  
err=''                                                                                            
                                                                                                  
if keyword_set(all) then begin                                                                    
 obj_copy,self,cobj                                                                               
 return                                                                                           
endif                                                                                             
                                                                                                  
if ~self->has_data(k,_extra=extra,err=err) then begin                                                       
 mprint,err,/info                                                                                
 cobj=-1                                                                                          
 return                                                                                           
endif                                                                                             
                                                                                                  
map=self->get(k,/map)                                                                
index=self->get(k,/index)                                                            
props=self->get(k,/props)
                                                                                            
class=obj_class(self)                                                                             
if obj_valid(cobj) then obj_destroy,cobj                                                          
cobj=obj_new(class)          
dprint,'% MAP::CLONE...'

cobj->set,map=map,index=index,props=props,/no_copy                                            

return                                                                                            
                                                                                                  
end                                                                                               
                                                                                                  
;-------------------------------------------------------------------                              
;-- set map object properties                                                                     
                                                                                                  
pro map::set,k,map=map,index=index,_ref_extra=extra,$                                         
          props=props,add=add

if keyword_set(add) then begin
 count=self->get(/count)
 k=count
endif else begin
 if ~is_number(k) then k=0
endelse
   
;-- update map object properties 

if valid_map(map) then self.omap->set,k,map,_extra=extra
if is_struct(props) then self.oprop->set,k,props,_extra=extra
if is_struct(index) then self.oindex->set,k,index,_extra=extra

if ~is_string(extra) then return

self->set_plot_prop,k,_extra=extra
self->set_map_prop,k,_extra=extra
                                                         
return                                                                                            
end                                                                                               

;--------------------------------------------------------------------------
;-- explicitly set map properties

pro map::set_map_prop,k,data=data,_extra=extra

;-- if inserting data then create and replace whole map

sz=size(data)
if sz[0] eq 2 then smap=make_map(data,_extra=extra) else begin
 if is_struct(extra) then begin
  smap=self->get(k,/map,/no_copy,err=err)
  if valid_map(smap) then begin
   extra=fix_extra(extra,tag_names(smap))
   struct_assign,extra,smap,/nozero
  endif
 endif
endelse

if valid_map(smap) then self.omap->set,k,smap,_extra=extra,/no_copy


return & end
                                                                                                  
;-------------------------------------------------------------------------                        
;-- update index with map information                                                             
                                                                                                  
pro map::update_index,k,err=err                                                                   
                                                                                                  
err=''                                                                                            
if ~self->has_data(k,err=err) then begin                 
 mprint,err                                                                               
 return                                                                                           
endif                                                                                             
                                                                                                  
index=self->get(k,/index)                                                              

if ~is_struct(index) then mprint,'Generating index...'

if err ne '' then return                                                                          
                                                                                                  
;-- make sure CRPIX/CRVAL and XCEN/YCEN are self-consistent                                       
                                                                                                  
nx=self->get(k,/nx)                                                                               
ny=self->get(k,/ny)                                                                               
dx=self->get(k,/dx)                                                                               
dy=self->get(k,/dy)                                                                               
xc=self->get(k,/xc)                                                                               
yc=self->get(k,/yc)                                                                               
roll=self->get(k,/roll_angle)                                                                     
rollc=self->get(k,/roll_center)                                                                   
         
index=rep_tag_value(index,2,'naxis')                                                             
index=rep_tag_value(index,nx,'naxis1')                                                             
index=rep_tag_value(index,ny,'naxis2')                                                             
                                                                        
index=rep_tag_value(index,0,'crval1')                                                             
index=rep_tag_value(index,0,'crval2')                                                             
                                                                                                  
index=rep_tag_value(index,dx,'cdelt1')                                                            
index=rep_tag_value(index,dy,'cdelt2')                                                            
                                                                                                  
crpix1=comp_fits_crpix(xc,dx,nx,0.)                                                               
crpix2=comp_fits_crpix(yc,dy,ny,0.)                                                               
                                                                                                  
index=rep_tag_value(index,crpix1,'crpix1')                                                        
index=rep_tag_value(index,crpix2,'crpix2')                                                        
                                                                                                  
index=rep_tag_value(index,xc,'xcen')                                                              
index=rep_tag_value(index,yc,'ycen')                                                              
                                                                                                  
index=rep_tag_value(index,roll,'crota')

index=rep_tag_value(index,rollc[0],'crotacn1')                                                    
index=rep_tag_value(index,rollc[1],'crotacn2')                                                    

;-- update DATE_OBS in case of differential rotation

rtime=self->get(k,/rtime)
if string(rtime) then index=rep_tag_value(index,rtime,'date_obs')

self->set,k,index=index
                                                                                                  
return & end                                                                                      
                    
;--------------------------------------------------------------------------                       
                                                                                                  
pro map::write,file,k,err=err,compress=compress,$
             verbose=verbose,_extra=extra,local_file=local_file                         
                                                                                                  
;-- validate output file name and directory                                                       
                                                                                                  
err=''                                                                                            
local_file=''
if is_blank(file) then begin                                                                      
 err='Invalid file name entered.'                                                                  
 mprint,err,/info                                                                                
 return                                                                                           
endif                                                                                             

count=self->get(/count)
if count eq 0 then return
ofile=def_file(file,_extra=extra,err=err)
if is_string(err) then return
oname=file_basename(ofile)
         
wrote_file=0b
if is_number(k) then count=1 else k=0
for i=0,count-1 do begin
 if count eq 1 then j=k else j=i
 if ~self->has_index(j) || ~self->has_data(j) then continue
 map=self->get(j,/map)                                                                     
 if ~valid_map(map) then continue
 index=self->get(j,/index)                                                                         
 index=rep_tag_value(index,oname,'filename')
 if have_tag(index,'bscale') then bscale=index.bscale else bscale=0.
 if bscale eq 0. then index=rep_tag_value(index,1.,'bscale')
 index=rep_tag_value(index,1,'naxis3')
 index=rep_tag_value(index,map.roll_angle,'crota1')
 rcenter=map.roll_center
 index=rep_tag_value(index,rcenter[0],'crotacn1')
 index=rep_tag_value(index,rcenter[1],'crotacn2')
 if have_tag(map,'l0') then begin
  index=rep_tag_value(index,map.l0,'L0')
  index=rep_tag_value(index,map.b0,'B0')
  index=rep_tag_value(index,map.rsun,'RSUN')
 endif
 if have_tag(map,'rtime') then begin
  index=rep_tag_value(index,map.rtime,'DATE_OBS') 
  index=rep_tag_value(index,'','TIME_OBS') 
 endif
 header=struct2fitshead(index,/allow_crota)
 mwrfits,map.data,ofile[0],header,create=(i eq 0),/silent
; mprint,'Writing file - '+ofile[0],/info
 wrote_file=1b
endfor
      
if wrote_file then begin
 if keyword_set(verbose) then mprint,'Wrote FITS file - '+ofile,/info                  
 chmod,ofile,/g_write,/g_read,/verbose                                                                      
 if keyword_set(compress) then espawn,'gzip -f '+ofile,/noshell,_extra=extra
 local_file=ofile
endif else mprint,'FITS file not written.',/info
                                                                                                  
return & end
                                                                                      
;----------------------------------------------------------------------------                     
;-- get data method                                                                               
                                                                                                  
function map::getdata,k                                                                           
return, self-> get(k,/data)                                                                       
end                                                                                               

;----------------------------------------------------------------------------                     
;-- get map method                                                                               
                                                                                                  
function map::getmap,k,_ref_extra=extra,xshift=xshift,yshift=yshift,$
                       xrange=xrange,yrange=yrange,roll=roll,$
                       get_colors=get_colors

count=self.omap->get_count()                          
if count eq 0 then return,-1
if ~is_number(k) then k=0
map=self.omap->get(k,_extra=extra)

if ~is_number(xshift) then xshift=0.
if ~is_number(yshift) then yshift=0.
if ~is_number(roll) then roll=0.
rolling=(roll mod 360.) ne 0.
shifting=(xshift ne 0.) || (yshift ne 0.)
subsetting=valid_range(xrange) || valid_range(yrange)

if ~rolling && ~shifting && ~subsetting && ~keyword_set(get_colors) then return,map

ptr=ptr_exist(map)
if ptr then tmap=*map else tmap=temporary(map)

if rolling then tmap=rot_map(tmap,roll,/no_copy)
if shifting then tmap=shift_map(tmap,xshift,yshift,/no_copy)
if subsetting then begin
 sub_map,tmap,smap,xrange=xrange,yrange=yrange,/moplot
 tmap=temporary(smap)
endif
if ptr then map=ptr_new(tmap,/no_copy,/alloc) else map=temporary(tmap)

if keyword_set(get_colors) && self->get(k,/has_colors) then begin
 red=self->get(k,/red)
 green=self->get(k,/green)
 blue=self->get(k,/blue)
 map=create_struct(map,'red',red,'green',green,'blue',blue)
endif

return,map

end                   
              

;----------------------------------------------------------------------------
;-- set map method

pro map::setmap,k,map,_ref_extra=extra

self->set,k,map=map,_extra=extra

return & end
                                                                                    
;-------------------------------------------------------------------                              
;-- get map object properties                                                                     
                                                                                                  
function map::get,k,map=map,_extra=extra,$              
              plot_type=plot_type,filename=filename,err=err,header=header,$                       
              index=index,count=count,description=description,$                                   
              props=props,all_props=all_props,flag=flag

flag=1b
err=''                                                                                            
error=0
catch,error
if error ne 0 then begin
 mprint,err_state(),/info
 catch,/cancel
 message,/reset
 goto,bail
endif
    
if ~is_number(k) then k=0               
                     
if keyword_set(map) then return,self->getmap(k,_extra=extra)                                                                    
                                                                                                  
;-- top level properties                                                                          
               
if keyword_set(plot_type) then return,self.plot_type                                              

if keyword_set(description) then begin
 desc=file_basename(self->get(k,/filename))+' '+self->get(k,/id) + ' ' + self->get(k,/time)
 return,strcompress(desc)
endif
                                                                                      
if keyword_set(index) || keyword_set(header) then begin                                           
 if self->has_index(k,err=err) then begin
  index=self.oindex->get(k)
  if is_struct(index) then begin
   if keyword_set(header) then return,struct2fitshead(index) else return,index                      
  endif
 endif
endif                                                                                             
                                                                                                  
if keyword_set(count) then return,self.omap->get_count()                                          

;-- index properties                                                                              
                                                                                                  
if keyword_set(filename) then begin                                                               
 if self->has_index(k,err=err) then return,(self.oindex->get(k)).filename                                              
endif       

if keyword_set(props) || keyword_set(all_props) then return,self.oprop->get(k)                                

if is_struct(extra) then begin
 map_prop=self->get_map_prop(k,_extra=extra,err=err)                                              
 if err eq '' then return,map_prop                                                                
 plot_prop=self->get_plot_prop(k,_extra=extra,err=err)
 if err eq '' then return,plot_prop                                                               
        
;-- check index

 index_prop=self->get_index_prop(k,_extra=extra,err=err)
 if err eq '' then return,index_prop

endif

;-- if we get here then property is not supported                                                 
   
bail:         
err='No matching property found.'
flag=0b
                                                                                                  
return,''                                                                                         
end                                                                                               
            

;-------------------------------------------------------------------------
;--- get properties from INDEX structure

function map::get_index_prop,k,_extra=extra,err=err

err=''

if ~is_number(k) then k=0
if is_struct(extra) then begin
 if self->has_index(k,err=err) then begin
  index=self.oindex->get(k)
  if is_struct(index) then begin
   chk=have_tag(index,(tag_names(extra))[0],/start,sindex)
   if sindex[0] ne -1 then return,index.(sindex[0]) 
  endif
 endif
endif

err='No matching property found.'
return,''
end

;--------------------------------------------------------------------------                       
;-- get properties of plot map structure                                                               
                                                                                                  
function map::get_plot_prop,k,_extra=extra,err=err

err=''
if ~is_number(k) then k=0                                                                          
if is_struct(extra) then begin
 props=self.oprop->get(k) 
 if is_struct(props) then begin
  plot_map_struct,tprops
  extra=fix_extra(extra,tprops)
  etags=tag_names(extra)
  ptags=tag_names(props)
  match,ptags,etags,i,j,count=count
  if count ne 0 then return,props.(i[0])
 endif
endif

err='No matching property found.'
return,''
end
                                                                                    
;--------------------------------------------------------------------------                       
;-- set properties of plot map structure                                                               
                                                                                                  
pro map::set_plot_prop,k,_extra=extra

if ~is_struct(extra) then return
if ~is_number(k) then k=0

;-- create plot map structure if not present

plot_map_struct,tprops
props=self.oprop->get(k) 
if ~is_struct(props) then props=tprops

;-- update matching tags

extra=fix_extra(extra,tprops)
etags=tag_names(extra)
ptags=tag_names(props)
match,ptags,etags,i,j,count=count
if count eq 0 then return
nstruct=n_elements(etags)
for i=0,nstruct-1 do begin
 chk=where(etags[i] eq ptags,count)
 if count gt 0 then props=rep_tag_value(props,extra.(i),etags[i],/no_check)
endfor 
 
;-- update object

self.oprop->set,k,props

end
                                                                                    
;--------------------------------------------------------------------------                       
;-- get properties of map structure                                                               
                                                                                                  
function map::get_map_prop,k,xc=xc,yc=yc,dx=dx,dy=dy,nx=nx,ny=ny,$                                
              roll_angle=roll_angle,roll_center=roll_center,$                                     
              xyoffset=xyoffset,xrange=xrange,yrange=yrange,drange=drange,$                       
              time=time,data=data,id=id,xunits=xunits,yunits=yunits,dur=dur,$                     
              xp=xp,yp=yp,pixel_size=pixel_size,$                                       
              err=err,_extra=extra                                                                
                                           
err=''   
if ~is_number(k) then k=0                                                                          
emess='No matching property found.'                                                                                         
ptr=self.omap->get(k,/pointer)                                                                
if ~ptr_exist(ptr) then begin
 err=emess
 return,''
endif                                                                       
                                                                                                  
;-- basic properties                                                                              
            
if keyword_set(xc) then return,(*ptr).xc                                                          
if keyword_set(yc) then return,(*ptr).yc                                                          
if keyword_set(dx) then return,(*ptr).dx                                                          
if keyword_set(dy) then return,(*ptr).dy                                                          
if keyword_set(roll_angle) then return,(*ptr).roll_angle                                          
if keyword_set(roll_center) then return,(*ptr).roll_center                                        
if keyword_set(data) then return,(*ptr).data                                                      
                                                                                                  
;-- optional properties                                                                           
                                                                                                  
if keyword_set(xunits) then return,(*ptr).xunits                                                  
if keyword_set(yunits) then return,(*ptr).yunits                                                  
if keyword_set(dur) then return,(*ptr).dur                                                        
if keyword_set(id) then return,(*ptr).id                                                          
      
;-- check extra

if is_struct(extra) then begin
 tags=tag_names(extra)                                                                                            
 ptags=tag_names(*ptr)
 chk=where(tags[0] eq ptags,pcount)
 if pcount gt 0 then return,(*ptr).(chk[0])
endif
 
;-- derived properties                                                                            
                                                                                                  
if keyword_set(time) then begin                                                                   
 if have_tag(*ptr,'rtime') then return,anytim2utc((*ptr).rtime,/vms) else $                       
  return,anytim2utc((*ptr).time,/vms)                                                             
endif                                                                                             
                                                                                                  
if keyword_set(xyoffset) then return,[(*ptr).xc,(*ptr).yc]                                        
if keyword_set(pixel_size) then return,[(*ptr).dx,(*ptr).dy]                                      
if keyword_set(xp) then return,self->xp(k)                                                        
if keyword_set(yp) then return,self->yp(k)                                                        
if keyword_set(xrange) then return,self->xrange(k)                                                
if keyword_set(yrange) then return,self->yrange(k)                                                
if keyword_set(drange) then return,self->drange(k)                                                
if keyword_set(nx) then return,(size((*ptr).data))[1]                                             
if keyword_set(ny) then return,(size((*ptr).data))[2]                                             

err=emess
            
return,'' & end                                                                                   
         
;-----------------------------------------------------------------------                          
                                                                                                  
function map::xrange,k                                                                            
                                                                                                  
xc=self->get(k,/xc)                                                                               
nx=self->get(k,/nx)                                                                               
dx=self->get(k,/dx)                                                                               
                                                                                                  
xmin=min(xc-dx*(nx-1.d)/2.d)                                                                        
xmax=max(xc+dx*(nx-1.d)/2.d)                                                                        
return,[xmin,xmax]                                                                                
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------------                    
                                                                                                  
function map::yrange,k                                                                            
                                                                                                  
yc=self->get(k,/yc)                                                                               
ny=self->get(k,/ny)                                                                               
dy=self->get(k,/dy)                                                                               
                                                                                                  
ymin=min(yc-dy*(ny-1.d)/2.d)                                                                        
ymax=max(yc+dy*(ny-1.d)/2.d)                                                                        
return,[ymin,ymax]                                                                                
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------------                    
                                                                                                  
function map::drange,k                                                                            
                                                                                                  
if ~self->has_data(k,err=err) then return,[0,0]                                                
                                                                                                  
item=self.omap->get(k,/pointer)                                                               
dmin=min( (*item).data,max=dmax)                                                                  
return,[dmin,dmax]                                                                                
                                                                                                  
end                                                                                               
                                                                                                  
;-------------------------------------------------------------------------------                  
                                                                                                  
function map::xp,k,oned=oned                                                                      
                                                                                                  
xc=self->get(k,/xc)                                                                               
nx=self->get(k,/nx)                                                                               
ny=self->get(k,/ny)                                                                               
dx=self->get(k,/dx)                                                                               
                                                                                                  
if keyword_set(oned) then ny=1                                                                    
                                                                                                  
return,mk_map_xp(xc,dx,nx,ny)                                                                     
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------------------              
                                                                                                  
function map::yp,k,oned=oned                                                                      
                                                                                                  
yc=self->get(k,/yc)                                                                               
dy=self->get(k,/dy)                                                                               
nx=self->get(k,/nx)                                                                               
ny=self->get(k,/ny)                                                                               
                                                                                                  
if keyword_set(oned) then nx=1                                                                    
                                                                                                  
return,mk_map_yp(yc,dy,nx,ny)                                                                     
                                                                                                  
end                                                                                               
                                                                                                  
;----------------------------------------------------------------------------                     
;-- plot map object                                                                               
                                                                                                  
pro map::plot,k,_extra=extra,surface=surface,shade_surf=shade_surf,$
              err_msg=err_msg,status=status, no_timestamp=no_timestamp

status=0
error=0
if is_string(k) then return

catch,error

if error ne 0 then begin
 status=0
 err_msg=!err_string
 mprint,err_msg,/info
 catch,/cancel
 return
endif

if ~self->has_data(k,_extra=extra,/verbose) then return                
props=self->get(k,/props)                                                                              
pmap=self->get(k,/map,/pointer)                                                        
if ~ptr_exist(pmap) then return
      
;-- override plot properties with command-line keywords
       
if is_struct(extra) then begin
 plot_map_struct,template
 extra=fix_extra(extra,template)
endif  

if is_struct(props) then extra=join_struct(extra,props)                                                                    

if keyword_set(surface) || keyword_set(shade_surf) then $
 surface_map,*pmap,shade_surf=shade_surf,_extra=extra,err=err_msg else $
  plot_map,*pmap,_extra=extra,err_msg=err_msg,status=status

if ~keyword_set( no_timestamp ) then timestamp, /bottom

return & end                                                                                      
         
;---------------------------------------------------------------------------                     
       
pro map::plotman, k, plotman_obj=plotman_obj,_ref_extra=extra

error=0
catch,error
if error ne 0 then begin
 mprint,err_state(),/info
 catch,/cancel
 return
endif

count=self->get(/count)
if count eq 0 then begin
 mprint,'Map object is empty.',/info
 return
endif

;-- check input index. If not entered plot all available maps.

do_all=0b
if is_number(k) then begin
 if (k lt 0) || (k gt count) then begin
  mprint,'Invalid map index',/info
  return
 endif
endif else do_all=1b

;-- invoke plotman object

if ~obj_valid(plotman_obj) then plotman_obj=obj_new('plotman')

if do_all then val=indgen(count) else val=k
for i=0,n_elements(val)-1 do begin
 kval=val[i]
 desc = self->get(kval,/desc)
 if (count eq 1) then kobj=self else kobj=self->clone(kval) 
 noclone=(count gt 1)
 plotman_obj -> new_panel, input=kobj, plot_type='image',/nodup,noclone=noclone,desc =desc,$
  _extra=extra
endfor

return & end
                                 
                                                      
;----------------------------------------------------------------------------                     
;-- save current color table into map         
                                                                                         
pro map::save_ct,k,_extra=extra                                                                              
         
tvlct,red,green,blue,/get                                                                         
self->set,k,red=red,green=green,blue=blue,_extra=extra,/has_colors
                                                                                                  
return & end                                      
                                                                                                  
;--------------------------------------------------------------------------                       
;-- extract sub-region (function)                                                                 
                                                                                                  
function map::extract,k,_ref_extra=extra                                                          
                                                                                                  
self->clone,cobj,k,_extra=extra                                                                   
cobj->extract,_extra=extra                                                                        
return,cobj                                                                                       
end                                                                                               
                                                                                                  
;--------------------------------------------------------------------------                       
;-- extract sub-region (procedure)                                                                
                                                                                                  
pro map::extract,k,_extra=extra,err=err                                                           
                                                                                                  
err=''                                                                                            
if ~self->has_data(k,err=err) then begin                                                       
 mprint,err,/info                                                                                
 return                                                                                           
endif                                                                                             
                                                                                                  
map=self->get(k,/map,/no_copy)                                                                    
                                                                                                  
sub_map,map,smap,_extra=extra                                                                     
self->set,k,map=smap,/no_copy                                                            
self->update_index,k                                                                              
return & end                                                                                      
                                                                                                  
;----------------------------------------------------------------------------                     
;-- rotate map object (function)                                                                  
                                                                                                  
function map::rotate,angle,k,_ref_extra=extra                                                     
            
self->clone,cobj,k,_extra=extra                                                                   
cobj->rotate,angle,_extra=extra                                                                   
return,cobj                                                                                       
                                                                                                  
end                                                                                               
                                                                                                  
                                                                                                  
;----------------------------------------------------------------------------                     
;-- drotate map object (function)                                                                 
                                                                                                  
function map::drotate,duration,k,_ref_extra=extra                                                 
                                                                                                  
self->clone,cobj,k,_extra=extra                                                                   
cobj->drotate,duration,_extra=extra                                                               
return,cobj                                                                                       
                                                                                                  
end                                                                                               
                                                                                                  
;----------------------------------------------------------------------------                     
;-- rotate map object (procedure)                                                                 
                                                                                                  
pro map::rotate,angle,k,_extra=extra,err=err,all=all                                              
                                                                                                  
err=''                                                                                            
                                                                                                  
count=self->get(/count)                                                                           
if is_number(k) then m=k else m=0                                                                 
all=keyword_set(all)                                                                              
istart=m & iend=m                                                                                 
if all then begin                                                                                 
 istart=0 & iend=count-1                                                                          
endif                                                                                             
                                                                                                  
for i=istart,iend do begin                                                                        
                                                                                                  
 if ~self->has_data(m,err=err) then begin                                                      
  mprint,err,/info                                                                               
  continue                                                                                        
 endif                                                                                            
                                                                                                  
 map=self->get(m,/map,/no_copy)                                                                   
       
 rmap=rot_map(map,angle,_extra=extra,err=err)                                          
 if err ne '' then begin                                                                          
  self->set,m,map=map,/no_copy                                                           
  continue                                                                                        
 endif                                                                                            
                                                                                                  
 self->set,m,map=rmap,/no_copy
                        
 self->update_index,m                                                                             
                                                                                                  
endfor                                                                                            
                                                                                                  
status=1b                                                                                         
return & end                                                                                      
                                                                                                  
                                                                                                  
;----------------------------------------------------------------------------                     
;-- solar rotate map object                                                                       
                                                                                                  
pro map::drotate,duration,k,_extra=extra,err=err,all=all                                          
                                                                                                  
err=''                                                                                            
if ~is_number(k) then k=0                                                                      
do_all=keyword_set(all)                                                                           
count=self->get(/count)                                                                           
lind=indgen(count)                                                                                
                                                                                                  
;-- check if doing all or one                                                                     
                                                                                                  
if do_all then begin                                                                              
 chk=lind & dcount=count                                                                          
endif else begin                                                                                  
 chk=where(k eq lind,dcount)                                                                      
 if dcount eq 0 then begin                                                                        
  lind=0 & dcount=1                                                                               
 endif                                                                                            
endelse                                                                                           
                                                                                                  
for i=0,dcount-1 do begin                                                                         
 err=''                                                                                           
 j=lind[i]                                                                                        
 if ~self->has_data(j,err=err) then begin                                                      
  mprint,err,/info                                                                               
  continue                                                                                        
 endif                                                                                            
                                                                                                  
 map=self->get(j,/map,/no_copy)                                                                   
                                                                                                  
 rmap=drot_map(map,duration,_extra=extra,err=err)                                                 
 if err ne '' then begin
  self->set,j,map=map,index=index,/no_copy
  continue                                                                                        
 endif                                                                                            
  
 self->set,j,map=rmap,/no_copy
 self->update_index,j                                                                             
endfor                                                                                            
                                                                                                  
return & end                                                                                      
              
;---------------------------------------------------------------------------                      
;-- check if map is contained in object                                                           
                                                                                                  
function map::has_data,k,err=err,verbose=verbose                                                                  
                                                                                                  
err=''                                                                                            
if ~is_number(k) then k=0                                                                      
ptr=self.omap->get(k,/pointer)                                                                        
have_map=ptr_exist(ptr)                                                                           
if ~have_map then err='No map currently saved ('+trim(k)+')'                               
if keyword_set(verbose) && is_string(err) then mprint,err,/info            
                                                                                      
return,have_map                                                                                   
end                                                                                               
                                                                                                  
;---------------------------------------------------------------------------                      
;-- check if index is contained in object                                                         
                                                                                                  
function map::has_index,k,err=err                                                                 
                                                                                                  
err=''                                                                                            
if ~is_number(k) then k=0                                                                      
self.oindex->get,k,index                                                             
have_index=is_struct(index)                                                                         
if ~have_index then err='No index currently saved ('+trim(k)+')'                               
return,have_index                                                                                 
                                                                                                  
end                                                                                               
                 
;-------------------------------------------------------------------------

pro map::show,k

if self->has_data(k) then begin
 mprint,strtrim(self->get(k,/id),2)+' -> '+strtrim(self->get(k,/time),2),/info
endif

return & end

;--------------------------------------------------------------------------
;-- check text in index history tag

function map::has_history,k,text

kindex=0
if is_number(k) then kindex=k
if is_string(text) then ktext=text
if is_string(k) then begin
 ktext=k & kindex=0
endif 
index=self->get(kindex,/index)
history=get_history(index)
chk=where(stregex(history,ktext,/bool),count)
return,count gt 0
end

;--------------------------------------------------------------------------
;-- update text in index history tag

pro map::update_history,k,text

kindex=0
if is_number(k) then kindex=k
if is_string(text) then ktext=text
if is_string(k) then begin
 ktext=k & kindex=0
endif 
index=self->get(kindex,/index)
update_history,index,ktext
self->set,kindex,index=index
return
end

;-------------------------------------------------------------------------
;-- correct roll_center to be Sun center

pro map::fix_roll_center
if ~self->has_data() then return
roll_angle=self->get(/roll_angle)
if (nint(roll_angle) mod 360) eq 0 then return
roll_center=self->get(/roll_center)
if ~valid_range(roll_center) then return
map=self->get(/map,/no_copy)
roll_center=map.roll_center
roll_xy,roll_center[0],roll_center[1],roll_angle,p,q
map.xc=map.xc-p
map.yc=map.yc-q
map.roll_center=[0,0]
self->set,map=map,/no_copy
return & end

;-------------------------------------------------------------------------

pro map::help

hname=local_name('$SSW/gen/idl/maps/map__define.hlp')
if file_test(hname) then begin
 help=rd_tfile(hname)
 if have_windows() then r=dialog_message(help,/infor) else print,help
endif
return & end

;---------------------------------------------------------------------------                      
pro map__define                                                                                   
                                                                                                  
map={map, $                                                                                       
     plot_type:'',$                                                                               
     omap:obj_new(),$                                                                             
     oindex:obj_new(),$                                                                           
     oprop:obj_new(), inherits free_var, inherits dotprop}                                                                            

return                                                                                            
end                                                                                               

