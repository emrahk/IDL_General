;+
; NAME:
;       movit
;
;
;
; PURPOSE:
;       Interactive event view tool for IBIS/INTEGRAL
;
;
; CALLING SEQUENCE:
;       movit, filename, extension=extension
;
;
;
; INPUTS:
;      Fits file name for file containing events to display.
;
;
;
;
; OPTIONAL INPUTS:
;      extension - Fits extension to use. Default: 1.
;      columns   - string array with column names for time, x, y,
;                  energy. Default:
;                  ["GCAL_TIME","PICSIT_Y","PICSIT_Z","PICSIT_PHA"]
;
;
; KEYWORD PARAMETERS:
;      isgri     - read isgri data file
;      multi     - select multiple events in a single pixel
;
;
;
; OUTPUTS:
;       Displays event movies.
;
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
;
;
; COMMON BLOCKS:
;       Beware!
;
;
;
;
; SIDE EFFECTS:
;       None. If not crashing.
;
;
;
;
; RESTRICTIONS:
;       Data must fit into memory.
;
;
; PROCEDURE:
;       Starting with a event file opens a window from which all
;       events will be displayed in frames. Via button it is possible
;       to move between data.
;
; EXAMPLE:
;       movit,"S1.fits"
;
; DISCLAIMER:
;       This environment was built at the Institute for
;       Astronomy and Astrophysic Tuebingen (IAAT),
;       http://astro.uni-tuebingen.de).
;       Design, structure and basic commands are
;       created by Eckart Goehler, 2002.
;
;       The software may be copied and distributed for free
;       following the terms of the free software foundation.
;
; MODIFICATION HISTORY:
;       $Log: movit.pro,v $
;       Revision 1.8  2002/12/09 09:25:13  barnsted
;       - produce text files to be imported into Ecxel
;         from the time interval selected for movies
;       - time interval remains valid even if new
;         FITS file is loaded
;
;       Revision 1.7  2002/11/28 13:46:29  barnsted
;       - movies: GIFs and MPEG (selectable)
;       - adjust image size and display image after start
;       - size problem corrected
;       - buttons rearranged
;
;       Revision 1.6  2002/11/27 16:40:23  barnsted
;       - automatic detector selection from FITS header
;       - production of MPEG movies instead of GIF images
;
;       Revision 1.5  2002/11/26 16:50:49  barnsted
;       - buttons rearranged
;       - new button: select new file
;
;       Revision 1.4  2002/11/25 17:01:56  barnsted
;       - plot window fits plot area
;       - movie production working
;       - file selection dialog if no FITS-file suplied
;       - color table selection button
;
;       Revision 1.3  2002/11/21 15:06:16  goehler
;       save/multi options
;
;       Revision 1.2  2002/11/20 07:56:18  goehler
;       added energy option
;
;       Revision 1.1  2002/11/19 17:33:22  goehler
;       initial integral event viewer
;
;
;-

;; determine data index of given time value
FUNCTION index_of_time, data, timeval
		n = size(data)
		maxindex = n[1]-1

    index1 = 0
    index2 = maxindex
		old_index3 = -1

		;; nested intervals:
		WHILE (index1 NE index2) DO BEGIN
				index3=floor((index1+index2)/2)
				if(index3 EQ old_index3) THEN return, index3

				time3 = data[index3,0]
				IF (time3 EQ timeval) THEN return, index3

				IF (time3 LT timeval) THEN index1 = index3 $
				ELSE                       index2 = index3

				old_index3 = index3

		ENDWHILE

		return, index1
END


;; remove path and extension from filename
FUNCTION remove_path_and_ext, filename

	; select operating system
  CASE !VERSION.OS_FAMILY OF
			"MacOS"   : path_delim="/"
			"unix"    : path_delim="/"
			"vms"     : path_delim="/"
			"Windows" : path_delim="\"
	ENDCASE

  ; remove path
  pos = RSTRPOS(filename, path_delim) > 0
  result = STRMID (filename, pos+1)

	; remove extension
	pos = RSTRPOS(result, ".")
	IF (pos GT 0) THEN result =  STRMID (result, 0, pos)

	return, result
END


