pro ssw_setsswdb_gen, force=force
;
;+
;   Name: ssw_setsswdb_gen
;
;   Purpose: set general use SSWDB environment not otherwise set
;
;   Input Parameters:
;      NONE
;
;   Output Parameters:
;      NONE
;
;   Keyword Parameters:
;      FORCE - if set, setup envs indpendent of pre-existing check
;
;   Calling Sequence:
;      IDL> ssw_setsswdb_gen (normally from SSW-gen IDL_STARTUP )
;
;   Side Effects: will set certain environmentals relative to $SSWDB & $ydb
;
;
;   History:
;      2-Nov-2005 - S.L.Freeland - to allow use of "Yohkoh" general
;                   interest $SSWDB($ydb), such as gev, nar, & goes LC
;
;-
;
force=keyword_set(force)
; Verify $SSWDB & $ydb general purpose dbases
sswdb_setup=concat_dir('$SSW_GEN_SETUP','setup.sswdb_env')
if get_logenv('DIR_GEN_GEV') eq '' or force then begin ; =>no Yohokh setup run
   if file_exist(sswdb_setup) then set_logenv,file=sswdb_setup,/quiet
endif

return
end


