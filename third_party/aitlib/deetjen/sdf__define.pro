;; =============================================================================
;+
; NAME: 
;       SDF
;
; PURPOSE:
;       This object defines the Scientific Data Format type.
;
; CATEGORY:
;       Data I/O
;
; CALLING SEQUENCE:
;	To initialize create:
;	       	oSDF = OBJ_NEW('sdf') 
;
;	To retrieve a property value:
;		oLinelist->GetProperty
;
;	To set a property value:
;		oLinelist->SetProperty
;
;	To print to the standard output stream the current properties of 
;	the specline:
;		oLinelist->Print
;
;	To destroy:
;		OBJ_DESTROY, oLinelist
;
; KEYWORD PARAMETERS:
;   SPECLINE::INIT:
;       WAVELENGTH: A floating point number representing the wavelenth
;               of the spectral line in A. 
;       GF_VALUE: A floating point number representing the gf-value of
;               the spectral line.
;       NAME:   A string containing am identifier of the specral line.
;
;   SPECLINE::GETPROPERTY:
;       WAVELENGTH: A floating point number representing the wavelenth
;               of the spectral line in A.
;       GF_VALUE: A floating point number representing the gf-value of
;               the spectral line.
;       NAME:   A string containing am identifier of the specral line.
;
;   SPECLINE::SETPROPERTY:
;       WAVELENGTH: A floating point number representing the wavelenth
;               of the spectral line in A.
;       GF_VALUE: A floating point number representing the gf-value of
;               the spectral line.
;       NAME:   A string containing am identifier of the specral line.
;
; DEFAULTS:
;      WAVELENTH: 0.0
;      GF_VALUE : -100.0
;      NAME     : 'undefined'
;
; EXAMPLE:
;	Create an specline containing Hydrogen Lyman alpha 
;		oSpecline = OBJ_NEW('specline', WAVELENGTH=1215.7, name='Hydrogen: Lyman alpha') 
;
; MODIFICATION HISTORY:
;      Version 1.0, 1999/26/11, by Jochen Deetjen 
;
;-
;; =============================================================================


;-------------------------------------------------------------------------------
; SDF::INIT
;
; Purpose:
;  Initializes an sdf object.
;
;  This function returns a 1 if initialization is successful
;
FUNCTION sdf::Init, _EXTRA=extra

   self.name     = 'undefined'
   self.in_file  = 'undefined'
   self.out_file = 'undefined'
   self.comment  = ''
   self.gf_min   = -100.0
   self.lamb_min = 0.0
   self.lamb_max = 10000.0
   
   self->SetProperty, _EXTRA=extra
   
   RETURN, 1
END


;-------------------------------------------------------------------------------
; SDF::CLEANUP
;
; Purpose:
;  Cleans up all memory associated with the sdf.
;
PRO sdf::Cleanup

    ; Cleanup the specline object array.
    self->IDL_Container::Cleanup

END


;-------------------------------------------------------------------------------
; SDF::SETPROPERTY
;
; Purpose:
;  Sets the value of properties associated with the sdf object.
;
PRO sdf::SetProperty, NAME=name, IN_FILE=in_file, OUT_FILE=out_file, $
            GF_MIN=gf_min, COMMENT=comment, SDF=sdf

    IF (N_ELEMENTS(name) EQ 1) THEN $
      self.name = name
    
    IF (N_ELEMENTS(in_file) EQ 1) THEN $
      self.in_file = in_file
   
    IF (N_ELEMENTS(out_file) EQ 1) THEN $
      self.out_file = out_file
   
    IF (N_ELEMENTS(gf_min) EQ 1) THEN $
      self.gf_min = gf_min
    
    IF (N_ELEMENTS(comment) EQ 1) THEN $
      self.comment = comment
    
    IF (N_ELEMENTS(sdf) EQ 1) THEN $
      self->Copy, sdf
END


;-------------------------------------------------------------------------------
; SDF::GETPROPERTY
;
; Purpose:
;  Retrieves the value of properties associated with the sdf object.
;
PRO sdf::GetProperty, NAME=name, IN_FILE=in_file, OUT_FILE=out_file, COMMENT=comment 

   IF (ARG_PRESENT(name) EQ 1) THEN $
     name = self.name
   
   IF (ARG_PRESENT(in_file) EQ 1) THEN $
     in_file = self.in_file
   
   IF (ARG_PRESENT(comment) EQ 1) THEN $
     comment = self.comment
END


;-------------------------------------------------------------------------------
; SDF::COPY
;
; Purpose:
;    Copy the contents of another sdf to self
;
PRO sdf::Copy, sdf
   
   FOR i=0,sdf->Count()-1 DO BEGIN
       lineI = sdf->Get( POS=i )
       line  = OBJ_NEW('specline', SPECLINE=lineI)
       self  -> Add, line
   ENDFOR       
       
   self.name     = sdf.name 
   self.in_file  = sdf.in_file
   self.out_file = sdf.out_file
   self.comment  = sdf.comment
   self.gf_min   = sdf.gf_min
   self.lamb_min = sdf.lamb_min
   self.lamb_max = sdf.lamb_max

