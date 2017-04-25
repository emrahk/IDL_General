	PRO WR_MOVIE, FILENAME, IMAGE_ARRAY, IFRAME, NFRAMES, MPEG=K_MPEG, $
		GIF=K_GIF, PICT=PICT, DELETE=DELETE, FRAMEDELAY=FRAMEDELAY, $
		LOOPCNT=LOOPCNT, NOSCALE=NOSCALE, JAVASCRIPT=K_JAVASCRIPT, $
		INCREMENT=INCREMENT, URL=URL, TITLE=TITLE, TOP=TOP,	$
		JPEG=K_JPEG, PNG=K_PNG, INTERNAL_MPEG=K_INTERNAL_MPEG,	$
		ALT_MPEG=ALT_MPEG, RED=RED, GREEN=GREEN, BLUE=BLUE
;+
; Project     : SOHO - CDS     
;                   
; Name        : WR_MOVIE
;               
; Purpose     : Convert an array of frames to a JAVASCRIPT or MPEG movie.
;               
; Explanation : This procedure takes a three dimensional array of images
;		in the form (X-dim, Y-dim, Frames) and generates a movie out of
;		it in various formats.
;
;		In the older (default) mode of operation, an intermediate
;		series of GIF files is written out, where each GIF contains one
;		image frame.  The procedure then will convert the GIF files to
;		a GIF movie (viewable with Netscape >2.0) and/or an MPEG movie.
;		The procedure uses the program mpeg_encode to create the MPEG
;		movie and the program whirlgif to create the GIF movie.  For
;		IDL v5.4 and above, pict files are used as the intermediate
;		format for MPEG movies, since there was a period where GIF
;		files were no longer supported by IDL.  (However, this routine
;		uses SSW_WRITE_GIF which can allow the writing of GIF images on
;		some computers.)
;
;		Alternatively, this procedure can create MPEG movies using
;		IDL's internal MPEG encoder, without use of any intermediate
;		GIF files.
;
;		A third type of output which can be produced is a JAVASCRIPT
;		movie suitable for viewing in a web browser like Netscape or
;		Microsoft Internet Explorer.  This can be produced with either
;		GIF, PNG, or JPEG frame files.  For versions of IDL earlier
;		than 5.4 the default is GIF; after that it is JPEG.  If no
;		keywords are passed, then JAVASCRIPT movies are the default.
;
;		This procedure creates a subdirectory /mpegframes to store the
;		individual (e.g. GIF) image frames.  If the procedure is called
;		with the /DELETE keyword, then this directory and its contents
;		will be removed before the procedure exits.  Otherwise it will
;		be left intact.
;
;		An alternative way to use this routine is to pass it one frame
;		at a time.  This is useful when the total amount of data is too
;		large to have in memory at the same time.
;
;               
; Use         :	IDL> WR_MOVIE, FILENAME, MOVIE_ARRAY, /MPEG, /GIF, /DELETE 
;
;		IDL> WR_MOVIE, FILENAME, MOVIE_FRAME, IFRAME, NFRAME, ...
;    
; Inputs      : FILENAME:	Base filename to use when creating MPEG and
;				GIF movies (no extension).  If a GIF movie is
;				created, then it will be named filename.gif.
;				If an MPEG movie is created, then it will be
;				called filename.mpg.  JAVASCRIPT movies will
;				have a file called filename.html, and a
;				subdirectory simply called filename to hold the
;				individual frames.
;
;		IMAGE_ARRAY:	Three dimensional array of images in the form
;				(X-dim, Y-dim, Frames) to be converted to 
;				a movie.  This is the same form of input that
;				is used by XMOVIE.
;               
; Opt. Inputs : An alternative way of calling this routine is one frame at a
;		time.  When using this option, two additional parameters are
;		required:
;
;			IFRAME:	 The frame number, from 0 to N-1.
;			NFRAMES: The total number of frames.
;
;		Also, in this case IMAGE_ARRAY would be a two-dimensional frame
;		rather than a three-dimensional array of frames.
;
;		When using this approach, the following restrictions apply:
;
;		* All the frames must be exactly the same size.
;
;		* All the calls to WR_MOVIE must be with the same value of
;		  NFRAMES.
;
;		* The frames must be passed in order, from 0 to NFRAMES-1.  No
;		  frames can be omitted.
;
;		* If the /PICT option is desired, then it must be passed in
;		  each call to WR_MOVIE.
;
;		* If the /GIF or /MPEG option is desired, then the appropriate
;		  keywords must be present in the last call to WR_MOVIE.  (In
;		  the preceeding calls, these keywords are ignored--the safest
;		  thing to do is to use the same format for all the calls.)
;
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : The following keywords are used to determine what kind of movie
;		is produced.  If none are passed, then the default format is
;		a JAVASCRIPT movie.  If more than one are passed, then multiple
;		formats are created.
;
;		MPEG:		If set, then an MPEG movie is created.
;
;		GIF:		If set, then a GIF movie is created.
;
;		JAVASCRIPT:	If set, then an Java Script HTML file is
;				written out.  There are two parts to the
;				Java Script movie package: the file
;				filename.html which contains the Java Script
;				commands, and the subdirectory filename which
;				contains the images.
;
;		Additional keywords are:
;
;		JPEG:		When used with /JAVASCRIPT, the files written
;				out are in JPEG format, rather than GIF.  This
;				is the default for IDL versions 5.4 and above,
;				which no longer support writing GIF images.
;
;		PNG:		When used with /JAVASCRIPT, the files written
;				out are in PNG format, rather than GIF or JPEG.
;
;		PICT:		If set, then a series of PICT frames are
;				written out.  This is suitable for converting
;				to a VHS tape.  The filenames will be written
;				such that the extensions are the frame number,
;				e.g. "filename.00", "filename.01", etc.
;
;		ALT_MPEG:	Uses an alternate set of parameters for
;				mpeg_encode, courtesy of Stein Vidar Haugan and
;				Bernhard Fleck, which may make a better movie,
;				at the expense of a slightly larger file.
;
;		INTERNAL_MPEG:	If set, then the internal MPEG writer is used
;				instead of spawning mpeg_encode.  This is the
;				default for IDL versions 5.4 and above, which
;				no longer support writing the intermediate GIF
;				images.
;
;		DELETE:		If set, then the temporary directory 
;				/mpegframes will be deleted before this 
;				procedure exits.
;
;		FRAMEDELAY:	The delay time between frames, in 1/100 of a
;				second.  The default value of 10 gives a movie
;				rate of approximately 10 frames/second.  The
;				bigger the number, the slower the movie will
;				run.  Not applicable to MPEG movies.
;
;		LOOPCNT:	The number of times to loop through the GIF
;				movie.  The default value is 0, which
;				represents an infinite number of loops.
;
;		NOSCALE:	If set, then the routine BYTSCL will not be
;				called.  Use this keyword when the movie frames
;				have already been scaled into the color table.
;
;               INCREMENT:	Percent increment for speed control for Java
;				Script movies.  [def= 10]
;
;               URL:		Optional URL path to GIF images for Java Script
;				movies.  The default is that the GIF frames
;				will be in the subdirectory FILENAME.
;
;               TITLE:		Optional HTML title for Java Script movies.
;
;		TOP	 	The maximum value of the scaled image array, as
;				used by BYTSCL.  The default value is
;				!D.TABLE_SIZE-1.
;
;               RED,GREEN,BLUE: Color tables to apply to the movie.  If not
;                               passed, then TVLCT,/GET is called.
;
; Calls       : FILE_EXIST, FILE_DELETE, FILE_COPY, FILE_MOVE, FILE_SEARCH,
;               MK_DIR, SSW_BIN
;
; Common      : The internal common block WR_MOVIE is used to keep information
;		between calls.
;
; Restrictions: This process that is running IDL when this procedure 
;		executes must have write priveleges to the working directory
;		or this procedure will fail.
;               
;		For versions of IDL prior to 5.1, if an MPEG movie is being
;		created, then the following programs must be in the current
;		path:
;
;			mpeg_encode
;			giftoppm  (or picttoppm for v5.4 and above)
;
;		For IDL v5.1 and above, MPEGs can be created without the above
;		programs.  However, for IDL v5.4 and above, a special license
;		is required from RSI.
;
;		If a GIF movie is being created, then the following program 
;		must be in the current path:
;
;			whirlgif
;
;		Note that IDL versions 5.4 to 6.0 don't support writing GIF
;		files.
; 
; Side effects: Files and subdirectory are created in the working directory.
;
;		When called with the single frame option, the temporary file
;		giflist is left open between calls, and is only closed on the
;		final call.
;               
; Category    : Display
;               
; Prev. Hist. : This procedure is based on WRITE_MPEG by
; 		A. Scott Denning		scott@abyss.Atmos.ColoState.edu
;		Dept. of Atmospheric Science	Phone (970)491-2134
;		Colorado State University  
;
; Written     : Ron Yurow, GSFC
;               
; Modified    : Version 1, 19 September 1996
;		Version 2, 6 December 1996, William Thompson, GSFC
;			Made slight modifications--better error handling.
;		Version 3, 9 December 1996, William Thompson, GSFC
;			Corrected bug writing GIF movies with LE 10 frames.
;			Corrected bug writing GIF movies with LE 10 frames.
;		Version 4, 30 December 1996, Zarro, GSFC
;                       Added FRAMEDELAY and LOOPCNT keywords
;                       Added '-f' to spawn,'rm '
;		Version 5, 8 January 1997, William Thompson, GSFC
;			Added single frame option.
;			Added keywords PICT and NOSCALE.
;		Version 6, 10 January 1997, William Thompson, GSFC
;			Changed file naming convention for PICT files
;		Version 7, 16 July 1997, William Thompson, GSFC
;			Added keywords JAVASCRIPT, INCREMENT, URL, AND TITLE
;		Version 8, 23 July 1997, William Thompson, GSFC
;			Create directory for GIF files when /JAVASCRIPT keyword
;			is used.
;		Version 9, 08-Dec-1997, William Thompson, GSFC
;			Scale image to top color.  Added keyword TOP
;		Version 10, 04-Jun-1998, William Thompson, GSFC
;			Check for existence of whirl_gif and mpeg_encode
;			Allow FILENAME to contain periods.
;			Won't automatically create GIF movie if /JAVA passed.
;		Version 11, 23-Oct-2000, William Thompson
;			Added keywords INTERNAL_MPEG, JPEG, and PNG.
;			Don't write GIF files if IDL v5.4 or above.
;		Version 12, 26-Oct-2000, William Thompson
;			Added keyword ALT_MPEG.
;			Allow use of PICT temporary files for MPEG movies.
;		Version 13, 18-Dec-2000, William Thompson
;			Make JPEG the default, rather than PNG
;       	Version 14, William Thompson, GSFC, 16 April 2003
;               	Added support for TrueColor displays.
;                       Added keywords RED, GREEN, BLUE
;               Version 15, 13-Aug-2003, William Thompson
;                       Use SSW_WRITE_GIF instead of WRITE_GIF
;               Version 16, 04-Jan-2005, William Thompson
;                       Reworked spawning to be more OS-tolerant for versions
;			5.6 and above
;               Version 17, 10-Nov-2005, William Thompson
;                       Reworked to use WRITE_GIF,/MULTIPLE, when appropriate.
;               Version 18, 23-Feb-2007, William Thompson
;                       If giftoppm not found, try giftopnm
;
; Version     : Version 18, 23-Feb-2007
;-
;
	ON_ERROR, 2
	COMMON WR_MOVIE, GIFLST, TMPDIR, MPEG_UNIT
