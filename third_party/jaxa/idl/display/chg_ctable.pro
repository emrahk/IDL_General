;---------------------------------------------------------------------------
; Document name: chg_ctable.pro
; Created by:    Liyun Wang, NASA/GSFC, November 20, 1995
;
; Last Modified: Mon Nov 20 17:23:27 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO chg_ctable, gamma=gamma, bottom=bottom, top=top, ncolors=nc
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       CHG_CTABLE
;
; PURPOSE:
;       Change current color table in terms of gamma, bottom and top
;
; CATEGORY:
;
;
; EXPLANATION:
;       There are cases where there is a need to change the current color
;       table in terms of gamma, first and last color index to
;       use. This routine does exactly this.
;
; SYNTAX:
;       chg_ctable, gamma=gamma, bottom=bottom, top=top
;
; EXAMPLES:
;       IDL> loadct, 3
;       IDL> chg_ctable, gamma=0.67, bottom=20
;
; INPUTS:
;       None required.
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       GAMMA = Gamma value (0.1 to 10.0) to be set
;       BOTTOM = First color index to use
;       TOP = Last color index to use
;	NCOLORS = number of colors to use.  Use color indices from BOTTOM
;		to the smaller of !D.TABLE_SIZE-1 and NCOLORS-1.;
; COMMON:
;       COLORS
;
; RESTRICTIONS:
;       But be called only after LOADCT (otherwise variables in COLORS
;          common blocks will not be defined.
;
; SIDE EFFECTS:
;       Current color table is changed.
;
; HISTORY:
;       Version 1, November 20, 1995, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   COMMON colors
   ON_ERROR, 2
   IF NOT KEYWORD_SET(gamma) THEN gamma = 1.0
   IF NOT KEYWORD_SET(bottom) THEN bottom = 0
   IF NOT KEYWORD_SET(top) THEN top = 100

   IF N_ELEMENTS(bottom) GT 0 THEN cbot = bottom ELSE cbot = 0
   ncolors = !d.table_size - cbot

   IF N_ELEMENTS(nc) GT 0 THEN ncolors = ncolors < nc
   IF ncolors LE 0 THEN MESSAGE, 'Number of colors is 0 or negative'
   nc = ncolors

   TVLCT, r_orig, g_orig, b_orig, /GET
   r_curr = r_orig
   b_curr = b_orig
   g_curr = g_orig

   s = (nc-1)/100.
   x0 = bottom * s
   x1 = top * s
   IF x0 NE x1 THEN s = (nc-1.0)/(x1 - x0) ELSE s = 1.0
   int = -s * x0
   IF gamma EQ 1.0 THEN s = round(FINDGEN(nc) * s + int > 0.0) $
   ELSE s = ((FINDGEN(nc) * (s/nc) + (int/nc) > 0.0) ^ gamma) * nc
   s = s + cbot
   r_curr(cbot) = (r=r_orig(s))
   g_curr(cbot) = (g=g_orig(s))
   b_curr(cbot) = (b=b_orig(s))
   TVLCT, r, g, b, cbot

END

;---------------------------------------------------------------------------
; End of 'chg_ctable.pro'.
;---------------------------------------------------------------------------
