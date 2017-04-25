pro show_pix_event,event
;
;
;   Name: show_pix_event
;
;   Purpose: event driver for xshow_pix
;
;   History:
;      20-Dec-1993 (SLF) (guts of show_pix.pro, 10-Nov)
;      22-Dec-1993 (SLF) window creation logic (IDL feature workaround)
;	1-Feb-1994 (SLF) allow empty directories
;      18-Jul-1994 (SLF) if new data disply, show current UT Time 
;      22-Jul-1994 (SLF) add common block (externalize after exit)
;       7-Sep-1994 (SLF) Prepend (not append) UT TIME for new_data subdirectory
;      16-feb-1994 (SLF) enable hardcopy option
;       2-apr-1995 (slf) movie option
;      10-apr-1995 (SLF) problem with pre-existing window display
;
;
common show_pix_blk, clastfile, cimage, ctext, cr, cg, cb, cindex

widget_control,event.top,get_uvalue=top_struct
wchk=where(tag_names(top_struct) eq 'BASE')
main=wchk(0) eq 0
files=get_wuvalue(top_struct.allfiles)
subdir=get_wuvalue(top_struct.subdir)
file=get_wuvalue(top_struct.file)

case (strtrim(event_name(event),2)) of
   "BUTTON":begin                               ; option selection
      case strupcase(get_wvalue(event.id)) of
         "QUIT": begin
		widget_control, top_struct.captbase,/destroy
		widget_control, event.top,/destroy
	    endcase
         "XLOADCT": xloadct, group=event.top
	 "DELETE LAST": if !d.window ne -1 then wdelete
	 "HARDCOPY": begin
               site_copy=get_logenv('SITE_SHOWPIX_COPY')
               land=strtrim(fix(!d.x_size ge !d.y_size),2)
               if site_copy eq '' then $
                  site_copy='hardcopy,/color,/noprompt,landscape=' + land
               message,/info,"Hardcopy Command:  IDL> " + site_copy
               exestat=execute(site_copy) 
            endcase
	  "SHOW IMAGE": begin
		widget_control,top_struct.modebuts(0), 	set_uvalue=event.select
	     endcase
	  "SHOW DOCUMENTATION" : begin
		widget_control,top_struct.modebuts(1), set_uvalue=event.select
	        mapx,top_struct.captbase,show=event.select, $
		   map=event.select, sens=event.select
	     endcase
          else: message,/info,"UNKNOWN BUTTON"
       endcase
   endcase 
   "LIST": begin
      cfiles=get_wuvalue(event.id)
      subdir=get_wuvalue(top_struct.subdir)
      filen=get_wuvalue(top_struct.file)
      break_file,files,alog,apath,afiles,aext,aver
      chksub = wc_where(afiles,cfiles(0),cnt)
      case cnt of
         0: begin
	       new=wc_where(files, cfiles(event.index) + '*',cnt)
               if cnt gt 0 then uval=afiles(new) else uval=''
               widget_control, top_struct.flist, set_value=uval, $
		  set_uvalue=uval
	       widget_control,top_struct.subdir, set_uvalue=cfiles(event.index)
	    endcase
         else: begin
	          which = wc_where(afiles,cfiles(event.index),cnt)
		  modes=get_wuvalue(top_struct.modebuts)
                  if cnt gt 0 then begin
		     widget_control,top_struct.current, set_value=files(which)
		     if modes(1) then widget_control,/realize, $
			top_struct.captbase
		     widget_control,top_struct.capttext, set_value= $
			[strarr(10),'...READING IMAGE FILE, PLEASE BE PATIENT']
		     mapx,event.top,/map,/show,sensitive=0
                     clastfile=files(which(0))
		     restgen,image,r,g,b,index, nodata=1-modes(0),text=text, $
			file=files(which(0))
	             if top_struct.wantimage then begin
	                cimage=image
			ctext=text
		        case data_chk(r,/type) of
			   8:cindex=r			; index
			   0:
			   else: begin
			      cr=r			; color table
			      cg=g
			      cb=b
			      if data_chk(index,/struct) then cindex=index
			   endcase
			endcase			
                     endif
		     mapx,event.top,/map,/show,sensitive=1
		     if n_elements(text) eq 1 and text(0) eq '' then $
			text='NO CAPTION AVAILABLE'
		
		     if strpos(subdir(0),'new_data') ne -1 then $
		        text=['---------- Current UT TIME is: ' + $
			ut_time() +  ' ----------','','',text] 

		     widget_control, top_struct.capttext, set_value=text
		     if modes(0) and n_elements(image) ne 0 then begin
		        if data_chk(r,/defined) and data_chk(g,/defined) and $
				data_chk(b,/defined) then tvlct,r,g,b
			simage=size(image)
                        if n_elements(index) eq 0 then info='' else $
                           info=get_infox(index,/fmt_tim) 
                        if simage(0) eq 3 then begin
