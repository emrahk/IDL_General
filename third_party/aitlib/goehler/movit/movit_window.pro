;+
; NAME:
;           movit_window.pro
;
; PURPOSE:
;           show data in window, add some buttons for control.
;
; CATEGORY:
;           movit
;
; CALLING SEQUENCE:
;           movit_window, data, xsize=xsize, ysize=ysize
;
; INPUT:
;           data - data set to display. Must be 2-dim array with 4 columns,
;                  representing time, x-pos,y-pos and energy (all
;                  double).
;
; OPTIONAL INPUTS:
;           xsize, ysize - size of application window (in pixel)
;           pathname     - path to current input file
;           name_of_file - name of current input file without path and extension
;           isgri        - 1=ISGRI, 0=PICSIT
;           datatype     - type of input data (10=S1, 20=S2, 30=S3.0, 31=S3.1, 40=S4.0, 41=S4.1)
;
; KEYWORD PARAMETERS:
;
;
; OUTPUT:
;
; OPTIONAL OUTPUT:
;
; SIDE EFFECTS:
;
;
; MODIFICATION HISTORY:
; $Log: movit_window.pro,v $
; Revision 1.10  2002/12/09 09:25:13  barnsted
; - produce text files to be imported into Ecxel
;   from the time interval selected for movies
; - time interval remains valid even if new
;   FITS file is loaded
;
; Revision 1.9  2002/11/28 13:46:29  barnsted
; - movies: GIFs and MPEG (selectable)
; - adjust image size and display image after start
; - size problem corrected
; - buttons rearranged
;
; Revision 1.8  2002/11/27 16:40:23  barnsted
; - automatic detector selection from FITS header
; - production of MPEG movies instead of GIF images
;
; Revision 1.7  2002/11/26 16:50:49  barnsted
; - buttons rearranged
; - new button: select new file
;
; Revision 1.6  2002/11/25 17:01:56  barnsted
; - plot window fits plot area
; - movie production working
; - file selection dialog if no FITS-file suplied
; - color table selection button
;
; Revision 1.5  2002/11/22 16:45:17  barnsted
; added: buttons to define and extract single GIF-images
; (this version produces just one GIF image)
;
; Revision 1.4  2002/11/21 15:06:17  goehler
; save/multi options
;
; Revision 1.3  2002/11/20 10:50:41  goehler
; - printint
; - fine time
; - no remove of first time
; -> really nice
;
; Revision 1.2  2002/11/20 07:56:18  goehler
; added energy option
;
; Revision 1.1  2002/11/19 17:33:22  goehler
; initial integral event viewer
;
;-


;; ------------------------------------------------------------
;; DRAWING ROUTINE
;; ------------------------------------------------------------



;; find value with binary search:
FUNCTION binsearch, data, val
    left = 0
    right = n_elements(data)-1
    mid = (left+right)/2
    WHILE (left LE right) AND (data[mid] NE val) DO BEGIN
        mid = (left+right)/2
;        print,left,mid,right
        IF data[mid] GT val THEN right = mid-1 ELSE left = mid+1
    ENDWHILE
    return, mid
END



PRO MOVIT_WINDOW_TV, env, erase=erase, printfile=printfile


    ;; -> select relevant data:
;    t = (*env.data)[*,0]

;    left_t = binsearch(t,env.time)
;    right_t = binsearch(t,env.time+env.dt)


    left_index = 0 > ((env.index+env.granularindex)  < ((size(*env.data,/dimensions))[0]-1L))
    right_index = 0 > ((env.index+env.granularindex + env.int ) < ((size(*env.data,/dimensions))[0]-1L))

    d = (*env.data)[left_index:right_index,*]



    ;; get window to plot onto
    widget_control, env.drawID, get_value=winID
    wset,winID


    ;; erase screen if desired
    IF keyword_set(erase) THEN erase


    ;; print if file given
    IF n_elements(printfile) NE 0 THEN open_print,printfile,/postscript,/color



    ;; select multiple events only
    IF env.multi THEN BEGIN

        shifted_data = d[1:n_elements(d[*,0])-1,*]

        ;; pixel equal
        index = where(d[*,1] EQ shifted_data[*,1] AND d[*,2] EQ shifted_data[*,2])

        IF index[0] NE -1 THEN BEGIN
            d = d[index,*]

            ;; show value
            movit_tv, d,$
              offset=env.offset, gain=env.gain, pixel=env.pixel, energy=env.energy, size=env.image_width
        ENDIF

    ENDIF  ELSE BEGIN

        ;; show value
        movit_tv, d,$
          offset=env.offset, gain=env.gain, pixel=env.pixel, energy=env.energy, size=env.image_width

    ENDELSE


    ;; print time into pic
    xyouts,0.,0.08,"Time: "+strtrim(string((*env.data)[left_index],$
           format="(F20.5)"),2),/normal,color=255

    ;; print filename into pic
    xyouts,0.,0.02,*env.name_of_file,/normal,color=255

    ;; close print file
    IF n_elements(printfile) NE 0 THEN close_print

    ;; show time value:
    widget_control, env.timelabelID, set_value=$
      " Time: "+strtrim(string((*env.data)[left_index],format="(F20.5)"),2)

    ;; update slider position:
    widget_control,env.timesliderID, $
      set_value=long(env.index*10000.D0/(size(*env.data,/dimensions))[0])