;
; Check the input parameters.
;
	CASE N_PARAMS() OF
	    2:  BEGIN
		SINGLE_FRAME = 0
		IFRAME = 0
		END
	    4:  BEGIN
		IF N_ELEMENTS(IFRAME) NE 1 THEN MESSAGE,	$
			'IFRAME must be a scalar'
		IF N_ELEMENTS(NFRAMES) NE 1 THEN MESSAGE,	$
			'NFRAMES must be a scalar'
		SINGLE_FRAME = 1
		END
	    ELSE: MESSAGE, 'Syntax:  WR_MOVIE, FILENAME, ARRAY'
	ENDCASE
	IF DATATYPE(FILENAME,1) NE 'String' THEN MESSAGE,	$
		'Input parameter FILENAME must be a character string'
	IF N_ELEMENTS(FILENAME) NE 1 THEN MESSAGE,		$
		'FILENAME must be a scalar value'
;
; If any of the color table keywords were passed, then make sure that they're
; all consistent with each other.
;
        IF (N_ELEMENTS(RED) GT 0) OR (N_ELEMENTS(GREEN) GT 0) OR        $
                (N_ELEMENTS(BLUE) GT 0) THEN BEGIN
            IF (N_ELEMENTS(RED) NE N_ELEMENTS(GREEN)) OR                $
                    (N_ELEMENTS(RED) NE N_ELEMENTS(BLUE)) THEN MESSAGE, $
                    'Color table vectors must all have the same size.'
        ENDIF
