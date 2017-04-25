;---------------------------------------------------------------------------
; Document name: hsi_strategy_holder_passive__define
; Created by:    Andre Csillaghy, May 1999
;
; Last Modified: Tue Sep 04 15:08:57 2001 (csillag@TOURNESOL)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       PASSIVE STRATEGY HOLDER ABSTRACT CLASS
;
; PURPOSE: 
;       Extends the strategy holder class to allow selecting
;       startegies based on another, source, strategy holder. The
;       concrete classes check the source object to decide what
;       startegy the must use.  
;       
;       In the HESSI software, for instance, there are two strategies
;       for image reconstruction: visibility-based and annular-sector
;       based. Furthermore, for both imaging strategies, there are three classes
;       that generate data products for each strategy: back
;       projection, point spread function and modulation
;       profiles. The choice of the strategy to use, however, is given by the
;       source class of these three data products: hsi_modul_pattern,
;       which is used by each class. This passive class allows them to
;       check for the correct startegy in the source object.
;
; CATEGORY:
;       Objects
; 
; CONSTRUCTION:
;       This is an abstracet class. The construction is done through
;       the concrete classes.
;
; METHODS DEFINED IN THIS CLASS:
;       INIT( strategy_available ): the initialization of the object
;                                   takes a required parameter, the
;                                   name of the strategy objects it
;                                   will hold (strarr).
;       SetStrategy: sets the used strategy according to the
;                    startegy used by the source object
;       GetStrategy: gets the startegy taht correspond to the startegy
;                    used in the source object
;
; PARENT OBJECT:
;       Strategy_Holder
; 
; KNOWN SOURCE OBJECTS:
;       HSI_Modul_Pattern
;
; KNOWN CONCRETE CLASSES:
;       HSI_Bproj, HSI_Modul_Profile, HSI_PSF
;
; SEE ALSO:
;       HESSI Utility Reference 
;          http://hessi.ssl.berkeley.edu/software/reference.html
;       hsi_bproj__define
;       hsi_modul_profile__define
;       hsi_psf__define
;       hsi_modul_pattern__define
;
; HISTORY:
;       Release 6: created, A.Csillaghy, csillag@ssl.berkeley.edu,
;                  April 2001
;
;----------------------------------------------------------

FUNCTION Strategy_Holder_Passive::INIT, $
                 strategy_available,  $
                 _EXTRA=_extra

ret=self->Strategy_Holder::INIT( strategy_available, $
                                 _EXTRA=_extra )

self->SetStrategy

RETURN, ret

END

;---------------------------------------------------------------------------

PRO Strategy_Holder_Passive::SetStrategy, dummy

source = self->Get( /SOURCE )
index = source->GetStrategy( /STRATEGY_INDEX )
self->Strategy_Holder::SetStrategy, index

END

;---------------------------------------------------------------------------

FUNCTION Strategy_Holder_Passive::GetStrategy, _EXTRA = _extra

self->SetStrategy
RETURN, self->Strategy_Holder::GetStrategy(_EXTRA = _extra)

END

;---------------------------------------------------------------------------

PRO Strategy_Holder_Passive__Define

shpd = {Strategy_Holder_Passive, $
        INHERITS Strategy_Holder }

END


;---------------------------------------------------------------------------
; End of 'strategy_holder_passive__define.pro'.
;---------------------------------------------------------------------------
