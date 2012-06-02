PRO mergelc,t1,c1,t2,c2
;+
; NAME:
;     mergelc
;
;
; PURPOSE:
;     merge two disjunct light curves t1,c1 and t2,c2 and return the
;     merged light curve in t1,c1 (e.g. for merging HEXTE light-curves)
;
; CATEGORY:
;     X-ray astronomy
;
;
; CALLING SEQUENCE:
;     mergelc,t1,c1,t2,c2
;
; 
; INPUTS:
;     t1,c1: 1st light curve
;     t2,c2: 2nd light curve
;
; OPTIONAL INPUTS:
;     none
;
;	
; KEYWORD PARAMETERS:
;     none
;
;
; OUTPUTS:
;     t1,c1: the merged light-curve
;
;
; OPTIONAL OUTPUTS:
;     none
;
;
; COMMON BLOCKS:
;     none
;
;
; SIDE EFFECTS:
;     t1,c1 gets overwritten ; the routine is using sort, use with
;     care with large arrays... also possible memory restrictions
;     might apply
;
;
; RESTRICTIONS:
;     the light curves have to be disjunct, i.e. none of the times is
;     allowed to occur twice.
;
;
; PROCEDURE:
;     trivial :-)
;
;
; EXAMPLE:
;     readlc,t1,c1,'hextea.txt_src.lc'
;     readlc,t2,c2,'hexteb.txt_src.lc'
;     mergelc,t1,c1,t2,c2
;     plot,t1,c1
;     ... and enjoy
;
; MODIFICATION HISTORY:
;     version 1.0, 1997/03/04  Ingo Kreykenbohm and Joern Wilms, AIT
;-

   idx1=where(c1 ne 0.)
   idx2=where(c2 NE 0.)
   t1=[t1(idx1),t2(idx2)]
   c1=[c1(idx1),c2(idx2)]

   sidx=sort(t1)
   t1=t1(sidx)
   c1=c1(sidx)
END 



