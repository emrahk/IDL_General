; =========================================================================
;+
; Project     : The General IDL SYNoptic IMage Object (SYNIMON)
;
; Name        : SYNIMON__DEFINE
;
; Purpose     : Define a SYNIMON IDL object. This object is to be inherited by 
;               specific data objects. Instead of having to design an object 
;               from scratch, SYNIMON's general methods may be inherited, and 
;               only specific archive directories and plotting configurations 
;               need be written into the SYNIMON::INIT method, within the 
;               SAT_PROP settings structure. 
;               
;               SYNIMON utilizes Andre Csillaghy's Framework object to great 
;               benefit.
;
; Category    : Ancillary Synoptic Objects
;
; Syntax      : IDL> SYNIMON=obj_new('SYNIMON')
;
; Example     : IDL> SYNIMON=obj_new('SYNIMON')
;               IDL> SYNIMON->plot, grid=15, fov=20
;
; Notes       : 1. On its own, SYNIMON will not run. It must be inherited by 
;                  another object.
;               2. SOLMON__DEFINE is the first object to inherit SYNIMON.
;				3. SWAP__DEFINE also inherits SYNIMON (31-Mar-2010).
;
; History     : 18-AUG-2007 Written (My birthday!), Paul Higgins, (ARG/TCD)
;               14-OCT-2008 Changed object name from ULTIMON to SYNIMON, Paul Higgins, (ARG/TCD)
;				09-Jun-2010 Added LIST_INDEX method for searching remote FITS file headers, and fixed PLOTMAN method color table problem, Paul Higgins, (ARG/TCD)
;				03-Sep-2012 Made a change to timearrgen since time grid lops off hrs., min., sec. (problem reported by Dan Seaton), Paul Higgins, (ARG/TCD)
;				09-Sep-2012 Added field to SAT_PROP to test whether to set color table, Paul Higgins, (ARG/TCD)
;
; Tutorial    : Not yet. For now take a look at the configuration section of 
;               http://solarmonitor.org/objects/solmon/ 
;				place holder: http://solarmonitor.org/objects/synimon/
;
; Contact     : P.A. Higgins: pohuigin {at} gmail {dot} com
;               P. Gallagher: peter.gallagher {at} tcd {dot} ie
;-
; =========================================================================

;----------------------------------------------->
;-- The help procedure, sampling SYNIMON's object commands

pro SYNIMON::help

print,' '
print,'*** The Synoptic Image IDL Object ***'
print,'Astrophysics Research Group - Trinity College Dublin'
print,' '
print,'Version: JUL.30.2007 - Written: Jul 30 2007 - P.A. Higgins'
print,' '
print,'Temporary tutorial may be found at: http://solarmonitor.org/objects/solmon'
print,' '
print,'General Object Commands:'
print,' '
print,"IDL> SYNIMON = obj_new('SYNIMON')              ;-- Creates the SYNIMON object."
print,"IDL> files = SYNIMON->list(time='4-jun-2007')  ;-- Lists the files in the given range."
print,"IDL> index = SYNIMON->list_index(filelist=ff)  ;-- Output an array of remote FITS index structures."
print,"IDL> SYNIMON->read,time='4-jun-2007'           ;-- Reads the files in the given range into the object."
print,"IDL> data = SYNIMON->getdata('4-jun-2007')     ;-- Retrieves the data and, optionally, the headers and" 
print,"                                               ;-- file names saved in the object"
print,"IDL> maps = SYNIMON->getmap('4-jun-2007',indx) ;-- Retrieves the data maps saved in the object."
print,"IDL> time = SYNIMON->get(/time)                ;-- Retrieves the value of the specified keyword."
print,"IDL> SYNIMON->latest                           ;-- Reads the latest data file available for SYNIMON."
print,"IDL> SYNIMON->plot,time='30-may-2007 00:00:00' ;-- Plots the data set with the date closest to that" 
print,"                                               ;-- specified."
print,"IDL> obj_destroy,SYNIMON                       ;-- Destroys the object, freeing precious memory."
print,' '

return

end

;-------------------------------------------------------------------->

FUNCTION SYNIMON::INIT, SOURCE = source, _EXTRA=_extra

RET=self->Framework::INIT( CONTROL = synimon_control(), $

                           INFO={synimon_info}, $

                           SOURCE=source, $

                           _EXTRA=_extra )

self.data = ptr_new(/allocate)
self.map = ptr_new(/allocate)
self.headers = ptr_new(/allocate)
self.index = ptr_new(/allocate)
self.filelist = ptr_new(/allocate)
self.filescopied = ptr_new(/allocate)
self.filesread = ptr_new(/allocate)
self.filesall = ptr_new(/allocate)
self.setstart = ptr_new(/allocate)
self.setend = ptr_new(/allocate)

self.sat_prop = ptr_new(/allocate)
sat_prop={explot:{log:1,grid:1,center:1,colortable:1}, $
	plot_prop:{log:1,grid:15,center:[0,0],colortable:1}, $
	fspan:{url:'http://solarmonitor.org',ftype:'*.fts*',path:'/swap/20100101'}, $
	xstd:1050,ystd:1050,loadct:1,docolor:1}
;sat_prop={explot:{log:1,grid:1,center:1,colortable:1}, $
;	plot_prop:{log:1,grid:15,center:[0,0],colortable:3}, $
;	fspan:{url:'http://sohowww.nascom.nasa.gov',ftype:'*.fits',path:'/sdb/hinode/xrt/l1q_synop'}, $
;	xstd:2100,ystd:2100,loadct:3}
*(self.sat_prop) = sat_prop

self._explot = ptr_new(/allocate)
*(self._explot) = sat_prop.explot

self.plot_prop = ptr_new(/allocate)
*(self.plot_prop) = obj_new('plot_prop')

self->server
self->set,instrument='SYNIMON'
self->restoreplot

RETURN, RET

END

;-------------------------------------------------------------------->

PRO SYNIMON::Process,_EXTRA=_extra

if ptr_exist(self.map) ne 0 then map = *(self.map)
if ptr_exist(self.data) ne 0 then data = *(self.data)

;--<< GET Map header variables. >>

timerange = self->Get( /timerange )

header = self->Get( /header )

;--<< Hidden variables the object uses to run checks. Except for MAP, these
;--<< do not actually work with GET or SET becase they aren't magic.. >>