;
; Determine the correct setting for the MPEG keyword.
;
	MPEG = KEYWORD_SET(K_MPEG)
;
; Determine the correct setting for the JAVASCRIPT keyword.  If none of the GIF
; nor MPEG nor JAVASCRIPT keywords were passed, then write out a JAVASCRIPT
; movie file.
;
	JAVASCRIPT = KEYWORD_SET(K_JAVASCRIPT)
	IF (NOT KEYWORD_SET(K_GIF)) AND (NOT MPEG) AND (NOT JAVASCRIPT) THEN $
		JAVASCRIPT = 1
;
; Determine the correct setting for the GIF, PNG, and JPEG keywords.
;
	GIF  = KEYWORD_SET(K_GIF)
	PNG  = KEYWORD_SET(K_PNG)  AND KEYWORD_SET(JAVASCRIPT)
	JPEG = KEYWORD_SET(K_JPEG) AND KEYWORD_SET(JAVASCRIPT) AND (NOT PNG)
;
;  Check on IDL's ability to create GIF images.
;
        INTERNAL_GIF = 0
        TEMP_FORMAT = 'gif'
        IF ALLOW_GIF() THEN BEGIN
            INTERNAL_GIF = GIF
        END ELSE BEGIN
            IF !VERSION.OS_FAMILY EQ 'unix' THEN $
              IF SSW_BIN('ppmtogif',FOUND=FOUND) THEN GIF = 0
            IF GIF EQ 0 THEN BEGIN
                TEMP_FORMAT = 'pict'
                IF KEYWORD_SET(K_GIF) THEN MESSAGE, /CONTINUE,		$
                  'Unable to write GIF movies in current IDL release'
                JPEG = KEYWORD_SET(JAVASCRIPT) AND (NOT PNG)
            ENDIF
        ENDELSE
