;+
; Project     : HESSI
;
; Name        : LIST_SYNOP
;
; Purpose     : List available synoptic data servers and directory paths
;
; Category    : synoptic 
;
; Inputs      : None
;
; Outputs     : SERVERS = server names
;               PATH = server paths
;
; Keywords    : None
;
; History     : 20-Jan-2007, Zarro (ADNET/GSFC) - written.
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


pro list_synop,servers,paths

servers='sohowww.nascom.nasa.gov'

paths='/data/ancillary'

return & end
