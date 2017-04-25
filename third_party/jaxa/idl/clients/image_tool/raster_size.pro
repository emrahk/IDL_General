;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: raster_size.pro
; Created by:    Liyun Wang, NASA/GSFC, October 31, 1994
;
; Last Modified: Mon Mar 27 14:55:25 1995 (lwang@achilles.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO RASTER_SIZE, raster, width=width, height=height
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       RASTER_SIZE
;
; PURPOSE:
;       Get raster size based on RASTER structure from GET_RASTER.
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       RASTER_SIZE, raster, width=width, height=height
;
; INPUTS:
;       RASTER -- A structure of type "CDS_RASTER" obtained by
;                 GET_RASTER. It should have the following tags:
;
;          RAS_ID     = Raster ID number.  If the requested raster
;                       is not found, then a simpler structure is
;                       returned, with this set to -1.
;          DETECTOR   = Either "G" for GIS or "N" for NIS.
;          RAS_DESC   = A short description of the raster, giving
;                       its purpose.
;          SLIT_NUM   = The ID number for the slit to be used.
;          XSTEP      = The step size in the X direction, in
;                       arcsec.
;          YSTEP      = The step size in the Y direction, in
;                       arcsec.
;          NX         = The number of exposure positions in X.
;          NY         = The number of exposure positions in Y.
;          RAS_VAR    = Raster variation index.
;          RV_DESC    = A short description of the raster
;                       variation beyond what is given in the
;                       associated fundamental raster description.
;          EXPTIME    = Exposure time in seconds, to millisecond
;                       accuracy.
;          LL_ID      = Line list ID.  Alternatively, this can be
;                       zero to signal that the raster is not
;                       connected to a line list.
;          LL_DESC    = A description of the line list, e.g.
;                       "Temperature sensitive line pairs".
;          N_LINES    = The number of lines.
;          COMP_ID    = Compression method ID.
;          COMP_OPT   = Compression option parameter.
;          DW_ID      = Data extraction window list ID.
;          DW_DESC    = A short description of the data window
;                       list beyond what is given in the
;                       associated line list description, e.g.
;                       "Full slit, 10 pixels wide".
;          W_WIDTH    = Width in pixels used to generate the windows
;          W_HEIGHT   = Height in pixels used to generate the
;                       windows. VDS only, for GIS this is set to zero
;          VDS_ORIENT = VDS orientation, either 0 (row) or 1
;                       (column).
;          VDS_MAP    = VDS mapping mode: 2=Normal, 3=Accumulate.
;          VDS_BACK   = Either 0 for off, or 1 for on,
;                       representing whether or not VDS background
;                       windows are being used.  For GIS window
;                       lists this is 0.
;          N_WINDOWS  = The number of windows.
;          TEL_RATE   = Estimated required telemetry rate, as a
;                       character representing Low/Medium/High
;          DURATION   = Estimated duration of the raster, in
;                       seconds.
;          USABLE     = Either "Y" or "N" to signal whether or not
;                                    the raster is usable.  Normally "Y".
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       WIDTH  -- East/West extent of the raster, in arcsecs
;       HEIGHT -- North/South extent of the raster, in arcsecs
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       None.
;
; CALLS:
;       DATATYPE
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Planning, image_tool
;
; PREVIOUS HISTORY:
;       Written October 31, 1994, by Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;
; VERSION:
;       Version 1, October 31, 1994
;-
;
   ON_ERROR, 2

   IF datatype(raster) NE 'STC' OR N_PARAMS() NE 1 THEN BEGIN
      MESSAGE,'Syntax: RASTER_SIZE, structure'
      RETURN
   ENDIF

;    IF N_ELEMENTS(TAG_NAMES(raster)) NE 18 THEN BEGIN
;       MESSAGE,'Input structure is not valid. It has to be created ',/cont
;       MESSAGE,'with GET_CDS_SHAPE.'
;       RETURN
;    ENDIF

;----------------------------------------------------------------------
;  Assign 6 slit sizes
;----------------------------------------------------------------------
   s_w = [2,4, 8,  2,  4, 90]
   s_h = [2,4,51,240,240,240]
   
   IF raster.detector EQ 'N' THEN BEGIN
;----------------------------------------------------------------------
;     For the NIS detector:
;        N/S extent = slit_height < w_height*2
;        E/W extent = (NX-1)*XSTEP + slit_width
;----------------------------------------------------------------------
      height = s_h(raster.slit_num-1) < 2*raster.w_height
      width = (raster.nx-1)*raster.xstep+s_w(raster.slit_num-1)
   ENDIF ELSE BEGIN
;----------------------------------------------------------------------
;     For the GIS detector:
;        N/S extent = (NY-1)*YSTEP + slit_height
;        E/W extent = (NX-1)*XSTEP + slit_width
;----------------------------------------------------------------------
      height = (raster.ny-1)*raster.ystep+s_h(raster.slit_num-1)
      width = (raster.nx-1)*raster.xstep+s_w(raster.slit_num-1)
   ENDELSE
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'raster_size.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