END







;; ------------------------------------------------------------
;; MOUSEEVENT --- EVENT PROCEDURE OF A MOUSE CLICK
;; ------------------------------------------------------------

PRO movit_window_mouseevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env

    ;; get window ID to draw at:
    widget_control,env.drawID, get_value=winID
    wset,winID


    ;; get type+position:
    event_type = ev.type
    coord = Convert_Coord(ev.x, ev.y, /Device, /To_Normal)
    x = coord[0]
    y = coord[1]

    ;; define set/unset state:
    selectit = (ev.release EQ 1)


    ;; -----------------------------
    ;; EVENT: button pressed:
    IF event_type EQ 0 THEN BEGIN

    ENDIF

    ;; -----------------------------
    ;; EVENT: button released:
    IF event_type EQ 1 THEN BEGIN

        ;; START ACTION:
        ;; --------------------------------------------------------
        ;; MARK SELECTED:



        ;; END ACTION:
        ;; --------------------------------------------------------

    ENDIF ;; mouse up event


    ;; -----------------------------
    ;; EVENT: mouse moved
    IF event_type EQ 2 THEN BEGIN


    ENDIF


    ;; -----------------------------
    ;; update label positions:
    ;; -----------------------------

    ;; define position
    mousepos=Convert_Coord(ev.x, ev.y, /Device, /To_Data)

    ;; set values:
    widget_control,env.xlabelID,set_value=$
      " X Pos: "+strtrim(string(mousepos[0]*env.image_width),2)

    widget_control,env.ylabelID,set_value=$
      " Y Pos: "+strtrim(string(mousepos[1]*env.image_width),2)
END



;; ------------------------------------------------------------
;; SLIDEREVENTS --- EVENT PROCEDURES WHEN  SLIDER MOVED
;; ------------------------------------------------------------

;; change time:
PRO movit_window_slidertimeevent, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env


    ;; is this a timer event? -> restart timer with new time
    IF (TAG_NAMES(ev, /STRUCTURE_NAME) EQ 'WIDGET_TIMER') THEN BEGIN

        IF env.timer THEN WIDGET_CONTROL, ev.id, TIMER=0.1

				;; stop if limit reached
        IF ((env.back AND (env.index - env.int) LE 0L) OR $
            (NOT env.back AND ((env.index + env.int) GE ((size(*env.data,/dimensions))[0]-1L)))) THEN env.timer=0

        ;; timer forward/backward:
        IF env.back THEN  env.index = (env.index - env.int) > 0L $
        ELSE              env.index = (env.index + env.int) < ((size(*env.data,/dimensions))[0]-1L)

    ENDIF ELSE BEGIN

        ;; not a timer event but slider -> extract position:

        ;; get value:
        widget_control,ev.id, get_value=pos

        ;; compute new time index:
        env.index = 0L > long((size(*env.data,/dimensions))[0] / 10000.D0 * pos) < ((size(*env.data,/dimensions))[0]-1L)

    ENDELSE

    ;; show
    movit_window_tv, env

		;; produce movie: save single image, stop if end index reached
		IF (env.movie_flag) THEN BEGIN

				;; read image
				img=tvrd()

				;; write single GIF image
				IF (env.gif_flag) THEN BEGIN
						env.gif_frame = env.gif_frame + 1
						imgfilename=(*env.path)+(*env.name_of_file)+"__movieimg"+strtrim(string(env.movie_img_index,format="(I3.3)"),2) $
						                                                    +"_"+strtrim(string(env.gif_frame,format="(I3.3)"),2)+".gif"

						IF (env.gif_frame EQ 1) THEN BEGIN
						    ;; look for non-existing file:
						    WHILE file_exist(img_filename) DO BEGIN
						    		env.movie_img_index = env.movie_img_index + 1
										imgfilename=(*env.path)+(*env.name_of_file)+"__movieimg"+strtrim(string(env.movie_img_index,format="(I3.3)"),2) $
										                                                    +"_"+strtrim(string(env.gif_frame,format="(I3.3)"),2)+".gif"
						    ENDWHILE
						ENDIF

						write_gif, imgfilename, img
				ENDIF

				;; write MPEG video frame
				IF (env.mpeg_flag) THEN BEGIN
						img=rotate(img,7)  ; mirror y-direction
						FOR i=1,env.mpeg_repeat DO BEGIN
								MPEG_PUT, *env.mpegID, IMAGE=img, FRAME=env.mpeg_frame
								env.mpeg_frame = env.mpeg_frame + 1
						ENDFOR
				ENDIF

				;; end time reached: stop it
        IF (env.index ge env.movie_stop_time) THEN BEGIN
						env.timer = 0
						env.movie_flag = 0

						IF (env.gif_flag) THEN BEGIN
								print,"***  Written:"
								print,imgfilename
		        ENDIF

						;; save MPEG video
						IF (env.mpeg_flag) THEN BEGIN
								mpeg_filename=(*env.path)+(*env.name_of_file)+"__movie"+strtrim(string(env.movie_img_index,format="(I3.3)"),2)+".mpg"


						    ;; look for non-existing file:
						    WHILE file_exist(mpeg_filename) DO BEGIN
						    		env.movie_img_index = env.movie_img_index + 1
										mpeg_filename=(*env.path)+(*env.name_of_file)+"__movie"+strtrim(string(env.movie_img_index,format="(I3.3)"),2)+".mpg"
						    ENDWHILE


								print, "***  Saving MPEG video...   --- wait ---
								MPEG_SAVE, *env.mpegID, FILENAME=mpeg_filename
								MPEG_CLOSE, *env.mpegID
								print,"***  Written:"
								print,mpeg_filename
		        ENDIF
        ENDIF
		ENDIF

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env
END



