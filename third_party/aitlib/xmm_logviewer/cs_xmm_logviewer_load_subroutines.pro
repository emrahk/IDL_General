;+
; NAME:
;cs_xmm_logviewer_load_subroutines.pro
;
;
; PURPOSE:
;loads constructors and selectors  
;
;
; CATEGORY:
;XMM
;
;
; CALLING SEQUENCE:
;cs_xmm_logviewer_load_subroutines
;make_datatype, xwerte, ywerte, revs, xparameter, yparameter,  xunit, yunit, datatype=datatype
;perform_operation, data, operation, par1, par2, datatype=datatype, nachricht=nachricht
;reset_datatype, data,datatype=datatype
;get_color, datatype, color=color
;set_color, data, color, datatype=datatype
;get_background, datatype, background=background
;set_background, data, background, datatype=datatype
;get_sym, datatype, sym=sym
;set_sym, data, sym, datatype=datatype
;get_y_style, datatype, y_style=y_style
;set_y_style, data, y_style, datatype=datatype
;get_orig_xmin, datatype, orig_xmin=orig_xmin
;get_orig_xmax, datatype, orig_xmax=xmax
;get_orig_ymin, datatype, orig_ymin=orig_ymin
;get_orig_ymax, datatype, orig_ymax=orig_ymax
;get_current_xmin, datatype, current_xmin=current_xmin
;get_current_xmax, datatype, current_xmax=current_xmax 
;get_current_ymin, datatype, current_ymin=current_ymin
;get_current_ymax, datatype, current_ymax=current_ymax
;get_orig_xwerte, datatype, orig_xwerte=orig_xwerte
;get_orig_ywerte, datatype, orig_ywerte=orig_ywerte
;get_current_xwerte, datatype, current_xwerte=current_xwerte
;set_current_xwerte, data, xwerte, datatype=datatype
;get_current_ywerte, datatype, current_ywerte=current_ywerte
;set_current_ywerte, data, ywerte, datatype=datatype
;get_operations, datatype,  operations=operations
;get_one_operation, datatype, index,  one_operation=one_operation, param1=param1, param2=param2
;set_operations, data, new_operation,par1,par2, datatype=datatype
;change_operations, data, new_operation,par1,par2, index, datatype=datatype
;get_operations_length, datatype, length=length
;set_operations_length, data, new_length, datatype=datatype
;get_orig_xunit, datatype,orig_xunit=orig_xunit
;get_orig_yunit, datatype, orig_yunit=orig_yunit
;get_current_xunit, datatype, current_xunit=current_xunit
;get_current_yunit, datatype, current_yunit=current_yunit
;set_current_xunit, data, new_xunit, datatype=datatype
;set_current_yunit, data, new_yunit, datatype=datatype
;get_revs, datatype, revs=revs
;get_orig_xparameter, datatype, orig_xparameter=orig_xparameter
;get_orig_yparameter, datatype, orig_yparameter=orig_yparameter
;get_current_xparameter, datatype, current_xparameter=current_xparameter
;get_current_yparameter, datatype, current_yparameter=current_yparameter
;set_current_xparameter, data, new_xparameter, datatype=datatype
;set_current_yparameter, data, new_yparameter, datatype=datatype
;get_current_length, datatype, current_length=current_length
;set_current_length, data, new_length, datatype=datatype
;get_orig_length, datatype, orig_length=orig_length
;
; INPUTS:
; xwerte: double-array  
; ywerte: double-array , same length as xwerte
; revs: String e.g. '187-215'
; xparameter: String e.g. 'TIME'
; yparameter: String e.g. 'F1375'
; xunit: String e.g. 'days'
; yunit: String e.g. 'mA'
; data: datatype, returned by make_datatype
; operation: String e.g. 'CORRELATE'
; par1: double parameter value 1 used for operation
; par2: double parameter value 2 used for operation



; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-