;                          make a movie (zoom if tiny) 
                          ttext=get_wvalue(top_struct.capttext)
                          widget_control,top_struct.capttext, set_value= $
		             ['','...Creating PIXMAPS for MOVIE - please be patient', $
			      '','',ttext]
	               widget_control, top_struct.capttext, set_value=ttext

                       xmovie,image, ([2,1]) (max(simage(1:2)) ge 256), $ 
			   title='show_pix movie'

                        endif else  if !d.window eq -1 or abs(!d.y_size - simage(2)) gt 10 or $
			   !d.x_size lt simage(1) then begin
                              wdef,wind,/ur,simage(1),simage(2)
         		      tv,image
			   endif else if !d.window ne -1 then tv,image				
                       				
			mapx,/show,/map,/sens,event.top
		        mapx,/show,/map,/sens,top_struct.captbase
	             endif	             
		  endif
	    endcase
      endcase
   endcase
endcase

widget_control,event.top, set_uvalue=top_struct, bad_id=destroyed

return
end

pro show_pix, image, text, r,g,b, moon=moon, merc=merc, misc=misc, base0, $
	lastfile=lastfile, index=index
;
;+
;   Name: show_pix
;
;   Purpose: dipslay processed images saved with mk_pix.pro
;
;   Calling Sequence: 
;      show_pix 
;      Widget version - file selection is intuitive now (?)
;      show_pix, lastfile=lastfile 	; return last path/filename selected
;
;   History:
;      7-Nov-1993 (SLF) Written for mercury picture display
;     10-Nov-1993 (SLF) allow r,g,b parameters, auto size window if too small
;     20-Dec-1993 (SLF) widgitized, some new features
;      4-Jan-1993 (GAL) replaced call to concat_dir with get_subdirs 
;			to correct a noted bug when run on the SGI.
;     17-Mar-1994 (SLF) use DIR_GEN_SHOWPIX if site not defined
;	                (forward/backward compatibility?)
;     13-Apr-1994 (SLF) eliminate subdirectory keywords from documentation
;     31-May-1994 (DMZ) added VMS patch
;      8-Jun-1994 (SLF) limit number files displayed (scroll function)
;     22-Jul-1994 (SLF) add LASTFILE keyword, common block show_pix_blk
;     14-sep-1994 (SLF) minor mods / protect against environmental naming ...
;      9-Nov-1994 (SLF) list files in reverse chronological order (UNIX)
;     20-dec-1994 (SLF) fix for unix shortcoming under sgi (arg list too long)
;     26-mar-1995 (slf) call get_xfont to get fixed font (allow tables)
;     12-mar-1996 (slf) combine merge show_pix_event->show_pix
;-

common show_pix_blk, clastfile, cimage, ctext, cr, cg, cb, cindex

base0=widget_base(/column,title='Show Pix', xoff=0, yoff=0)
xmenu,['QUIT','XLOADCT','Delete Last','Hardcopy'],base0, $
	buttons=main_buts,/row


base1=widget_base(/column,/frame)
mlabel=widget_label(base1,value='Display Options',/frame)
xmenu,['Show Image', 'Show Documentation'],/nonexclusive, base0, $
	buttons=mode_buts,/row, uvalue=[1,1]

case 1 of
   keyword_set(moon): selsub='moon'
   keyword_set(misc): selsub='misc'
   keyword_set(merc): selsub='merc'
   else: selsub='misc'
endcase 

case 1 of
   file_exist(get_logenv('$DIR_SITE_SHOWPIX')): pixdir=get_logenv('$DIR_SITE_SHOWPIX')
   file_exist(get_logenv('$DIR_GEN_SHOWPIX')): pixdir=get_logenv('$DIR_GEN_SHOWPIX')
   else: begin
      message,/info,"Can't find showpix area or no files 
      message,/info,"Please define DIR_GEN_SHOWPIX and/or verify files exist"
      return
   endcase
