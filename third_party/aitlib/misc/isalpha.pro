FUNCTION isalpha,ch
   ;;
   ;; Returns 1 if character ch is in [a-zA-Z]
   ;;
   tmp=strpos('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',ch)
   IF (tmp EQ -1) THEN return,0
   return,1
END 