if ptr_exist(self.filelist) ne 0 then filelist = *(self.filelist)
if ptr_exist(self.filescopied) ne 0 then filesread = *(self.filescopied)
if ptr_exist(self.filesread) ne 0 then filesread = *(self.filesread)
if ptr_exist(self.index) ne 0 then index = *(self.index)
if ptr_exist(self.headers) ne 0 then headers = *(self.headers)
if ptr_exist(self.setstart) ne 0 then setstart = *(self.setstart)
if ptr_exist(self.setend) ne 0 then setend = *(self.setend)

self->read,timerange=timerange

if self->findnumimgs() lt 1 then return

out_data = *(self.map)
out_data=out_data[0]

if n_elements(out_data) gt 0 then begin

;--<< SET Map header variables. >>

	self->Set, ut = out_data.time
	self->Set, obs = out_data.id

	self->Set, timerange = out_data.time

endif

END

;-------------------------------------------------------------------->

FUNCTION SYNIMON::GetData, $
                  THIS_SUBSET1=this_subset1, $
                  THIS_SUBSET2=this_subset2, $
                  timerange=timerange, $
                  filelist=filelist, $

                  _EXTRA=_extra

if keyword_set(timerange) then begin
	self->set,timerange=timerange
	self->read,timerange=timerange
	if self->findnumimgs() lt 1 then return,''
endif

if keyword_set(filelist) then begin
	if self->frameworkcheck(self.filesread,filelist,wfile) eq 0 then begin
		self->read,filelist=filelist
		if self->findnumimgs() lt 1 then return,''
	endif
	map=*(self.map)
	data=map.data
	;data=self->getdataext(data)
	return,data;[*,*,wfile]
endif

if not keyword_set(timerange) and $
	not keyword_set(filelist) then begin
	self->process
	if self->findnumimgs() lt 1 then return,''
endif

timerange=self->get(/timerange)
data=self->Framework::GetData( timerange=timerange,filelist=filelist )

if self->findnumimgs() lt 1 then return,''
;data=self->getdataext(data)

IF Keyword_Set( THIS_SUBSET1 ) THEN BEGIN 
    data = Some_Selection( data, this_subset1 )
ENDIF 

IF Keyword_Set( THIS_SUBSET2 ) THEN BEGIN 
    data = Some_More_Selection( data, this_subset2 )
ENDIF 

RETURN, data

END 

;-------------------------------------------------------------------->

PRO SYNIMON::Set, $
       timerange=timerange, $
       _EXTRA=_extra

if keyword_Set(timerange) then begin
	self->Framework::Set, timerange = timerange
endif

IF Keyword_Set( _EXTRA ) THEN BEGIN

;--<< Set the plot keywords in the PLOT_PROP object. >>

	plot_prop=*(self.plot_prop)
	plot_prop->set, _EXTRA = _extra

;--<< Remember which plot keywords have been set. >>

	zero={zero:''}
	_explot=*(self._explot)
	extratag=tag_names(_extra)
	plottag=tag_names(_explot)

	for i=0,n_elements(extratag)-1 do begin 

		thisprop=CREATE_STRUCT(extratag[i], 1, zero)
		thisprop=rem_tag(thisprop,'zero')
		testprop=plot_prop->get(_extra=thisprop)
		
		wtag=where(extratag[i] eq plottag)
;--> May cause problems, since I'm assuming testprop=-1 means that prop doesn't exist...
		if wtag[0] eq -1 and testprop[0] ne -1 then _explot=CREATE_STRUCT(extratag[i], 1, _explot)
	endfor

	*(self._explot)=_explot

	self->Framework::Set, _EXTRA = _extra

ENDIF

END

;---------------------------------------------------------------------------

FUNCTION SYNIMON::Get, $
                  NOT_FOUND=NOT_found, $
                  FOUND=found, $
                  PARAMETER=parameter, $
                  filelist=filelist, $
                  filescopied=filescopied, $
                  filesread=filesread, $
                  index=index, $
                  _EXTRA=_extra 

if keyword_set(filelist) then begin 
	if data_chk(*(self.filelist),/type) ne 0 then return, *(self.filelist) else return,'' & endif
if keyword_set(filescopied) then begin
	if data_chk(*(self.filescopied),/type) ne 0 then return, *(self.filescopied) else return,'' & endif
if keyword_set(filesread) then begin
	if data_chk(*(self.filesread),/type) ne 0 then return, *(self.filesread) else return,'' & endif
if keyword_set(index) then begin
	if data_chk(*(self.index),/type) ne 0 then return, *(self.index) else return,'' & endif

;--> Plot_map object...

IF Keyword_Set( PARAMETER ) THEN BEGIN
    parameter_local=self->Framework::Get( /PARAMETER )
    Do_Something_With_Parameter, parameter_local
ENDIF 
plot_prop=*(self.plot_prop)
;_extra=_extra.(0)

property = plot_prop->get(_EXTRA = _extra)

;if data_chk(property,/type) eq 8 then property=property.(0)
if property[0] ne '' and property[0] ne -1 then return,property
RETURN, self->Framework::Get( $;PARAMETER = parameter, $
                              ;NOT_FOUND=not_found, $
                              FOUND=found, _EXTRA=_extra, /info_only ) ;ADDED INFO_ONLY to stop printing of 'join_struct' error
                             
END

;--------------------------------------------------------------------------->

;<<< BEGIN NON-FRAMEWORK CODE >>>

;----------------------------------------------->

function SYNIMON::data_process,maparr

;for i=0,n_elements(maparr)-1 do begin
;	map=maparr[i]
;	data=map.data

;--<< Process DATA >>

;insert procedures for tweaking displayed data
;ie. kludge pointing etc.

;--<< >>

;	map.data=data
;	maparr[i]=map
;endfor

maparr_process=maparr

return,maparr_process

end

;----------------------------------------------->

function SYNIMON::point_offset, index, xoff, yoff

retval=index
;   if n_elements(xoff) eq 0 then xoff=0
;   if n_elements(yoff) eq 0 then yoff=0
;   retval.xcen=index.xcen+xoff
;   retval.ycen=index.ycen+yoff
return,retval
end

;----------------------------------------------->
;-- Compensate for the off-centering of the data.

function SYNIMON::compensate,maparr,xoff=xoff,yoff=yoff

nmap=n_elements(maparr)

firstmap=maparr[0]
map2index,firstmap,index

retval=self->point_offset(index)

index2map,retval,firstmap.data,newmap
maparrnew=newmap

*(self.map)=maparrnew

if nmap lt 2 then return,maparrnew

for i=1,nmap-1 do begin
	thismap=maparr[i]
	map2index,thismap,index

	retval=self->point_offset(index)

	index2map,retval,thismap.data,newmap
	maparrnew=[maparrnew,newmap]
endfor

*(self.map)=maparrnew