endcase   
subdirs=get_subdirs(pixdir)
; only 'bottom level' subdirectories...
subdirs=subdirs(where(str_lastpos(subdirs,'/') ne (strlen(subdirs)-1)))
break_file,subdirs,sdl,sdp,sdf,sde,sdv 


;-- VMS patch needed because last subdirectory in a path name cannot
;   be treated as a file name (although in UNIX it can) -- DMZ May'94

which=wc_where(sdf,selsub,cnt)
case strlowcase(!version.os) of
   'vms': begin
      sdf=sdp
      clook=strpos(strupcase(subdirs),strupcase(selsub))
      which=where(clook gt 0,cnt)
      allpix=file_list(get_subdirs(pixdir),'*.genx')
   endcase
   'irix': begin		; irix imposes tighter limitations on 
      allpix=''			; command string lists 
      pushd,curdir()		; save current directory
      for i=0,n_elements(sdf)-1 do begin
         newdir=concat_dir(pixdir,sdf(i))		; for each subdirectory
         cd,newdir
         spawn,['/bin/ls','-t'],genfiles,/noshell	; rev-chron listing
         which=where(strpos(genfiles,'.genx') ne -1,fcount)
         if fcount gt 0 then allpix=[allpix,concat_dir(newdir,genfiles(which))]
      endfor
      allpix=allpix(1:*)
      popd			; restore directory
   endcase
   else: begin
      spawn,'/bin/ls -t ' + concat_dir(concat_dir(pixdir,'*'),'*.genx'),allpix
   endcase
endcase

if cnt ne 0 then begin
   files=findfile(subdirs(which(cnt-1)))
endif else begin
   files=strarr(10)
endelse

break_file,allpix,apl,app,apf,apv,apf
big=max(strlen(apf))
most=max(deriv_arr(uniqo(app)))

base2=widget_base(/colum,/frame,base0)
flabel1=widget_label(base2,value='File Selection',/frame)
widget_control,set_uvalue=allpix,flabel1
base21=widget_base(/row,base2)
base21a=widget_base(/column,base21,/frame)
flabel21a=widget_label(base21a,value='Subdirectory',/frame,uvalue=sdf(which))
flist1=widget_list(base21a,value=sdf, uvalue=subdirs,ysize=n_elements(sdf))

pad=''
flab='File Name'
if big gt strlen(flab) then pad = string(replicate(32b,big/2+1))
flab=pad + flab + pad

files=str_replace(files,'.genx','')
base21b=widget_base(/column,base21,/frame)
flabel21b=widget_label(base21b,value=flab,/frame,uval='')
flist2=widget_list(base21b,value=files(0:(n_elements(files)-1)<15), $
	ysize=most < 15, uvalue=files)

base3=widget_base(base0,/column)
flabel3=widget_label(base3,value='Current File',/frame)
ftext3=widget_text(base3,value=concat_dir(pixdir,sdf(which)))

captbase=widget_base(/column,title='Image Captions',yoff=400,xoff=0)
capttext=widget_text(captbase,ysize=30,xsize=80,/scroll, $
   font=get_xfont(/fixed,closest=15,/only_one))
;widget_control,captbase,/realize, group=base0, show=0
;widget_control,captbase, sensitive=0, map=0, show=0

uval=  {base:base0,			$
	mainbuts:main_buts,		$	; Quit et all.
	modebuts:mode_buts,		$	; image / documentaiont
	allfiles:flabel1,		$	; all under dir_site_genpix
	subdir:flabel21a,		$	; current sub directory
	file: flabel21b,		$	; current file
	slist:flist1,			$	; all subdirectories
	flist: flist2,			$	; all files in this sub
	current: ftext3,		$       ; text disp of current select
	captbase:captbase,		$	; caption base
	capttext:capttext,		$       ; caption text (output)
	wantimage:n_params() gt 0	}	; 
	
clastfile=''
widget_control,mode_buts(0),/set_button
widget_control,mode_buts(1),/set_button
widget_control,set_uvalue=uval, base0
widget_control,base0,/realize
xmanager,'show_pix',base0
lastfile=clastfile				; last value from common

if uval.wantimage and n_elements(cimage) ne 0 then begin	; valuess assigen in event 
   image=cimage
   text=ctext   
   if data_chk(cr,/defined) and data_chk(cg,/defined) and data_chk(cb,/defined) then begin
      r=cr
      g=cg
      b=cb
   endif
   if data_chk(cindex,/struct) then index=cindex
endif

return
end
