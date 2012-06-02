;-------------------------------------------------------------------------------
;
; PURPOSE: Show an SDF file using mzoom_plot
;
PRO sdf_show, file1, file2=file2, file3=file3, select=select, dir=dir, no_neg=no_neg, _Extra=extra
   
   
   ;; Read in data file
   ;;
   IF (keyword_set(dir)) THEN file1 = dir+file1
   sdf_read, file1, data1, title=title
   
   IF (keyword_set(file2)) THEN BEGIN
       IF (keyword_set(dir)) THEN file2 = dir+file2
       sdf_read, file2, data2
   END
   
   IF (keyword_set(file3)) THEN BEGIN
       IF (keyword_set(dir)) THEN file3 = dir+file3
       sdf_read, file3, data3
   END   
   
   ;; Avoid negative y-values
   ;;
   IF (keyword_set(no_neg)) THEN BEGIN
       
       idx = WHERE (data1 LE 0.0)
       data1(idx) = 1E-25
       
       IF (keyword_set(file2)) THEN BEGIN
           idx = WHERE (data2 LE 0.0)
           data2(idx) = 1E-25
       END
           
       IF (keyword_set(file3)) THEN BEGIN
           idx = WHERE (data3 LE 0.0)
           data3(idx) = 1E-25
       END
   END
           
   ;; Plot data
   ;;
   IF (keyword_set(select)) THEN BEGIN

     IF (keyword_set(FILE2)) THEN BEGIN
       IF (KEYWORD_SET(FILE3)) THEN BEGIN

         I = select
         ZOOM_PLOT, REFORM(DATA1[0,*]), REFORM(DATA1[I,*]), $
           X2=REFORM(DATA2[0,*]), Y2=REFORM(DATA2[I,*]),  $
           X3=REFORM(DATA3[0,*]), Y3=REFORM(DATA3[I,*]),  $
           _EXTRA=EXTRA
               
       END ELSE BEGIN
               
         I = select
         ZOOM_PLOT, REFORM(DATA1[0,*]), REFORM(DATA1[I,*]), $
           X2=REFORM(DATA2[0,*]), Y2=REFORM(DATA2[I,*]),  $
           _EXTRA=EXTRA
         
       END 
     END ELSE BEGIN
       
       I = select
       ZOOM_PLOT, REFORM(DATA1[0,*]), REFORM(DATA1[I,*]), $
         _EXTRA=EXTRA
       
     END

   ENDIF ELSE BEGIN
     
     IF (KEYWORD_SET(FILE2)) THEN BEGIN
       IF (KEYWORD_SET(FILE3)) THEN BEGIN
         MZOOM_PLOT, DATA1, DATA2=DATA2, DATA3=DATA3, TITLE=TITLE, _EXTRA=EXTRA
       END ELSE BEGIN
         MZOOM_PLOT, DATA1, DATA2=DATA2, TITLE=TITLE, _EXTRA=EXTRA
       END
     END ELSE BEGIN
       MZOOM_PLOT, DATA1, TITLE=TITLE, _EXTRA=EXTRA
     ENDELSE

   ENDELSE
END
;; of SDF_SHOW -----------------------------------------------------------------

;
;-------------------------------------------------------------------------------