END

;-------------------------------------------------------------------------------
; SDF::PRINT
;
; Purpose:
;  Prints the value of properties associated with the sdf object.
;
PRO sdf::Print, ALL=all, _EXTRA=extra
   IF (KEYWORD_SET(ALL)) THEN BEGIN
       FOR i=0, self->Count()-1 DO BEGIN
           specline = self->Get(pos=i)
           specline->Print, _EXTRA=extra
       ENDFOR
   ENDIF ELSE BEGIN
       
       PRINT, "-------------------------------"
       PRINT, self.name, " contains ", self->Count(), " Spectrallines"
       PRINT, "Input  File: ", self.in_file
       PRINT, "Output File: ", self.out_file
       PRINT, "Comment: ",self.comment
   ENDELSE
END


;-------------------------------------------------------------------------------
; SDF::GETTABLE
;
; Purpose:
;  Create a Table containing all lines
;
PRO sdf::GetTable
   
   data        = FLTARR(2, self->Count() )
   data[0,*]   = self -> GetWavelength()
   data[1,*]   = self -> GetGF_Values()
   
   tableBase   = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0, TITLE=self.name)
   tableWidget = WIDGET_TABLE(tableBase, VALUE=data, scr_ysize=400)
   WIDGET_CONTROL, tableBase, /REALIZE
   
END


;-------------------------------------------------------------------------------
; SDF::READFILE
;
; Purpose:
;  Read in a file containing several spectral lines
;
PRO sdf::ReadFile, TYP1=typ1
   
   
   ;; -----------------------------------------------
   ;; TYP1
   ;;
   IF (N_ELEMENTS(typ1) EQ 1) THEN BEGIN
       
       IF (self.in_file EQ "undefined") THEN BEGIN
           PRINT, "% ERROR in sdf::ReadFile --- Input filename not defined"
       ENDIF ELSE BEGIN
           
           find_res = FINDFILE( self.in_file, count=count )
           IF (count NE 1) THEN BEGIN
               PRINT, " ERROR in sdf::ReadFile --- Input file not found"
           ENDIF ELSE BEGIN
               
               GET_LUN, unit
               OPENR, unit, self.in_file, ERROR=err
               
               IF (err EQ 0) THEN BEGIN
                   str_typ1 = ' '
                   
                   READF, unit, str_typ1
                   self.comment = str_typ1
                   READF, unit, str_typ1
                   
                   WHILE(NOT EOF(unit)) DO BEGIN 
                       specline = OBJ_NEW('specline', TYP1=str_typ1)
                       specline -> GetProperty, gf_value=gf, element=element, ion=ion
                       IF (gf GE self.gf_min) THEN BEGIN
                           ;IF (element EQ 'Si' AND ion EQ 'IV') THEN $
                           self->Add, specline
                       ENDIF
                       READF, unit, str_typ1
                   ENDWHILE
               ENDIF
               
               FREE_LUN, unit
               
           ENDELSE
       ENDELSE
   ENDIF
   
END


;-------------------------------------------------------------------------------
; SDF::WRITEFILE
;
; Purpose:
;  Write a file containing several spectral lines
;
PRO sdf::WriteFile
   
   IF (self.out_file EQ "undefined") THEN BEGIN
       PRINT, "% ERROR in sdf::WriteFile --- Output filename not defined"
   ENDIF ELSE BEGIN
             
       GET_LUN, unit
       OPENW, unit, self.out_file, ERROR=err
       
       IF (err EQ 0) THEN BEGIN
           PRINTF, unit, self.comment
           
           size      = self->Count()
           FOR i=0, size-1L DO BEGIN
               specline  = self->Get(POS=i)
               specline->GetProperty, WAVELENGTH=wave, GF_VALUE=gf, $
                 ELEMENT=atom, ION=ion
               PRINTF, unit, FORMAT = '(F10.3,"     ",F10.3,"     ",A2," ",A2)', $
                 wave, gf, atom, ion
           ENDFOR
           
       ENDIF
           
       FREE_LUN, unit
       
   ENDELSE
  
END


;-------------------------------------------------------------------------------
; SDF::GETWAVELENGTH
;
; Purpose:
;  Extract an array containing the wavelengths
;
FUNCTION sdf::GetWavelength
   
   size   = self->Count()
   lambda = FLTARR(size)
   
   FOR i=0, size-1L DO BEGIN
       specline  = self->Get(POS=i)
       specline->GetProperty, WAVELENGTH=lamb
       lambda[i] = lamb
   ENDFOR
   
   RETURN, lambda
END

   
;-------------------------------------------------------------------------------
; SDF::GETGF_VALUES
;
; Purpose:
;  Extract an array containing the gf-values.
;
FUNCTION sdf::GetGF_Values
   
   size      = self->Count()
   gf_values = FLTARR(size)
   
   FOR i=0, size-1L DO BEGIN
       specline  = self->Get(POS=i)
       specline->GetProperty, GF_VALUE=gf
       gf_values[i] = gf
   ENDFOR
   
   RETURN, gf_values