PRO make_datatype, xwerte, ywerte, revs, xparameter, yparameter,  xunit, yunit, color, sym, background, y_style, datatype=datatype
datatype=strarr(N_Elements(xwerte), 6)
FOR i=0L, N_ELEMENTS(xwerte)-1 DO BEGIN
datatype(i, 0)=xwerte(i)
datatype(i, 1)=ywerte(i)
datatype(i, 2)=xwerte(i)
datatype(i, 3)=ywerte(i)
ENDFOR
datatype(0, 5)=revs
datatype(1, 5)=xparameter ;;orig_xparameter
datatype(2, 5)=yparameter ;;orig_yparameter
datatype(3, 5)=xunit      ;;originalxunit  
datatype(4, 5)=yunit      ;;originalyunit
datatype(5, 5)=color      ;;orig_color
datatype(6, 5)=sym       ;;orig_sym
datatype(7, 5)=background   ;;orig_bgcolor
i=LONG(N_ELEMENTS(xwerte))
datatype(8, 5)=i            ;;orig_n_elements
datatype(9, 5)=i            ;;current_n_elements
datatype(10,5)=0          ;;Anzahl Operationen
datatype(11,5)=y_style     ;;orig_style   
datatype(12,5)=xunit          ;;currentxunit
datatype(13,5)=yunit         ;;currentyunit
datatype(14, 5)=xparameter ;;currentxparameter
datatype(15, 5)=yparameter ;;currentyparameter
datatype(16, 5)=color
datatype(17, 5)=sym
datatype(18, 5)=background
datatype(19,5)=y_style
END

PRO perform_operation, data, operation, par1, par2, datatype=datatype, nachricht=nachricht
nachricht='Done'
CASE operation OF 
'ZOOM_X' : BEGIN
a=[DOUBLE(par1(0)), DOUBLE(par2(0))]
par2=MAX(a, MIN=par1)
               get_current_xwerte, data, current_xwerte=current_xwerte
               get_current_ywerte, data, current_ywerte=current_ywerte
               get_current_length, data, current_length=current_length 
               new_x=dblarr(current_length)
               new_y=dblarr(current_length)
               j=0L
               For i=0L, current_length-1 do Begin 
                 if ((current_xwerte(i) GE par1(0)) and (current_xwerte(i) LE par2(0))) then Begin
                   new_x(j)=current_xwerte(i) 
                   new_y(j)=current_ywerte(i)
                   j=j+1  
                 endif               
               endfor
             IF j LE 2 THEN BEGIN 
            nachricht='array contains no values ! zoom stopped !'
	      datatype=data
		ENDIF ELSE BEGIN
              new_x=extrac(new_x, 0, j-1)
              new_y=extrac(new_y, 0, j-1)
              set_current_xwerte, data, new_x, datatype=datatype
              set_current_ywerte, datatype, new_y, datatype=datatype
              set_operations , datatype, 'ZOOM_X',par1,par2, datatype=datatype
             ENDELSE
 END
'ZOOM_Y' : BEGIN

a=[DOUBLE(par1(0)), DOUBLE(par2(0))]
par2=MAX(a, MIN=par1)


               get_current_xwerte, data, current_xwerte=current_xwerte
               get_current_ywerte, data, current_ywerte=current_ywerte
               get_current_length, data, current_length=current_length 
               new_x=dblarr(current_length)
               new_y=dblarr(current_length)
               j=0L
               FOR i=0L, current_length-1 DO BEGIN 
                 IF ((current_ywerte(i) GE par1(0)) AND (current_ywerte(i) LE par2(0))) THEN BEGIN
                   new_x(j)=current_xwerte(i) 
                   new_y(j)=current_ywerte(i)
                   j=j+1  
                 ENDIF              
               ENDFOR
             IF j LE 2 THEN BEGIN 
            nachricht='array contains no values ! zoom stopped !'
	      datatype=data
		ENDIF ELSE BEGIN
              new_x=extrac(new_x, 0, j-1)
              new_y=extrac(new_y, 0, j-1)
              set_current_xwerte, data, new_x, datatype=datatype
              set_current_ywerte, datatype, new_y, datatype=datatype
              set_operations , datatype, 'ZOOM_Y',par1,par2, datatype=datatype
             ENDELSE
 END
  'SYMBOL': BEGIN
                   set_sym, data, par1, datatype=datatype
                   set_operations , datatype, 'SYMBOL',par1,par2, datatype=datatype
      END 
 'COLOR': BEGIN
                   set_color, data, par1, datatype=datatype
                   set_operations , datatype, 'COLOR',par1,par2, datatype=datatype
      END
'BACKGROUND': BEGIN
                   set_background, data, par1, datatype=datatype
                   set_operations , datatype, 'BACKGROUND',par1,par2, datatype=datatype
      END
 'SMOOTH': BEGIN
                  get_current_ywerte, data, current_ywerte=current_ywerte
                  new_y=SMOOTH(current_ywerte,FIX(par1(0)))
                  set_current_ywerte, datatype, new_y, datatype=datatype
                  set_operations , datatype, 'SMOOTH',par1,par2, datatype=datatype
      END