;; change time:
PRO movit_window_slidergranulartimeevent, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; not a timer event but slider -> extract position:

    ;; get value:
    widget_control,ev.id, get_value=pos

    ;; compute new granular time index:
    env.granularindex = env.int * long((pos - 5000.D0) / 5000.D0)

    ;; show
    movit_window_tv, env

    ;; print granular time value:
    widget_control,env.granulartimelabelID,set_value=$
      " Fine Time: "+strtrim(string(env.granularindex),2)

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env
END




;; change integration time:
PRO movit_window_sliderdtevent, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; get value:
    widget_control,ev.id, get_value=pos

    ;; compute new time:
    env.int = pos

    ;; show
    movit_window_tv, env

    ;; print time value:
    widget_control,env.dtlabelID,set_value=$
      " Integrate: "+strtrim(string(env.int),2)


    ;; push back environment:
    widget_control, ev.top, set_uvalue=env
END





;; change offset:
PRO movit_window_slideroffsetevent, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; get value:
    widget_control,ev.id, get_value=pos

    ;; compute new time:
    env.offset = pos - 10

    ;; show
    movit_window_tv, env

    ;; print time value:
    widget_control,env.offsetlabelID,set_value=$
      " Offset: "+strtrim(string(env.offset,format="(I)"),2)


    ;; push back environment:
    widget_control, ev.top, set_uvalue=env
END


;; change gain:
PRO movit_window_slidergainevent, ev, gain=gain

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; get value:
    widget_control,ev.id, get_value=pos

    ;; compute new time:
    env.gain = pos

    ;; show
    movit_window_tv, env

    ;; print time value:
    widget_control,env.gainlabelID,set_value=$
      " Gain: "+strtrim(string(env.gain,format="(I)"),2)


    ;; push back environment:
    widget_control, ev.top, set_uvalue=env
END


;; ------------------------------------------------------------
;; PIXELBUTTONSEVENT --- EVENT FUNCTION WHEN PIXEL BUTTON CHANGED
;; ------------------------------------------------------------

function movit_window_pixelbuttonsevent, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; get value:
    widget_control,ev.id, get_value=pix

    ;; compute new pixel size:
    CASE pix OF
        0 : env.pixel = 1
        1 : env.pixel = 2
        2 : env.pixel = 4
        3 : env.pixel = 8
    ENDCASE

    ;; update window size
    Widget_Control, env.drawID,      $
      Draw_XSize=env.pixel*env.image_width, Draw_YSize=env.pixel*env.image_width

    ;; show
    movit_window_tv, env,/erase

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env

    return, 0
END


;; -----------------------------------------------------------
;; IMAGEWIDTHEVENT --- EVENT FUNCTION WHEN IMAGE WIDTH CHANGED
;; -----------------------------------------------------------

FUNCTION movit_window_imagewidthevent, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; get value:
    widget_control,ev.id, get_value=wid

    ;; compute new image width:
    CASE wid OF
        0 : env.image_width = 64
        1 : env.image_width = 128
    ENDCASE

    ;; update window size
    Widget_Control, env.drawID,      $
      Draw_XSize=env.pixel*env.image_width, Draw_YSize=env.pixel*env.image_width

    ;; show
    movit_window_tv, env,/erase

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env

    return, 0
END


;; ------------------------------------------------------------
;; RESIZEEVENT --- EVENT PROCEDURE WHEN RESIZE OCCURS
;; ------------------------------------------------------------

