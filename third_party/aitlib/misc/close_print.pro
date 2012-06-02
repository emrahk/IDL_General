;
; J.W., 1994,1996
;
; CVS Version 1.1: use gv if it exists
; J.Wilms, 2001.08.13 (first change since 1996!!!!!!!!)
; CVS Version 1.2, 2001.08.13: ... and now we check for gv and ghostview
;   in a way that works on OSF and Linux!
;
pro close_print,print=print,ghost=ghost,infotag=infotag
  common plotstuff,filename,savefont
  IF (n_elements(infotag) NE 0) THEN BEGIN 
      spawn,'whoami',/noshell,username
      xyouts,0.01,0.005,username(0)+', '+systime(0),alignment=0.,/normal, $
        size=0.7
      tag=filename
      IF (NOT keyword_set(infotag)) THEN tag=infotag
      xyouts,0.99,0.005,tag,alignment=1.,/normal,size=0.7
  ENDIF 
  device, /close                    ; close current device
  IF (keyword_set(ghost)) THEN BEGIN 
      prgs=['/usr/local/bin/gv','/usr/bin/X11/gv', $
           '/usr/bin/X11/ghostview','/usr/local/bin/ghostview']
      executed=0
      FOR i=0,n_elements(prgs)-1 DO BEGIN 
          IF ((executed EQ 0) AND (file_exist(prgs[i]))) THEN BEGIN 
              spawn,[prgs[i],filename],/noshell
              executed=1
          ENDIF 
      ENDFOR 

      ;; last resort
      IF (executed EQ 0) THEN spawn, 'ghostview '+filename,/sh

  ENDIF 
  IF (filename EQ 'idl.ps') THEN BEGIN 
      IF (keyword_set(print)) THEN BEGIN 
          spawn, 'lpr idl.ps ; rm -f idl.ps',/sh
      ENDIF
  END
  set_plot,'X'                      ; Back to Screen-output
  !P.FONT=savefont
end