'EXECUT': BEGIN
                  get_current_ywerte, data, current_ywerte=current_ywerte
                  y=current_ywerte
		     new_y=y
                  s=EXECUTE('new_y='+par1(0))              
                  set_current_ywerte, datatype, new_y, datatype=datatype
                  set_operations , datatype, 'EXECUT',par1,par2, datatype=datatype
      END
'FLIPAXES':BEGIN
                  get_current_ywerte, data, current_ywerte=current_ywerte
		     get_current_xwerte, data, current_xwerte=current_xwerte
                  set_current_ywerte, datatype, current_xwerte, datatype=datatype
                  set_current_xwerte, datatype, current_ywerte, datatype=datatype
                  get_current_yparameter, data, current_yparameter=current_yparameter
		     get_current_xparameter, data, current_xparameter=current_xparameter
                  set_current_yparameter, datatype, current_xparameter, datatype=datatype
                  set_current_xparameter, datatype, current_yparameter, datatype=datatype
                  get_current_yunit, data, current_yunit=current_yunit
		     get_current_xunit, data, current_xunit=current_xunit
                  set_current_yunit, datatype, current_xunit, datatype=datatype
                  set_current_xunit, datatype, current_yunit, datatype=datatype
 		     set_operations ,datatype, 'FLIPAXES',par1,par2, datatype=datatype
     END

'YSTYLE': BEGIN
                  set_y_style, data, par1, datatype=datatype
                  set_operations , datatype, 'YSTYLE',par1,par2, datatype=datatype

END
'UNZOOM': BEGIN
			get_operations_length, datatype, length=length            
               	 FOR i=0L , length-1 DO BEGIN
		  		IF ( i LE length-1 )THEN BEGIN
                		get_one_operation, datatype, i, one_operation=one_operation, param1=param1, param2=param2
                			IF ((one_operation EQ 'ZOOM_X') OR (one_operation EQ 'ZOOM_Y')) THEN BEGIN
		  				FOR k=i , length-2 DO BEGIN
		 				get_one_operation, datatype, k+1, one_operation=one_operation, param1=param1, param2=param2
                				change_operations, datatype,  one_operation,param1,param2,  k,datatype=datatype
		 				ENDFOR
             	  		set_operations_length, datatype, length-1, datatype=datatype
		 			get_operations_length, datatype, length=length 
               			i=i-1		 
               			ENDIF
				ENDIF
               	ENDFOR
               
             	 reset_datatype, datatype,datatype=datatype
			FOR i=0L, length-1 DO BEGIN
			get_one_operation, datatype, i, one_operation=one_operation, param1=param1, param2=param2
            	 	mess=nachricht
			perform_operation, datatype, one_operation,param1,param2, datatype=datatype, nachricht=mess
			ENDFOR
			get_operations_length, datatype, length=length
			set_operations_length, datatype, length/2, datatype=datatype
      END
'UNDO': BEGIN
                get_operations_length, datatype, length=length                
                FOR i=par1 , length-2 DO BEGIN
                get_one_operation, datatype, i+1, one_operation=one_operation, param1=param1, param2=param2
                change_operations, datatype,  one_operation,param1,param2,  i,datatype=datatype
                ENDFOR
               set_operations_length, datatype, length-1, datatype=datatype

              reset_datatype, datatype,datatype=datatype
		FOR i=0L, length-2 DO BEGIN
		get_one_operation, datatype, i, one_operation=one_operation, param1=param1, param2=param2
            mess=nachricht
		perform_operation, datatype, one_operation,param1,param2, datatype=datatype, nachricht=mess
		ENDFOR
		get_operations_length, datatype, length=length
		set_operations_length, datatype, length/2, datatype=datatype
 END
'RESET':BEGIN
             reset_datatype, datatype,datatype=datatype
             reset_operations, datatype, datatype=datatype
              END
ENDCASE
END

