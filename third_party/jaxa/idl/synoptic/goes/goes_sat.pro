;+
; Project     : HESSI
;
; Name        : GOES_SAT
;
; Purpose     : convenient list of GOES satellite names
;
; Category    : synoptic gbo
;
; Syntax      : IDL> print, goes_sat()
;
; Inputs      : None
;
; Outputs     : GOES10 GOES8 GOES9 GOES7 GOES6
;
; Keywords    : NUMBER - return GOES satellite number
;               SINCE_1980 - return post 1980 satellites
;               LATEST - return most recent satellite
;
; History     : Written 18 June 2002, D. Zarro, LAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
; Modifications:
;   19-Apr-2007, Kim.  Added goes 11.
;   10-Aug-2008, Added since_1980 keyword.  If it's not set, include pre-1980 sats.
;   25-Nov-2009, Kim. Added 13 and 14
;   08-Nov-2010, Kim. Added 15
;   23-May-2011, Kim. Added 5
;   20-Jan-2012, Zarro (ADNET) - added LATEST keyword
;-

function goes_sat,index,number=number, since_1980=since_1980,latest=latest

sats=['15','14','13','12','11','10','9','8','7','6','5']
if ~keyword_set(since_1980) then sats = [sats,'3','2','1','92','91']
if keyword_set(latest) then sats=sats[0]
if keyword_set(number) then gsat=fix(sats) else gsat='GOES'+sats
nsat=n_elements(gsat)
if is_number(index) then return, gsat(0 > index < (nsat-1)) else return,gsat

end

