FUNCTION backsub,ts,cs,tb,cb
   ndx=where(ts NE tb)
   IF (ndx(0) EQ -1) THEN return,cs-cb

   print,'well, you have a problem...'
   stop
END 
