; =========================================================================
;+
; Project     : SOLAR MONITOR
;
; Name        : SOLMON_CONFIG__DEFINE
;
; Purpose     : Define a SOLAR MONITOR instrument configuration object
;
; Category    : Ancillary Synoptic Objects
;
; Syntax      : IDL> solmon=obj_new('solmon_config')
;
; History     : Written 11-Jul-2007, Paul Higgins, (ARG/TCD)
;               Beta Version 12-Jul-2007, Paul Higgins, (ARG/TCD)
;                  --Added SOLMON_CONFIG::DATA_PROCESS
;				Edit 6-Nov-2008, Paul Higgins, (ARG/TCD)
;				   --Changed XRT bit in SOLMON_CONFIG::DATA_PROCESS to use external proc.
;				Edit 26-Jan-2009, Paul Higgins, (ARG/TCD)
;				   --Changed XRT bit in SOLMON_CONFIG::DATA_PROCESS to use internal proc.
;
; Contact     : P.A. Higgins: pohuigin {at} gmail {dot} com
;               P. Gallagher: peter.gallagher {at} tcd {dot} ie
;-
; =========================================================================

;-------------------------------------------------------------------->

FUNCTION solmon_config::INIT

self.use_config = ptr_new(/allocate)

;--<< CHANGE THIS VALUE TO 1 FOR THIS CONFIG FILE TO BE USED OR 0 TO TURN IT OFF. >>
*(self.use_config) = 1

return,1
end

;-------------------------------------------------------------------->

PRO solmon_config::config,instrument=instrument,filter=filter,sat_prop,filter_prop

if keyword_set(instrument) then begin

;--<< BEGIN INSTRUMENT DEFINITIONS >>

;--<< HMI PROPERTIES >>

	if instrument eq 'hmi' then begin
		filter_prop=''
		
		sat_prop={explot:{grid:1,center:1,drange:1}, $
		plot_prop:{grid:15,center:[0,0],drange:[-1000,1000]}, $
		fspan:{url:'http://www.solarmonitor.org', $
			ftype:'*_fd_*.fts*', $
			path:['/data/','insert','/fits/shmi']}, $
		xstd:4050,ystd:4050,loadct:0,hasfilter:0,unisize:1,arch_type:2}
	endif


;--<< XRT PROPERTIES >>

	if instrument eq 'xrt' then begin
		filter_prop=''
	
		sat_prop={explot:{log:1,grid:1,center:1,drange:''}, $
		plot_prop:{log:1,grid:15,center:[0,0],drange:['','']}, $
		fspan:{url:'http://www.solarmonitor.org',ftype:'*_fd_*.fts*',path:['/data/','insert','/fits/hxrt']}, $
		xstd:2100,ystd:2100,loadct:3,hasfilter:0,unisize:1,arch_type:2}
	endif

;--<< GONG PROPERTIES >>

	if instrument eq 'gong' then begin
		filter_prop=''
	
		sat_prop={explot:{log:'',grid:1,center:1,drange:1}, $
		plot_prop:{log:'',grid:15,center:[0,0],drange:[-100,100]}, $
		fspan:{url:'http://www.solarmonitor.org',ftype:'*_fd_*.fts*',path:['/data/','insert','/fits/gong']}, $
		xstd:1100,ystd:1100,loadct:0,hasfilter:0,unisize:0,arch_type:2}
	endif
	
;--<< NSOGONG PROPERTIES >>

	if instrument eq 'nsogong' then begin
		filter_prop=''
	
		sat_prop={explot:{dmin:1,dmax:1,log:'',grid:1,center:1}, $
		plot_prop:{dmin:-200,dmax:200,log:'',grid:15,center:[0,0]}, $
		fspan:{url:'http://gong.nso.edu',ftype:'bb*.fits*',path:['/Daily_Images/bb/fits/','insert','']}, $
		xstd:1100,ystd:1100,loadct:0,hasfilter:0,unisize:0,arch_type:2}
	endif

;--<< BBSO PROPERTIES >>

	if instrument eq 'bbso' then begin
		filter_prop=''
		
		sat_prop={explot:{log:'',grid:1,center:1}, $
		plot_prop:{log:'',grid:15,center:[0,0]}, $
		fspan:{url:'http://www.solarmonitor.org',ftype:'*_fd_*.fts*',path:['/data/','insert','/fits/bbso']}, $
		xstd:2100,ystd:2100,loadct:3,hasfilter:0,unisize:0,arch_type:2}
	endif

