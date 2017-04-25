;+
; Project     : HESSI
;
; Name        : YDB_PATH
;
; Purpose     : return path to synoptic data
;
; Category    : synoptic sockets
;                   
; Inputs      : None
;
; Outputs     : PATH =  environment value associated with $ydb
;                        [def=''/sdb/yohkoh/ys_dbase']
;
; Keywords    : None
;
; History     : 29-Dec-2001,  D.M. Zarro (EITI/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function ydb_path

ydb='/sdb/yohkoh/ys_dbase'

return,ydb

end
