;+
; :Description:
;    Initializes the prepresponse object
;
; :Returns:
;    True if the initialization process was successful
;
; :Author: Laszlo Istvan Etesi
;-
FUNCTION prepresponse::init
  RETURN, 1
END

;+
; :Description:
;    Cleans up 
;    Do not delete prep, since it has been set from the outside
;
; :Author: Laszlo Istvan Etesi
;-
PRO prepresponse::cleanUp
  
END

FUNCTION prepresponse::getUserMessage
  RETURN, self.usermessage
END

FUNCTION prepresponse::getDebugMessage
  RETURN, self.debugmessage
END

FUNCTION prepresponse::getStatus
  RETURN, self.status
END

FUNCTION prepresponse::getData
  RETURN, self.data
END
  
PRO prepresponse::setUserMessage, usermessage
  self.usermessage = usermessage
END

PRO prepresponse::appendDebugMessage, debugmessage
  breakline = STRING(13B) + '>>> NEW MESSAGE MESSAGE IDL <<<' + STRING(13B)
  self.debugmessage = debugmessage + breakline + self.debugmessage
END

PRO prepresponse::setStatus, status
  self.status = status
END

PRO prepresponse::setData, data
  self.data = data
END
;+
; :Description:
;    Object definition routine
;
; :Author: Laszlo Istvan Etesi
;-
PRO prepresponse__define
  void = { prepresponse, usermessage:'', debugmessage:'', status:'SUCCESS', data:[0b] }
END