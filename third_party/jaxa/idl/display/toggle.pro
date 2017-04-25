pro toggle,color=color,landscape=landscape,portrait=portrait,letter=letter, $
           legal=legal,print=print,filename=filename,eps=eps,queue=queue, $
           _extra=_extra
;+
; ROUTINE:      toggle,color=color,landscape=landscape,portrait=portrait, $
;                      letter=letter,legal=legal,filename=filename
;
; PURPOSE:      toggles IDL graphics output between X-window and a postscript
;               output file.
;
; OPTIONAL INPUTS (keyword parameters):
;
;   COLOR       Enable color plotting (output to Tek Phaser color printer)
;
;   LANDSCAPE   Horizontal plotting format
;   PORTRAIT    Vertical plotting format (default)
;
;   LETTER      8.5 by 11 inch page size (default)
;   LEGAL       11 by 14 inch page size (Phaser)
;
;   EPS 
;               if set, encapsulated postscript file is produced. 
;               Many word processing and typesetting programs provide
;               facilities to include encapsulated PostScript output
;               within documents.  See the discussion of the POSTSCRIPT
;               and EPS options of the DEVICE command in the IDL
;               user manual.  
;
;   PRINT       1 = submit to default printer ( setenv PRINTER ????)
;               otherwise if PRINT is a string variable
;               the job will be spooled to the named print queue
;
;   QUEUE       if set, print queue is selected from a pop-up menu
;
;   FILENAME    name of postscript file (default = plot.ps or plotc.ps)
;
; PROCEDURE:    The first call to TOGGLE (and all odd number calls) 
;               changes the output device from X-window to a
;               Postscript output file.  If the output file name is not
;               specified on the command line the default file name will
;               be plot.ps for the laser printers, or plotc.ps for the 
;               TEK Phaser color printer. 
;
;               The next call (and all even number calls) switches back 
;               to the X-window and closes the plot file.  If the keyword
;               PRINT is set the plotfile will be submitted to one of the
;               ESRG print queues.  
;
;               NOTE: Only one postscript file can be open at any given time
;
; SIDE EFFECTS: 
;               In order to maintain a font size which keeps the same
;               relation to the screen size, the global variable
;               !p.charsize is changed when switching to and from
;               postscript mode, as follows,
; 
;               When toggleing to PS !p.charsize --> !p.charsize/fac
;               When toggleing to X  !p.charsize --> !p.charsize*fac
;
;                           [!d.x_ch_size]    [!d.x_vsize  ]
;               where fac=  [------------]    [----------- ]
;                           [!d.x_vsize  ]    [!d.x_ch_size]
;                                         PS                X 
;
;               Thus, to ensure that plotted character strings scale
;               properly in postscript mode, specify all character
;               sizes as as multiples of !p.charsize.
;
; EXAMPLE:
;               View the IDL dist function and then make a hardcopy:
;
;                d=dist(200)
;                loadct,5
;                tvscl,d                    ; view the plot on X-windows
;                toggle,/color,/landscape   ; redirect output to plotc.ps
;                tvscl,d                    ; write plot onto plotc.ps
;                toggle,/print              ; resume output to X-windows
;                                           ; submit plot job to default printer
;                toggle,/color,/land
;                tvscl,d
;                toggle,print='term'        ; submit plot "term" print queue
;               
;
;  author:  Paul Ricchiazzi                            1jun92
;           Institute for Computational Earth System Science
;           University of California, Santa Barbara
; 
;
; NOTE: you can check for the currently defined print queues in /etc/printcap
;
; REVISIONS:
;  feb93: added PRINT keyword
;  feb93: set yoffset=10.5 in landscape mode
;  feb93: added FILENAME keyword
;  mar93: added bits=8 in black and white mode
;  mar96: modify !p.charsize to compensate for larger ps font size
;  mar96: send output to print queue tree on eos
;-
;
common toggle_blk,psfile
chpscr=float(!d.x_vsize/!d.x_ch_size)

if !d.name eq 'X' then begin
  if !p.charsize eq 0 then !p.charsize=1.
  set_plot, 'PS', /interpolate
  !p.charsize=!p.charsize*float(!d.x_vsize/!d.x_ch_size)/chpscr
  eps=keyword_set(eps)
  if keyword_set(color) eq 0 then begin
    if keyword_set(filename) eq 0 then psfile='plot.ps' else psfile=filename
