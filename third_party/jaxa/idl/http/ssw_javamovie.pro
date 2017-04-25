pro ssw_javamovie, image_files, applet, $
   _extra=_extra, anisurl=anisurl , movie_dir=movie_dir, $
   outsize=outsize, add_controls=add_controls, debug=debug, enhance=enhance, $
   labels=labels
;
;+
;   Name: ssw_javamovie
;
;   Purpose: ssw interface to AniS applet for java animations
;
;   Input Parameters:
;      image_files - list of gif or jpeg  files to include in animation
;                    or an ascii file containing the graphics file names
;   
;   Output Parameters:
;      applet - the implied html/applet for inclusion in an html document
;
;   Calling Sequence:
;      IDL> ssw_javamovie,filelist,applet [,controls=...],[PARAM=VALUE]
;      IDL> ssw_javamovie,file_of_filenames,applet [,controls=...],[PARAM=VALUE]
;
;   Calling Examples:
;      IDL> ssw_javamovie,gifs,applet,rate=240 ; defaults+framerate=24F/sec
;      IDL> ssw_javamovie,file_of_filenames,applet ; use FILE_OF_FILENAMES
;
;      IDL> ssw_javamovie,list1,app,/ROCKING,/USE_CACHE ; keyword inherit->AniS
;
;   Context Example:
;      IDL> html_doc,'new.html',/header         ; init an html document
;      IDL> ssw_javamovie,giflist1,app1         ; make 1 java "movie"
;      IDL> ssw_javamovie,giflist2,app2         ; make another java movie
;      IDL> file_append,'new.html',[app1,app2]  ; movie applet -> html doc
;      IDL> html_dc,'new.html',/trailer         ; terminate html doc
;
;   Keyword Parameters:
;    _extra - any PARAM names accepted by AniS 
;     add_controls - take the defaults -PLUS- these (comma delimited list)
;     enhance (switch) - if set, add ENHANCE to default bottom_controls
;     [SEE http://www.ssec.wisc.edu/visit/AniS/anisdoc.html ]
;     controls - desired subset of controls to include
;                STARTSTOP,LOOPROCK,STEP,FIRSTLAST,SPEED,SHOW,ENHANCE,
;                REFRESH,AUTO_TOGGLE,TOGGLE,ROTATOR,SETFRAME,ZOOM,FADER,
;                OVERLAY,OVERLAY_RADIO,FRAMELABEL,AUDIO
;     bottom_controls - same list as controls, but theses go on bottom of AniS window
;     labels - string array of labels -or- SSW compatible times ("index")
;
;     use_progress_bar - 
;     active_zoom 
;     keep_zoom 
;     overlay_zoom
;     use_caching
;     auto_refresh - #minutes
;     base_static
;     start_looping - (initial loop state, def=true)
;     start_frame - (frame to display after loading) 
;     rate - frames/sec*10 (120->12 frames/sec)
;     minimum_dwell - min dwell set wit speed slider (milliseconds, default=30)
;     dwell_rates - optional interframe dwell, vector 1:1 w/nframes
;     rocking - make rocking/swing mode the startup loop mode
;     pause - optional pause after last frame (milliseconds, def=0)
;     fade - generate intermediate fade sequence
;     fade_label
; 
;     anisurl - local url (ie, same machine as graphics files) where you have
;             copies of AniS class&jar files use this to avoid propagating
;             AniS copies to implied output directory (ie, path image_files) 
;     
;     History:
;     21-mar-2006 - S.L.Freeland
;     22-mar-2006 - S.L.Freeland enable file_of_filenames, booleans 
;     28-mar-2006 - S.L.Freeland Add WindowsXX tweaks, movie /ENHANCE
;                   to bottom_controls, image_window_size + limit to defaults 
;
;     Restrictions:
;        overlays and portals not yet implemented while I work the $;
;        AniS/SSW logistics using this basal version
;        The ENHANCE option looks very useful, but as of today, only
;        the supplied file is invoked as a "placeholder" - since that
;        was developed for terrestial weather applications.....
;      
;        WINDOWS - for today at least, the input graphics files must
;        reside on the same disk as the SSW distribution - 
;        This is a trivial limitation easily fixed by someone more
;        facile at MS/DOS -                         
;
;    Notes: this is a memory only routine; generates an applet for 
;    insertion in an htmldoc - see CONTEXT EXAMPLE above.
;    User may explicitly supply CONTROLS and/or BOTTOM_CONTROLS - otherwise,
;    a set of defaults will be invoked - Current defaults
;-
debug=keyword_set(debug)

if n_params() lt 2 then begin 
   box_message,'IDL> ssw_javamovie, graphicsfiles, outputappet [OPTIONS]
   return
endif

break_file,image_files(0),ll,topdir,tff,text
graphics=is_member(text,'.png,.gif,.jpeg')
if topdir(0) eq '' then topdir=curdir()

; Is input filelist -or- a file of filenames?
fof=n_elements(image_files) eq 1 and file_exist(image_files(0)) $
   and (1-graphics) ; file of names??

if fof then gfiles=rd_tfile(image_files(0),nocom='#') else gfiles=image_files 

break_file,gfiles,ll,gdir,gff,gext,gver
case n_elements(outsize) of
   0: begin 
         tfile=image_files(0)
         if fof then begin 
            tfile=concat_dir(topdir,(rd_tfile(tfile,nocom='#'))(0))
            if not file_exist(tfile) then begin
              box_message,'Cant test image size.. assigning default HxW
              nx=512
              ny=512
            endif
         endif   
         if n_elements(nx) eq 0 then begin 
            test=read_image(tfile)
            nx=data_chk(test,/nx)
            ny=data_chk(test,/ny)
            if data_chk(test,/nimage) gt 1 then begin 
               nx=ny
               ny=data_chk(test,/nimage)
            endif
         endif
   endcase
   1: begin
         nx=outsize(0)
         ny=nx
   endcase
   else: begin 
      nx=outsize(0)
      ny=outsize(1)
   endcase
endcase 

nx=nx<1024  ; need to think about IMAGE_WINDOW_SIZE autoing...
ny=ny<1024

anisjar='aniscode.jar'

mdirjar=concat_dir(topdir,anisjar)
ssw_anis=concat_dir(concat_dir(concat_dir('$SSW','gen'),'java'),'anis')
ssw_jar=concat_dir(ssw_anis,anisjar)
ssw_enh=concat_dir(ssw_anis,'enh.tab') ; ENHANCE file (to be extended...)

if not file_exist(mdirjar) then begin 
   if file_exist(ssw_jar) then begin 
      box_message,'Copying SSW anisjar -> movie_dir...  ; TODO MS/DOS equiv!
      case os_family() of 
         'Windows': begin
             spawn,'copy ' + ssw_jar + ' ' + topdir
             spawn,'copy ' + ssw_enh + ' ' + topdir
         endcase
         else: begin 
            spawn,['cp',ssw_jar,topdir],/noshell
            spawn,['cp',ssw_enh,topdir],/noshell
         endcase
      endcase
   endif else begin 
      box_message,'Cannot find AniS in SSW distribution??'
      return
   endelse
endif 
 

defcontrols=str2arr('startstop,refresh,speed,zoom,looprock')
if data_chk(add_controls,/string) then $            
   defcontrols=[defcontrols,str2arr(add_controls)]

case 1 of
   data_chk(labels,/string): labs=labels ; user verbatim
   n_elements(labels) ne 0: labs=anytim(labels,/ecs,/trunc) ; assume ssw time
   else:
endcase


retval='<applet archive="aniscode.jar" code="AniS.class" ' +  $
   'height='+strtrim(nx+50,2) +  ' width='+strtrim(ny+50,2)+'>'
if fof then begin 
   break_file,image_files(0),ll,pp,ff,ee,vv
   retval=[retval,'<param name="file_of_filenames" value="' + ff+ee +'">'] 
endif else $
   retval=[retval,'<param name="filenames" value="'+arr2str(gff+gext)+'">']
pnames=''
bool=str2arr('false,true')
bparams=str2arr('use_progress_bar,active_zoom,keep_zoom,use_caching,rocking')

; Handle Keyword Inherit -> PARAM=VALUE
if data_chk(_extra,/struct) then begin 
   parr=strarr(n_tags(_extra))
   pnames=strlowcase(tag_names(_extra))
   for i=0,n_tags(_extra)-1 do begin 
      vali=strtrim(_extra.(i),2)
      if is_member(pnames(i),bparams) then vali=(bool)(vali eq '1') ; switch
      case 1 of
         data_chk(vali,/scalar,/string): val=vali
         data_chk(vali,/string): val=arr2str(vali)
         n_elements(vali) gt 0: val=arr2str(vali)
         else: val=vali
      endcase 
      parr(i)='<param name="'+pnames(i)+'" value="' + val + '">' 
   endfor
endif

ssc=where(strpos(strlowcase(pnames),'controls') ne -1,ccnt)
defbottom='step,toggle'
if keyword_set(enhance) then defbottom='enhance,'+defbottom
if keyword_set(labs) then defbottom='framelabel,'+defbottom
if ccnt eq 0 then pnames=$
   ['<param name="controls" value="' + arr2str(defcontrols)+'">', $
   '<param name="bottom_controls" value="'+defbottom+'">']
if data_chk(parr,/string) then pnames=[pnames,parr]
ssiw=where(strpos(pnames,'image_window_size') ne -1,iwcnt)
if iwcnt eq 0 then pnames =  [temporary(pnames), $
      '<param name="image_window_size"  value="' + $
      arr2str([nx,ny]<1024,/trim) + '">']
ssl=where(strpos(pnames,'frame_label"') ne -1,flcnt)
if n_elements(labs) gt 0  and flcnt eq 0 then begin 
   pnames=[temporary(pnames), $
    '<param name="frame_label" value="' + arr2str(labs) + '">']
   if (where(strpos(pnames,'frame_label_width')))(0) eq 0 then $
      pnames=[temporary(pnames),'<param name="frame_label_width" value="' + $
         strtrim(max(strlen(labs)),2) + '">']
endif

applet=[retval,pnames,'</applet>']
      
if debug then stop, 'pre return..' 
return
end 