;
; Make sure that the program is going to do something.
;
	IF NOT (GIF OR MPEG OR PNG OR JPEG OR JAVASCRIPT OR	$
		KEYWORD_SET(PICT)) THEN RETURN
;
; Determine the correct setting for the INTERNAL_MPEG keyword.  Not supported
; for versions of IDL prior to 5.1.
;
	INTERNAL_MPEG = KEYWORD_SET(K_INTERNAL_MPEG) AND KEYWORD_SET(MPEG)
	IF !VERSION.RELEASE LT '5.1' THEN INTERNAL_MPEG = 0
;
; If the /GIF option was passed, and INTERNAL_GIF is not set, then make sure
; that whirlgif is in the path.
;
	IF KEYWORD_SET(GIF) AND (NOT INTERNAL_GIF) THEN BEGIN
            WHIRLGIF_COMMAND = SSW_BIN('whirlgif', FOUND=FOUND)
            IF WHIRLGIF_COMMAND EQ '' THEN BEGIN
		MESSAGE, /INFORMATIONAL,	$
			'Unable to create GIF movie -- whirlgif not found'
		GIF = 0
	    ENDIF
	ENDIF
;
; If the /MPEG option was passed, then make sure that mpeg_encode and giftoppm
; (picttoppm) are both in the path.  Not necessary for IDL versions 5.1 and
; above, as it will fail over to the internal mode.
;
	IF KEYWORD_SET(MPEG) AND NOT KEYWORD_SET(INTERNAL_MPEG) THEN BEGIN
            MPEG_ENCODE_COMMAND = SSW_BIN('mpeg_encode', FOUND=FOUND)
            IF MPEG_ENCODE_COMMAND EQ '' THEN BEGIN
		IF !VERSION.RELEASE GE 5.1 THEN INTERNAL_MPEG=1 ELSE BEGIN
		    MESSAGE, /INFORMATIONAL,	$
			    'Unable to create MPEG movie -- ' +		$
			    'mpeg_encode not found'
		    MPEG = 0
		ENDELSE
	    ENDIF
	    IF NOT KEYWORD_SET(INTERNAL_MPEG) THEN BEGIN
                BASE_FORMAT = 'PPM'
                TOPPM_COMMAND = SSW_BIN(TEMP_FORMAT+'toppm', FOUND=FOUND)
                IF NOT FOUND THEN BEGIN
                    BASE_FORMAT = 'PNM'
                    TOPPM_COMMAND = SSW_BIN(TEMP_FORMAT+'topnm', FOUND=FOUND)
                ENDIF
                IF NOT FOUND THEN BEGIN
		    IF !VERSION.RELEASE GE 5.1 THEN INTERNAL_MPEG=1 ELSE BEGIN
			MESSAGE, /INFORMATIONAL,	$
				'Unable to create MPEG movie -- ' +	$
				TEMP_FORMAT + 'toppm not found'
			MPEG = 0
		    ENDELSE
		ENDIF
	    ENDIF
	ENDIF
;
; Determine whether or not intermediate GIF images should be written.  Do the
; same for intermediate PICT images.
;
	WR_GIF = (GIF AND (NOT INTERNAL_GIF)) OR	$
                (KEYWORD_SET(JAVASCRIPT) AND (NOT PNG) AND (NOT JPEG)) OR $
		(MPEG AND (NOT INTERNAL_MPEG) AND (TEMP_FORMAT EQ 'gif'))
	WR_PICT = MPEG AND (NOT INTERNAL_MPEG) AND (TEMP_FORMAT EQ 'pict')
;
; Call the SIZE function in order to find the dimensions of the image array.
;
        TRUE_COLOR = 0
	MOVIESIZE = SIZE(IMAGE_ARRAY)
;
	IF SINGLE_FRAME THEN BEGIN
            IF MOVIESIZE[0] EQ 3 THEN BEGIN
                TRUE_COLOR = (WHERE(MOVIESIZE[1:3] EQ 3))[0] + 1
                IF TRUE_COLOR LE 0 THEN MESSAGE,        $
                        'Input array must be two-dimensional'
            END ELSE IF MOVIESIZE[0] NE 2 THEN MESSAGE,	$
		    'Input array must be two-dimensional'
	END ELSE BEGIN
            IF MOVIESIZE[0] EQ 4 THEN BEGIN
                TRUE_COLOR = (WHERE(MOVIESIZE[1:3] EQ 3))[0] + 1
                IF TRUE_COLOR LE 0 THEN MESSAGE,        $
                        'Input array must be three-dimensional'
            END ELSE IF MOVIESIZE[0] NE 3 THEN MESSAGE,	$
		    'Input array must be three-dimensional'
	ENDELSE