;
; Apple Laserwriter
;
    if keyword_set(landscape) eq 0 then begin	
      if eps then yoffset=0 else yoffset=.5
      device, bits=8, filename=psfile,xsize=7,ysize=10,yoffset=yoffset, $
          /inches, /portrait,encapsulate=eps,_extra=_extra
    endif else begin
      if eps then yoffset=0 else yoffset=10.5
      device, bits=8, filename=psfile,xsize=10,ysize=7,yoffset=yoffset, $
          /inches, /landscape,encapsulate=eps,_extra=_extra
    endelse
    print, 'Output directed to ',psfile,', for output on BW postscript'
  endif else begin
;
; Tektronics Phaser color printer
;
    if keyword_set(filename) eq 0 then psfile='plotc.ps' else psfile=filename
    short_side = 8.0
    small_offset=(8.5-short_side)/2.
    set_plot, 'ps', /interpolate
    if n_elements(legal) ne 0 then begin
      long_side=10.5
      big_offset=(14.-long_side)/2.
    endif else begin
      long_side=8.5
      big_offset=(11.-long_side)/2
    endelse
    if n_elements(portrait) ne 0 then begin
      up_shift=0.  ;   up shift in inches
      yoffset=big_offset+up_shift
      if eps then begin
        small_offset=0
        yoffset=0
      endif
      print,form='(5a10)','portrait','xsize','ysize','xoffset','yoffset'
      print,form='(10x,4g10.5)',short_side,long_side,small_offset,yoffset
      device, bits=8, /color, xsize=short_side, ysize=long_side, $
             xoffset=small_offset, yoffset=yoffset, $
             /inch, /portrait,file=psfile,encapsulate=eps,_extra=_extra
    endif else begin
      left_shift=.5;    left shift in inches
      yoffset=long_side+big_offset+left_shift
      if eps then begin
        small_offset=0
        yoffset=0
      endif
      print,form='(5a10)','landscape','xsize','ysize','xoffset','yoffset'
      print,form='(10x,4g10.5)',long_side,short_side,small_offset,yoffset
      device, bits=8, /color, xsize=long_side, ysize=short_side, $
             xoffset=small_offset, yoffset=yoffset, $
             /inch, /landscape,file=psfile,encapsulate=eps,_extra=_extra
    endelse
    print, 'Color output directed to file ',psfile,', for output on Phaser'
  endelse  
;
;
endif else begin
  device, /close_file 
  set_plot, 'X' 
  !p.charsize=!p.charsize*float(!d.x_vsize/!d.x_ch_size)/chpscr
  print,'file '+psfile+' closed. Output directed to Xwindow  ' 

  if keyword_set(print) or keyword_set(queue) then begin

    pdefault=getenv("PRINTER")

    if keyword_set(queue) then begin
      printers=['do not print',pdefault]
      descrip =['','(the default printer)']
      descrip(0)='(output saved in '+psfile+')'
      openr,lunp,/get_lun,"/etc/printcap"
      line='' & blank='                       '

      while eof(lunp) eq 0 do begin
        readf,lunp,line
        if strpos(line,'|') ge 0 then begin
          parse=str_sep(line,"|")
          if strpos(parse(0),'6') eq 0 then parse(0)=parse(1)
          dsc=parse(n_elements(parse)-1)
          printers=[printers,parse(0)]
          nd=strlen(dsc)-2
          descrip=[descrip,strmid(dsc,0,nd)]
        endif
      endwhile

      free_lun,lunp
      plen=strlen(printers)
      pspace=fix(5+max(plen)-plen)
      nprn=n_elements(printers)
      for i=0,nprn-1 do descrip(i)=printers(i)+$
                                   strmid(blank,0,pspace(i)) + descrip(i)
      descrip=['Choose a print queue',descrip]
      p=wmenu(descrip,title=0,init=1)-1
      printq=printers(p)
      if p le 0 then return
    endif else begin
      if (size(print))(1) eq 7 then printq=print else printq=pdefault
    endelse

    print,psfile+" spooled to printer queue "+printq

    case printq of
      'tree':  spawn,'rsh eos cd $PWD ";" lpr -Ptree  '+psfile
      'tree2': spawn,'rsh eos cd $PWD ";" lpr -Ptree2 '+psfile
      else:    spawn,['lpr','-P',printq,psfile],/noshell
    endcase

  endif
endelse
return
end





