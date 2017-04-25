;+
; NAME:
;	 DEFAULTS
;
; PURPOSE: 
;	Supply default volume, directory, and extension parts of a file name 
;	when not supplied.   
;
; CATEGORY:
;	GEN
;
; CALLING SEQUENCE:
;	DEFAULTS,Filenm,Volume,Dir,Ext  
;
; INPUTS:
;   	Filenm:	File name (also an output parameter)
;   	Volume:	Default volume to insert in FILENM (include colon).  If either 
;            	a colon or a right bracket appears in FILENM, then the volume 
;            	and directory information in FILENM are left alone.  
;            	Otherwise, VOLUME and DIR are inserted in FILENM. 
;   	Dir:	Default directory to insert in FILENM.  See above.
;   	Ext:	Default extension (include period).  If FILENM has no 
;            	extension, EXT is appended. Set to ' ' to indicate no default.
;
; OUTPUTS:
;   	Filenm:	Complete file name with volume, directory, filename, 
;		and extension.
; EXAMPLE:
;    	FILENM = 'HXR1000'
;    	DEFAULTS,FILENM,'HXRBS$DATA:','','.SC4' 
;    	FILENM is now set to 'HXRBS$DATA:HXR1000.SC4'
; RESTRICTIONS:
;	Designed for VMS, considered obsolete, unsure of UNIX support.
;	Modified to use break_file and concat_dir
; MODIFICATION HISTORY:
;       Mod. 12/16/88.
;	Mod. 04/26/89.
;	Mod. 05/06/96 by RCJ. Added documentation.
;	Version 4, ras, 23-may-1996, using break_file and concat_dir
;-
pro defaults,filenm,volume,dir,ext 


break_file, filenm, disk_in, dir_in, fnam_in, ext_in, version, node_in
if disk_in eq '' then disk_in = fcheck(volume, '')
if dir_in eq '' then dir_in = fcheck(dir, '')
if ext_in eq '' then ext_in = fcheck(ext, '')

filenm = node_in+concat_dir( disk_in+dir_in, fnam_in+ext_in+version)

end