;
; Set the X dimension and Y dimension of each frame as well as the number of
; frames in the movie based on the size of image_array.
;
        CASE TRUE_COLOR OF
            1:  BEGIN
                XSIZE = MOVIESIZE[2]
                YSIZE = MOVIESIZE[3]
            END
            2:  BEGIN
                XSIZE = MOVIESIZE[1]
                YSIZE = MOVIESIZE[3]
            END
            ELSE: BEGIN
                XSIZE = MOVIESIZE[1]
                YSIZE = MOVIESIZE[2]
            END
        ENDCASE
	IF NOT SINGLE_FRAME THEN NFRAMES = MOVIESIZE[MOVIESIZE[0]]
;
; Set NDIGITS to the minimum field length required to display largest frame
; number.  Can't be less than 2, or whirlgif won't work.
;
	NDIGITS = (1 + FIX (ALOG10 (NFRAMES))) > 2
;
; Set FRMT to a format string that will result in the frame number of each 
; frame using the same number of characters with 0's padding left side as
; needed.
;
	FRMT = '(i' + STRING (NDIGITS) + '.' + STRING (NDIGITS) + ')'
	FRMT = STRCOMPRESS(FRMT, /REMOVE_ALL) 
;
; If we screw up writing a frame, we will just have to give up and go home.
;
	ON_IOERROR, BADWRITE
;
; Make a temporary directory to hold the individual frames of the the movie
; with each frame stored as GIF file.  Begin by setting TMPDIR to the name
; of the tempory directory to create or clear.
;
	IF (NOT SINGLE_FRAME) OR (IFRAME EQ 0) THEN BEGIN
	    TMPDIR = 'mpegframes'
;
; Clear or add the directory as needed.
;
	    IF FILE_EXIST(TMPDIR) THEN BEGIN
		IF !VERSION.RELEASE LT 5.6 THEN BEGIN
		    SPAWN, 'rm -f ' + TMPDIR + '/*'
		END ELSE BEGIN
		    RMFILES = CALL_FUNCTION('FILE_SEARCH', TMPDIR + '/*', $
			    COUNT=RMCOUNT)
                    IF RMCOUNT GT 0 THEN FILE_DELETE, RMFILES
		ENDELSE
            END ELSE MK_DIR, TMPDIR
;
; Open a file for recording which GIFs we created.
;
	    IF KEYWORD_SET(GIF) AND (NOT INTERNAL_GIF) THEN	$
		    OPENW, GIFLST, TMPDIR + "/giflist", /GET_LUN 
;
; If we're using the built-in MPEG writer, then open up the logical unit.
;
	    IF INTERNAL_MPEG THEN MPEG_UNIT = MPEG_OPEN(MOVIESIZE[1:2])
	ENDIF
;
; Write each frame into TMPDIR as a gif image file
;
	IF SINGLE_FRAME THEN BEGIN
	    FRAME1 = IFRAME
	    FRAME2 = IFRAME
	END ELSE BEGIN
	    FRAME1 = 0
	    FRAME2 = NFRAMES - 1
	ENDELSE
;
; If autoscaling is to be used, then get the minimum and maximum values to use
; for scaling the images.
;
	IF NOT KEYWORD_SET(NOSCALE) THEN IMIN = MIN(IMAGE_ARRAY, MAX=IMAX)
;
	FOR FRAME = FRAME1,FRAME2 DO BEGIN
;
; Let FILENAME be the name of the file we are creating.
;
	    FRAMENAME = 'frame' + STRING (FRAME, FORMAT = FRMT)
;
; Let PATHNAME be the entire file and path of the file.
;
	    PATHNAME = TMPDIR + '/' + FRAMENAME
	    IF SINGLE_FRAME THEN IMAGE = IMAGE_ARRAY ELSE BEGIN
                IF TRUE_COLOR EQ 0 THEN IMAGE = IMAGE_ARRAY[*,*,FRAME] ELSE $
                        IMAGE = IMAGE_ARRAY[*,*,*,FRAME]
            ENDELSE
            SZ = SIZE(IMAGE)
	    IF N_ELEMENTS(TOP) NE 1 THEN TOP = !D.TABLE_SIZE-1
	    IF NOT KEYWORD_SET(NOSCALE) THEN	$
		    IMAGE = BYTSCL(IMAGE, TOP=TOP, MIN=IMIN, MAX=IMAX)
;
;  Write GIF images.
;
            IF WR_GIF OR INTERNAL_GIF THEN BEGIN
                IF TRUE_COLOR GT 0 THEN BEGIN
                    TEMP = COLOR_QUAN(IMAGE,TRUE_COLOR,RRED,GGREEN,BBLUE)
                END ELSE BEGIN
                    TEMP = IMAGE
                    IF N_ELEMENTS(RED) GT 0 THEN BEGIN
                        RRED   = RED
                        GGREEN = GREEN
                        BBLUE  = BLUE
                    ENDIF
                ENDELSE
                IF WR_GIF THEN SSW_WRITE_GIF, PATHNAME+'.gif', $
                  TEMP, RRED, GGREEN, BBLUE
                IF INTERNAL_GIF THEN WRITE_GIF, FILENAME+'.gif', $
                  TEMP, RRED, GGREEN, BBLUE, /MULTIPLE
            ENDIF
