;-------------------------------------------------------------
;+
; NAME:
;       STREP
; PURPOSE:
;       Edit a string by position. Precede, Follow, Replace, Delete.
; CATEGORY:
; CALLING SEQUENCE:
;       newstring = strep(string,cmd,p,ss,[iflg])
; INPUTS:
;       string = string to edit.                               in
;       cmd = edit command:                                    in
;         'P' = precede position p with substring ss.
;         'F' = follow position p with substring ss.
;         'R' = replace text starting at position p
;               with text from substring ss.
;         'D' = delete N characters starting at
;               position p.  The calling sequence for
;               this command is slightly different:
;               IFLG = STREP(string,'D',p,n,[iflg])
;               Where n = number of characters to delete.
;       p = character position to use.                         in
;           0 = first char.  Any number larger
;           than the string length = last char.
;       ss = substring to use.  For 'D' command                in
;            n is used instead of ss.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       iflg = 0 for a successful edit,                        out
;       iflg = -1 for an error and no change to string.
;       newstring = edited string.                             out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 27 Dec, 1984.
;       Converted to SUN 13 Aug, 1989 --- R. Sterner.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function strep,s,cmd,ip,ss,iflg, help=hlp 
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Edit a string by position. Precede, Follow, Replace, Delete.'
	  print,' newstring = strep(string,cmd,p,ss,[iflg])
	  print,'   string = string to edit.                               in'
	  print,'   cmd = edit command:                                    in'
	  print,"     'P' = precede position p with substring ss.
	  print,"     'F' = follow position p with substring ss.
	  print,"     'R' = replace text starting at position p
	  print,'           with text from substring ss.
	  print,"     'D' = delete N characters starting at
	  print,'           position p.  The calling sequence for
	  print,'           this command is slightly different:
	  print,"           IFLG = STREP(string,'D',p,n,[iflg])
	  print,'           Where n = number of characters to delete.
	  print,'   p = character position to use.                         in'
	  print,'       0 = first char.  Any number larger
	  print,'       than the string length = last char.
	  print,"   ss = substring to use.  For 'D' command                in"
	  print,'        n is used instead of ss.
	  print,'   iflg = 0 for a successful edit,                        out'
	  print,'   iflg = -1 for an error and no change to string.
	  print,'   newstring = edited string.                             out'
	  return, -1
	endif
 
	N = STRLEN(S) - 1
	IF N LT 0 THEN $
	  IF CMD EQ 'D' THEN RETURN, '' ELSE RETURN, SS
	P = IP>0<N
	BS = BYTE(S)
	IF (CMD NE 'D') THEN  BSS = BYTE(SS)
	JFLG = 0
 
	CASE CMD OF
  'P':	BEGIN
	IF P EQ 0 THEN T = [BSS,BS] ELSE $
		T = [BS(0:P-1),BSS,BS(P:*)]
	END
  'F':	BEGIN
	IF P EQ N THEN BEGIN
	  T = [BS,BSS]
	ENDIF ELSE BEGIN
	  IF IP GE 0 THEN BEGIN
	    T = [BS(0:P),BSS,BS(P+1:*)]
	  ENDIF ELSE BEGIN
	    T = [BSS, BS]
	  ENDELSE
	ENDELSE
	END
  'R':  BEGIN
	NSS = STRLEN(SS)
	IF NSS GT N - P + 1 THEN $
		T = [BS(0:P-1),BSS] $
	ELSE BEGIN $
		T = BS
		T(P) = BSS
	ENDELSE
	END
  'D':	BEGIN
	ND = SS < (N + 1)
	IF P EQ 0 THEN $
	  IF ND EQ N+1 THEN T = '' ELSE $
	    T = [BS(ND:*)]
	IF P GT 0 THEN $
	  IF ND+P-1 GE N THEN $
	    T = [BS(0:P-1)] ELSE $
	    T = [BS(0:P-1),BS(ND+P:*)]
	END
  ELSE: JFLG = -1
  ENDCASE
 
	IF JFLG NE 0 THEN T = S
	IF JFLG EQ 0 THEN T = STRING(T)
	IF N_PARAMS(0) EQ 5 THEN IFLG = JFLG
 
 
	RETURN,T
 
	END