;; determine detector from fits header
FUNCTION select_detector, header, columns, datatype

  	n = size(header)

		IF (n[0] NE 1) THEN return, -1    ; not a 1-dimensional array
		IF (n[2] NE 7) THEN return, -1	  ; not a string array


		;FOR i=0,n[1]-1 DO BEGIN
		;		IF (STRPOS(header[i],"ISGRI_" ) GT 0) THEN return, 1   ; ISGRI  = 1
		;		IF (STRPOS(header[i],"PICSIT_") GT 0) THEN return, 0   ; PICSIT = 0
		;ENDFOR


		;; look for type of data
		result = SXPAR(header, "DATADESC")

		CASE result OF
				'ISGRI PPM':            BEGIN          ; S1
				                          isgri=1
				                          datatype=10
														      columns = ["GCAL_TIME","ISGRI_Y","ISGRI_Z","ISGRI_PHA","RISE_TIME"]
															  END

				'ISGRI Calibration':    BEGIN          ; S2
				                          isgri=1
				                          datatype=20
														      columns = ["GCAL_TIME","ISGRI_Y","ISGRI_Z","ISGRI_PHA","RISE_TIME"]
															  END

				'Compton single ':      BEGIN          ; S3.0
				                          isgri=0
				                          datatype=30
														      columns = ["GCAL_TIME","PICSIT_Y","PICSIT_Z","PICSIT_PHA","ISGRI_Y","ISGRI_Z","ISGRI_PHA","RISE_TIME","CAL_FLAG"]
															  END

				'Compton multiple':     BEGIN          ; S3.1
				                          isgri=0
				                          datatype=31
														      columns = ["GCAL_TIME","PICSIT_Y","PICSIT_Z","PICSIT_PHA","ISGRI_Y","ISGRI_Z","ISGRI_PHA","RISE_TIME","CAL_FLAG"]
															  END

				'PICSIT PPM single':    BEGIN          ; S4.0
				                          isgri=0
				                          datatype=40
														      columns = ["GCAL_TIME","PICSIT_Y","PICSIT_Z","PICSIT_PHA"]
															  END

				'PICSIT PPM mult.':     BEGIN          ; S4.1
				                          isgri=0
				                          datatype=41
														      columns = ["GCAL_TIME","PICSIT_Y","PICSIT_Z","PICSIT_PHA"]
															  END

		ELSE:                       return, -1
		ENDCASE

END


;; read events from fits file into data structure
FUNCTION movit_read_fits, filename=filename, extension=extension, columns=columns, isgri=isgri, multi=multi, datatype=datatype

    IF n_elements(extension) EQ 0 THEN extension=1


    IF n_elements(filename) NE 0 THEN BEGIN

        ;; printout header:
				header=headfits(filename, exten=extension)
				hprint, header

				;; look for number of rows
				result = SXPAR(header, "NAXIS2")
				IF (result LE 0) THEN BEGIN
						print, "***  No data in FITS file!  ***"
						isgri = 0
						datatype = 10
						return, indgen(100,4)
				ENDIF


				;; select detector from fits header:
				IF (n_elements(isgri) EQ 0) THEN isgri=select_detector(header,columns,datatype)
				IF (isgri LT 0) THEN BEGIN
						print, "***  No detector found in FITS header!  ***"
						return, indgen(100,4)
				ENDIF

		    ;; set columns for isgri default:

		    ;; set columns for picsit default:
		    IF n_elements(columns) EQ 0 THEN BEGIN
			    IF (isgri) THEN columns = ["GCAL_TIME","ISGRI_Y","ISGRI_Z","ISGRI_PHA"] $
			    ELSE            columns = ["GCAL_TIME","PICSIT_Y","PICSIT_Z","PICSIT_PHA"]
				ENDIF


        tcol = columns[0]       ; time column
        xcol = columns[1]       ; x column
        ycol = columns[2]       ; y column
        ecol = columns[3]       ; energy column


        ;; read data:
        print, " "
        print, "***  reading ...   --- please wait ---"
        ftab_ext,filename,xcol,xpos,exten_no=extension
        ftab_ext,filename,ycol,ypos,exten_no=extension
        ftab_ext,filename,tcol,time,exten_no=extension
        ftab_ext,filename,ecol,energy,exten_no=extension

        ;; build array containing all data to display:
        data = [[time],[xpos],[ypos],[energy]]

				i=4
				WHILE (i LT n_elements(columns)) DO BEGIN
						ftab_ext,filename,columns[i],col,exten_no=extension
						data=[[data],[col]]
						i=i+1
				ENDWHILE

        print, "***  done  ***

    ENDIF  ELSE data = indgen(100,4)


    ;; ------------------------------------------------------------
    ;; SELECT MULTIPLE EVENTS
    ;; ------------------------------------------------------------

    IF keyword_set(multi) THEN BEGIN

        shifted_data = data[1:n_elements(data[*,0])-1,*]

        ;; pixel equal
        index = where(data[*,1] EQ shifted_data[*,1] AND data[*,2] EQ shifted_data[*,2])

        data = data[index,*]

    ENDIF

		return, data
END



PRO movit, filename=filename, extension=extension, columns=columns, isgri=isgri, multi=multi


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------


    IF n_elements(filename) EQ 0 THEN BEGIN
				filename = dialog_pickfile(/read,/noconfirm,   $
						title = "Select FITS-File",                $
						get_path = pathname,                       $
						filter="*.fits")
				print, "Filename : "+filename

				;; set new path as default
				cd, pathname

    ENDIF


    ;; ------------------------------------------------------------
    ;; GREETINGS
    ;; ------------------------------------------------------------

    PRINT, "          THIS IS MOVIT - Moving frames of incoming events"
    PRINT, "                          IAAT, 2002"


    ;; ------------------------------------------------------------
    ;; LOAD EVENTS FROM FITS FILE
    ;; ------------------------------------------------------------


		data = movit_read_fits(filename=filename, extension=extension, columns=columns, isgri=isgri, multi=multi, datatype=datatype)



    ;; ------------------------------------------------------------
    ;; START WINDOW
    ;; ------------------------------------------------------------



    movit_window, data, pathname=pathname, name_of_file=remove_path_and_ext(filename), isgri=isgri, datatype=datatype
;    movit_tv, data, gain=200



    RETURN
END