;
;  Write PICT images.
;
	    IF WR_PICT THEN BEGIN
                IF TRUE_COLOR GT 0 THEN BEGIN
                    TEMP = COLOR_QUAN(IMAGE,TRUE_COLOR,RRED,GGREEN,BBLUE)
                END ELSE BEGIN
                    TEMP = IMAGE
                    IF N_ELEMENTS(RED) GT 0 THEN BEGIN
                        RRED   = RED
                        GGREEN = GREEN
                        BBLUE  = BLUE
                    END ELSE TVLCT, RRED, GGREEN, BBLUE, /GET
                ENDELSE
                WRITE_PICT, PATHNAME+'.pict', TEMP, RRED, GGREEN, BBLUE
            ENDIF
;
;  Write PNG images.
;
	    IF PNG THEN BEGIN
                CASE TRUE_COLOR OF
                    2:  TEMP = REARRANGE(IMAGE,[2,1,3])
                    3:  TEMP = REARRANGE(IMAGE,[3,1,2])
                    ELSE: TEMP = IMAGE
                ENDCASE
                IF N_ELEMENTS(RED) EQ 0 THEN TVLCT, RED, GREEN, BLUE, /GET
		IF !VERSION.RELEASE LT '5.4' THEN BEGIN
                    IF TRUE_COLOR GT 0 THEN BEGIN
                        FOR I=0,2 DO TEMP[I,*,*] =      $
                                ROTATE(REFORM(TEMP[I,*,*]),7)
                    END ELSE TEMP = ROTATE(TEMP,7)
                ENDIF
		WRITE_PNG, PATHNAME+'.png', TEMP, RED, GREEN, BLUE
            ENDIF
;
;  Write JPEG images.
;
	    IF JPEG THEN BEGIN
                IF TRUE_COLOR GT 0 THEN BEGIN
                    TEMP = IMAGE
                    TRUE = TRUE_COLOR
                END ELSE BEGIN
                    IF N_ELEMENTS(RED) EQ 0 THEN TVLCT, RED, GREEN, BLUE, /GET
                    TEMP = BYTARR(3,XSIZE,YSIZE)
                    TEMP(0,*,*) = RED  (IMAGE)
                    TEMP(1,*,*) = GREEN(IMAGE)
                    TEMP(2,*,*) = BLUE (IMAGE)
                    TRUE = 1
                ENDELSE
		WRITE_JPEG, PATHNAME+'.jpg', TEMP, TRUE=TRUE
            ENDIF
;
;  Write MPEG using the internal procedure.
;
	    IF INTERNAL_MPEG THEN BEGIN
                CASE TRUE_COLOR OF
                    0:  BEGIN
                        IF N_ELEMENTS(RED) EQ 0 THEN TVLCT,RED,GREEN,BLUE,/GET
                        TEMP = BYTARR(3,XSIZE,YSIZE)
                        TEMP(0,*,*) = RED  [IMAGE]
                        TEMP(1,*,*) = GREEN[IMAGE]
                        TEMP(2,*,*) = BLUE [IMAGE]
                    END
                    2:  TEMP = REARRANGE(IMAGE,[2,1,3])
                    3:  TEMP = REARRANGE(IMAGE,[3,1,2])
                    ELSE: TEMP = IMAGE
                ENDCASE
		MPEG_PUT, MPEG_UNIT, IMAGE=TEMP, FRAME=FRAME, /ORDER
	    ENDIF
;
; Write the file name into our list of GIFs.
;
	    IF GIF AND (NOT INTERNAL_GIF) THEN PRINTF, GIFLST, FRAMENAME+'.gif'
  	    PRINT, 'Processed frame ', FRAME + 1
;
;  If the PICT keyword was passed, then also write the PICT file.
;
            IF KEYWORD_SET(PICT) THEN BEGIN
                IF TRUE_COLOR GT 0 THEN BEGIN
                    TEMP = COLOR_QUAN(IMAGE,TRUE_COLOR,RRED,GGREEN,BBLUE)
                END ELSE BEGIN
                    TEMP = IMAGE
                    IF N_ELEMENTS(RED) GT 0 THEN BEGIN
                        RRED   = RED
                        GGREEN = GREEN
                        BBLUE  = BLUE
                    END ELSE TVLCT, RRED, GGREEN, BBLUE, /GET
                ENDELSE
                WRITE_PICT, FILENAME + '.' + STRING(FRAME, FORMAT=FRMT), $
                        TEMP, RRED, GGREEN, BBLUE
            ENDIF
	ENDFOR
;
; If only processing a single frame, and it's not the last frame, then we can
; return now.
;
	IF SINGLE_FRAME AND ((IFRAME+1) NE NFRAMES) THEN RETURN