;-------------------------------------------------------------
;+
; NAME:
;       STRESS
; PURPOSE:
;       String edit by sub-string. Precede, Follow, Delete, Replace.
; CATEGORY:
; CALLING SEQUENCE:
;       new = stress(old,cmd,n,oldss,newss,ned)
; INPUTS:
;       old = string to edit.                               in
;       cmd = edit command:                                 in
;         'P' = precede.
;         'F' = follow.
;         'D' = delete.
;         'R' = replace.
;       n = occurrence number to process (0 = all).         in
;       oldss = reference substring.                        in
;       oldss may have any of the following forms:
;         1. s	  a single substring.
;         2. s...    start at substring s, end at end of string.
;         3. ...e    from start of string to substring e.
;         4. s...e   from subs s to subs e.
;         5. ...     entire string.
;       newss = substring to add. Not needed for 'D'        in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ned = number of occurrences actually changed.       out
;       new = resulting string after editing.               out
; COMMON BLOCKS:
; NOTES:
;       Notes: oldss and newss may be arrays.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 6 Jan, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES --- 23 May, 1988 fixed a bug in SSTYP = 2.
;       Converted to SUN 13 Aug, 1989 --- R. Sterner. (FOR loop change).
;       --- 8 Dec, 1992 added recursion so that OLDSS and NEWSS may be arrays
;       T.J.Harris, University of Adelaide.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function stress,strng,cmdx,n,old_in,new_in,ned, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' String edit by sub-string. Precede, Follow, Delete, Replace.'
	  print,' new = stress(old,cmd,n,oldss,newss,ned)
	  print,'   old = string to edit.                               in'
	  print,'   cmd = edit command:                                 in'
	  print,"     'P' = precede.
	  print,"     'F' = follow.
	  print,"     'D' = delete.
	  print,"     'R' = replace.
	  print,'   n = occurrence number to process (0 = all).         in'
	  print,'   oldss = reference substring.                        in'
	  print,'   oldss may have any of the following forms:
	  print,'     1. s	  a single substring.
	  print,'     2. s...    start at substring s, end at end of string.
	  print,'     3. ...e    from start of string to substring e.
	  print,'     4. s...e   from subs s to subs e.
	  print,'     5. ...     entire string.
	  print,"   newss = substring to add. Not needed for 'D'        in"
	  print,'   ned = number of occurrences actually changed.       out'
	  print,'   new = resulting string after editing.               out'
	  print,' Notes: oldss and newss may be arrays.'
	  return, -1
	endif
 
	;--- if old_in an array then do the first element then call recursively
	old = old_in(0)
	if (n_elements(new_in) Gt 0) then new = new_in(0)
 
	cmd = strupcase(cmdx)
	pdot = strpos(old,'...')
	ssl = strlen(old)
	sstyp = 0
	pos1 = -1
	pos2 = -1
	rstr = strng
	if (pdot eq -1) then sstyp = 1
;	IF ((PDOT>0) EQ SSL-3) THEN SSTYP = 2
	if (pdot gt 0) and (pdot eq ssl-3) then sstyp = 2
	if (pdot eq 0) and (ssl gt 3) then sstyp = 3
	if (pdot gt 0) and (pdot lt ssl-3) then sstyp = 4
	if (pdot eq 0) and (ssl eq 3) then sstyp = 5
	ned = 0		; Number of occurrences actually changed.
 
 
	case sstyp of
1:	  begin
	    s = old
	    e = ''
	  end
2:	  begin
	    s = strsub(old,0,ssl-4)
	    e = ''
    	  end
3:  	  begin
	    s = ''
	    e = strsub(old,3,ssl-1)
	  end
4:  	  begin
	    s = strsub(old,0,pdot-1)
	    e = strsub(old,pdot+3,ssl-1)
	  end
5:  	  begin
	    s = ''
	    e = ''
	  end
else: 	  print, ' Error in STRESS: Error in sstyp'
	endcase
 
 
;---------------  Find substring # N start  ---------------
	pos = -1
	nfor = n>1
loop:
	for i = 1, nfor do begin
	  pos = pos + 1
	  case sstyp of
    1:      pos = strpos(rstr,s,pos)
    2:      pos = strpos(rstr,s,pos)
    4:      pos = strpos(rstr,s,pos)
    3:      pos = strpos(rstr,e,pos)
    5:      pos = 0
	  endcase
  	  if pos lt 0 then goto, done
	endfor
 
;----------  Find substring # N END  ----------------
    	case sstyp of
1:  	  begin
	    pos1 = pos
	    pos2 = pos + strlen(s) - 1
	  end
2:  	  begin
	    pos1 = pos
	    pos2 = strlen(rstr) - 1
	  end
3:  	  begin
	    pos1 = 0
	    pos2 = pos + strlen(e) - 1
	  end
4:  	  begin
	    pos1 = pos
	    pos2 = strpos(rstr,e,pos+1)
	    if (pos2 lt 0) then goto, done
	    pos2 = pos2 + strlen(e) - 1
	  end
5:  	  begin
	    pos1 = 0
	    pos2 = strlen(rstr) - 1
	  end
	endcase
 
;------------  edit string  --------------
    	case cmd of
'P':  	  begin
	    rstr = strep(rstr,cmd,pos1,new)
	    pos = pos + strlen(new)
	  end
'F':  	  begin
	    rstr = strep(rstr,cmd,pos2,new)
	    pos = pos + strlen(new)
	  end
'R':  	  begin
	    rstr = strep(rstr,'D',pos1,pos2-pos1+1)
	    if (pos1 gt 0) then $
	      rstr = strep(rstr,'F',pos1-1,new)
	    if (pos1 eq 0) then $
	      rstr = strep(rstr,'P',0,new)
	    pos = pos + strlen(new) - 1
	  end
'D':  	  begin
	    rstr = strep(rstr,cmd,pos1,pos2-pos1+1)
	    pos = pos - 1
	  end
else: 	  begin
	    print, 'Error in STRESS: unknown command.'
	    return,rstr
	  end
endcase
 
	ned = ned + 1
	if sstyp eq 5 then return,rstr
	if n eq 0 then goto, loop
 
done:
 
	;--- if old_in an array then do the first element then call recursively
	;--- and accumulate the results
	if (n_elements(old_in) gt 1) then begin	;call again until done all
		old = old_in(1:*)
		if (n_elements(new_in) gt 1) then new = new_in(1:*)
		tmp = 0
		rstr = stress(rstr,cmdx,n,old,new,tmp)
		ned = ned+tmp
	endif
	return, rstr
	end
