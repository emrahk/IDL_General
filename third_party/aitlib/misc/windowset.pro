;;
;; Set plotting-window to window win, restoring the graphics context
;; to the one when the window was last left.
;;
;; Version 1.0
;; Joern Wilms, 1995-1997
;;
PRO windowset,win
   COMMON windowset,dsav,psav,xsav,ysav,zsav

   IF (n_elements(psav) EQ 0) THEN BEGIN 
       dsav=replicate(!d,200)
       psav=replicate(!p,200)
       xsav=replicate(!x,200)
       ysav=replicate(!y,200)
       zsav=replicate(!z,200)
   ENDIF 
   dsav(!d.window)=!d
   psav(!d.window)=!p
   xsav(!d.window)=!x
   ysav(!d.window)=!y
   zsav(!d.window)=!z

   wset, win

   !p=psav(win)
   !x=xsav(win)
   !y=ysav(win)
   !z=zsav(win)
END 
