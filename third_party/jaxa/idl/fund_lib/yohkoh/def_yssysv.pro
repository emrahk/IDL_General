pro def_yssysv, loud=loud
;+   
;   Name: def_yssysv
;
;   Purpose: define system variables for Yohkoh SW 
;	     values are assigned elsewhere
;
;   Category:
;      swmaint, system, gen
;
;   Calling Sequence:
;	def_yssysv [,/loud] 	(generally part of idl startup)
;
;   Common Blocks:
;      def_yssysv_blk	- private to track first call
;
;   History: slf, 21-dec-1992
;            slf, 23-feb-1993 	; anonomous to make_str for compatibility
;				; with older idl versions
;            slf,  9-mar-1993   ; back to named structures - will control
;				; compatibilty with restore files within
;				; this routine
;	     slf, 30-mar-1993   ; add some new vars, error return to caller
;	     slf, 21-apr-1993   ; add !ys_idlsys_temp/!ys_idlsys_init
;	     slf, 22-apr-1993   ; removed !more tag from 21-apr (old idl prob)
;	     slf, 12-Jan-1993   ; add !ys_deftape
;	     slf, 20-Jan-1993   ; add !ys_sxt_ef
;            slf,  5-oct-1994   ; sxt pixel size
;            rdb, 23-Apr-1996   ; removed callss to anytim2ints
;            slf,  6-Aug-1997   ; added /LOUD keyword (default=quiet)
;-
common def_yssysv_blk, called

loud=keyword_set(loud)
on_error,2

if n_elements(called) eq 1 then begin
   if loud then message,/info,'YS system variables already defined, returning...'
   return
endif   
called=1  

; ------------------------ Hardware -----------------------------------
; Printer setup structure

;              -- printer definitions --

;ys_printdev=	"{dummy,"	+ $
;		"pers:'' ,"	+ $
;		"site:'', "     + $
;		"default:'' }"
;ys_printdev=make_str(ys_printdev)

ys_printdev = {!ys_printdev_01,	$	; slf, 9-mar-1993, named
		pers:'',	$
		site:'',	$
		default:''	}
defsysv, '!ys_printdev',ys_printdev
;
;
;             -- print command definitions --
;ys_printcmd=	"{dummy,"	+ $
;	 	"pers:'',"	+ $
;		"site:''," 	+ $
;		"default:'' ,"  + $
;		"filename:'',"	+ $
;		"orient:'', "	+ $
;		"font:''}"	
;ys_printcmd=make_str(ys_printcmd)
ys_printcmd = {!ys_printcmd_01,	$
		pers:'',	$
		site:'',	$
		default:'',	$
		filename:'',	$
		orient:'',	$
		font:''		}

defsysv, '!ys_printcmd',ys_printcmd
;
; --- Tape Drive ---
defsysv, '!ys_deftape',' ' 
;----------------------  Data Path --------------------------------------
;ys_dpath=	"{dummy,"	+ $
;		"pers:'',"	+ $
;		"site:'',"	+ $
;		"default:''}"
;ys_dpath=make_str(ys_dpath)
ys_dpath=	{!ys_dpath_01, 	$
		pers:'',	$
		site:'',	$
		default:''	}

defsysv, '!ys_dpath', ys_dpath
;-----------------------------------------------------------------------
;
;----------------------- IDL Environment ---------------------------------
;
ys_wdef_font = {!ys_wdef_font_01,	$	; widget default fonts
		default:'',		$	; default default
		button:'',		$	; widget type specific
		label:'',		$	; ""	""
		slider:'',		$	; ""	""
		text:''			}	; ""	""
		
; initialize values via wdef_font.pro
defsysv,'!ys_wdef_font',ys_wdef_font		; copy initial values
ys_wdef_fonti=ys_wdef_font			; initial copy
tags=tag_names(ys_wdef_font)
for i=0,n_elements(tags)-1 do $
   exestat=execute('ys_wdef_fonti.' + tags(i) + $
	'=def_font(/' + tags(i) + ',/init)')
defsysv,'!ys_wdef_fonti',ys_wdef_fonti,1	; readonly intial values
defsysv,'!ys_wdef_font',ys_wdef_fonti		; copy initial values
; ---------------------- Yohkoh Utility ----------------------------------
;
; Dynamic 
defsysv, '!ys_loc2gmt',0	; local to gmt hours offset
;
; Readonly (Yohkoh Constants) 
defsysv, '!ys_sxtpix',2.455,1	; arcsec per full resolution SXT pixel
defsysv, '!ys_hxapix',2.073,1   ; arcsec per HXA pixel
defsysv, '!ys_irupix',0.08,1    ; arcsec per IRU data value
defsysv, '!ys_tfsspix',1.93,1   ; arcsec per TFSS data value
defsysv, '!ys_sxtroll',.70,1	; sxt/sc roll offset

defsysv, '!ys_launch','10:30:00 30-Aug-91',1 	; Solar-A (yohkoh) launch

; sxt entrance filter failures
ys_sxt_ef={!ys_sxt_ef,	$
		   time:0l,		$
		   day:0,		$
		   percent_loss:0.0	}
nfails=3
fails=replicate(ys_sxt_ef,nfails)
;;ftimes=anytim2ints(['27-oct-92 05:30','13-nov-92 16:50'])
;;{    19800000    5049}{    60600000    5066}
;;ys_sxt_ef=str_copy_tags(ys_sxt_ef,ftimes)
fails.time = [19800000L,60600000L,30062000L]
fails.day  = [5049,5066,6072]
fails.percent_loss=[04.16,08.33,16.67]
defsysv,'!ys_sxt_ef',fails,1
; ------------------------------------------------------------------------
;
; idl system variable storage
; structure to hold idl system variables (read/write)
ys_idlsys={!ys_idlsys_02,		$
	    !C:!C,			$
	    !MAP:!MAP,			$
	    !P:!P,			$
	    !X:!X, !Y:!Y, !Z:!Z,	$
	    !ORDER:!ORDER		}
;	    !MORE:!MORE			} ; removed for old idl

defsysv, '!ys_idlsys_init',ys_idlsys,1	; read only startup values
defsysv, '!ys_idlsys_temp',ys_idlsys	; read/write (save/restore values)
; --------------------------------------------------------------------------
;
;
return
end
