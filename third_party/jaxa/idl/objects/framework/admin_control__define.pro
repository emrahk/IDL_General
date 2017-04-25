;---------------------------------------------------------------------------
; Document name: admin_control__define.pro
; Created by:    Andre Csillaghy, October 29, 1999
; Time-stamp: <Fri May 21 2004 13:46:58 csillag soleil.ifi.fh-aargau.ch>
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       ADMIN_CONTROL__DEFINE
;
; PURPOSE:
;       Defines the structure that contains the administrative
;       parameters. It is managed by the structure_manager program
;       through framework__define, so
;       usually you dont care about this structure.
;
; CATEGORY:
;       Util
;
; CALLING SEQUENCE:
;       struct = {admin_control}
;
; HISTORY:
;       2004-05-21 - changed the last update from double to long to
;                    use a counter instead of systime for the last
;                    update stuff.
;       2001-05-26 - modified, dont remember exaclty what changed
;       Version 1, October 29, 1999,
;           A Csillaghy, csillag@ssl.berkeley.edu
;
;-
;

PRO admin_control__define

dummy =  {admin_control, $
          verbose:0B, $         ; comments the current operations
          need_update: 0B, $
; acs 2004-05-20 lst update uses now a specially defined counter
;         last_update: 0D
          last_update: 0L, $
          debug: 0B, $
          PLOT: 0B }

END

;---------------------------------------------------------------------------
; End of 'admin_control__define.pro'.
;---------------------------------------------------------------------------
