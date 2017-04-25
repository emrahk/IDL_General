;+
; Project     : SOHO - LASCO/EIT
;
; Name        : GIFS2MPEG
;
; Purpose     : Make MPEG or Animated Gifs from Gifs
;
; Use         : GIFS2MPEG, mpegFileName, gif_match, gifdir, WHIRLGIF=WHIRLGIF, $
;		SCALE=scale, REFERENCE=reference, $
;		MPEG_DIR=mpeg_dir
;
; Inputs      : mpegFileName - Name of output file
;               gif_match - string (wildcards allowed) used to find input GIF file
;               gifdir - directory to search for input GIF files (string)
;
; Optional Inputs:
;
; Outputs     :
;
; Keywords    :  WHIRLGIF - Make Animated GIF using WHIRLGIF
;                SCALE -
;		 REFERENCE - 
;                MPEG_DIR - Name of directory to put MPEG file; default is gifdir
;		NFRAMES - set named variable to number of frames used (output)
;
;
; Comments    :
;
; Side effects:
;
; Category    : Image Display.  Animation.
;
; Modified:
;	990316  NBR	Change whirlgif options to loop indefinitely
;	990521 NBr	Change paramfile INPUT
;	020204	Jake	Added /SH to all SPAWN
;	020225, nbr - Change how files are selected and INPUT_DIR in idl2mpeg.params
;       030408 DW	Comments added
;	030617, nbr - Make it unnecessary to have write permission in gifdir
;	030709, nbr - Fix problem from previous mod
;	030715	jake	added PNG keyword
;	031010, nbr - Add NFRAMES keyword
;       061013  Karl B  - if host is einstein or hercules use giftopnm instead of giftoppm
;
; Version     :
;
; @(#)gifs2mpeg.pro	1.9 10/13/06 :LASCO IDL LIBRARY
;
;-

;-----------------------------------------------------------------------


PRO GIFS2MPEG, mpegFileName, gif_match, gifdir, WHIRLGIF=WHIRLGIF, $
		SCALE=scale, REFERENCE=reference, $
		MPEG_DIR=mpeg_dir, PNG=png, NFRAMES=n

	CD, gifdir, current=old
	giflist = FINDFILE('*'+gif_match+'*')
	nFrames = N_ELEMENTS(giflist)

	IF KEYWORD_SET(SCALE) THEN ascale = STRTRIM(scale,2) ELSE ascale = '4'
	IF KEYWORD_SET(REFERENCE) THEN aref = STRUPCASE(STRTRIM(reference,2)) ELSE aref = 'DECODED'
	IF keyword_set(MPEG_DIR) THEN mpgdir = mpeg_dir ELSE mpgdir = ''
	
	mpegFilename = concat_dir(mpgdir,mpegfilename)
	paramfile = concat_dir(mpgdir,'idl2mpeg.params')
	
	nDigits = 1+FIX(ALOG10(nFrames))
	formatString = STRCOMPRESS('(i'+STRING(nDigits)+'.'+STRING(nDigits)+ ')', /REMOVE_ALL)

	ON_IOERROR, badWrite

	;** get gif converter
	IF KEYWORD_SET(PNG) THEN BEGIN
		convert_type='PNM'
		converter='pngtopnm'
	ENDIF ELSE BEGIN
            SPAWN,'hostname',host,/SH
            IF (host EQ 'einstein') OR (host EQ 'hercules') THEN BEGIN 
                convert_type = 'PNM'
		converter = 'giftopnm'
            ENDIF ELSE BEGIN
		SPAWN, 'which giftoppm', result, /SH & result = result(0)
		IF (STRPOS(result, 'no giftoppm') GE 0) THEN BEGIN
			convert_type = 'PNM'
			converter = 'giftopnm'
		ENDIF ELSE BEGIN
			convert_type = 'PPM'
			converter = 'giftoppm'
		ENDELSE
            ENDELSE
	ENDELSE

	; Build the mpeg parameter file
	first=STRING(0,FORMAT=formatString)
	last =STRING(nFrames-1,FORMAT=formatString)
	;paramFile = gifdir + '/idl2mpeg.params'
	;paramFile = '/tmp/idl2mpeg.params'
	OPENW, unit, paramFile, /GET_LUN
	PRINTF, unit, 'PATTERN     IBBPBBPBBPBB'
	PRINTF, unit, 'OUTPUT      ' + mpegFileName
	PRINTF, unit, 'GOP_SIZE 12'
	PRINTF, unit, 'SLICES_PER_FRAME  1'
	PRINTF, unit, 'BASE_FILE_FORMAT  '+convert_type
	PRINTF, unit, 'INPUT_CONVERT  ' + converter + ' *'
	PRINTF, unit, 'INPUT_DIR .'
	PRINTF, unit, 'INPUT'
	;spawn,'ls -1 *'+gif_match+'*',giflist, /SH
	n = n_elements(giflist)
	print,'Compiling',n,' image files...'
	for i=0,n-1 do printf,unit,  giflist(i)
	;PRINTF, unit, '`ls *'+gif_match+'*`'
	PRINTF, unit, 'END_INPUT'
	PRINTF, unit, 'PIXEL    HALF'
	PRINTF, unit, 'RANGE    8'
	PRINTF, unit, 'PSEARCH_ALG LOGARITHMIC'
	PRINTF, unit, 'BSEARCH_ALG SIMPLE'
	PRINTF, unit, 'IQSCALE     '+ascale
	PRINTF, unit, 'PQSCALE     '+ascale
	PRINTF, unit, 'BQSCALE     '+ascale
	PRINTF, unit, 'REFERENCE_FRAME   '+aref
	PRINTF, unit, 'FORCE_ENCODE_LAST_FRAME'
	FREE_LUN, unit

	; spawn a shell to process the mpeg_encode command
	SPAWN, 'mpeg_encode ' + paramFile , /SH
wait,5
	;IF KEYWORD_SET(MPEG_DIR) THEN BEGIN
	;	cmd = 'mv '+mpegFileName+' '+MPEG_DIR
	;	SPAWN,cmd, /SH
	;ENDIF

	IF KEYWORD_SET(WHIRLGIF) AND NOT KEYWORD_SET(PNG) THEN BEGIN
		;   cmd = 'whirlgif -o '+mpegFileName+'.gif'+' -loop 5 -time 5 *'+gif_match+'*'
		cmd = 'whirlgif -o '+mpegFileName+'.gif'+' -loop -time 5 *'+gif_match+'*'
		print,cmd
		SPAWN, cmd, /SH
	ENDIF


	CD, old
	RETURN

	badWrite:
	help
	message, 'Unable to write MPEG file!'

END