;
; Close the file contianing our list of GIFs
;
	IF GIF AND (NOT INTERNAL_GIF) THEN FREE_LUN, GIFLST
;
; Set FRAMEDELAY and LOOPCNT to determine how the GIF will be displayed by
; netscape.
;
      	IF NOT EXIST(FRAMEDELAY) THEN FRAMEDELAY = 10 ; 10 frames per second
	IF NOT EXIST(LOOPCNT) THEN LOOPCNT    = 0  ; Infinite repititions
;
; Check if we should create a GIF movie.  If we do, then we will have to
; create a command to SPAWN whirlgif.
;
	IF KEYWORD_SET (GIF) THEN BEGIN
            IF INTERNAL_GIF THEN WRITE_GIF, FILENAME+'.gif', /CLOSE ELSE BEGIN
;
; Create a unix command to make GIF movie from all of our gif frames
;
                CMD = "cd " + TMPDIR + " ; "
                CMD = CMD + WHIRLGIF_COMMAND
                CMD = CMD + " -loop " + STRING (LOOPCNT, FORMAT = FRMT)
                CMD = CMD + " -time " + STRING (FRAMEDELAY, FORMAT = FRMT)
                FNAME = FILENAME + ".gif"
                CMD = CMD + " -o " + FNAME + " -i giflist"
;
; Spawn the command.
;
                SPAWN, CMD
;
; Move the resulting GIF file out of the temporary frames directory.
;
                IF !VERSION.RELEASE LT 5.6 THEN BEGIN
                    SPAWN, 'mv ' + TMPDIR + '/' + FNAME + ' .'
                END ELSE BEGIN
                    MVFILES = CALL_FUNCTION('FILE_SEARCH', TMPDIR + '/' + $
                                            FNAME, COUNT=MVCOUNT)
                    IF MVCOUNT GT 0 THEN FILE_MOVE, MVFILES, '.'
                ENDELSE
            ENDELSE
        ENDIF
;
; Check if we should create MPEG movie.
;
	IF KEYWORD_SET(MPEG) THEN BEGIN
;
; If the built-in MPEG writer is being used, then close the file.
;
	    IF INTERNAL_MPEG THEN BEGIN
		PRINT, 'Writing MPEG movie, please wait ...'
		MPEG_SAVE,  MPEG_UNIT, FILENAME=FILENAME+'.mpg'
		MPEG_CLOSE, MPEG_UNIT
;
; Otherwise, we will have to set up the parameter file for mpeg_encode, and
; then SPAWN mpeg_encode.
;
	    END ELSE BEGIN
;
; Set up the name and path to the mpeg parameter file
;
		PARAMFILE = TMPDIR + '/params.mpeg'
;
; Open the mpeg parameter file for writing.  Store logical unit number in
; MPRM.
;
		OPENW, MPRM, PARAMFILE, /GET_LUN
;
; Write out the mpeg parameter file.
;
		IF KEYWORD_SET(ALT_MPEG) THEN BEGIN
		    PRINTF, MPRM, 'PATTERN          IPI'
		    PRINTF, MPRM, 'OUTPUT           ' + FILENAME + '.mpg'
		    PRINTF, MPRM, 'GOP_SIZE         6'
		    PRINTF, MPRM, 'SLICES_PER_FRAME 1'
		    PRINTF, MPRM, 'BASE_FILE_FORMAT ' + BASE_FORMAT
		    PRINTF, MPRM, 'INPUT_CONVERT ' + TOPPM_COMMAND + ' *'
		    PRINTF, MPRM, 'INPUT_DIR        ' + TMPDIR
		    PRINTF, MPRM, 'INPUT'
		    PRINTF, MPRM, 'frame*.' + TEMP_FORMAT + ' [' +	$
			    STRING(0,FORMAT=FRMT) + '-' +	$
			    STRING(NFRAMES-1,FORMAT=FRMT) + ']'
		    PRINTF, MPRM, 'END_INPUT'
		    PRINTF, MPRM, 'PIXEL            HALF'
		    PRINTF, MPRM, 'RANGE            32'
		    PRINTF, MPRM, 'PSEARCH_ALG      LOGARITHMIC'
		    PRINTF, MPRM, 'BSEARCH_ALG      SIMPLE'
		    PRINTF, MPRM, 'IQSCALE          7'
		    PRINTF, MPRM, 'PQSCALE          7'
		    PRINTF, MPRM, 'BQSCALE          7'
		    PRINTF, MPRM, 'REFERENCE_FRAME  DECODED'
		    PRINTF, MPRM, 'FORCE_ENCODE_LAST_FRAME'
		END ELSE BEGIN
		    PRINTF, MPRM, 'PATTERN          IBBBBBBBBBBP'
		    PRINTF, MPRM, 'OUTPUT           ' + FILENAME + '.mpg'
		    PRINTF, MPRM, 'GOP_SIZE 12'
		    PRINTF, MPRM, 'SLICES_PER_FRAME 5'
		    PRINTF, MPRM, 'BASE_FILE_FORMAT ' + BASE_FORMAT
		    PRINTF, MPRM, 'INPUT_CONVERT ' + TOPPM_COMMAND + ' *'
		    PRINTF, MPRM, 'INPUT_DIR        ' + TMPDIR
		    PRINTF, MPRM, 'INPUT'
		    PRINTF, MPRM, 'frame*.' + TEMP_FORMAT + ' [' +	$
			    STRING(0,FORMAT=FRMT) + '-' +	$
			    STRING(NFRAMES-1,FORMAT=FRMT) + ']'
		    PRINTF, MPRM, 'END_INPUT'
		    PRINTF, MPRM, 'PIXEL            FULL'
		    PRINTF, MPRM, 'RANGE            5'
		    PRINTF, MPRM, 'PSEARCH_ALG      LOGARITHMIC'
		    PRINTF, MPRM, 'BSEARCH_ALG      SIMPLE'
		    PRINTF, MPRM, 'IQSCALE          6'
		    PRINTF, MPRM, 'PQSCALE          6'
		    PRINTF, MPRM, 'BQSCALE          6'
		    PRINTF, MPRM, 'REFERENCE_FRAME  ORIGINAL'
		    PRINTF, MPRM, 'FORCE_ENCODE_LAST_FRAME'
		ENDELSE
