;+
; NAME: 
;	DEFAULTS_2
;
; PURPOSE: 
;	Supply default volume, directory, and extension parts of a file name 
;	when not supplied.
;
; 	See DEFAULTS for positional parameters.
;
; CATEGORY:
;	GEN
;
; CALLING SEQUENCE:
; 	DEFAULTS_2,filenm=Filemn,volume=Volume,directory=Dir,extension=Ext
;
; CALLS:
;       Checkvar, defaults.
;
; INPUTS:
;   	Filenm:	File name (also an output parameter)
;   	Volume:	Default volume to insert in FILENM (include colon).  If either 
;            	a colon or a right bracket appears in FILENM, then the volume 
;            	and directory information in FILENM are left alone.  
;            	Otherwise, VOLUME and DIR are inserted in FILENM. 
;   	Dir:	Default directory to insert in FILENM.  See above.
;   	Ext:	Default extension (include period).  If FILENM has no 
;            	extension, EXT is appended.
;
; OUTPUTS:
;       Filenm:	Complete file name with volume, directory, filename,
;               and extension.
;
; EXAMPLE:
;    	FILENM = 'HXR1000'
;    	DEFAULTS,FILE=FILENM,DIR='HXRBS$DATA:',EXT='.SC4' 
;    	FILENM is now set to 'HXRBS$DATA:HXR1000.SC4'
;
; MODIFICATION HISTORY:
;       Mod. 02/12/91.
;	Mod. 05/06/96 by RCJ. Added documentation.
;-
pro defaults_2, filename=filenm, volume=volume, directory=dir, extension=ext
;
checkvar,volume,''
checkvar,dir,''
checkvar,ext,''

defaults,filenm,volume,dir,ext        ;add volume,dir, and ext if absent

end