return,maparrnew

end 

;----------------------------------------------->
;-- Plot a series of images

pro SYNIMON::multiplot,_extra=_extra,pmulti=pmulti,wsize=wsize,wset=wset, timerange=timerange, outpmulti, numplots

oldpmulti=!p.multi

maparr=self->getmap(_extra=_extra, timerange=timerange)

if not keyword_Set(wsize) then wsize=300.
if not keyword_set(pmulti) then pmulti=[0,n_elements(maparr),1]
outpmulti=pmulti
numplots=pmulti[1]*pmulti[2]
if not keyword_set(wset) then wset=10

window,wset,xsize=wsize*pmulti[1],ysize=wsize*pmulti[2]

!p.multi=[pmulti[0],pmulti[1],pmulti[2]]

if self->findnumimgs() lt 1 then return

if pmulti[1]*pmulti[2] gt n_elements(maparr) then $
	plotnum=(n_elements(maparr)-1) else $
	plotnum=pmulti[1]*pmulti[2]-1

for i=0,plotnum do begin
	self->setplotspecs, maparr[i],_extra=_extra
endfor

!p.multi=oldpmulti

return

end

;----------------------------------------------->
;-- Animate a series of images

pro SYNIMON::movie,_extra=_extra,xsize=xsize,ysize=ysize,title=title, $	
	rotate=rotate, tref=tref, gif=gif, gname=gname, rate=rate, $
	filelist=filelist, timerange=timerange, scale=scale, nocolor=nocolor

sat_prop = *(self.sat_prop)

mapset=self->getmap(_extra=_extra, filelist=filelist, timerange=timerange)

if self->findnumimgs() lt 2 then begin
	print,' '
	print,'There must be more than one image loaded to make a movie.'
	print,' '
	return
endif

if data_chk(mapset[0],/type) ne 8 then return 

;Check whether to set a color table
if not keyword_set(nocolor) then begin
	if (where(strlowcase(tag_names(sat_prop)) eq 'docolor'))[0] ne -1 then begin
		if sat_prop.docolor ne 0 then loadct,sat_prop.loadct
	endif else loadct,sat_prop.loadct
endif

;--->
self->set, _EXTRA = _extra;exset
plot_prop=*(self.plot_prop)
plot_prop->set, _EXTRA = _extra;exset
_explot=*(self._explot)
ex = plot_prop->get(_EXTRA=_explot)
;--->

if not keyword_Set(xsize) then xsize=500
if not keyword_Set(ysize) then ysize=500
;if not keyword_Set(title) then title='Synimon -> Movie'
if not keyword_set(rate) then rate=10

;widget_control, /delay_destroy
;movie_map
xinteranimate2, /close

mapset=self->data_process(mapset)

movie_map, mapset, _extra=ex, xsize=xsize, ysize=ysize, rate=rate, title=title, $
	rotate=rotate, tref=tref, gif=gif, gname=gname

return

end

;----------------------------------------------->
;-- Calls a plot manager for the specified input image.

pro SYNIMON::plotman,timerange=timerange,filelist=filelist,xtitle=xtitle,ytitle=ytitle,title=title,_extra=exset

if not have_proc('plotman__define') then begin
	print,' '
	print,'Your SolarSoft archive does not contain PLOTMAN__DEFINE'
	print,' '
	return
endif

sat_prop = *(self.sat_prop)

plottype='image'

if keyword_set(timerange) then timerange=anytim(timerange[0],/vms)
if keyword_set(filelist) then filelist=filelist[0]
if not keyword_set(timerange) and not keyword_set(filelist) then begin
	timerange=self->get(/timerange)
	timerange=anytim(timerange[0],/vms)
endif
map=self->getmap(timerange=timerange,filelist=filelist,_extra=exset)
if self->findnumimgs() eq 0 then return
map=map[0]

map=self->data_process(map)

;--->
self->set, _EXTRA = exset
plot_prop=*(self.plot_prop)
plot_prop->set, _EXTRA = exset
_explot=*(self._explot)
ex = plot_prop->get(_EXTRA=_explot)
;--->

if not keyword_set(xtitle) then ex = CREATE_STRUCT('xtitle', map.xunits, ex)
if not keyword_set(ytitle) then ex = CREATE_STRUCT('ytitle', map.yunits, ex)
if not keyword_set(title) then ex = CREATE_STRUCT('title', map.id+' '+map.time, ex)
ex = CREATE_STRUCT('colortable', 1, ex)

plotman_obj = obj_new('plotman',input=map, plot_type=plottype, _extra=ex)
;plotman_obj->set, colortable=3
;plotman_obj = plotman(input=map[0], plot_type=plottype,_extra=ex)

return

end

;----------------------------------------------->
;-- Outputs a 3D (if more than one set) array of the data sets contained in the object.

function SYNIMON::getdataext,dataset

numimgs=self->findnumimgs()
testmap=*(self.map[0])
imgsz=size(testmap.data)

if numimgs eq 1 then begin
	extractset=fltarr(imgsz[1],imgsz[2],numimgs)
	for i=0,numimgs-1 do begin
		extractset[*,*,i]=self->extractplot(dataset[*,*,i])
	endfor

endif else extractset=dataset

return,extractset

end

;----------------------------------------------->
;-- Outputs an array of the map structures contained in the object.

function SYNIMON::getmap,index,fnames,filelist=filelist,timerange=timerange

if keyword_set(filelist) then begin
	if self->frameworkcheck(self.filesread,filelist,wfile,wflist) eq 0 $
		then self->read,filelist=filelist $;[0] $
	else begin 
		data=*(self.map)
		return,data[wflist]
	endelse 
endif

dummy=self->getdata(timerange=timerange,filelist=filelist)

if self->findnumimgs() lt 1 then return,''
maparr=*(self.map)
header=*(self.headers)
index=*(self.index)
fnames=*(self.filesread)

return,maparr

end


;----------------------------------------------->
;-- Reads in the latest data set.

pro SYNIMON::latest,filelist,fileslist

self->read,timerange=anytim( strjoin([anytim(systim(/utc),/date,/vms),'23:59:59.999'],' '),/vms )

if self->findnumimgs() eq 0 then begin
	print,'Searching 1 day prior...'
	self->read,timerange=anytim( strjoin([anytim(anytim(systim(/utc))-24.*3600.,/date,/vms),'23:59:59.999'],' '),/vms )
endif

if self->findnumimgs() eq 0 then begin
	print,'Searching 2 days prior...'
	self->read,timerange=anytim( strjoin([anytim(anytim(systim(/utc))-24.*3600.*2.,/date,/vms),'23:59:59.999'],' '),/vms )
