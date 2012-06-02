PRO RMC_CLEANUP, mother
   ;; Clean up the image pointer
  
   WIDGET_CONTROL, mother, GET_UVALUE=INFO
   IF N_ELEMENTS(INFO) GT 0 THEN PTR_FREE, INFO.IMAGE    
END















