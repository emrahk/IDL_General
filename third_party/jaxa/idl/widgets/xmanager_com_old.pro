;+
; Project     : SOHO - CDS     
;                   
; Name        : XMANAGER_COM_OLD
;               
; Purpose     : return widget ID's and application names from
;               XMANAGER common block
;               
; Category    : widgets
;               
; Explanation : useful to check what the heck XMANAGER is doing when
;               an application crashes. Used for IDL version le 3.6.
;               The XMANAGER common block MANAGED has to be hardwired
;               in this case.
;               
; Syntax      : IDL> XMANAGER_COM_OLD,IDS,NAMES
;    
; Examples    : 
;
; Inputs      : None.
;               
; Opt. Inputs : None
;               
; Outputs     : WIDS = long array of widget IDS
;               WNAMES = companion string array of associated application names
;               WNUMMANAGED = number of widgets being managed
;
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; History     : Version 1,  17-July-1996,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro xmanager_com_old,wids,wnames,wnummanaged

COMMON MANAGED, ids, names, $
                nummanaged, inuseflag, $
                backroutines, backids, backnumber, nbacks, validbacks, $
                blocksize, $
                cleanups, $
                outermodal 

if datatype(ids) eq 'LON' then wids=ids
if datatype(names) eq 'STR' then wnames=names
if exist(nummanaged) then wnummanaged=nummanaged

return & end