endif

return

end

;----------------------------------------------->
;-- Reinitializes the object's fields.

pro SYNIMON::finishedplot 

self.data = ptr_new(/allocate)
self.map = ptr_new(/allocate)
self.index = ptr_new(/allocate)
self.header = ptr_new(/allocate)
self.filelist = ptr_new(/allocate)
self.filesread = ptr_new(/allocate)
self.filescopied=ptr_new(/allocate)

print,' '
print,'The object has been reinitialized.'
print,"To plot without reinitializing, use keyword, '/SAV'"
print,' '

return

end

;----------------------------------------------->
;-- Restore the default plot settings.

pro SYNIMON::restoreplot

sat_prop=*(self.sat_prop)
ex = sat_prop.explot

;Check whether to set a color table
if (where(strlowcase(tag_names(sat_prop)) eq 'docolor'))[0] ne -1 then begin
	if sat_prop.docolor ne 0 then loadct,sat_prop.loadct
endif else loadct,sat_prop.loadct

plot_prop=*(self.plot_prop)
plot_prop->set, _EXTRA = sat_prop.plot_prop

*(self._explot) = sat_prop.explot

!p.multi=0

return

end

;----------------------------------------------->
;-- Routine for setting the plot color and secifics.

pro SYNIMON::setplotspecs,imagemap,_extra=exset

self->set, _EXTRA = exset
plot_prop=*(self.plot_prop)
plot_prop->set, _EXTRA = exset
_explot=*(self._explot)
ex = plot_prop->get(_EXTRA=_explot)

;--<< Compensate for the off centering of the GRID >> it's done in savefits2map
;imagemap=self->compensate(imagemap)
;--<< >>

imagemap=imagemap[0]
imagemap=self->data_process(imagemap)

plot_map,imagemap,_extra=ex

return

end

;----------------------------------------------->
;-- Extracts the image to be plotted which is embedded in a frame of -1's.

function SYNIMON::extractplot,image

bdrval=10000
imgsz=size(image)

wnegone=where(image ne -1*bdrval)

xmin=min(wnegone) mod imgsz[1]
ymin=min(wnegone)/imgsz[2]
xmax=max(wnegone) mod imgsz[1]
ymax=max(wnegone)/imgsz[2]

imgcrop=image[xmin:xmax,ymin:ymax]

return,imgcrop
end

;----------------------------------------------->
;-- Returns 1 if the string is a filename, 0 if the string is a time, or -1 if it is neither.

function SYNIMON::fileortime,filetime

if datatype(filetime) ne 'STR' then begin
	print,' '
	print,'Input must be in the form of a file name or time string.'
	print,' '
	return,-1
endif
timesec=anytim(filetime)
datyp=datatype(timesec)
if datyp eq 'STR' then begin
	if n_elements(strsplit(filetime,'.',/extract)) gt 1 then whichtype=1 else whichtype=-1
endif else whichtype=0
if whichtype eq -1 then begin
	print,' '
	print,'Input must be in the form of a file name or time string.'
	print,' '
	return,-1
endif

return, whichtype

end

;----------------------------------------------->
;-- Finds a value for the number of images loaded into the object.

function SYNIMON::findnumimgs

numimgs=n_elements(*(self.map))

return,numimgs

end

;----------------------------------------------->
;-- Checks to see if the data to be plotted has already been read into the object.

function SYNIMON::checkreaddata,filelist

print,' '
print,'Checking object data...'
print,' '
fnamelist=self->fullpath2filename(filelist)

if ptr_exist(self.filesread) eq 0 then return,0 else filereadlist=self->fullpath2filename(*(self.filesread))

if self->findnumimgs() gt 0 then begin
	fileread=1
	for i=0,n_elements(fnamelist)-1 do begin
		wread=where(fnamelist[i] eq filereadlist)
		if wread[0] eq -1 then fileread=0
	endfor
endif else begin
	fileread=0
endelse
if fileread eq 1 then begin
	print,' '
	print,'The files have already been read.'
	print,' '

endif


return,fileread

end

;----------------------------------------------->
;-- Plots the data held in the object structure.

pro SYNIMON::plot,timerange=timerange,filelist=filelist,latest=latest,_extra=exset

self->set,_extra=exset

wfile=0
numimg=0
numimgs=0
spansearch=302400
foundfile=0
fileslist=1
cas=0

if not keyword_set(filelist) and not keyword_set(timerange) then begin
	timerange=self->get(/time)
	self->set,timerange=anytim(timerange[0],/vms)
endif

if keyword_set(latest) then begin
	self->latest
	if self->findnumimgs() lt 1 then return
	imagemap=*(self.map)
	imagemap=imagemap[numimg]
	self->setplotspecs,imagemap[numimg],_extra=exset
	return

endif

if keyword_set(timerange) then begin
	self->set,timerange=anytim(timerange[0],/vms)
	timerange=self->get(/timerange)
endif

;if keyword_set(filelist) then begin
;filelist=filelist[0]
;endif

imagemap=self->getmap(timerange=timerange,filelist=filelist)

imagemap=imagemap[0]

if self->findnumimgs() lt 1 then return

self->setplotspecs,imagemap[0],_extra=exset

return

end

;----------------------------------------------->
;-- Extracts and creates a nice header array from a data map.

function SYNIMON::writeheader,datamap

nheadery=12
nheaderx=2

header=strarr(nheaderx,nheadery)

header[1,0]=string(datamap.xc)
header[1,1]=string(datamap.yc)
header[1,2]=string(datamap.dx)
header[1,3]=string(datamap.dy)
header[1,4]=string(datamap.time)
header[1,5]=string(datamap.id)
header[1,6]=string(datamap.roll_angle)
header[1,7]=strjoin(datamap.roll_center,' ')
header[1,8]=string(datamap.dur)
header[1,9]=string(datamap.xunits)
header[1,10]=string(datamap.yunits)
;header[1,11]=string(datamap.soho)

header[0,0]='XC'
header[0,1]='YC'
header[0,2]='DX'
header[0,3]='DY'
header[0,4]='TIME'
header[0,5]='ID'
header[0,6]='ROLL_ANGLE'
header[0,7]='ROLL_CENTER'
header[0,8]='DUR'
header[0,9]='XUNITS'
header[0,10]='YUNITS'
;header[0,11]='SOHO'

return,header

end

;----------------------------------------------->
;-- Makes all images the same size before grouping them into an array.

function SYNIMON::embedimg,image,filename

sat_prop=*(self.sat_prop)

bdrval=10000
ystd=sat_prop.ystd
xstd=sat_prop.xstd