;
; Close the mpeg parameter file.
;
		FREE_LUN, MPRM
;
; Spawn a shell to process the mpeg_encode command.
;
		SPAWN, MPEG_ENCODE_COMMAND + ' ' + PARAMFILE
	    ENDELSE
	ENDIF
;
; Check to see if the Java Script HTML file should be written.
;
	IF KEYWORD_SET(JAVASCRIPT) THEN BEGIN
	    NAMES = 'frame' + STRING(INDGEN(NFRAMES), FORMAT=FRMT)
	    IF PNG THEN NAMES = NAMES + '.png' ELSE $
		    IF JPEG THEN NAMES = NAMES + '.jpg' ELSE	$
		    NAMES = NAMES + '.gif'
	    IF N_ELEMENTS(FRAMEDELAY) EQ 1 THEN DELAY = FRAMEDELAY*10.
	    IF N_ELEMENTS(URL) EQ 0 THEN URL = FILENAME
	    JSMOVIE, FILENAME+'.html', NAMES, DELAY=DELAY, TITLE=TITLE,	$
		    URL=URL, SIZE=[XSIZE,YSIZE], INCREMENT=INCREMENT
;
; Create the directory to hold the files, and move the files to that directory.
;
	    IF FILE_EXIST(FILENAME) THEN BEGIN
		IF !VERSION.RELEASE LT 5.6 THEN BEGIN
		    SPAWN, 'rm -f ' + FILENAME + '/*'
		END ELSE BEGIN
                    RMFILES = CALL_FUNCTION('FILE_SEARCH', FILENAME + '/*', $
			    COUNT=RMCOUNT)
		    IF RMCOUNT GT 0 THEN FILE_DELETE, RMFILES
		ENDELSE
            END ELSE MK_DIR, FILENAME
	    TMPNAME = TMPDIR + '/frame*'
	    IF KEYWORD_SET(PNG) THEN TMPNAME = TMPNAME + '.png' $
		    ELSE IF KEYWORD_SET(JPEG) THEN TMPNAME = TMPNAME + '.jpg' $
		    ELSE TMPNAME = TMPNAME + '.gif'
;
	    IF !VERSION.RELEASE GE 5.6 THEN TMPFILES =	$
		    CALL_FUNCTION('FILE_SEARCH', TMPNAME, COUNT=TMPCOUNT)
	    IF KEYWORD_SET(DELETE) THEN BEGIN
		IF !VERSION.RELEASE LT 5.6 THEN				$
		    SPAWN, 'mv ' + TMPNAME + ' ' + FILENAME ELSE	$
		    FILE_MOVE, TMPNAME, FILENAME
	    END ELSE BEGIN
		IF !VERSION.RELEASE LT 5.6 THEN				$
		    SPAWN, 'cp ' + TMPNAME + ' ' + FILENAME ELSE	$
		    FILE_COPY, TMPNAME, FILENAME
	    ENDELSE
	ENDIF
;
; Check if we should remove the temporary frames directory that we just
; created.
;
	IF KEYWORD_SET(DELETE) THEN BEGIN
	    IF !VERSION.RELEASE LT 5.6 THEN BEGIN
		SPAWN, 'rm -rf ' + TMPDIR
	    END ELSE BEGIN
		RMFILES = CALL_FUNCTION('FILE_SEARCH', TMPDIR + '/*', $
			COUNT=RMCOUNT)
		IF RMCOUNT GT 0 THEN FILE_DELETE, RMFILES
		FILE_DELETE, TMPDIR
	    ENDELSE
        ENDIF
	RETURN
;
BADWRITE:
	MESSAGE, 'Unable to write MPEG and/or GIF file!'
	END
