pro ssw_track_demo, time0, time1, title=title, $
	   ref_map=ref_map, hours=hours, waves=waves, _extra=_extra
;+
;   Name: ssw_track_demo
;
;   Purpose: make level1 EIT movies for WWW, demo some SSW/EIT SW.
;
;   History:
;      8-Nov-1998 - S.L.Freeland - string together some common EIT/SSW stuff
;                   (based on mk_lasteit_movie, trace_special_movie, etc)  
;  
;   Input Parameters:
;      time0, time1 - time range of interest
;
;   Keyword Parameters:
;      ref_map - (optional) a map (per DMZ) of reduced FOV to track  
;                [if not supplied, user selection of FOV 1st wavelen]
;      hours   - desired movie cadence
;      waves   - optional set of waves (default is all=[171,195,284,304]  )
;      _extra  - other keywords passed via inheritance to special_movie.  
;
;   Calls:
;      EIT   > eit_files, read_eit, eit_prep, eit_colors
;      Solar > ssw_track_fov (diff_rot, index2map, plot_map, rot_xy...)
;      Movie > special_movie (image2movie, mkthumb, jsmovie...)
;      HTML  > html_doc, strtab2html, str2html, mkthumb
;      Time  > grid_data, file2time (anytim)
;      Util  > file_append, sobel_scale, concat_dir, box_message, data_chk
;-
dtemp=!d.name                                    ; save current device

if n_params() lt 2 then begin
   box_message,['Need start time & stop time','IDL> ssw_track_demo,t0,t1']
   return
endif  

; --------- set options, inc. cadence and wavelenths ----------
if n_elements(hours) eq 0 then hours=12                     ; cadence hours
if n_elements(waves) eq 0 then waves=str2arr('171,195,284,304')
swaves=strtrim(waves,2)
movie_dir=concat_dir('$path_http','movies')
if not data_chk(movie_name,/string) then movie_name='ssw_movie'

; -------- initialize HTML array inc. user title if supplied ---------
if not data_chk(title,/string) then title='EIT Observations'
allhtml='<h1>'+title+'</h1>'                               ; accumulate html


; ------------- MOVIE LOOP ----------------------
for i=0,n_elements(swaves)-1 do begin                      ; for each waveleng

;  ------- find / read / prep / scale EIT for wavelen(i) -
   eitfiles=eit_files(time0,time1,wave=waves(i),/full)    ; get eit file names
   ss=grid_data(file2time(eitfiles,out='int'),hour=hours) ; grid to cadence
   read_eit,eitfiles(ss), eitindex, eitdata               ; read the data
   eit_prep,eitindex,data=eitdata,outind,outdat           ; prep (l0->l1)

   sdata=sobel_scale(outind,outdat, minper=5, hi=1500)    ; scale data for WWW

;  ---- identify, helio/diff track , and extract a solar feature ----------
   ssw_track_fov, outind, sdata, tindex, tdata, ref_map=ref_map, interact=(n_elements(ref_map) eq 0)

;  setup colors
   set_plot,'z'                                                ; use Z buffer
   eit_colors,fix(swaves(i)), r , g , b                        ; get an rgb
   stretch,0,255,.85
   tvlct,r,g,b,/get
   
;  Make Movies (mpeg/gif-animate/javascript - thumbnails and html)   
   special_movie, tindex, tdata, r,g,b, /no_html_doc, html=html, $
       movie_name=movie_name+'_' + swaves(i), movie_dir=movie_dir, $
       _extra=_extra, thumbsize=128

;  add html for THIS  movie to output html
   allhtml=[allhtml,"<h4>Wavelength: " + swaves(i) + "&#197", html]
endfor   
; -------------- END OF MOVIE LOOP ---------------------------------

; --------------- make the html document --------------
hdoc=concat_dir(movie_dir,'ssw_track_demo.html')              ; name it
html_doc,hdoc,/header                                         ; header
file_append,hdoc,allhtml                                      ; append html   
html_doc,hdoc,/trailer                                        ; trailer
; --------------------------------------------------------
set_plot,dtemp
end
