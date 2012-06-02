FUNCTION tmpnam,template,path=path
   ;;
   ;; Create a temporary file-name in the current subdir (if path is
   ;; set) or in /tmp, if path is not set. Analoguous to the tmpnam
   ;; function in Unix.
   ;;
   ;; template: template for the filename, a random-number gets
   ;;    prepended to template
   ;; path: path to be appended to the filename (/tmp if not set)
   ;;
   ;; Version 1.0 J.W., 1996 wilms@astro.uni-tuebingen.de
   ;; Version 1.1 J.W./S.B., 1999
   ;;
   IF (n_elements(path) EQ 0) THEN path='/tmp/'
   IF (strmid(path,strlen(path)-1,1) NE '/') THEN path=path+'/'
   IF (n_elements(template) EQ 0) THEN template='idl'
   
   number=0
   REPEAT BEGIN 
       filename=path+template+string(format='(I5.5)',number)
       filename=strtrim(filename,2)
       number=number+1
   END UNTIL NOT file_exist(filename)
   return,filename
END 