if n_elements(image) gt 1 then begin
	imgsz=size(image)
	xsz=imgsz[1]
	ysz=imgsz[2]

	if xsz lt xstd and ysz lt ystd then begin

		if xsz gt ysz then begin
			horzbdr=fltarr(xsz,(ystd-ysz))
			horzbdr=horzbdr-bdrval
			vertbdr=fltarr((xstd-xsz),ystd)
			vertbdr=vertbdr-bdrval
			image=[[image],[horzbdr]]
			image=[image,vertbdr]
		endif

		if xsz lt ysz then begin
			horzbdr=fltarr(xstd,(ystd-ysz))
			horzbdr=horzbdr-bdrval
			vertbdr=fltarr((xstd-xsz),ysz)
			vertbdr=vertbdr-bdrval
			image=[image,vertbdr]
			image=[[image],[horzbdr]]
		endif

		if xsz eq ysz then begin
			horzbdr=fltarr(xstd,(ystd-ysz))
			horzbdr=horzbdr-bdrval
			vertbdr=fltarr((xstd-xsz),ysz)
			vertbdr=vertbdr-bdrval
			image=[image,vertbdr]
			image=[[image],[horzbdr]]
		endif

	endif else begin
		image=fltarr(xstd,ystd)
		image=image-10*bdrval
		print,' '
		print,'Image dimensions are too large.'
		print,filename+' has been excluded.'
		print,' '
	endelse

endif else begin
	print,' '
	print,'Image data is missing. Check the HTML file links.'
	print,filename+' has been excluded.'
	print,' '
	image=fltarr(xstd,ystd)
	image=image-10*bdrval
endelse

return,image

end

;----------------------------------------------->
;-- Converts a fits filelist to a map structure and saves it to the object.

pro SYNIMON::savefits2map,filelist

mreadfits,filelist,indexarr,dataarr
;fits2map,filelist,maparr

*(self.index)=indexarr

index2map,indexarr,dataarr,maparr
*(self.map)=maparr

;if self->get(/instrument) eq 'SYNIMON' then maparr=self->compensate(maparr)

return

end

;----------------------------------------------->
;-- Converts a list of full path file name to a list of local file names.

function SYNIMON::fullpath2filename,filelist

filelist0=reform(filelist)

;--<< might cause problems >>
wblank=where(filelist0 ne '')
if wblank[0] eq -1 then return,'' else filelist0=filelist0[wblank]


filenamelist=(reverse(str_sep(filelist0[0],'/')))[0]
;testfname=filenamelist

if n_elements(filelist0) gt 1 then begin

	for i=1,n_elements(filelist0)-1 do begin
		nextfname=(reverse(str_sep(filelist0[i],'/')))[0]
		filenamelist=[[filenamelist],[nextfname]]
	endfor
	;sizelist=size(filenamelist)
	;if sizelist[1] ge n_elements(testfname) then begin
	;	filenamelist=filenamelist[n_elements(testfname)-1,*]
	;endif

endif

filenamelist=reform(filenamelist)

return,filenamelist

end

;----------------------------------------------->
;-- Reads in the specified fits files from a file list.

pro SYNIMON::loaddata,filelist,fileslist

print,' '
print,'Reading files...'
print,' '

sat_prop = *(self.sat_prop)

imgind=0
testimg=0
nelemtest=0
minimgsz=2
fileslist=1
embedx=sat_prop.xstd
embedy=sat_prop.ystd
nheader=[2,12]

if n_elements(str_sep(filelist[0],'/')) gt 1 then begin
	fnamelist=self->fullpath2filename(filelist)
endif else begin
	fnamelist=filelist
endelse

self->savefits2map,fnamelist
*(self.filelist)=reform(fnamelist)
*(self.filescopied)=reform(fnamelist)
*(self.filesread)=reform(fnamelist)


if ptr_exist(self.map) ne 0 then begin
	maparr=*(self.map)
endif else begin
	maparr=''
	print,' '
	print,'There is no map data loaded into the object.'
	print,' '
	return
endelse

numimgs=self->findnumimgs()

;dataset=fltarr(embedx,embedy,numimgs)
headerset=strarr(nheader[0],nheader[1],numimgs)
for i=0,numimgs-1 do begin
	datamap=maparr[i]
;	data=datamap.data
;	dataset[*,*,i]=self->embedimg(data,fnamelist[i])
	headerset[*,*,i]=self->writeheader(datamap)
endfor

dataset=maparr.data
*(self.data)=dataset
*(self.headers)=headerset

self->set,header=headerset[*,*,0]

;--<< Set the header info into universal variables. >>

print,' '
print,'The files were read successfully.'
print,' '

return

end

;----------------------------------------------->
;-- Checks the local directory for the listed files so as not to waste time searching 
;-- the remote directory if they already exist on the drive.

function SYNIMON::checklocal,filelist

print,' '
print,'Searching local directory...'
print,' '
searchlist=''

for i=0,n_elements(filelist)-1 do begin
	file=strsplit(filelist[i],'/',/extract)
	search=file_search(file[n_elements(file)-1])
	searchlist=[searchlist,search]
endfor

searchlist=searchlist[1:*]

return,searchlist

end

;----------------------------------------------->
;-- Returns 1 if the files have already been operated on, 0 if they have not.

function SYNIMON::frameworkcheck,pointervar,filelist,wfile,wflist

filelistcheck=reform(self->fullpath2filename(filelist))

if ptr_exist(pointervar) then begin
	filesold=self->fullpath2filename(*(pointervar))
	notfile=1
	wflist=strarr(n_elements(filelistcheck))
	for i=0,n_elements(filelistcheck)-1 do begin
		wfile=where(filesold eq filelistcheck[i])
		wflist[i]=wfile
		if wfile[0] eq -1 then notfile=0
	endfor
	wgood=where(wflist ne -1)
	if wgood[0] ne -1 then wflist=wflist[wgood]
	if notfile eq 1 then return,1
endif

return,0

end

;----------------------------------------------->
;-- Reads in fits files from a file list
;-- If the files are not in the local directory, it downloads them, then reads them.

pro SYNIMON::read,timerange=timerange,filelist=filelist,_extra=ex

if keyword_set(timerange) then begin
	filelist=self->list(timerange=timerange)
	if filelist[0] eq '' then return
endif

if n_elements(filelist) lt 1 then begin
	print,' '
	print,'Please specify a TIMERANGE or FILELIST.'
	print,' '
return
endif

;--> Framework check...
if self->frameworkcheck(self.filesread,filelist) eq 1 then return
;-->

