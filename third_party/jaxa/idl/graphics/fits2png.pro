pro fits2png, list, outdir, SUMMARY=summary
; $Id: fits2png.pro,v 1.1 2005/04/21 19:34:02 nathan Exp $
;
; Project   : STEREO SECCHI
;                   
; Name      : fits2png
;               
; Purpose   : convert list of FITS files into PNG images
;               
; Explanation:  Outputs image in 544x(544+32) window with filename and image
;               size as label. Image is histogram equalized. Handles 2150x2150
;               images. Summary image includes list of keywords which is 
;               hardcoded in program, but may be easily modified.
;               
; Use       : IDL> fits2png, filelist [,outdir]
;    
; Inputs    : filelist  STRARR  list of FITS file names
;
; Optional Inputs: outdir   STRING  name of directory to put output, otherwise
;               puts in ~/images
;               
; Outputs   : png images in outdir or ~/images
;
; Keywords  : SUMMARY   if set, generate output from img_summary.pro also
;
; Calls from LASCO : 
;
; Common    : 
;               
; Restrictions: Note that output summary image has black background (not 
;               suitable for printing). Regular image is OK.
;               
; Side effects: 
;               
; Category    : display, image processing
;               
; Prev. Hist. : None.
;
; Written     : Nathan Rich, NRL/I2, Apr 2005
;               
; $Log: fits2png.pro,v $
; Revision 1.1  2005/04/21 19:34:02  nathan
; *** empty log message ***
;

n=n_elements(list)

IF n_params() GT 1 THEN BEGIN
    parts=str_sep(outdir,'/')
    np=n_elements(parts)
    IF parts[np-1] NE '' THEN outdir=outdir+'/'
ENDIF ELSE outdir='~/images/'
spawn,'mkdir '+outdir,/sh

for i=0,n-1 do begin
    im=sccreadfits(list[i],h)
    bigaxis=h.naxis1>h.naxis2
    IF bigaxis EQ 2150 THEN BEGIN
        im=im[0:2147,0:2147]
        bigaxis=2148
        naxis1=2148
        naxis2=2148
    ENDIF ELSE BEGIN
        naxis1=h.naxis1
        naxis2=h.naxis2
    ENDELSE
    factor=fix(1/(512./bigaxis))
    
    !p.background=255
    !p.color=0
    window,2,xsize=2176/4,ysize=(2176/4)+32
    
    IF max(im) NE min(im) THEN $
    tvscl,hist_equal(rebin(im,naxis1/factor,naxis2/factor)),0,32 $
    ELSE tvscl,(rebin(im,naxis1/factor,naxis2/factor)),0,32
    xyouts,10,5,h.filename+'   '+trim(string(h.naxis1))+'x'+trim(string(h.naxis2)),/dev,size=2
    outp=tvrd()
    break_file,h.filename,nnn,dir,fileroot,suff
    write_png,outdir+fileroot+'.png',outp
    window,0
        summarr=['DATE-OBS: '+h.date_obs, 'FILEORIG: '+h.fileorig, $
             'SEB_PROG: '+h.seb_prog, 'EXPTIME : '+string(h.exptime), $
             'LED     : '+h.led,      'LEDPULSE: '+string(h.ledpulse), $
             'OFFSET  : '+string(h.offset),   'GAINMODE: '+h.gainmode, $
             'CEB_T   : '+string(h.ceb_t),    'CAMERA  : '+h.camera, h.comment]
    img_summary,im,h.filename,summarr
    outp=tvrd()
    write_png,outdir+fileroot+'smry.png',outp
    
endfor

end
        