PRO reset_datatype, data,datatype=datatype
		get_orig_xwerte,datatype, orig_xwerte=orig_xwerte
             get_orig_ywerte,datatype, orig_ywerte=orig_ywerte
             set_current_xwerte, datatype, orig_xwerte, datatype=datatype
		set_current_ywerte, datatype, orig_ywerte, datatype=datatype
		get_orig_color, datatype, color=color
		set_color, datatype, color, datatype=datatype
		get_orig_sym, datatype, sym=sym
             set_sym, datatype, sym, datatype=datatype
		get_orig_y_style, datatype, y_style=y_style
             set_y_style, datatype, y_style, datatype=datatype
		get_orig_background, datatype, background=background
             set_background, datatype, background, datatype=datatype
		get_orig_length, datatype, orig_length=orig_length
		set_current_length, datatype,orig_length,datatype=datatype
             get_orig_yunit, data, orig_yunit=orig_yunit
             get_orig_xunit, data, orig_xunit=orig_xunit
             get_orig_xparameter, data, orig_xparameter=orig_xparameter
             get_orig_yparameter, data, orig_yparameter=orig_yparameter
             set_current_yparameter, datatype, orig_yparameter, datatype=datatype
             set_current_xparameter, datatype, orig_xparameter, datatype=datatype
             set_current_yunit, datatype, orig_yunit, datatype=datatype
             set_current_xunit, datatype, orig_xunit, datatype=datatype
END

PRO get_orig_color, datatype, color=color
color=FIX(datatype(5, 5))
END

PRO get_color, datatype, color=color
color=FIX(datatype(16, 5))
END

PRO set_color, data, color, datatype=datatype
datatype=data
datatype(16, 5)=color
END

PRO get_orig_background, datatype, background=background
background=FIX(datatype(7, 5))
END

PRO get_background, datatype, background=background
background=FIX(datatype(18, 5))
END

PRO set_background, data, background, datatype=datatype
datatype=data
datatype(18, 5)=background
END

PRO get_orig_sym, datatype, sym=sym
sym=FIX(datatype(6, 5))
END

PRO get_sym, datatype, sym=sym
sym=FIX(datatype(17, 5))
END

PRO set_sym, data, sym, datatype=datatype
datatype=data
datatype(17, 5)=sym
END

PRO get_orig_y_style, datatype, y_style=y_style
y_style=FIX(datatype(11, 5))
END

PRO get_y_style, datatype, y_style=y_style
y_style=FIX(datatype(19, 5))
END

PRO set_y_style, data, y_style, datatype=datatype
datatype=data
datatype(19, 5)=y_style
END

PRO get_orig_xmin, datatype, orig_xmin=orig_xmin
get_orig_xwerte, datatype, orig_xwerte=orig_xwerte
orig_xmin=min(orig_xwerte)
END

PRO get_orig_xmax, datatype, orig_xmax=xmax
get_orig_xwerte, datatype, orig_xwerte=orig_xwerte
orig_xmax=max(orig_xwerte)
END

PRO get_orig_ymin, datatype, orig_ymin=orig_ymin
get_orig_ywerte, datatype, orig_ywerte=orig_ywerte
orig_ymin=min(orig_ywerte)
END

PRO get_orig_ymax, datatype, orig_ymax=orig_ymax
get_orig_ywerte, datatype, orig_ywerte=orig_ywerte
orig_ymax=max(orig_ywerte)
END

PRO get_current_xmin, datatype, current_xmin=current_xmin
get_current_xwerte, datatype, current_xwerte=current_xwerte
current_xmin=min(current_xwerte)
END

PRO get_current_xmax, datatype, current_xmax=current_xmax 
get_current_xwerte, datatype, current_xwerte=current_xwerte
current_xmax=max(current_xwerte)
END

PRO get_current_ymin, datatype, current_ymin=current_ymin
get_current_ywerte, datatype, current_ywerte=current_ywerte
current_ymin=min(current_ywerte)
END

PRO get_current_ymax, datatype, current_ymax=current_ymax
get_current_ywerte, datatype, current_ywerte=current_ywerte
current_ymax=max(current_ywerte)
END

PRO get_orig_xwerte, datatype, orig_xwerte=orig_xwerte
get_orig_length, datatype, orig_length=orig_length
orig_xwerte=dblarr(orig_length)
for i=0L, orig_length-1 do begin
orig_xwerte(i)=double(datatype(i,0))
endfor
END

PRO get_orig_ywerte, datatype, orig_ywerte=orig_ywerte
get_orig_length, datatype, orig_length=orig_length
orig_ywerte=dblarr(orig_length)
for i=0L, orig_length-1 do begin
orig_ywerte(i)=double(datatype(i,1))
endfor
END