;--<< Download only the files that are not on the local disk. >>

self->copy,error,filelist=filelist

if error[0] eq -1 then return

self->loaddata,filelist

return

end

;----------------------------------------------->
;-- Copy files from a remote host using a list of full-path file names

pro SYNIMON::copy,error,filelist=filelist

error=1
allfound=0
fileslist=1

if n_elements(filelist) ne 0 then begin

	;--> Framework check...
	if self->frameworkcheck(self.filescopied,filelist) eq 1 then return
	;-->

	searchlist=self->checklocal(filelist)
	wsearch=where(searchlist ne '')
	wnotfound=where(searchlist eq '')

	wgood=-1

	if wnotfound[0] ne -1 then begin
		flistcopy=filelist[wnotfound]

;--<< Check Server Status. >>
	self->server,status
	if status ne 1 then begin & fileslist='' & error=-1 & return & endif

		print,' '
		print,'Copying data...'
		print,' '

		for i=0,n_elements(filelist)-1 do begin

			fsize=sock_size(filelist[i])

			if fsize gt 1 then begin
				sock_copy,filelist[i],/verb
				wgood=[wgood,i]
				
			endif else begin
				print,' '
				print,'HTML link is empty.'
				print,strtrim(filelist[i],2)+' has been excluded.'
				print,' '
			endelse

		endfor

	endif else begin
		print,' '
		print,'All files were found on the local drive.'
		print,' '
		allfound=1
	endelse

	if n_elements(wgood) gt 1 then begin
		wgood=wgood[1:*]
		filelist=filelist[wgood]
	endif else begin
		if allfound ne 1 then begin
		print,' '
		print,'No valid URLs.'
		print,' '
fileslist=''
error=-1
		endif
return
	endelse
	*(self.filelist)=reform(filelist)
	*(self.filescopied)=reform(filelist)

endif else begin
	print,' '
	print,'No file was specified.'
	print,' '
fileslist=''
error=-1
return
endelse 

return

end

;----------------------------------------------->
;-- Generates an array of file name vectors, where the y-dimension is the file index, 
;-- and each element in the x direction is one element of the file name 

function SYNIMON::splitpath,filelist

minelem=8

splitlist=str_sep(filelist[0],'_')
while n_elements(splitlist) lt minelem do begin
	splitlist=[splitlist,'']
endwhile

for i=1,n_elements(filelist)-1 do begin
	nextsplit=str_sep(filelist[i],'_')
	while n_elements(nextsplit) lt minelem do begin
		nextsplit=[nextsplit,'']
	endwhile
	splitlist=[[splitlist],[nextsplit]]
endfor

return,splitlist

end

;----------------------------------------------->
;-- Generates a list of times from a list of files

function SYNIMON::flist2tlist,filelist

timelist=anytim(file2time(filelist))

return,timelist

end

;----------------------------------------------->
;-- Makes sure that months and days are 2 characters in length

function SYNIMON::i02,num

if strlen(strcompress(num,/remo)) eq 1 then begin
	num='0'+strcompress(num,/remo)
endif

return,num

end

;----------------------------------------------->
;-- Generates a 3 element array holding the year, month, and day of some file name 

function SYNIMON::pathogen,tname

fstart=strsplit(time2file(tname),'_',/extract)
tstart=strarr(3)
tstart[0]=strmid(fstart[0],0,4)
tstart[1]=strmid(fstart[0],4,2)
tstart[2]=strmid(fstart[0],6,2)
tstart=fix(tstart)

return,tstart

end

;----------------------------------------------->
;-- Generates a list of path names, one for each day in the specified range

function SYNIMON::timearrgen,tstart,tend;, vms=vms

sat_prop = *(self.sat_prop)
satspan=sat_prop.fspan

;if not keyword_set(vms) then begin
;	tstart1=anytim(file2time(strtrim(tstart,2)),/date,/vms)
;	tend1=anytim(file2time(strtrim(tstart,2)),/date,/vms)
;endif else begin
	tstart1=tstart
	tend1=tend
;endelse

;dates = TIME2FILE( TIMEGRID( ANYTIM( '15-may-99' ), ANYTIM( '15-jun-99' ), /DAYS, /VMS ), /DATE )
anyst=ANYTIM( tstart1, error=error1 )
anyen=ANYTIM( tend1, error=error2 )
if error1 or error2 eq 1 then begin
	print,[[' '],['Incorrect date format!'],[' ']]
	return,''
endif

;2012-09-03 Phiggins edit, problem reported by Dan Seaton. 
;TIMEGRID lops off hours, minutes, and seconds
;dates = TIME2FILE( TIMEGRID( anyst, anyen, /DAYS, /VMS, /quiet ), /DATE )

;stop

hours = TIME2FILE( TIMEGRID( anyst, anyen, /HOURS, /VMS, /quiet), /DATE)
dates = hours(uniq(hours))

dates=dates[uniq(dates)]

;return,dates

npath=n_elements(dates)
instpath=satspan.path

inst0=strarr(npath)+instpath[0]
inst2=strarr(npath)+instpath[2]
fullpath=inst0+dates+inst2

;for i=0,n_elements(path)-1 do begin
;	pathelem=strjoin([instpath[0],dates[i],instpath[2]],'')
;	fullpath[i]=pathelem
;endfor

return,fullpath

end

;----------------------------------------------->

function SYNIMON::filter,filelist,sttime,entime,_extra=exfilt

minelem=8

tlist=self->flist2tlist(filelist)
wfilt=where(tlist ge sttime and tlist le entime)

if wfilt[0] ne -1 then begin
	flistfilt=filelist[wfilt]
endif else begin
	print,' '
	print,'No files were found within the specified range.'
	print,' '
flistfilt=''
return,flistfilt
endelse

return,flistfilt

end

;----------------------------------------------->
;-- Handles the case of list finding no files.

function SYNIMON::listcrash

flistfilt=''

return,flistfilt

end

;----------------------------------------------->
;-- 

function SYNIMON::checklatest,setstart,tstart

set=strsplit(anytim(setstart,/vms),':',/extract)
tst=strsplit(anytim(tstart,/vms),':',/extract)
sys=strsplit(anytim(systim(/ut),/vms),':',/extract)
if strjoin(set[0:1],':') eq strjoin(sys[0:1],':') then begin
	if strjoin(set[0:1],':') eq strjoin(tst[0:1],':') then return,1
endif

return,0

end

;----------------------------------------------->

function SYNIMON::checkfilerepeat,filelist

listtest=self->fullpath2filename(filelist)

if filelist[0] eq '' and n_elements(filelist) lt 2 then return,filelist

