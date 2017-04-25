function cube_edit, incube,  outcube,  reform=reform , $
                    ss=ss, nx=nx, ny=ny, data=data
;+
;   Name: cube_edit
;
;   Purpose: edit 3D cube (mouse -OR- command line) w/optional rebin
;
;   Input Parameters: 
;         incube - data cube to edit
;
;   Output Parameters: 
;      outcube - optional output - the 'edited'/reduced cube
;
;   Output:
;      Function returns subscripts of edited cube -OR- new cube if /DATA set
;
;   Keyword Parameter:
;      data - if set, return value is edited cube, not the subscripts
;      ss - optional input SubScripts to use (bypass edit, just take subset)
;      nx,ny - optionally congrid the reduced cube
;  
;   Calling Sequence:
;      goodss=cube_edit(incube [,outcube] [,/DATA] )          ;mouse edit
;      goodss=cube_edit(incube [,outcube],ss=ss[,nx,ny])      ;SS/command line
;      good3d=cube_edit(incube [,outcube],ss=ss[,nx,ny],/DATA);return edited
;                                                               cube, not SS
;
;   Calling Examples:
;      new=cube_edit(oldcube)                       ; mouse edit, return SS
;      new=cube_edit(oldcube,nx=512,ss=[4,12] )     ; command line, img #4&12
;                                                   ; output= (512,ny',2)
;   Illustrative Call:
;   Extract frames 4 and 6 from cube w/rebin
;                       |----- incube ----|
;   IDL> help,cube_edit(bindgen(128,256,20), ss=[4,6], nx=300, /data)
;   <Expression>    BYTE      = Array[300, 600, 2]
;
;   Notes/Features:
;      Use /DATA to return the edited cube - default are SS (subscripts)
;      Use SS=SS input to do 'command line' (non interactive)
;      To rebin, specify NX and optionally NY (for example, zoom in on
;         only specified SS of cube for memory management)
;      If only NX specified, derive ny (~preserve aspect ratio)
;  
;   Category:
;      3D , cube, Movie, X Windows, Image
;
;   History:
;      Circa 1995       - S.L.Freeland - 
;      23-October-1998 - Optimize output cube generation via make_array and
;                         insertion, calls to 'modern' routines
;                         Document, move to SSW/gen...
;      28-apr-1999 - S.L.Freeland - add rebin option (NX,NY)
;                                   documentation , add /DATA return keyword
;      
;   Restrictions:
;      Simple minded but may prove useful
;-
nimages=data_chk(incube,/nimages)
if nimages lt 2 then begin 
   box_message,'Input to something called "cube_edit" should be 3D...'
   return,-1
endif

; ---- determine output size (rebin required?) -----------
nx0=data_chk(incube,/nx)
ny0=data_chk(incube,/ny)

case 1 of
   keyword_set(nx) and keyword_set(ny):                  ; user supplied rebin
   keyword_set(nx): ny=round(ny0*(float(nx)/nx0))        ; preserve aspect
   keyword_set(ny): nx=round(nx0*(float(ny)/ny0))        ; preserve aspect
   else: begin
     nx=nx0
     ny=ny0
   endcase
endcase

data=keyword_set(data)                                ; return data?, not SS
rebinit=(ny ne ny0) or (nx ne nx0)                    ; set the rebin flag
refdat=keyword_set(reform) or n_params() eq 2 or data ; output data array?

ind=intarr(nimages)-1
count=n_elements(ss)

; ===================== MOUSE EDIT ============================
if not keyword_set(ss) then begin 
   delvarx,xx
   wdef, xx, nx>256,ny>256,/uright
   tbeep
   box_message,["With Cursor in Window:",    $        ; print directions
             "   Left Button Keeps",      $
             "   Center Button Discards", $
             "   Right Button Backs Up One Image"]
;
   outx=.1*nx
   outy=.1*ny
   dir=1				; start forward
   i=0				; start at the beginning
   goodmess=' Keeping This One'
   badmess= ' Throwing This One Out'
   while i ne nimages do begin   
      tvscl,incube(*,*,i)
;
      imess='Image: ' + strtrim(i,2)
      case ind(i) of
         0: Mess=imess + badmess
         1: Mess=imess + goodmess
         else: Mess=''
      endcase      
;
      xyouts,outx,outy,mess, size=1.2,/device
      cursor,x,y,3,/device
;
      if !err ne 4 then begin
         ind(i) = !err eq 1 
         if ind(i) then mess= imess + goodmess  $
            else mess=imess + badmess 
         xyouts,outx,outy,mess, size=1.2,/device
         wait,.5
         i=i+1
      endif else if i ge 1 then i=i-1 
;
   endwhile
   ss=where(ind,count)
   box_message,'Done with all images'
   wait,.3
   wdelete
endif else count=n_elements(ss)

;===================== END OF MOUSE EDIT ===========================
; 

; ================= DATA extraction, optional rebin =================
retval=ss
outcube=0
case 1 of
   count eq 0: box_message,"You did not like any of the images??" 
   max(ss) gt (nimages-1): box_message,'Subscripts (SS) > NIMAGES
   else:  begin 
      if refdat then begin 
         outcube=make_array(nx, ny, count, type=data_chk(incube,/type))
         case 1 of
	    rebinit:for i=0,count-1 do outcube(0,0,i)= $
		        congrid(incube(*,*,ss(i)),nx,ny)           
	    else:   for i=0,count-1 do outcube(0,0,i)=incube(*,*,ss(i))
         endcase
      endif
   endcase
endcase
; =====================================================================

retval=ss                                            ; defaut return is SS
if keyword_set(data) then retval=temporary(outcube)  ; optional DATA return 

return, retval
end