;--<< SXI PROPERTIES >>

	if instrument eq 'sxi' then begin
		filter_prop=''

		sat_prop={explot:{log:1,grid:1,center:1}, $
		plot_prop:{log:1,grid:15,center:[0,0]}, $
		fspan:{url:'http://www.solarmonitor.org',ftype:'*_fd_*.fts*',path:['/data/','insert','/fits/gsxi']}, $
		xstd:1100,ystd:1100,loadct:3,hasfilter:0,unisize:0,arch_type:2}
	endif

;--<< EIT PROPERTIES >>

	if instrument eq 'eit' then begin
		filter_prop={f195:['8','195',''],f171:['1','171',''],f304:['3','304',''],f284:['3','284','']}
	
		sat_prop={explot:{log:1,grid:1,center:1}, $
		plot_prop:{log:1,grid:15,center:[0,0]}, $
		fspan:{url:'http://www.solarmonitor.org', $
			ftype:['*','insert', '*_fd_','*.fts*'], $
			path:['/data/','insert','/fits/seit']}, $
		xstd:1100,ystd:1100,loadct:8,hasfilter:1,def_filt:'195',unisize:1,arch_type:2}
	endif
	
;--<< MDI PROPERTIES >>

	if instrument eq 'mdi' then begin
		filter_prop={fmaglc:['0','maglc',''],figram:['1','igram','']}
		
		sat_prop={explot:{grid:1,center:1}, $
		plot_prop:{grid:15,center:[0,0]}, $
		fspan:{url:'http://www.solarmonitor.org', $
			ftype:['*','insert','*_fd_','*.fts*'], $
			path:['/data/','insert','/fits/smdi']}, $
		xstd:1100,ystd:1100,loadct:0,hasfilter:1,def_filt:'maglc',unisize:1,arch_type:2}
	endif
	
;--<< GRIANMDI PROPERTIES >>

	if instrument eq 'grianmdi' then begin
		filter_prop={fmaglc:['0','maglc',''],figram:['1','igram','']}
		
		sat_prop={explot:{grid:1,center:1}, $
		plot_prop:{grid:15,center:[0,0]}, $
		fspan:{url:'', $
			ftype:['*','insert','*_fd_','*.fts*'], $
			path:['~/Sites/data/','insert','/fits/smdi']}, $
		xstd:1100,ystd:1100,loadct:0,hasfilter:1,def_filt:'maglc',unisize:1,arch_type:0}
	endif
	
;--<< ARCHMDI PROPERTIES >>

	if instrument eq 'archmdi' then begin
		filter_prop={fmaglc:['0','fd','/mdi_mag'],figram:['1','int','/mdi_int']}
	
		sat_prop={explot:{dmin:1,dmax:1,grid:1,center:1}, $
		plot_prop:{dmin:-200,dmax:200,grid:15,center:[0,0]}, $
		fspan:{url:'http://solarmonitor.org', $
			ftype:['*_','insert','_*.fits'], $
			path:'insert'}, $
		xstd:1100,ystd:1100,loadct:0,hasfilter:1,def_filt:'maglc',unisize:1,arch_type:1}
	endif
	
;--<< TRACE PROPERTIES >>

	if instrument eq 'trace' then begin
		filter_prop=''
	
		sat_prop={explot:{log:1,grid:1,center:1}, $
		plot_prop:{log:1,grid:15,center:[0,0]}, $
		fspan:{url:'http://www.solarmonitor.org',ftype:'*_fd_*.fts*',path:['/data/','insert','/fits/trce']}, $
		xstd:1100,ystd:1100,loadct:8,hasfilter:0,unisize:0,arch_type:2}
	endif

;--<< DEIT PROPERTIES >>


	if instrument eq 'deit' then begin
		filter_prop={f195:['8','195',''],f171:['1','171',''],f304:['3','304',''],f284:['8','284','']}
	
		sat_prop={explot:{log:1,grid:1,center:1}, $
		plot_prop:{log:1,grid:15,center:[0,0]}, $
		fspan:{url:'', $
			ftype:['*','insert','*_fd_','*.fts*'], $
			path:['~/data/eit']}, $
		xstd:1100,ystd:1100,loadct:0,hasfilter:1,def_filt:'195',unisize:0,arch_type:0}
	endif
	
;--<< DXRT PROPERTIES >>

	if instrument eq 'dxrt' then begin
		filter_prop=''
	
		sat_prop={explot:{log:1,grid:1,center:1}, $
		plot_prop:{log:1,grid:15,center:[0,0]}, $
		fspan:{url:'',ftype:'*.fits',path:'~/data/xrt'}, $
		xstd:2100,ystd:2100,loadct:3,hasfilter:0,unisize:0,arch_type:0}
	endif
	
