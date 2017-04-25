function rd_atodat,infil
;+
;  NAME:
;    rd_atodat
;  PURPOSE:
;    Read the atomic data files: ssec3.dat, casec3.dat, fesec3.dat, f26sec.dat
;
;  CALLING SEQUENCE:
;    ato_data = rd_atodat( infil )
;
;  INPUTS:
;    infil   =  Input file name
;  OUTPUTS:
;    Returned parameter (ato_data) is a structure containing the data 
;    read from the file.
;  MODIFICATION HISTORY:
;    11-oct-93, Written, J. R. Lemen
;     9-mar-94, JRL, Read density data from the end of data file
;    11-mar-94, JRL, Read letter identifier in D.R. list.  This is
;			to identify the q, k and j lines.
;     6-oct-94, JRL, Added code to flag the statistical weight of the D.R. lines
;-
on_error,2

; Does the file exist?

if not file_exist(infil) then message,'Data file does not exist = '+infil 
message,'Reading atomic data file = '+infil,/cont,/info

; Initialize and read the file:

Stage = 0		; Initialize the stage which we are reading in the file
offset = 0.		; Wavelength offset for dielectronic recomb. lines
dd = {sec3_dr, n:0, wave:0., f2s:0., gs: 0, group:0, line:''}	; Diel. Recomb. Structure
buff = rd_tfile(infil,nocomm=';')	; Strip out the comments
buff = buff(where(strlen(strcompress(buff,/remove)) gt 0))	; Eliminate blank lines

; First Non Comment Line is the Version
  version = strtrim(buff(0),2)		; Strip off blanks

; --- 2nd Line is Atomic Number and Number of Electrons
  Enum = 0 & Znum = 0			; Number of electrons and Z
  reads,buff(1),Znum,Enum

; --- 3rd Line are # of Collisional lines, # of radiative recomb. lines, # of branch ratios
  N_omega = 0 & N_radrecomb = 0 & N_branch = 0
  reads,buff(2),N_omega,N_radrecomb,N_branch
  if n_branch eq 0 then branch = -1		; No branching ratios present in file
  if n_radrecomb eq 0 then radrecomb = -1	; No radiative line data read

; --- 4th Line are the wavelengthsfor w,x,y,z,q,r,s,t,u,v     
  wave0 = fltarr(n_omega)
  reads,buff(3),wave0 & ii = 3

; --- 5th line might be branching ratios

  if n_branch gt 0 then begin
     branch = fltarr(N_branch)
     ii = ii + 1 & reads,buff(ii),branch
  endif 

; --- Get Number of Temperatures and the Temperature Vector
  N_Temp = 0
  ii = ii + 1 & reads,Buff(ii),N_Temp
  Temp = fltarr(N_Temp)
  ii = ii + 1 & reads,buff(ii),Temp

; --- Read the Omega factors
  omega = fltarr(N_temp,N_omega)
  for i=0,N_omega-1 do begin
    ii = ii + 1 & aa = fltarr(N_Temp) & reads,buff(ii),aa
    omega(0,i) = aa
  endfor

; --- Read the Radiative Recombination Factors
  if n_radrecomb gt 0 then begin
     radrecomb = fltarr(N_temp,N_radrecomb)
     for i=0,N_radrecomb-1 do begin
        ii = ii + 1 & aa = fltarr(N_Temp) & reads,buff(ii),aa
	radrecomb(0,i) = aa
     endfor
  endif

; --- Read Es for N=2 dielectronic satellites
  Es = 0. & ii = ii + 1 & reads,buff(ii),Es

; --- Read the Lithium-Like, Be-like, B-like Dielectronic Satellites
  gs = 1			; Assume the statistical weight of ground state = 1
  i = ii + 1
  qdens = 0			; 0 until DENS= is detected
  while((i lt n_elements(buff)) and not qdens) do begin
    if strpos(strlowcase(buff(i)),'offset') ne -1 then begin
	reads,strmid(buff(i),strpos(buff(i),'=')+1,strlen(buff(i))),offset
    endif else if strpos(strlowcase(buff(i)),'dens=') ne -1 then begin
	qdens = 1		; The file contains density information
	message,'File contains density information',/info
    endif else begin
	nn = 0 & wwave = 0. & f2s = 0. & group = 0
	zz = str2arr(strtrim(strcompress(buff(i)),2),' ')
	if n_elements(zz) ge 5 then zz = zz(4) else zz = ''
	reads,buff(i),nn,wwave,f2s,group
	if wwave gt 0. then begin
	  dd.n = nn & dd.wave = wwave + offset	; Add current offset
	  dd.f2s = f2s & dd.group = group & dd.line = zz & dd.gs = gs
	  if n_elements(dr_str) eq 0 then dr_str = dd else dr_str = [dr_str,dd]
        endif else if gs eq 1 then gs = 2 else gs = 1	; Toggle between gs = 1 and gs = 2
; . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
; The previous line of code is necessary, because the atomic data files do not
; record the statistical weights of the ground states.
; This routine assumes that gs=1 until a case with wave=0 is encountered.
; Then it assumes that the following lines have gs=2 until another wave=0 is
; encountered, in which case gs=1 is again assumed (eg. Fe XXIV, XXIII, XXIII).
; . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    endelse
    if not qdens then i = i + 1
  endwhile

; --- Read the Density dependent information if it exists
  if qdens then begin
    Label = strarr(3)
    Count = intarr(3)
; Expect 3 density ratios: x/w, y/w, z/w
    for j=0,2 do begin
      Label(j) = (str2arr(buff(i),'"'))(1)
      i = i + 1
      TT = float(str2arr(strtrim(strcompress(buff(i)),2)," "))
      if j eq 0 then Temp_ne = TT else begin
          if (min(TT-Temp_ne) ne 0) or (max(TT-Temp_ne) ne 0) then begin
	     message,'Temperature Vector must be the same for each line ratio',/cont
	     qdens = 0
             tbeep,5
	     print,'Compare:',string(TT,format='(f5.2)')
             print,'with:   ',string(Temp_ne,format='(f5.2)')
	     message,'No atomic density line ratios read from file',/cont
          endif
      endelse				; j eq 0
      i = i + 1
      qdens1 = 0
      while((i lt n_elements(buff)) and not qdens1) do begin
          if strpos(strlowcase(buff(i)),'dens=') ne -1 then begin
	    qdens1 = 1		; Found the next density case
          endif else begin
            count(j) = count(j) + 1
            bb = float(str2arr(strtrim(strcompress(buff(i)),2)," "))
	    if n_elements(mmm) eq 0 then mmm = bb else mmm = [[mmm],[bb]]
          endelse
	  if not qdens1 then i = i + 1
      endwhile
    endfor				; j=0,2
    if (count(0) ne count(1)) or (count(0) ne count(2)) then begin
	message,'Number of density values does not match for x, y, or z',/cont
	print,'       Numbers = ',count
        tbeep,5
	message,'No atomic density line ratios read from file',/cont
        qdens = 0
    endif else begin
	NTemp = n_elements(mmm(*,0,0))-1
        Ndens = count(0)
        mmm = reform(mmm,NTemp+1,Ndens,3)
        dens = (mmm(0,*,0))(0:*)
        if (min(dens-mmm(0,*,1)) ne 0) or (max(dens-mmm(0,*,1)) ne 0) or $
	   (min(dens-mmm(0,*,2)) ne 0) or (max(dens-mmm(0,*,2)) ne 0) then begin
	   message,'Density Values must match exactly',/cont
	   tbeep,5
	   message,'No atomic density line ratios read from file',/cont
	   qdens = 0
	endif else begin
	   xyz2w = mmm(1:*,*,*)
        endelse
    endelse
  endif

; One last check -- look at the labels.  Expect the order of
; the data in the file to be x/w, y/w, z/w

  if qdens then begin
    lll = ['x','y','z']
    for j=0,2 do begin
      if strpos(strlowcase(label(j)),lll(j)) eq -1 then begin
	tbeep,5
        message,'There may be a problem with order of density data',/cont
        print,'  Label for line '+strtrim(j,2)+'  (0,1,2) = '+label(j)
        print,'  I expected something with '+lll(j)
        print,'  Will return densities -- but please check'
     endif
    endfor
  endif



; Now combine the data into the return structure variable:
 
; Use an anonymous struture name:
str_string = '{ File:infil, '		+	$	; Data file name
	       'Head:version, '		+ 	$	; Version of the calculation
	       'Cal: 0, '		+	$	; Calculation (set by get_atodat)
	       'Znum:Znum, ' 		+	$	; Atomic Number
	       'Enum:Enum, '		+ 	$	; Number of Electrons
	       'Wave0:Wave0, '		+	$	; Wavelengths of w,x,y,z,q,r,s,t,u,v
	       'branch:branch,'		+	$	; Branching ratios
	       'Temp:Temp, '		+	$	; Temperatures of Omega's
	       'Omega:Omega,'		+	$	; Omega's
	       'radrecomb:radrecomb, '	+	$	; Radiative Recomb.  
	       'Es:Es, '		+ 	$ 	; 
	       'dr:dr_str'
if qdens then str_string = str_string+','+	$
               'Density:Dens,'		+	$	; Log10(Density)
	       'Temp_ne:Temp_ne,'	+	$	; Log10(Temp for Density case)
	       'xyz2w:xyz2w'				; x/w, y/w, z/w
str_string = str_string + '}'
ii = execute('ato_data = '+str_string)

return,ato_data
end