filelistchecked=filelist[uniq(listtest)]

;for i=0,n_elements(filelist)-1 do begin
;	
;	wsame=where(listtest eq listtest[i])
;	if n_elements(wsame) gt 1 then $
;		for j=1,n_elements(wsame)-1 do filelist[wsame[j]]=''
;endfor
;
;filelistchecked=filelist

;wnotblank=where(filelistchecked ne '')
;if wnotblank[0] eq -1 then return,''
;filelistchecked=filelistchecked[wnotblank]

return,filelistchecked

end

;----------------------------------------------->

function SYNIMON::sock_hread, filelist=files, wgood=wgood, err=error

indexarr=''
error=''
wgood=-1

nfiles=n_elements(files)
for i=0,nfiles-1 do begin

;sock_fits,'http://proba2.oma.be/swap/data/bsd/2010/05/17/swap_lv1_20100517_012108.fits',dummy,header=header,/nodata,err=err
	sock_fits,files[i],dummy,header=header,/nodata,err=err
	if err ne '' then begin & error='Not all files were successfully read.' & continue & endif

	if i gt 0 and data_chk(indexarr,/type) eq 8 then begin
		thisind=fitshead2struct(header, indexarr[0])
		if data_chk(thisind,/type) eq 8 then indexarr=[indexarr,thisind]
		if data_chk(thisind,/type) eq 8 then wgood=[wgood,i]
	endif
	
	if data_chk(indexarr,/type) ne 8 then begin 
		indexarr=fitshead2struct(header)
		if data_chk(indexarr,/type) eq 8 then wgood=i
	endif

endfor

if error ne '' then begin & print,[[' '],['Not all files were successfully read. Check WGOOD keyword.'],[' ']] & return, indexarr & endif

;http=obj_new('http',err=err)
;http->hset,_extra=extra
;http->list,url,page,_extra=extra,err=err
;obj_destroy,http

*(self.filelist)=files[wgood]
*(self.index)=indexarr

return, indexarr

end





;----------------------------------------------->

function SYNIMON::listgen,tstart,tend,range=range, settime=settime

fspan=self->fullpath(tstart,tend)

rungen=0
if data_chk(*(self.filesall),/type) eq 0 then rungen=1
if rungen eq 0 then begin & if (*(self.filesall))[0] eq '' then rungen=1 & endif

if rungen eq 1 then begin

;--<< Check Server Status. >>
	self->server,status
	if status ne 1 then return,''
	
	filelist=sock_find(fspan.url,fspan.ftype,path=fspan.fpath) 
	filelist=self->checkfilerepeat(filelist)
endif else filelist=*(self.filesall)

*(self.filesall)=filelist

return,filelist
end

;----------------------------------------------->

function SYNIMON::list,timerange=timerange,_extra=exfilt

range=0
settime=0
spansearch=302400
bignum=anytim(1.*10.^(10.),/vms)

if not keyword_set(timerange) then timerange=self->get(/timerange)

;--<< Set a TSTART and TEND based on TIMERANGE. >>

;--<< If TIMERANGE has 2 equal elements, then just take the first one. >>

if n_elements(timerange) gt 1 then begin
	if timerange[1] eq '' or timerange[0] eq timerange[1] then timerange=timerange[0]
endif

tstart=timerange[0]
if n_elements(timerange) gt 1 then begin
	tend=timerange[1]
	range=1
endif else begin
	closetime=tstart
	tend=bignum
endelse

;--<< Now we should have a TSTART and possibly a TEND. >>

;-----> Framework check...
if ptr_exist(self.setstart) ne 0 and ptr_exist(self.setend) ne 0 and ptr_exist(self.filelist) ne 0 then begin
	setstart=*(self.setstart)
	setend=*(self.setend)
	if anytim(setstart) eq anytim(tstart) then starttru=1 else starttru=0
	if self->checklatest(setstart,tstart) eq 1 then starttru=1
;	*(self.setstart)=tstart
	if anytim(setend) eq anytim(tend) then endtru=1 else endtru=0
;	*(self.setend)=tend
	if starttru eq 1 and endtru eq 1 then return,*(self.filelist)
endif
;----->

;--<< Update the Pointers. >>

*(self.setstart)=tstart
if range eq 1 then begin
	*(self.setend)=tend 
	self->set,timerange=timerange
endif else begin
	*(self.setend)=bignum
	self->set,timerange=[timerange[0],'']
endelse

nsttime=n_elements(strsplit(tstart,' ',/extract))

;--<< NSTTIME having 2 elements means that the user has specified a specific time of day.

if nsttime gt 1 then settime=1

;--<< If the time of day was not specified, we take the whole day. >>

;--<< Put the times in seconds. >> 


if range eq 1 then begin
	if settime eq 1 then begin
		sttime=anytim(tstart)
		entime=anytim(tend)
	endif else begin
		tstart=anytim(tstart,/vms,/date)+' 00:00:00'
		tend=tend+' 23:59:59.999'
		sttime=anytim(tstart)
		entime=anytim(tend)
	endelse
endif else begin
	if settime eq 1 then begin 
		tstart=anytim(closetime,/vms,/date)+' 00:00:00' ;anytim(anytim(closetime)-spansearch,/vms)
		sttime=anytim(tstart)
		tend=anytim(closetime,/vms,/date)+' 23:59:59.999' ;anytim(anytim(closetime)+spansearch,/vms)
		entime=anytim(tend)	
	endif else begin
		tstart=anytim(tstart,/vms)
		tend=anytim(tstart,/date,/vms)+' 23:59:59.999
		sttime=anytim(tstart)
		entime=anytim(tend)	
	endelse
endelse

if sttime le entime then begin

	filelist=self->listgen(tstart,tend,range=range,settime=settime)

;--<< Get rid of the blank list entries. >>

	wlist=where(filelist ne '')
	if wlist[0] ne -1 then begin
		filelist=filelist[wlist]

;--<< Get rid of the entries that are not within the correct time of day range. >>

;--> Temporary, don't filter filelist if only 1 time is specified.
;--> will cause prob if you need certain pict type. ie, find only full disk or something...
		if settime eq 1 and range eq 0 then begin
			flistfilt=filelist

		endif else flistfilt=self->filter(filelist,sttime,entime,_extra=exfilt)

;-->

		if flistfilt[0] eq '' and n_elements(flistfilt) lt 2 then return,flistfilt

	endif else begin
		print,' '
		print,'No files were found within the specified range.'
		print,' '

flistfilt=self->listcrash()
return,flistfilt
	endelse