;--<< DDXRT PROPERTIES >>

	if instrument eq 'ddxrt' then begin
		filter_prop=''
	
		sat_prop={explot:{log:1,grid:1,center:1}, $
		plot_prop:{log:1,grid:15,center:[0,0]}, $
		fspan:{url:'',ftype:'*.fits',path:''}, $
		xstd:2100,ystd:2100,loadct:3,hasfilter:0,unisize:0,arch_type:0}
	endif
	
;--<< DMDI PROPERTIES >>

	if instrument eq 'dmdi' then begin
		filter_prop={fmaglc:['0','fd',''],figram:['1','int','']}

		sat_prop={explot:{dmin:1,dmax:1,grid:1,center:1}, $
		plot_prop:{dmin:-300,dmax:300,grid:15,center:[0,0]}, $
		fspan:{url:'', $
		ftype:['*_','insert','_*0.fits*'],path:'~/idl/solarmonitor'}, $
		xstd:1100,ystd:1100,loadct:0,hasfilter:1,def_filt:'maglc',unisize:1,arch_type:0}
	endif

;--<< DEITTEMP PROPERTIES >>

	if instrument eq 'deittemp' then begin
		filter_prop=''

		sat_prop={explot:{dmin:1,center:1}, $
		plot_prop:{dmin:900000,center:[0,0]}, $
		fspan:{url:'', $
		ftype:['solmon_eit_temp*.fits'],path:'~/idl/solarmonitor'}, $
		xstd:1100,ystd:1100,loadct:0,hasfilter:0,unisize:1,arch_type:0}
	endif

;--<< END INSTRUMENT DEFINITIONS >>

endif

print,' '
print,'Configuration Complete.'
print,' '

return
end

;----------------------------------------------->

function solmon_config::data_process,maparr

for i=0,n_elements(maparr)-1 do begin
	map=maparr[i]
	data=map.data

;--<< Process MDI-MAGLC >>
	if self->get(/instrument) eq 'mdi' and self->get(/filter) eq 'maglc' then begin

		data=data > (-100.) < 100.

	endif
;--<< >>

;--<< Process MDI-IGRAM >>
	if self->get(/instrument) eq 'mdi' and self->get(/filter) eq 'igram' then begin

;		data=YOUR_FAVORITE_PROCESS(data)

	endif
;--<< >>

;--<< Process DMDI-IGRAM >>
	if self->get(/instrument) eq 'dmdi' and self->get(/filter) eq 'igram' then begin

	endif
;--<< >>

;--<< Process EIT-284 >>
	if self->get(/instrument) eq 'eit' and self->get(/filter) eq '284' then begin

		;meandata=mean(data[where(data gt 0)])
		data=exp(data^(.25)) > 0. < 10.
		
		eit_colors,284

	endif
;--<< >>

;--<< Process XRT >>
	if self->get(/instrument) eq 'xrt' then begin

		data=data > 1.
		xoff=10
		yoff=-15
		map.xc=map.xc+xoff
		map.yc=map.yc+yoff

;		map2index,map,index
;		retval=xrt_kludge_pointing(index)
;		index2map,retval,map.data,newmap
		
;		map=newmap

	endif
;--<< >>

	map.data=data
	maparr[i]=map
endfor

maparr_process=maparr

return,maparr_process

end

;----------------------------------------------->

function solmon_config::alterpath,fpath

;--<< Alter NSOGONG >>
if self->get(/instrument) eq 'nsogong' then begin
		
	npath=n_elements(fpath)
	for i=0,npath-1 do begin
		thisfpath=fpath[i]
		thispath=str_sep(fpath[i],'/')
		thisdate=thispath[n_elements(thispath)-1]
		thispath[n_elements(thispath)-1]=time2file(file2time(thisdate),/date,/year2digit)
		fpath[i]=strjoin(thispath,'/')
	endfor
	
endif
;--<< >>

fpathnew=fpath

return, fpathnew

end

;----------------------------------------------->

function solmon_config::movie_process,dataset ;DEFUNCT!!!!

;--<< Process DEITTEMP >>
if self->get(/instrument) eq 'deittemp' then begin
	
	dataset=dataset > 900000

endif
;--<< >>

dataset_process=dataset

return,dataset_process

end

;----------------------------------------------->

PRO solmon_config__Define

self = {solmon_config, use_config: ptr_new()}

END

;----------------------------------------------->