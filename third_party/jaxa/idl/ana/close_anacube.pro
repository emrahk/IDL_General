;+
; NAME:
;	CLOSE_ANACUBE
; PURPOSE:
;       Close ANA data cube opened with OPEN_ANACUBE
; CATEGORY:
; CALLING SEQUENCE:
;	close_anacube
; INPUTS:
;       none
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
;       anacube,anacube_window
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
;
; MODIFICATION HISTORY:
;          Mar-99  RDB  Written
;
;-

pro	close_anacube

common anacube
common anacube_window

if n_elements(ana_unit) gt 0 then $
      if ana_unit gt 0 then free_lun,ana_unit
ana_unit = -1

x0=0 & y0=0 & nx=10 & ny=10	;clear window limits...

end
