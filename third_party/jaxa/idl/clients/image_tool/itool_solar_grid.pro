;---------------------------------------------------------------------------
; Document name: itool_solar_grid.pro
; Created by:    Liyun Wang, NASA/GSFC, April 11, 1995
;
; Last Modified: Tue Aug 27 11:02:59 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO itool_solar_grid, lati, longi, date=date, linestyle=linestyle, $
                      color=color, limb=limb
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       ITOOL_SOLAR_GRID
;
; PURPOSE:
;       Plot grid lines over the solar image
;
; CALLING SEQUENCE:
;       itool_solar_grid, lati, longi, date=date
;
; INPUTS:
;       LATI  - The spacing in degrees between parallels of latitude;
;               default: 15.0 degrees. If LATI is zero or negative, no
;               latitudinal lines will be plotted
;       LONGI - The spacing in degrees between meridians of longitude;
;               default: 15.0 degrees. If LONGI is zero or negative, no
;               longitudinal lines will be plotted
;       DATE  - Data/time in CDS time format at which the grid is plotted.
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
; KEYWORD PARAMETERS:
;       LINESTYLE -- Line style to be used, default: dotted (1)
;       COLOR     -- color of the line to be draw; default: !d.table_size-1
;       LIMB      -- Plot limb of the solar disc if set
;
; CALLS:
;       HEL2ARCMIN
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       Can be called only AFTER the data coordinate system is established,
;       so it would be OK if it is called after ITOOL_PLOT_AXES is
;       called (which also sets the data coordinate system)
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Planning, Image_tool
;
; PREVIOUS HISTORY:
;       Written April 11, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, April 11, 1995
;       Version 2, July 14, 1995, Liyun Wang, NASA/GSFC
;          Added the LIMB keyword
;	Version 3, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;
; VERSION:
;	Version 3, 8 April 1998
;-
;
   ON_ERROR, 2
   IF N_ELEMENTS(linestyle) EQ 0 THEN linestyle = 1
   IF N_ELEMENTS(color) EQ 0 THEN color = !d.table_size-1

   CASE (N_PARAMS()) OF
      0: BEGIN
         lati = 15.0
         longi = 15.0
      END
      1: longi = 15.0
      ELSE:
   ENDCASE

;---------------------------------------------------------------------------
;  Test to see if the data coordinate system has been established
;---------------------------------------------------------------------------
   IF (!x.s(0) EQ 0.0 AND !x.s(1) EQ 0.0) OR $
      (!y.s(0) EQ 0.0 AND !y.s(1) EQ 0.0) THEN BEGIN
      MESSAGE, 'Data coordinate system not yet established.', /cont
      RETURN
   ENDIF

;---------------------------------------------------------------------------
;  Plot meridians of longitudes; Central meridian first
;---------------------------------------------------------------------------
   vlati = 90.0-FINDGEN(180)
   nlati = N_ELEMENTS(vlati)
   IF longi GT 0.0 THEN BEGIN 
      FOR vl=0.0, 89.0, longi DO BEGIN
         vlong = REPLICATE(vl, nlati)
         temp = hel2arcmin(vlati, vlong, date=date)*60.0
         IF vl EQ 0.0 THEN thick = 2 ELSE thick = 1
         PLOTS, temp(0, *), temp(1, *), /data, lines=linestyle, noclip=0, $
            thick=thick, color=color
         IF vl NE 0.0 THEN BEGIN
            vlong = REPLICATE(-vl, nlati)
            temp = hel2arcmin(vlati, vlong, date=date)*60.0
            PLOTS, temp(0, *), temp(1, *), /data, lines=linestyle, $
               noclip=0, color=color
         ENDIF
      ENDFOR
   ENDIF 
   
;---------------------------------------------------------------------------
;  Plot the limb longitude if LIMB is set
;---------------------------------------------------------------------------
   IF KEYWORD_SET(limb) THEN BEGIN
      vl = 90.0
      vlong = REPLICATE(vl, nlati)
      temp = hel2arcmin(vlati, vlong, date=date)*60.0
      PLOTS, temp(0, *), temp(1, *), /data, lines=linestyle, noclip=0, $
         thick=thick, color=color
      vlong = REPLICATE(-vl, nlati)
      temp = hel2arcmin(vlati, vlong, date=date)*60.0
      PLOTS, temp(0, *), temp(1, *), /data, lines=linestyle, $
         noclip=0, color=color
   ENDIF
   
;----------------------------------------------------------------------
;  Plot parallels of latitudes; equatorial circle first
;----------------------------------------------------------------------
   vlong = 90.0-FINDGEN(180)
   nlong = N_ELEMENTS(vlong)
   IF lati GT 0.0 THEN BEGIN 
      FOR vl=0.0, 90.0, lati DO BEGIN
         vlati = REPLICATE(vl, nlong)
         temp = hel2arcmin(vlati, vlong, date=date)*60.0
         IF vl EQ 0.0 THEN thick = 2 ELSE thick = 1
         PLOTS, temp(0, *), temp(1, *), /data, lines=linestyle, noclip=0, $
            thick=thick, color=color
         IF vl NE 0.0 THEN BEGIN
            vlati = REPLICATE(-vl, nlong)
            temp = hel2arcmin(vlati, vlong, date=date)*60.0
            PLOTS, temp(0, *), temp(1, *), /data, lines=linestyle, $
               noclip=0, color=color
         ENDIF
      ENDFOR
   ENDIF
   
END

;---------------------------------------------------------------------------
; End of 'itool_solar_grid.pro'.
;---------------------------------------------------------------------------
