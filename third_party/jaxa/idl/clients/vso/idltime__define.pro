;+
; :Author: László István Etesi
;
; TODO Add asserts for all the in-parameters
;-

;+
; :Description:
;    Wrapper object for the Java time object.
;
;    Based on Java (org.virtualsolar.vso.Time);
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
FUNCTION IdlTime::init
  self.timeT = OBJ_NEW('IDLJAVAOBJECT$ORG_VIRTUALSOLAR_VSO_TIME', 'org.virtualsolar.vso.Time')
  RETURN, 1
END

;+
; :Description:
;    Cleans up at object destruction
;
; :Author: László István Etesi
;-
PRO IdlTime::cleanUp
  OBJ_DESTROY, self.timeT
END

;+
; :Description:
;    Accessor routine: Get the start time
;
; :Returns:
;    The start time
;    
; :Author: László István Etesi
;-
FUNCTION IdlTime::doGetStartTime
  RETURN, self.timeT->getStart()
END

;+
; :Description:
;    Accessor routine: Get the end time
;
; :Returns:
;    The end time
;    
; :Author: László István Etesi
;-
FUNCTION IdlTime::doGetEndTime
  RETURN, self.timeT->getEnd()
END

;+
; :Description:
;    Mutator routine: Set the start time
;
; :Params:
;    startTime is the start time
;    
; :Author: László István Etesi
;-
PRO IdlTime::doSetStartTime, startTime
  self.timeT->setStart, startTime
END

;+
; :Description:
;    Mutator routine: Set the end time
;
; :Params:
;    endTime is the end time
;    
; :Author: László István Etesi
;-
PRO IdlTime::doSetEndTime, endTime
  self.timeT->setEnd, endTime
END

;+
; :Description:
;    Accessor routine: Get the internal JAVA 
;    reference for the time object
;
; :Returns:
;    The actual time object from JAVA
;    
; :Author: László István Etesi
;-
FUNCTION IdlTime::doGetJavaReference
  RETURN, self.timeT
END

;+
; :Description:
;    Object definition routine
;
; :Author: László István Etesi
;-
PRO IdlTime__define
  void = { IdlTime, timeT:OBJ_NEW() }
END