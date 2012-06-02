;
; Procedure to set up plotting to printer
; if file is set: print to eps-file
;
; J.W., 1994,1996
; 1997.08.27: added a4 keyword
; 1998.01.21: now device,encapsulated=0 when turning on postscript
;             (perhaps that helps when switching back and forth
;             between PS and EPS...)
; 2001.06.17: switch to 8 bits per pixel for color figures
; 2002.02.27: complete rewrite; added various formats for astronomy
;             and astrophysics 
; 2002.03.06: fixed problem with color printing, don't understand why
;             the old way of J.W. doesn't work
; $Log: open_print.pro,v $
; Revision 1.9  2002/08/06 08:46:55  goehler
; Changed x/ysize setting for /a4 style, added explicit
; x/yoffset settings which are necessary for landscape
; in general and the /a4 style in special.
;
; Revision 1.8  2002/07/16 18:07:51  wilms
; automatic logging needs dollars, not percent signs
;
;
pro open_print,file, color=color,a4=a4,postscript=postscript, $
               apj1col=apj1col,aa1col=aa1col,aa2col=aa2col,aa14cm=aa14cm, $
               aspect=aspect,scale=scale,fontsize=fontsize, $
               xsize=xsize,ysize=ysize,times=times

  common plotstuff, filename,savefont
  savefont=!p.font

  IF (n_elements(file) EQ 0) THEN file='idl.ps'
  filename=file

  set_plot,'PS'                    ; create output for postscript

  encapsulated=1
  IF (keyword_set(postscript)) THEN encapsulated=0

  landscape=0

  IF (file_exist(file)) THEN BEGIN 
      spawn,['/bin/rm',file],/noshell
  ENDIF 


  IF (n_elements(scale) EQ 0) THEN scale=1.

  IF (keyword_set(a4)) THEN BEGIN 
      
      ;; compute absolute size of a4:
      a4_xsize=29.8 
      aspect=21.1/a4_xsize

      ;; always landscape (?)
      landscape=1

      ;; add margins:
      margin = 2.;cm
      xsize = a4_xsize - 2.*margin      

      ;; shift this properly (IDL can't do it itself)
      xoffset=aspect*margin
      yoffset= a4_xsize-margin ;-)      
  ENDIF 
  
  IF (keyword_set(color)) THEN color=1 ELSE color=0

  ;; aspect ratio
  IF (n_elements(aspect) EQ 0) THEN aspect=0.75

  IF (n_elements(fontsize) EQ 0) THEN fontsize=12.
  IF (n_elements(times) EQ 0) THEN times=0

  IF (times EQ 0) THEN helvetica=1

  
  IF (keyword_set(apj1col)) THEN BEGIN 
      xsize=8 & times=1
      fontsize=10.

      scale=xsize*12./fontsize
  ENDIF 

  ;; A&A, 1column
  IF (keyword_set(aa1col)) THEN BEGIN 
      xsize=8.8 & times=1
      fontsize=9. ;; same size as caption

      scale=12./fontsize
  ENDIF 

  ;; A&A, 1column
  IF (keyword_set(aa2col)) THEN BEGIN 
      xsize=17. & times=1
      fontsize=9.

      scale=12./fontsize
  ENDIF 

  ;; A&A 14cm wide plot, caption at low right corner
  IF (keyword_set(aa14cm)) THEN BEGIN 
      xsize=14. & times=1
      fontsize=9.

      scale=12./fontsize
  ENDIF 

  IF (n_elements(xsize) EQ 0) THEN BEGIN 
      xsize=17.78 ;; idl default value
      IF (n_elements(ysize) EQ 0 AND n_elements(aspect) EQ 0) THEN BEGIN 
          aspect=12.700/17.780 ;; default IDL value
      ENDIF 
  ENDIF 

  device,encapsulated=encapsulated,landscape=landscape, $
    xsize=scale*xsize,ysize=scale*aspect*xsize,color=color,bits_per_pixel=8, $
    filename=file,times=times,inches=0,helvet=helvetica,                     $
    xoffset=xoffset, yoffset=yoffset
  device,/isolatin1
  !p.font=0                     ; use system font (helvetica or times)


  ;; setting the font size is more difficult
  ;; the following is how it should work...
  ;; default values for 12pt font -- cannot use !d structure
  ;; because that might have been changed from a previous
  ;; call to open_print
  ;  wi=222. ;x_ch_size
  ;  he=352. ;y_ch_size
  ;  device,set_character_size=[wi,he]*fontsize/12.
  ;..the problem is that I never got it to work --> see the cludge
  ;above in the A&A section to get 10pt fonts...
  
END 
