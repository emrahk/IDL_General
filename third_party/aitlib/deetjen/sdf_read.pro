;-------------------------------------------------------------------------------
;
; PURPOSE: Read an ASCII file given in the Scientific Data Format.
;
PRO sdf_read, data_file, data, title=title, nr_col=nr_col, nr_row=nr_row
   
   ;; Read in data file
   ;;
   GET_LUN, unit
   OPENR, unit, data_file
   
   dummy = ' '
   line  = ' '
   
   ;; read 1st line
   ;;
   READF, unit, dummy
   
   ;; read 2nd line
   ;;
   READF, unit, line
   
   compressed_line = STRCOMPRESS( line )
   compressed_line = STRTRIM(compressed_line, 2)
   parts           = STR_SEP( compressed_line, ' ' )
   
   
   IF (parts[0] EQ '*') THEN BEGIN
       nrColumns = parts[1]
       nrRows    = parts[2]
   ENDIF ELSE BEGIN
       nrColumns = parts[0]
       nrRows    = parts[1]
   ENDELSE
   
   ;; read 3d line
   ;;
   READF, unit, line
   
   compressed_line = STRCOMPRESS( line )
   compressed_line = STRTRIM(compressed_line, 2)
   parts           = STR_SEP( compressed_line, ' ' )
    
   title           = strarr(nrColumns-1)

   IF (N_ELEMENTS(parts) GT 1) THEN BEGIN
     IF (PARTS[1] EQ 'TITLE:') THEN BEGIN
       READF, UNIT, LINE
       COMPRESSED_LINE = STRCOMPRESS( LINE )
       COMPRESSED_LINE = STRTRIM(COMPRESSED_LINE, 2)
       PARTS           = STR_SEP( COMPRESSED_LINE, ' ' )
       TITLE           = PARTS[1:NRCOLUMNS-1]
       
       ;; READ 4TH LINE
       ;;
       READF, UNIT, LINE
     ENDIF
   ENDIF
   ;; read body
   ;;
   data = DBLARR( nrColumns, nrRows )
   
   READF, unit, data
   FREE_LUN, unit
   
   nr_col = nrColumns
   nr_row = nrRows
   
END
;; of SDF_READ -----------------------------------------------------------------

;
;-------------------------------------------------------------------------------
