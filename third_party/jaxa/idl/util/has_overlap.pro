;+
;NAME:
; 	has_overlap.pro
;PROJECT:
; 	ETHZ Radio Astronomy, HESSI
;CATEGORY:
; 	gen
;PURPOSE:
;	This routines accepts two arrays of intervals, and returns 1
;	if both overlap. Else, 0 is returned.;
;
;CALLING SEQUENCE:
;	res=has_overlap(interval1,interval2	[,inter=inter])
;
;INPUT:
;	interval1	: a 2-element array (float, int, double, ANYTIM string,...)
;	interval2	: a 2-element array (float, int, double, ANYTIM string,...)	
;
;
;	If one or both of the intervals are in string format, then it is
;	assumed they are dates in an ANYTIM format, and the proper
;	conversion to ANYTIM format (i.e. doubles) is done for comparison.
;
;	Intervals need not be given in ascending order, i.e.:
;		 has_overlap([a,b],[c,d])
;		 has_overlap([b,a],[c,d])
;		 has_overlap([a,b],[d,c])
;		 has_overlap([b,a],[d,c])
;			... all give the same result.
;
;OUTPUT:
;	0 (no overlap) or 1 (overlap).
;
;KEYWORD OUTPUT:
;	inter : the interval which is common to both input intervals. If none, returns -1
;
;
;
;RESTRICTIONS:
;	If input intervals are of string type, they are assumed to be ANYTIM-compatible times
;	No error checking is done.
;
;EXAMPLES:
;	IDL> res=has_overlap([3,7],[2.5,3.5])
;	IDL> res=has_overlap(['09:00:00','10:00:00'],['09:30:00','10:30:00'])
;	IDL> res=has_overlap('2000/09/03 '+['09:00:00','10:00:00'],'2000/09/03 '+['09:30:00','10:30:00'])
;
;HISTORY:
;
;	2001/05/18 created. Pascal Saint-Hilaire [shilaire@astro.phys.ethz.ch]
;
; MODIFICATIONS:
;	PSH 2001/11/16 : allowed the possibility to enter intervals in any ANYTIM format.
;	PSH 2002/03/14 : added keyword inter
;	PSH 2004/08/09 : corrected a bug where we had overlap also when the end of an interval corresponded to the beginning of the other one...
;			Also removed conversion to ECS format...
;
;-


FUNCTION has_overlap,in1,in2,inter=inter

tmp1=in1	; have to do this, because IDL passes parameters by reference...
tmp2=in2
inter=-1

IF DATATYPE(tmp1) EQ 'STR' THEN tmp1=anytim(tmp1)	; I assume that tmp1 was in anytim format...
IF DATATYPE(tmp2) EQ 'STR' THEN tmp2=anytim(tmp2)	; I assume that tmp2 was in anytim format...

a=min(tmp1)
b=max(tmp1)
c=min(tmp2)
d=max(tmp2)
IF ((c ge b) OR (d le a)) THEN RETURN,0	ELSE BEGIN
	inter=[max([a,c]),min([b,d])]
	RETURN,1
ENDELSE
END