PRO get_current_xwerte, datatype, current_xwerte=current_xwerte
get_current_length, datatype, current_length=current_length
current_xwerte=dblarr(current_length)
for i=0L, current_length-1 do begin
current_xwerte(i)=double(datatype(i, 2))
endfor
END


PRO set_current_xwerte, data, xwerte, datatype=datatype
k=N_ELEMENTS(xwerte)
for i=0L,k-1 do begin
data(i,2)=xwerte(i)
endfor
set_current_length, data, k-1, datatype=datatype
END


PRO get_current_ywerte, datatype, current_ywerte=current_ywerte
get_current_length, datatype, current_length=current_length
current_ywerte=dblarr(current_length)
for i=0L, current_length-1 do begin
current_ywerte(i)=double(datatype(i, 3))
endfor
END


PRO set_current_ywerte, data, ywerte, datatype=datatype
k=N_ELEMENTS(ywerte)
for i=0L,k-1 do begin
data(i,3)=ywerte(i)
endfor
set_current_length, data, k-1, datatype=datatype
END

PRO get_operations, datatype,  operations=operations
get_operations_length, datatype, length=length
operations=extrac(datatype,0,4,3*length+1,1)
END

PRO reset_operations, data, datatype=datatype
set_operations_length, data, 0, datatype=datatype
END
 
PRO get_one_operation, datatype, index,  one_operation=one_operation, param1=param1, param2=param2
get_operations, datatype, operations=operations
one_operation=operations(3*index+1)
param1=operations(3*index+2)
param2=operations(3*index+3)
END

PRO set_operations, data, new_operation,par1,par2, datatype=datatype
get_operations_length, data, length=length
set_operations_length, data, length+1, datatype=datatype
datatype(3*length+1,4)=new_operation 
datatype(3*length+2,4)=par1
datatype(3*length+3,4)=par2
END

PRO change_operations, data, new_operation,par1,par2, index, datatype=datatype
datatype=data
datatype(3*index+1,4)=new_operation 
datatype(3*index+2,4)=par1
datatype(3*index+3,4)=par2
END

PRO get_operations_length, datatype, length=length
length=datatype(10,5)
END

PRO set_operations_length, data, new_length, datatype=datatype
data(10,5)=new_length
datatype=data
END

PRO get_orig_xunit, datatype,orig_xunit=orig_xunit
orig_xunit=STRTRIM(STRING(datatype(3, 5)),2)
END

PRO get_orig_yunit, datatype, orig_yunit=orig_yunit
orig_yunit=STRTRIM(STRING(datatype(4, 5)),2)
END

PRO get_current_xunit, datatype, current_xunit=current_xunit
current_xunit=STRTRIM(STRING(datatype(12, 5)),2)
END

PRO get_current_yunit, datatype, current_yunit=current_yunit
current_yunit=STRTRIM(STRING(datatype(13, 5)),2)
END

PRO set_current_xunit, data, new_xunit, datatype=datatype
data(12,5)=new_xunit
datatype=data
END

PRO set_current_yunit, data, new_yunit, datatype=datatype
data(13,5)=new_yunit
datatype=data
END

PRO get_revs, datatype, revs=revs
revs=STRTRIM(STRING(datatype(0, 5)),2)
END

PRO get_orig_xparameter, datatype, orig_xparameter=orig_xparameter
orig_xparameter=datatype(1, 5)
END

PRO get_orig_yparameter, datatype, orig_yparameter=orig_yparameter
orig_yparameter=datatype(2, 5)
END

PRO get_current_xparameter, datatype, current_xparameter=current_xparameter
current_xparameter=datatype(14, 5)
END

PRO get_current_yparameter, datatype, current_yparameter=current_yparameter
current_yparameter=datatype(15, 5)
END

PRO set_current_xparameter, data, new_xparameter, datatype=datatype
data(14,5)=new_xparameter
datatype=data
END

PRO set_current_yparameter, data, new_yparameter, datatype=datatype
data(15,5)=new_yparameter
datatype=data
END

PRO get_current_length, datatype, current_length=current_length
current_length=LONG(datatype(9, 5))
END

PRO set_current_length, data, new_length, datatype=datatype
data(9, 5)=new_length
datatype=data
END

PRO get_orig_length, datatype, orig_length=orig_length
orig_length=LONG(datatype(8, 5))
END

PRO cs_xmm_logviewer_load_subroutines 
END
