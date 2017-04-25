;+
; :Author: László István Etesi
; 
; TODO Add asserts for all the in-parameters
;-

;+
; :Description:
;    Wrapper object for the Java server interface object.
;    Allows users to search VSO for image data (time interval
;    and instrument name).
;
;    Based on Java (org.virtualsolar.main.SearchAccessor);
;
; :Author: László István Etesi
;-

;+
; :Description:
;    Standard object initialization routine;
; 
;  :Returns:
;    True if the initialization was successful
;    
; :Author: László István Etesi
;-
FUNCTION IdlSearchAccessor::init
  self.sa = OBJ_NEW('IDLJavaObject$GOV_NASA_GSFC_HESSI_JIDL_VSO_SEARCH_SEARCHACCESSOR', 'gov.nasa.gsfc.hessi.jidl.vso.search.SearchAccessor')
  ; Call the JAVA side initialization method
  self.sa->doInit
  RETURN, 1
END

;+
; :Description:
;    Cleans up at object destruction
;
; :Author: László István Etesi
;-
PRO IdlSearchAccessor::cleanUp
  OBJ_DESTROY, self.sa
  self.timeT = OBJ_NEW()
END

;+
; :Description:
;    Performs the search on the underlying Java object
;    (VSO search).
;
; :Params:
;    instrument is the name of the requested instrument.
;    
; :Returns:
;    Returns a two-dimensional string array.
;    TODO Add information on the array structure.
;
; :Author: László István Etesi
;-
FUNCTION IdlSearchAccessor::doSearch, instrument
  RETURN, self.sa->doTimeSearch(self.timeT->doGetJavaReference(), instrument)
END

;+
; :Description:
;    Mutator routine: Sets the internal time object.
;
; :Params:
;    time defines the searched interval.
;
; :Author: László István Etesi
;-
PRO IdlSearchAccessor::doSetTime, time
  self.timeT = time
END

;+
; :Description:
;    Converts the time from VSO format to show_synop format.
;    VSO: DDMMYYYYmmhhss
;    show_synop: DD-MMM-YYYYTmm:hh:ss.000
;
; :Params:
;    time in VSO notation (string).
;    
; :Returns:
;    The time in show_synop notation (string).
;
;
; :Author: László István Etesi
;-
FUNCTION IdlSearchAccessor::parseTime, time
  RETURN, self.sa->parseTime(time)
END

;+
; :Description:
;    Object definition routine
;
; :Author: László István Etesi
;-
PRO IdlSearchAccessor__define
  void = {IdlSearchAccessor, sa:OBJ_NEW(), timeT:OBJ_NEW()}
END