; ------------------------------------------------------------------------------------------------

FUNCTION rpc_call_pm_getport, PROG = prog, VERS = vers

cnst = OBJ_NEW ('RPC_CONSTANTS')

self.

OBJ_DESTROY, cnst

cm   = OBJ_NEW ('RPC_MESSAGE', RM_DIRECTION = c.CALL,              $
                               CB_PROG      = c.PMAP_PROG,         $
                               /SET_XID,                           $
                               /SET_RPC_VERS,                      $
                               CB_VERS      = c.PMAP_VERS,         $
                               CB_PROC      = c.PMAPPROC_GETPORT,  $
                               AUTH_TYPE = "NULL",                 $
                               /STATIC,                            $
                               PROG         = prog,                $
                               VERS         = vers,                $
                               PROT         = c.IPPROTO_TCP,       $
                               PORT         = 0                    $
                               )


RETURN, cm

END

; ------------------------------------------------------------------------------------------------

PRO rpc_client__define

struct = {RPC_CLIENT,                        $
          server_address:        0L,         $
          CALL:                  0L,         $
          PMAP_PROG:             0L,         $
          PMAPPROC_GETPORT:      0L,         $
          IPPROTO_TCP:           0L,         $


END
