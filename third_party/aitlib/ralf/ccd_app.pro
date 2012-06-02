FUNCTION CCD_APP, file, EXT=ext, APP=app
;
;+
; NAME:
;	CCD_APP
;
; PURPOSE:   
;	Return string xxx_APP.EXT from
;	input file name xxx.***. 
;
; CATEGORY:
;	General.
;
; CALLING SEQUENCE:
;	CCD_APP, file, EXT=ext, APP=app
;
; INPUTS:
;	FILE : String with file name.
;	EXT  : See above.
;	APP  : See above.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	NONE.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(file) then message,'File name missing'

pos=RSTRPOS(file,'.')
if pos(0) eq -1 then message,'File name not of format xxx.extension'

if not EXIST(ext) then ext=STRMID(file,pos(0)+1,1000)

if EXIST(app) then $
out=STRMID(file,0,pos(0))+'_'+app+'.'+ext else $
out=STRMID(file,0,pos(0))+'.'+ext

RETURN,out
END
