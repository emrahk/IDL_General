;+
; Project     : VSO
;
; Name        : PREPROCESSOR__DEFINE
;
; Purpose     : Java - IDL interface object for PrepServer
;
; Category    : VSO, PrepServer
;
; Syntax      : IDL> obj=obj_new('preprocessor')
;
; History     : 04-Mar-2009  L. I. Etesi (CUA,FHNW/GSFC), initial release after redesign
;               23-Mar-2009  L. I. Etesi (CUA,FHNW/GSFC), redesign, depend on IDL/SSW objects
;               01-Apr-2009  L. I. Etesi (CUA,FHNW/GSFC), internal changes
;               05-Apr-2009  L. I. Etesi (CUA,FHNW/GSFC), internal changes
;            		07-May-2009  L. I. Etesi (CUA,FHNW/GSFC), quickfix for memory leak, changed execute command
;
; Contact     : LASZLO.ETESI@NASA.GOV
;-

;+
; :Description:
;    IDL objects handling the prepping. Is being exportet to Java and used in
;    the Java PrepServer part
;
; :Author: Laszlo Istvan Etesi
;-

;+
; :Description:
;    Initializes the preprocessor.
;
; :Returns:
;    True if the initialization process was successful
;
; :Author: Laszlo Istvan Etesi
;-
FUNCTION preprocessor::init
  RETURN, 1
END

;+
; :Description:
;    Mutator method for instrument field
;
; :Params:
;    instrument is the instrument (i.e. EIT, TRACE,...)
;
; :Author: Laszlo Istvan Etesi
;-
PRO preprocessor::setInstrument, instrument
  self.instrument = instrument
END
 
;+
; :Description:
;    Accessor method for instrument field
;
; :Returns:
;    The instrument name
;
; :Author: Laszlo Istvan Etesi
;-
FUNCTION preprocessor::getInstrument
  RETURN, self.instrument
END

;+
; :Description:
;    Mutator for the arguments field
;
; :Params:
;    argName is the argument's name (i.e. COSMIC)
;    argValue is the argument's value (i.e. 1). Types are preserved!
;
; :Author: Laszlo Istvan Etesi
;-
PRO preprocessor::addArgument, argName, argValue
  ; The arguments are stored in structures. Internally, the structures are referenced through pointers
  ; to be able to easily update / extend them.
  IF (PTR_VALID(self.arguments)) THEN BEGIN
    newStr = CREATE_STRUCT(argName, argValue, *self.arguments)
    PTR_FREE, self.arguments
    self.arguments = PTR_NEW(newStr);
  ENDIF ELSE BEGIN
    newStr = CREATE_STRUCT(argName, argValue)
    self.arguments = PTR_NEW(newStr);
  ENDELSE
END

;+
; :Description:
;    Accessor method for arguments field
;
; :Returns:
;    The arguments in a structure
;
; :Author: Laszlo Istvan Etesi
;-
FUNCTION preprocessor::getArguments
  RETURN, *self.arguments
END

;+
; :Description:
;    Mutator method for outfile field
;
; :Params:
;    outfile is the destination to where the prepped file is saved
;
; :Author: Laszlo Istvan Etesi
;-
PRO preprocessor::setOutfile, outfile
  self.outfile = outfile
END

;+
; :Description:
;    Accessor method for outfile field
;
; :Returns:
;    The path and name of the output file
;
; :Author: Laszlo Istvan Etesi
;-
FUNCTION preprocessor::getOutfile
  RETURN, self.outfile
END

;+
; :Description:
;    Mutator method for infile field
;
; :Params:
;    infile is the destination from where the input file is read
;
; :Author: Laszlo Istvan Etesi
;-
PRO preprocessor::setInfile, infile
  self.infile = infile
END
  
;+
; :Description:
;    Accessor method for infile field
;
; :Returns:
;    The path and name of the input file
;
; :Author: Laszlo Istvan Etesi
;-
FUNCTION preprocessor::getInfile
  RETURN, self.infile
END

;+
; :Description:
;    Accessor method for the response data field (IDL wrapper object!)
;
; :Returns:
;    The response data
;
; :Author: Laszlo Istvan Etesi
;-
;FUNCTION preprocessor::getResponse
;  RETURN, self.response
;END

;+
; :Description:
;    Mutator method for the response data field
;
; :Params:
;    response is the response object in Java (gov.nasa.gsfc.hessi.jidl.prep.server.PrepResponse)
;
; :Author: Laszlo Istvan Etesi
;-
;PRO preprocessor::setResponse, response
;  self.response = obj_new('prepresponse')
;  self.response->setJavaResponseObject, response
;  addArgument, 'JavaResponseObject', self.response
;END

PRO preprocessor::setResponse, response
  self.response = response
  self->addArgument, 'JavaResponseObject', self.response
END

;+
; :Description:
;    Prepping routine. Reads all the parameters, sets up the
;    IDL/SSW instrument object and initiates the prepping.
;
; :Author: Laszlo Istvan Etesi
;-
PRO preprocessor::preprocess
  ;search_network, /enable
  p = OBJ_NEW(self.instrument)
  
  ; The parameter built such that EXECUTE/CALL_METHOD will use real IDL variables with types.
  paramString = ''
  
  IF PTR_VALID(self.arguments) THEN BEGIN
    argStr = *self.arguments
    argNames = TAG_NAMES(argStr);
  
    FOR i = 0, N_TAGS(argStr) - 1 DO BEGIN    
      paramString = paramString + ', ' + argNames(i) + '=(*self.arguments).(' + STRCOMPRESS(STRING(i), /REMOVE_ALL) + ')'
    ENDFOR    
  ENDIF

  res = EXECUTE('p->read, self.infile' + paramString)

  p->write, self.outfile
  
  self.response->setStatus, 'SUCCESS'
  
  OBJ_DESTROY, p
END

;+
; :Description:
;    Cleans up when the arguments
;    when the object is destroyed.
;
; :Author: Laszlo Istvan Etesi
;-
PRO preprocessor::cleanUp
  free_var, self.arguments, /delete
END

;+
; :Description:
;    Object definition routine
;
; :Author: Laszlo Istvan Etesi
;-
PRO preprocessor__define
  void = { preprocessor, arguments:PTR_NEW(), instrument:'', outfile:'', infile:'', response:OBJ_NEW() }
END