PRO movit_window_resizeevent, ev

    ;; get environment:
    widget_control,ev.top,get_uvalue=env

    IF ev.id EQ env.mainID THEN BEGIN


        ;; update window size (with hard coded button sizes(?):
        Widget_Control, env.drawID,      $
          Draw_XSize=ev.x, Draw_YSize=((ev.y -220) > 220)

        Widget_Control,env.timesliderID, XSize=ev.x/2
    ENDIF

    ;; redraw:
    movit_window_tv,env, /erase

END



;; ------------------------------------------------------------
;; BUTTON EVENTS --- EVENT PROCEDURES WHEN  BUTTON PRESSED
;; ------------------------------------------------------------


;; stop application
PRO movit_window_exitevent, ev

    ;; close application:
    widget_control, ev.top, /destroy

END


;; start backward timer button
PRO movit_window_backevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env


    env.timer = 1
    env.back = 1

    ;; start timer
    widget_control,env.timesliderID, timer=0.1

    ;; set new environment:
    widget_control, ev.top, set_uvalue=env
END


;; step forward button
PRO movit_window_nextstepevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env

    env.index = (env.index + env.int ) < ((size(*env.data,/dimensions))[0]-1L)

    ;; redraw:
    movit_window_tv,env

    ;; set new environment:
    widget_control, ev.top, set_uvalue=env
END




;; step backward button
PRO movit_window_backstepevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env

    env.index = env.index - env.int > 0L

    ;; redraw:
    movit_window_tv,env

    ;; set new environment:
    widget_control, ev.top, set_uvalue=env
END


;; step small forward button
PRO movit_window_snextstepevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env

    env.index = (env.index + env.int/10 ) < ((size(*env.data,/dimensions))[0]-1L)

    ;; redraw:
    movit_window_tv,env

    ;; set new environment:
    widget_control, ev.top, set_uvalue=env
END




;; step small backward button
PRO movit_window_sbackstepevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env

    env.index = env.index - env.int/10 > 0L

    ;; redraw:
    movit_window_tv,env

    ;; set new environment:
    widget_control, ev.top, set_uvalue=env
END



;; start timer button
PRO movit_window_startevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env


    env.timer = 1
    env.back  = 0

    ;; start timer
    widget_control,env.timesliderID, timer=0.1

    ;; set new environment:
    widget_control, ev.top, set_uvalue=env
END


;; stop timer button
PRO movit_window_stopevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env


    env.timer = 0

    ;; set new environment:
    widget_control, ev.top, set_uvalue=env
END


 ;; print button
PRO movit_window_printevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env

    printfile = "movit_plot_"
    i = 0

    ;; look for non-existing file:
    WHILE file_exist(printfile+strtrim(string(i),2)+".ps") DO i = i+1

    printfilename = printfile+strtrim(string(i),2)+".ps"

    movit_window_tv,env, printfile=printfilename

END


 ;; save button
PRO movit_window_saveevent, ev

    ;; get environment:
    widget_control, ev.top, get_uvalue=env


		;;; --- old version ---
    ;printfile = "movit_save_"
    ;i = 0
		;
    ;;; look for non-existing file:
    ;WHILE file_exist(printfile+strtrim(string(i),2)+".txt") DO i = i+1
		;
    ;savefilename = printfile+strtrim(string(i),2)+".txt"
		;
    ;;; index of ranges:
    ;left_index = 0 > ((env.index+env.granularindex)  $
    ;                  < ((size(*env.data,/dimensions))[0]-1L))
    ;right_index = 0 > ((env.index+env.granularindex + env.int )$
    ;                   < ((size(*env.data,/dimensions))[0]-1L))
		;
		;
    ;;; write to file:
    ;get_lun,f
    ;openw, f, savefilename
    ;print, "Time[sec]","Y","Z","Energy[~5keV]", format="(A20,A4,A4,A15)"
    ;print, transpose((*env.data)[left_index:right_index,*]),$
    ;  format="(F20.10,I4,I4,F15.2)"
    ;close,f
    ;free_lun,f
		;;; --- old version end ---



		save_filename=(*env.path)+(*env.name_of_file)+"__save"+strtrim(string(env.movie_img_index,format="(I3.3)"),2)+".txt"


    ;; look for non-existing file:
    WHILE file_exist(save_filename) DO BEGIN
    		env.movie_img_index = env.movie_img_index + 1
				save_filename=(*env.path)+(*env.name_of_file)+"__save"+strtrim(string(env.movie_img_index,format="(I3.3)"),2)+".txt"
    ENDWHILE

		print, "Writing to"
		print, save_filename

    get_lun,f
    openw, f, save_filename, width=999

		printf, f, '"GCAL_TIME";"PICSIT_Y";"PICSIT_Z";"PICSIT_PHA";"ISGRI_Y";"ISGRI_Z";"ISGRI_PHA";"RISE_TIME";"CAL_FLAG";"TYPE"'

		FOR i = env.movie_start_time, env.movie_stop_time DO BEGIN
			CASE env.datatype OF
				10:	BEGIN
							printf, f, (*env.data)[i,0],'; ; ; ; ',(*env.data)[i,1],'; ',(*env.data)[i,2],'; ',(*env.data)[i,3],'; ',(*env.data)[i,4],'; 0;"S1"'
						END

				20:	BEGIN
							printf, f, (*env.data)[i,0],'; ; ; ; ',(*env.data)[i,1],'; ',(*env.data)[i,2],'; ',(*env.data)[i,3],'; ',(*env.data)[i,4],'; 1;"S2"'
						END

				30:	BEGIN
							printf, f, (*env.data)[i,0],'; ',(*env.data)[i,1],'; ',(*env.data)[i,2],'; ',(*env.data)[i,3],'; ',(*env.data)[i,4],'; ',(*env.data)[i,5],'; ',(*env.data)[i,6],'; ',(*env.data)[i,7],'; ',(*env.data)[i,8],';"S3.0"'
						END

				31:	BEGIN
							printf, f, (*env.data)[i,0],'; ',(*env.data)[i,1],'; ',(*env.data)[i,2],'; ',(*env.data)[i,3],'; ',(*env.data)[i,4],'; ',(*env.data)[i,5],'; ',(*env.data)[i,6],'; ',(*env.data)[i,7],'; ',(*env.data)[i,8],';"S3.1"'
						END

				40:	BEGIN
							printf, f, (*env.data)[i,0],'; ',(*env.data)[i,1],'; ',(*env.data)[i,2],'; ',(*env.data)[i,3],'; ; ; ; ; ;"S4.0"'
						END

				41:	BEGIN
							printf, f, (*env.data)[i,0],'; ',(*env.data)[i,1],'; ',(*env.data)[i,2],'; ',(*env.data)[i,3],'; ; ; ; ; ;"S4.1"'
						END

				ELSE:
			ENDCASE
		ENDFOR


    close,f
    free_lun,f

		print, "***  done  ***"

END



  ;; file button  JB 26.11.02
PRO movit_window_file_event, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

		filename = dialog_pickfile(/read,/noconfirm,   $
				title = "Select FITS-File",                $
				path = *env.path,                          $
				file = *env.name_of_file+".fits",          $
				get_path = pathname,                       $
				filter="*.fits")

		IF (filename ne "") THEN BEGIN
				print, "Filename : "+filename
				name_of_file=remove_path_and_ext(filename)

				;; release heap memory
				ptr_free, env.data, env.path, env.name_of_file

        ;; read new file
				data = movit_read_fits(filename=filename, extension=extension, columns=columns, isgri=isgri, multi=multi, datatype=datatype)

				;; set image width accordingly
				widget_control, LONG(env.widthbaseID), set_value=isgri

		    ;; compute new image width:
		    CASE isgri OF
		        0 : BEGIN
		        			env.image_width = 64
		        			pix = 2
		        		END
		        1 : BEGIN
		        			env.image_width = 128
		        			pix = 1
		        		END
		    ENDCASE

		    ;; set pixel zoom value:
		    widget_control, LONG(env.pixelbaseID), set_value=pix

		    ;; compute new pixel size:
		    CASE pix OF
		        0 : env.pixel = 1
		        1 : env.pixel = 2
		        2 : env.pixel = 4
		        3 : env.pixel = 8
		    ENDCASE

		    ;; update window size
		    Widget_Control, env.drawID,      $
		      Draw_XSize=env.pixel*env.image_width, Draw_YSize=env.pixel*env.image_width


				env.index = 0
				env.data = PTR_NEW(data)
				env.path = PTR_NEW(pathname)
				env.name_of_file = PTR_NEW(name_of_file)
				env.datatype = datatype

		    ;; show
		    movit_window_tv, env,/erase

				;; set new path as default
				cd, pathname

				;; determine start index and stop index for same movie time interval
				env.movie_start_time = index_of_time (*env.data, env.start_time)
				env.movie_stop_time = index_of_time (*env.data, env.stop_time)

		ENDIF

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env
END



  ;; start time button  JB 22.11.02
PRO movit_window_start_time_event, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; set movie start time to current time index
    env.movie_start_time = env.index
    env.start_time=(*env.data)[env.index,0]

    ;; show start time value:
    widget_control, env.startlabelID, set_value=$
      "Movie start time: "+strtrim(string(env.start_time,format="(F20.5)"),2)

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env

END



  ;; stop time button  JB 22.11.02
PRO movit_window_stop_time_event, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; set movie stop time to current time index
    env.movie_stop_time = env.index
    env.stop_time = (*env.data)[env.index,0]

    ;; show stop time value:
    widget_control, env.stoplabelID, set_value=$
      "Movie stop time : "+strtrim(string(env.stop_time,format="(F20.5)"),2)

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env
END



  ;; make movie button  JB 22.11.02
PRO movit_window_movie_event, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env


    env.timer = 1
    env.back  = 0
    env.movie_flag = 1

		dimensions=[env.pixel*env.image_width, env.pixel*env.image_width]
		mpegID = MPEG_OPEN(dimensions)
		env.mpegID = PTR_NEW(mpegID)

		;; next movie no.
		env.movie_img_index = env.movie_img_index + 1

		;; start with frame no. 0
		env.mpeg_frame = 0
		env.gif_frame  = 0

    ;; set start time index
    env.index = env.movie_start_time


    ;; start timer
    widget_control,env.timesliderID, timer=0.1

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env

		print, "***  Producing movie...  --- wait ---"
END



  ;; color button  JB 25.11.02
PRO movit_window_color_event, ev

  xloadct

END


;; select another type of displayed data
function movit_window_optionbuttonsevent, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; get value:
    widget_control,ev.id, get_value=options


    ;; set according options:
    env.energy = options[0]
    env.multi  = options[1]

    ;; show
    movit_window_tv, env,/erase

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env

    return, 0
END


;; select movie type
function movit_window_movieoptionsevent, ev

    ;; get environment:
    widget_control,ev.top, get_uvalue=env

    ;; get value:
    widget_control,ev.id, get_value=options


    ;; set according options:
    env.gif_flag  = options[0]
    env.mpeg_flag = options[1]

    ;; push back environment:
    widget_control, ev.top, set_uvalue=env

    return, 0
END


;; ------------------------------------------------------------
;; MOVIT_WINDOW --- MAIN PROCEDURE
;; ------------------------------------------------------------
PRO  movit_window, data, xsize=xsize, ysize=ysize, pathname=pathname, name_of_file=name_of_file, isgri=isgri, datatype=datatype

  ;; ------------------------------------------------------------
  ;; SETUP
  ;; ------------------------------------------------------------

  IF N_Elements(pathname) EQ 0 THEN pathname=""
  IF N_Elements(name_of_file) EQ 0 THEN name_of_file=""

  ;; get former window ID
  default_winID = !D.window

  ;; ------------------------------------------------------------
  ;; ENVIRONMENT RECORD
  ;; ------------------------------------------------------------

  ;; contains all information needed to draw current data:
  env = {envrecord,       $
         data             : PTR_NEW(data), $         ; data to display
         mainID           : 0,    $      ; ID of main window
         drawID           : 0,    $      ; ID of draw window
         controlframeID   : 0,    $      ; ID of control frame window
         buttonframeID    : 0,    $      ; ID of control frame window
         buttonframe2ID   : 0,    $      ; ID of control frame window 2
         buttonframe3ID   : 0,    $      ; ID of control frame window 3
         sliderframeID    : 0,    $      ; ID of slider frame window
         sliderbaseID     : 0,    $      ; ID of slider frame window
         timesliderID     : 0, $         ; ID of slider window
         xlabelID         : 0,    $      ; ID of x pos label
         ylabelID         : 0,    $      ; ID of y pos label
         timelabelID      : 0, $         ; ID of time label
         granulartimelabelID: 0, $       ; ID of granular time label
         dtlabelID        : 0,   $       ; ID of time label
         offsetlabelID    : 0,   $       ; ID of offset label
         gainlabelID      : 0,   $       ; ID of gain label
         timer            : 0 ,  $       ; flag if timer on
         back             : 0 ,  $       ; flag if timer backward on
         index            : 0L,  $       ; current time index to start with
         granularindex    : 0L,  $       ; current granular time index
         int              : 1000L, $     ; number of events to integrate
         offset           : 0.D0,  $     ; display offset (added to counts)
         gain             : 10.D0, $     ; display gain   (counts are multiplied with)
         energy           : 0,     $     ; show energy?
         multi            : 0,     $     ; select multiple pixel
         pixel            : 4,     $     ; pixel size to display
         movie_start_time : 0L,    $     ; time index to start movie images  JB 22.11.02
         movie_stop_time  : 0L,    $     ; time index to stop movie images   JB 22.11.02
         movie_flag       : 0,     $     ; flag if movie is being produced   JB 22.11.02
         movie_img_index  : 0,     $     ; index of current movie image      JB 22.11.02
         startlabelID     : 0L,    $     ; ID of movie start time label      JB 22.11.02
         stoplabelID      : 0L,    $     ; ID of movie stop time label       JB 22.11.02
         image_width      : 64,    $     ; number of pixels of image width   JB 26.11.02
         path             : PTR_NEW(pathname), $ ; path of current data file JB 26.11.02
         name_of_file     : PTR_NEW(name_of_file), $ ; filename w/o path     JB 27.11.02
         widthbaseID      : 0L,    $     ; ID of image width options         JB 27.11.02
         pixelbaseID      : 0L,    $     ; ID of pixel size options          JB 27.11.02
         mpegID           : PTR_NEW(), $ ; ID of current MPEG animation      JB 27.11.02
         mpeg_frame       : 0,     $     ; current MPEG frame no.            JB 27.11.02
         mpeg_repeat      : 10,    $     ; repetition rate of MPEG frames    JB 27.11.02
         gif_frame        : 0,     $     ; current GIF frame no.             JB 28.11.02
         gif_flag         : 0,     $     ; make GIF movie                    JB 28.11.02
         mpeg_flag        : 0,     $     ; make MPEG movie                   JB 28.11.02
         datatype         : 40,    $     ; type of input data (10,20,...)    JB 02.12.02
         start_time       : 0.D0,  $     ; movie start time in [s]           JB 02.12.02
         stop_time        : 0.D0   $     ; movie stop time in [s]            JB 02.12.02
        }

  IF N_Elements(isgri) EQ 0 THEN isgri=0

  ;; compute image width for current detector:
  CASE isgri OF
  		;; PICSIT:
      0 : BEGIN
      			env.image_width = 64
      			pix = 2
      		END

      ;; ISGRI:
      1 : BEGIN
      			env.image_width = 128
      			pix = 1
      		END
  ENDCASE

  ;; compute new pixel size:
  CASE pix OF
      0 : env.pixel = 1
      1 : env.pixel = 2
      2 : env.pixel = 4
      3 : env.pixel = 8
  ENDCASE


  ;; define default x/y size of plot window (pixel)
  IF N_Elements(xsize) EQ 0 THEN xsize = env.pixel*env.image_width
  IF N_Elements(ysize) EQ 0 THEN ysize = env.pixel*env.image_width


	env.datatype = datatype

  ;; ------------------------------------------------------------
  ;; CREATE BASE WIDGETS
  ;; ------------------------------------------------------------

  mainwID = widget_base(title="MOVIT",/column,/tlb_size_events)

  drawID  = widget_draw(mainwID, xsize=xsize, ysize=ysize,$
                        /button_events, /motion_events,   $
                        event_pro="movit_window_mouseevent")

  ;; save the draw ID -> wee need it for plotting

  env.mainID = mainwID
  env.drawID = drawID


  ;; ------------------------------------------------------------
  ;;  WIDGET ALLOCATION
  ;; ------------------------------------------------------------

  env.controlframeID  = widget_base(mainwID, /column)

  env.buttonframeID   = widget_base(env.controlframeID, /row, frame=1)

  env.buttonframe2ID  = widget_base(env.controlframeID, /row, frame=1)

  env.buttonframe3ID  = widget_base(env.controlframeID, /row, frame=1)

  env.sliderframeID   = widget_base(env.controlframeID, /row, frame=1)


  env.sliderbaseID    = widget_base(env.sliderframeID, /column, frame=1)

  slidertextID        = widget_base(env.sliderframeID, /column)





  ;; ------------------------------------------------------------
  ;; CREATE SLIDER
  ;; ------------------------------------------------------------

  env.timesliderID=widget_slider(env.sliderbaseID, $
                          event_PRO="movit_window_slidertimeevent",$
                          maximum=10000, $
                          minimum=0, $
                          value=0,/suppress_value)


  granulartimesliderID=widget_slider(env.sliderbaseID, $
                          event_PRO="movit_window_slidergranulartimeevent",$
                          maximum=10000, $
                          minimum=0, $
                          value=5000,/suppress_value,/drag)


  dtsliderID=widget_slider(env.sliderbaseID, $
                          event_PRO="movit_window_sliderdtevent",$
                          maximum=10000, $
                          minimum=10, $
                          value=env.int,/suppress_value,/drag)

  offsetID=widget_slider(env.sliderbaseID, $
                          event_PRO="movit_window_slideroffsetevent",$
                          maximum=10, $
                          minimum=0, $
                          value=env.offset+10,/suppress_value,/drag)


  gainID=widget_slider(env.sliderbaseID, $
                          event_PRO="movit_window_slidergainevent",$
                          maximum=200, $
                          minimum=1, $
                          value=env.gain,/suppress_value,/drag)


  ;; ------------------------------------------------------------
  ;; CREATE SLIDER TEXTS
  ;; ------------------------------------------------------------

  env.timelabelID   = widget_label(slidertextID,/align_left, $
                            value=" Time:                           ")

  env.granulartimelabelID   = widget_label(slidertextID,/align_left, $
                            value=" Fine Time: "+strtrim(string(env.granularindex),2))

  env.dtlabelID   = widget_label(slidertextID,/align_left, $
                            value=" Integrate: "+strtrim(string(env.int),2))

  env.offsetlabelID   = widget_label(slidertextID,/align_left, $
                            value=" Offset: "+strtrim(string(env.offset,format="(I)"),2))

  env.gainlabelID   = widget_label(slidertextID,/align_left, $
                            value=" Gain: "+strtrim(string(env.gain,format="(I)"),2))


  labelID = widget_label(slidertextID, value=" ")



  ;; ------------------------------------------------------------
  ;; CREATE PIXEL SELECTION BUTTONS
  ;; ------------------------------------------------------------

  labelID     = widget_label(env.sliderbaseID,/align_left, $
                            value=" Image zoom factor:")
  env.pixelbaseID = cw_bgroup(env.sliderbaseID,['1','2','4','8'],/exclusive,/row,set_value=pix,$
                          event_func="movit_window_pixelbuttonsevent")


  labelID     = widget_label(env.sliderbaseID,/align_left, $
                            value=" Image pixel width:")
  env.widthbaseID = cw_bgroup(env.sliderbaseID,['64','128'],/exclusive,/row,set_value=isgri,$
                          event_func="movit_window_imagewidthevent")


  ;; ------------------------------------------------------------
  ;; CREATE BUTTONS, 1st row
  ;; ------------------------------------------------------------


  ;; back timer
  buttonID = widget_button(env.buttonframeID, value="<|",$
                               event_pro="movit_window_backevent")

  ;; back step
  buttonID = widget_button(env.buttonframeID, value="<-",$
                               event_pro="movit_window_backstepevent")


  ;; small back step
  startbuttonID = widget_button(env.buttonframeID, value="<",$
                               event_pro="movit_window_sbackstepevent")

  ;; stop timer
  stopbuttonID = widget_button(env.buttonframeID, value="Stop",$
                               event_pro="movit_window_stopevent")

  ;; small forward step
  buttonID = widget_button(env.buttonframeID, value=">",$
                               event_pro="movit_window_snextstepevent")

  ;; forward step
  buttonID = widget_button(env.buttonframeID, value="->",$
                               event_pro="movit_window_nextstepevent")

  ;; start timer
  buttonID = widget_button(env.buttonframeID, value="|>",$
                               event_pro="movit_window_startevent")


  buttonID = widget_label(env.buttonframeID, value="   ")

  optionsID     = cw_bgroup(env.buttonframeID,['Energy','Multiple']$
                            ,/row,/nonexclusive,                   $
                            event_func="movit_window_optionbuttonsevent")


  ;; ------------------------------------------------------------
  ;; CREATE BUTTONS, 2nd row
  ;; ------------------------------------------------------------


  ;; file button -> read new file  JB 26.11.02
  buttonID = widget_button(env.buttonframe2ID, value="File",$
                               event_pro="movit_window_file_event")


  buttonID = widget_label(env.buttonframe2ID, value="   ")

  ;; show color selection  JB 25.11.02
  buttonID = widget_button(env.buttonframe2ID, value="Color",$
                               event_pro="movit_window_color_event")

  buttonID = widget_label(env.buttonframe2ID, value="   ")

    ;; print timer
  buttonID = widget_button(env.buttonframe2ID, value="Print",$
                               event_pro="movit_window_printevent")

  buttonID = widget_label(env.buttonframe2ID, value="   ")

  ;; save button -> save current events as ascii
  buttonID = widget_button(env.buttonframe2ID, value="Save",$
                               event_pro="movit_window_saveevent")

  buttonID = widget_label(env.buttonframe2ID, value="   ")

  ;; here defined event procedure -> EXIT MUST EXIST:
  exitbuttonID = widget_button(env.buttonframe2ID, value="Exit",$
                               event_pro="movit_window_exitevent")

  ;; ------------------------------------------------------------
  ;; CREATE BUTTONS, 3rd row
  ;; ------------------------------------------------------------


  ;; start time button -> set movie start time  JB 22.11.02
  buttonID = widget_button(env.buttonframe3ID, value="Start time",$
                               event_pro="movit_window_start_time_event")


  ;; stop time button -> set movie stop time  JB 22.11.02
  buttonID = widget_button(env.buttonframe3ID, value="Stop time",$
                               event_pro="movit_window_stop_time_event")


  ;; make movie button -> start making movie  JB 22.11.02
  buttonID = widget_button(env.buttonframe3ID, value="Movie",$
                               event_pro="movit_window_movie_event")


  buttonID = widget_label(env.buttonframe3ID, value="   ")


  optionsID     = cw_bgroup(env.buttonframe3ID,['GIF','MPEG']$
                            ,/row,/nonexclusive,                   $
                            event_func="movit_window_movieoptionsevent")

  ;; ------------------------------------------------------------
  ;; CREATE POSITION LABELS
  ;; ------------------------------------------------------------

  ;; label field:

  labelframeID     = widget_base(slidertextID, /column, /align_left)

  env.xlabelID     = widget_label(labelframeID, /align_left,$
                            value="X Pos:                 ")
  env.ylabelID     = widget_label(labelframeID,/align_left,$
                            value="Y Pos:                 ")


  env.startlabelID = widget_label(labelframeID, /align_left,$
                            value="Movie start time:                           ")
  env.stoplabelID  = widget_label(labelframeID, /align_left,$
                            value="Movie stop time :                           ")



  ;; ------------------------------------------------------------
  ;; PERFORM WIDGET INIT STUFF
  ;; ------------------------------------------------------------


  ;; make environment public:
  widget_control,mainwID, set_uvalue=env

  ;; display it:
  widget_control,mainwID,/realize

  ;; show
  movit_window_tv, env

  xmanager,"movit_window", mainwID, event_handler="movit_window_resizeevent"
  ;; restore default window ID:


END


