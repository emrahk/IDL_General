;;
;; Write as an xdr-file
;; (maps to specwrite)
;;
PRO xdrwrite,spe,file,verbose=verbose,comment=comment
   specwrite,spe,file,verbose=verbose,comment=comment
END 
