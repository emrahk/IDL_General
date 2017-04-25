;+
; PROJECT:
;       HESSI
;
; NAME:
;       FRAMEWORK_DEBUG
;
; PURPOSE:
;       Sets env. vars. SSW_FRAMEWORK_DEBUG and SSW_FRAMEWORK_VERBOSE to level requested
;        (10 is default), which has the following effects:
;       1. Sets self.debug and self.verbose to specified level on FRAMEWORK object creation (in INIT). Value persists 
;         for lifetime of object instance. Mostly controls whether informational messages are printed. The level
;         should manage the severity of type of messages that are displayed, but (for RHESSI objects) there doesn't seem
;         to be a plan.  (Also, in RHESSI objects, self.debug and self.verbose seem to have been used interchangeably.)
;       2. If SSW_FRAMEWORK_DEBUG is not 0, then in framework_insert_catch, the catch error handler is not
;         called.
;       If SSW_FRAMEWORK_DEBUG isn't defined (the default if framework_debug was never called) or is set to 0, 
;       framework objects that called framework_insert_catch 'handle' their errors.  If you're trying to debug 
;       the error, you want the code to stop in the faulty routine, so call framework_debug,10 and
;       rerun the code that generated the error.  Now it should stop in the faulty routine so you can debug.
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       framework_debug [,level]
;
; INPUTS:
;
;
; OPTIONAL INPUTS:
;       LEVEL - debug level to set (default is 10)
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; PROCEDURE:
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; EXAMPLES:
;
;
; SEE ALSO:
;
; HISTORY:
; 31-May-2013, Kim Tolbert.  Copied from hsi_debug, which now calls this.
;
;-
;

PRO framework_debug, level

if not exist(level) then level = 10

setenv, 'SSW_FRAMEWORK_DEBUG=' + trim(level)
setenv, 'SSW_FRAMEWORK_VERBOSE=' + trim(level)

END