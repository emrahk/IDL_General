function rd_ionbal,infil,calculation
;+
;  NAME:
;    rd_ionbal
;  PURPOSE:
;    Read ascii files containing ionization balance calculations.
;  CALLING SEQUENCE:
;    bal_data = rd_ionbal(infil)	; Reads first calculation in file
;    bal_data = rd_ionbal(infil,1)	; Reads 2nd calculation (if any) in file.
;  INPUTS:
;    infil	= File name of ionization balance file (ascii)
;  OPTIONAL INPUTS:
;    calculation = 0 	(default) to read the first calculation, 1 for 2nd, etc.
;  OUTPUT:
;    Returns a data structure containing the contents of the 
;    requested calculation.  Returns Log10(Abun) vs Log10(Temp)
;  METHOD:
;    rd_ionbal reads the BCS format of ionization balance files.  rd_ionbal
;    makes use of the point_lun procedure to parse the file.
;
;  MODIFICATION HISTORY:
;    11-oct-93, J. R. Lemen (LPARL), Written
;-
on_error,2

; Does the file exist?

if not file_exist(infil) then message,'Data file does not exist = '+infil
message,'Reading ion balance file = '+infil,/cont,/info

; Initialize:

Temp_step = 0.1			; Assumed dlog10(Temp) stepsize in data files
if n_elements(calculation) eq 0 then calculation = 0	; Set up default

; -----------------------------------------------------
;  Open the data file and read the header record:
; -----------------------------------------------------
openr,lun,infil,/get_lun	; open the input file
buf = '' & readf,lun,buf
Tot_cal = 0 & reads,buf,Tot_cal	; Find out the number of calculations in the file
Start_record = intarr(Tot_cal)
reads,buf,Tot_cal,Start_record	; Start_record = the starting record number for
				; each calculation in the file

if calculation+1 gt Tot_cal then begin
   message,'*** Error:  Invalid calculation specified ***',/cont,/info
   print,'    File: ',infil,' contains ',strtrim(Tot_cal,2),' calculations'
   print,'    User specified calculation = ',strtrim(calculation,2),	$
		'   (Max = ',strtrim(Tot_cal-1,2),')'
   print,'    Returning -- no calculation has been read'
   free_lun,lun
   return,-1
endif

; Skip to the correct starting location in the file:
for i=2,Start_record(calculation)-1 do readf,lun,buf

; Read the Header
Head = '' & readf,lun,Head & Head = strtrim(Head,2)
Tab = byte(9)		        ; Byte character
Buf = Head			; Remove Tabs from the header
while(strpos(buf,tab) ne -1) do strput,buf,' ',strpos(buf,tab)
Buf = str2arr(Buf,' ')		; Parse on blanks
Elem = Buf(N_elements(Buf)-1)	; Assume element name is last on header line
Head = strtrim(strmid(Head,0,strpos(Head,Elem)),2)

; Read the number of stages and starting stage
; (Routine assumes that lowest stage is given first)

N_stages = 0 & Start_stage = 0 & ZZ = 0
readf,lun,N_stages,Start_stage,ZZ		; ZZ = Atomic Number
Stages = Start_stage + indgen(N_stages)		; Stage number (XVIII = 18)

; -------------------------------------
;  Read the data section the first time - Get number of Temperates
; -------------------------------------

N_Temp = intarr(N_stages)	; Number of Temp values
Temp0  = fltarr(N_stages)	; Starting Log10(Temps)
point_lun,-1*lun,pos0		; Get the file current position

for i=0,N_stages-1 do begin
  point_lun,-1*lun,pos		; Get the file current position
  N_Temp0 = 0 & Temp1 = 0
  buff = '' & readf,lun,buff
  reads,buff,N_Temp0,Temp1	; Get the number of temperatures
  ion_arr = fltarr(N_Temp0)  
  point_lun,lun,pos		; Set the file position back one record
  readf,lun,N_Temp0,Temp1,ion_arr
  N_Temp(i) = N_Temp0		; Number of temperatures for this stage
endfor

; -------------------------------------
;  Read the data section the 2nd time - Read the data
; -------------------------------------
  
point_lun,lun,pos0		; Set file position to beginning of data section
maxt = max(N_Temp)		; Maximum number of temperatures
L_Abun = fltarr(maxt,N_stages)	; Set up the ion bal matrix
L_Temp = fltarr(maxt,N_stages)	; Set up the Temp matrix

for i=0,N_stages-1 do begin
  N_Temp0 = 0 & Temp1 = 0.
  ion_arr = fltarr(N_Temp(i))
  readf,lun,N_Temp0,Temp1,ion_arr
  L_Abun(0,i) = -ion_arr			; Save the Log10(Ion fracs.)
  L_Temp(0,i) = Temp1+indgen(N_Temp0)*Temp_step ; Save the Log10(Temperatures)
endfor

free_lun,lun					; Close the file

; -----------------------------------------------------
; Combine the data into the return structure variable:
; -----------------------------------------------------

break_file,infil,disk,dir,filnam,ext	; Structure name will contain filename
str_string =   '{File:infil,' 		+ $	; Save the original file name
		'Head:Head,'		+ $	; Label in the file
		'Cal:calculation, '	+ $ 	; Calculation number (0, 1, ...)
		'ELEMENT:ELEM, '	+ $	; Element Label
		'Z:ZZ, '		+ $	; Atomic number
		'Tot_cal:Tot_cal, '	+ $	; Total number of calculations in the file
		'Stages:Stages, '	+ $	; Number of stages in this calculation
		'N_Temp:N_Temp, '	+ $	; Number of temperature (vector)
		'L_Temp:L_Temp, '	+ $	; Log10(temperature)
		'L_Abun:L_Abun}'		; Log10(Abun)
ii = execute('bal_data = '+str_string)	; Create the data structure


return,bal_data				; All done
end