END

   
;-------------------------------------------------------------------------------
; SDF::PLOT
;
; Purpose:
;  Plot positon, gf-value and name of all spectrallines
;
PRO sdf::Plot
   
   lambda    = self->GetWavelength()
   gf_values = self->GetGF_Values()
   
   idx       = WHERE(gf_values GT self.gf_min)
   lambda    = lambda[idx] 
   gf_values = gf_values[idx]
   
   PLOT, lambda, gf_values, /NODATA, $
     title    = self.name, $
     xtitle   = textoidl('\lambda ['+STRING(197B)+']'), $
     charsize = 1.1, $
     ytitle   = 'gf-value'
   
   size = N_ELEMENTS(lambda)
   FOR i=0, size-1 DO BEGIN
       PLOTS, lambda[i], self.gf_min
       PLOTS, lambda[i], gf_values[i], /CONTINUE
   ENDFOR
END
   

;-------------------------------------------------------------------------------
; SDF::WAVESEARCH
;
; Purpose:
;  search for a given wavelength in a sdf object 
;
FUNCTION sdf::WaveSearch, wavelength, DELTAW=deltaw, SDF=new_list, $
            CURSOR=cursor, GF_MIN=gf_min
   
   IF (N_ELEMENTS(deltaw) NE 1) THEN deltaw=1
   
   lambda    = self->GetWavelength()
   
   result=0
   
   IF (N_ELEMENTS(wavelength) EQ 1) THEN BEGIN
       idx       = WHERE((lambda GE (wavelength-deltaw)) AND $
                         (lambda LE (wavelength+deltaw)), count )
       
       IF (count EQ 0) THEN BEGIN
           print, "% Wavelength: ",wavelength," not found in list ",self.name
           result = 0
       ENDIF ELSE BEGIN
           new_list  = OBJ_NEW('sdf')
           new_list->Add, self->Get(POS=idx)

           IF (NOT ARG_PRESENT(new_list)) THEN BEGIN
               new_list->Print,/ALL
           ENDIF
           result = 1
       ENDELSE
       
   ENDIF
   
   IF (KEYWORD_SET(cursor)) THEN BEGIN
       
       ;; +++ Get the initial points in data coordinates. +++
       CURSOR, X1, Y1, /DATA, /DOWN
       CURSOR, X2, Y2, /DATA, /DOWN
           
       ;; +++ Repeat until the right button is pressed. +++
       WHILE (!MOUSE.button NE 4) DO BEGIN
           idx       = WHERE((lambda GE x1) AND $
                             (lambda LE x2), count )
           
           PRINT, "------------------------------"
           PRINT, "Between ",x1," and ",x2,": ",count," lines"
           IF (count NE 0) THEN BEGIN
               new_list  = OBJ_NEW('sdf')
               new_list->Add, self->Get(POS=idx)
               new_list->Print,/ALL
               OBJ_DESTROY, new_list
           ENDIF
           PRINT, " "
           
           CURSOR, X1, Y1, /DATA, /DOWN
           CURSOR, X2, Y2, /DATA, /DOWN
       ENDWHILE
       
       result = 1 
   ENDIF
   
   RETURN, result
   
END
   

;-------------------------------------------------------------------------------
; SDF::REMOVEDOUBLES
;
; Purpose:
;   Remove doubles in a sdf
;
FUNCTION sdf::RemoveDoubles
   
   newList = OBJ_NEW('sdf', name=self.name, in_file=self.in_file, $
                     out_file=self.out_file, comment=self.comment, $
                     gf_min=self.gf_min,$
                     lamb_min=self.lamb_min, lamb_max=self.lamb_max)
   
   lambda_old  = 0
   element_old = ''
   ion_old     = ''
   
   FOR i=0, self->Count()-1 DO BEGIN
       line = self->Get(POS=i)
       line -> GetProperty, WAVELENGTH=lambda, ELEMENT=element, ION=ion
       
       IF ((lambda GT lambda_old)   OR $
           (element NE element_old) OR $
           (ion NE ion_old)           )  THEN BEGIN 
           newList -> Add, OBJ_NEW('specline', SPECLINE=line)
       ENDIF
       lambda_old  = lambda
       element_old = element
       ion_old     = ion
   ENDFOR
   
   RETURN, newList
   
END
   
   
;-------------------------------------------------------------------------------
; SDF__DEFINE
;
; Purpose:
;  Defines the object structure for an sdf object.
;
PRO sdf__define
   
   struct = { sdf                   , $
              INHERITS IDL_Container, $
              file    : ''          , $
              nr_col  : 0L          , $
              nr_row  : 0L          , $
              x_vec   : PTR_NEW()   , $
              y_vec   : PTRARR()    , $
              title   : PTR_NEW()   , $
              
   out_file: '',           $
              comment : '',           $
              gf_min  : 0.0,          $
              lamb_min: 0.0,          $
              lamb_max: 0.0           $
             }
END

;
;-------------------------------------------------------------------------------




