pro tripp_gc,imagefilename,ima=ima,_extra=ex
;+
; NAME:           
;                    TRIPP_GC
;
;
; PURPOSE:           
;                    Displays a full (FITS) image which is referred to
;                    by filename and, after two mouse clicks on the
;                    desired edges, zooms onto it in order to help
;                    *** quickly select an appropriate window of
;                    a fullframe image *** for which the coordinates
;                    are printed out
;
;
; CATEGORY:
;                    astronomical: image display and measurement
;
;
; CALLING SEQUENCE:
;                    TRIPP_GC,IMAGEFILENAME,IMA=ima
;
;
; INPUTS:
;                    imagefilename
;
;
; OPTIONAL INPUTS:
;                   
;
;
; KEYWORD PARAMETERS:
;                   _EXTRA   : All keywords are bypassed to the TRIPP_TV - procedure 
;                              used internally . 
;                   
;
;
; OUTPUTS:
;                    up to two plot windows
;                    printed output of selected coordinates
;
;
; OPTIONAL OUTPUTS:
;                    ima: array containing the then-readin image
;
;
; COMMON BLOCKS:
;                    none
;
;
; SIDE EFFECTS:
;                    may leave one window open 
;
;
; RESTRICTIONS:      
;                    imagefilenames has to refer to an image in FITS format
;                    The purpose of this routine si NOT to be as
;                    general as possible! On the contrary: it provides
;                    a very specific and limited functionality which
;                    is designed to help choose a (read-out) window QUICK
;
;
; PROCEDURE:         
;                    inspired by the MIDAS(ESO) procedure get/cursor
;                    but provides additional (rather fix) functionality  
;                    - reads in the desired image using READFITS 
;                    - reads and prints cursor position on (left) click;
;                    - displays selected area in a second window
;                    - allows to repeat this procedure starting from the
;                      original image until termination by (right or
;                      middle) mouse click 
;
; EXAMPLE:           
;                    tripp_gc, "/datapath/myimagefile.fits"
;
;
;
; MODIFICATION HISTORY: 
;                    Version 1.0 2001/07/25 Sonja L. Schuh 
;
;-

  
  on_error,2
  dt=.5
  dim=700
  
  tvwin=2
  zoomwin=0
  
  
  if n_elements(imagefilename) eq 0 then begin
    imagefilename=""
    message,"Missing image file name, please enter filename:",/inf
    read,imagefilename
  endif
  
  ima=readfits(imagefilename,header)
  
  tripp_tv,ima,window=tvwin,xmax=dim,ymax=dim,_extra=ex
  
  mouse=1
  while mouse eq 1 do begin
    
    print,""
    message,"Please select two corners for a zoom of the image by left-clicking",/inf
    message,"                             or exit by middle - or right-clicking.",/inf
    
    cursor,x1,y1 
    wait,dt
    mouse=!mouse.button
    
    case mouse of 
      1: begin
        
        oplot, [x1+0.5],[y1+0.5], psym=1, symsize=5, color=0,thick=1.5
        print,x1,y1
        cursor,x2,y2
        wait,dt
        oplot, [x2+0.5],[y2+0.5], psym=1, symsize=5, color=0,thick=1.5
        mouse=!mouse.button
        print,x2,y2
        
        x_min=fix(min([x1,x2]))
        x_max=fix(max([x1,x2]))
        y_min=fix(min([y1,y2]))
        y_max=fix(max([y1,y2]))
        
        tripp_tv,ima[x_min:x_max,y_min:y_max],window=zoomwin,xmax=dim,ymax=dim,_extra=ex
        tripp_tv,ima,window=tvwin,xmax=dim,ymax=dim,_extra=ex
        oplot, [x1+0.5],[y1+0.5], psym=1, symsize=1, color=0,thick=2
        oplot, [x2+0.5],[y2+0.5], psym=1, symsize=1, color=0,thick=2
        
        print,""
        message,"The coordinates of the selected subimage are:",/inf
        print,""
        print,"         x1:",x_min,"    x2:",x_max
        print,"         y1:",y_min,"    y2:",y_max
        print,""
        
      end
      
      else: mouse=2
      
    ENDCASE
    
  endwhile
  
  wdelete,tvwin
  
end