endif else begin
	print,' '
	print,'Start time must be less than or equal to the end time.'
	print,' '

flistfilt=self->listcrash()
return,flistfilt
endelse

if n_elements(flistfilt) gt 0 then begin
	print,' '
	print,'Files were found.'
	print,' '

;--<< If the user has specified one time with a time of day, the closest time is selected. >>

	if settime eq 1 and range eq 0 then begin
		closetime=anytim(closetime)
		timearr=self->flist2tlist(flistfilt)
		mintime=abs(timearr-closetime)
		wtime=where(mintime eq min(mintime))

		if wtime[0] eq -1 then begin
			print,' '
			print,'No file found on specified day.'; within 3.5 days of the specified time'
			print,' '
flistfilt=self->listcrash()
return,flistfilt
		endif else begin
			flistfilt=flistfilt[wtime]
		endelse
	endif

endif

checkedflistfilt=self->checkfilerepeat(flistfilt)

;--<< Remember files that were listed. >>

*(self.filelist)=checkedflistfilt

file_list=checkedflistfilt
help,file_list

return, checkedflistfilt

end

;----------------------------------------------->

function SYNIMON::list_index, timerange=timerange, filelist=filelist, err=error, _extra=extra

indexarr=''

if n_elements(filelist) gt 0 then indexarr=self->sock_hread(filelist=filelist, err=error, _extra=extra) else begin
	if n_elements(timerange) gt 0 then begin
		filelist=self->list(timerange=timerange)
		indexarr=self->sock_hread(filelist=filelist, err=error, _extra=extra) 
	endif else begin
		filelist=*(self.filelist)
		timerange=self->get(/timerange)
				
		if filelist[0] ne '' then indexarr=self->sock_hread(filelist=filelist, err=error, _extra=extra)
		if error ne '' then begin
			filelist=self->list(timerange=timerange)
			if filelist[0] ne '' then indexarr=self->sock_hread(filelist=filelist, err=error, _extra=extra)
			
			if data_chk(indexarr,/type) ne 8 then print,[[' '],['No valid files were found for '+strjoin(timerange,'-')],[' ']]
		endif

	endelse

endelse

if data_chk(indexarr,/type) ne 8 then error=-1

return,indexarr

end

;----------------------------------------------->

function SYNIMON::fullpath,tstart,tend

sat_prop = *(self.sat_prop)

satspan=sat_prop.fspan

tstartarr=self->pathogen(tstart)
tendarr=self->pathogen(tend)

fstart=time2file(anytim(tstart,/vms,/date),/date)
fend=time2file(anytim(tend,/vms,/date),/date)

;---->
url=satspan.url
ftype=satspan.ftype
path=satspan.path
;---->
fspan={fstart:fstart,fend:fend,url:url,ftype:ftype,fpath:path}

return, fspan

end

;----------------------------------------------->

pro SYNIMON::cleanup



;pointerarr=	[ $
;	'self.headers', 'self.filelist', 'self.filescopied', $
;	'self.filesread', 'self.map', 'self.setstart', $
;	'self.setend', 'self.data', 'self.xrange', $
;	'self.yrange', 'self.xc', 'self.yc', 'self.dx', $
;	'self.dy', 'self.ut', 'self.obs', 'self.roll_angle', $
;	'self.roll_center', 'self.dur', 'self.xunits', $
;	'self.yunits', 'self.soho', 'self.timerange', $
;	'self.header' $
;		]

;need a way to see if the ptr is allocated.. 
;ptr_exist sees if they have data. 
;ptr_free might need them to have data...

if ptr_exist(self.headers) ne 0 then ptr_free,self.headers
if ptr_exist(self.filelist) ne 0 then ptr_free,self.filelist
if ptr_exist(self.filescopied) ne 0 then ptr_free,self.filescopied
if ptr_exist(self.filesread) ne 0 then ptr_free,self.filesread
if ptr_exist(self.map) ne 0 then ptr_free,self.map
if ptr_exist(self.setstart) ne 0 then ptr_free,self.setstart
if ptr_exist(self.setend) ne 0 then ptr_free,self.setend
if ptr_exist(self.data) ne 0 then ptr_free,self.data
if ptr_exist(self.index) ne 0 then ptr_free,self.index

;if ptr_exist(self.xrange) ne 0 then ptr_free,self.xrange
;if ptr_exist(self.yrange) ne 0 then ptr_free,self.yrange

;if ptr_exist(self.xc) ne 0 then ptr_free,self.xc
;if ptr_exist(self.yc) ne 0 then ptr_free,self.yc
;if ptr_exist(self.dx) ne 0 then ptr_free,self.dx
;if ptr_exist(self.dy) ne 0 then ptr_free,self.dy
;if ptr_exist(self.ut) ne 0 then ptr_free,self.ut

;if ptr_exist(self.obs) ne 0 then ptr_free,self.obs
;if ptr_exist(self.roll_angle) ne 0 then ptr_free,self.roll_angle
;if ptr_exist(self.roll_center) ne 0 then ptr_free,self.roll_center
;if ptr_exist(self.dur) ne 0 then ptr_free,self.dur
;if ptr_exist(self.xunits) ne 0 then ptr_free,self.xunits
;if ptr_exist(self.yunits) ne 0 then ptr_free,self.yunits
;if ptr_exist(self.soho) ne 0 then ptr_free,self.soho
;if ptr_exist(self.timerange) ne 0 then ptr_free,self.timerange
;if ptr_exist(self.header) ne 0 then ptr_free,self.header

print,' '
print,'SYNIMON cleanup complete.'
print,' '

return

end

;----------------------------------------------->

pro SYNIMON::server,status,time

fspan=self->fullpath(systim(/utc),systim(/utc))
sock_ping,fspan.url,status,time=time

if status eq 1 then begin

endif
if status eq 0 then begin
	print,' '
	print,'The server '+fspan.url+' is down.'
	print,' '
	wait,.5
endif

return

end

;----------------------------------------------->

;<<< END NON-FRAMEWORK CODE >>>

;--------------------------------------------------------------------------->

PRO SYNIMON__Define

self = {SYNIMON, headers: Ptr_New(), $
		filelist: Ptr_New(), $
		filescopied: Ptr_New(), $ 
		filesread: Ptr_New(), $
		filesall: Ptr_New(), $
		map: Ptr_New(), $
		index: Ptr_New(), $
		setstart: Ptr_New(), $
		setend: Ptr_New(), $
		plot_prop: Ptr_New(), $
		_explot: Ptr_New(), $
		sat_prop: Ptr_New(), $
		INHERITS Framework }

END

;--------------------------------------------------------------------------->