PRO RPC_DEMO, host,                                       $
              PM_ADDRESS      = pm_address,               $
              PM_HOSTNAME     = pm_hostname,              $
              IDL_RPC_ID      = idl_rpc_id,               $
              CONNECT_TIMEOUT = connect_timeout

; This is a demonstration program to show how to use the IDL_RPC_CLIENT object.  Basically all
; this program does read a IDL command line from input and then sends the command to the remote
; IDL server.  It then reads back whatever output the remote server generates and displays it.
; The program exits when the user types 'EXIT'.

; The address of the remote IDL server is passed to this procedure as the parameter host.

; First we create an IDL_RPC_CLIENT object.  There are two important keywords that can be
; included when we initialize the object.  The first important keyword  is 'IDL_RPC_CLIENT which
; specifies the ID of the rpc server that we wish to connect to.  If not set, then it will default
; to a value of 0x2010CAFE (which default ID for an IDL server).  The other important keyword is
; CONNECT_TIMEOUT which specifies the amount of time we should for a socket connection to be
; established.  The default value for this keyword is 5 seconds.

rpc = OBJ_NEW ('IDL_RPC_CLIENT', IDL_RPC_ID = idl_rpc_id, CONNECT_TIMEOUT = connect_timeout )

IF NOT OBJ_VALID (rpc) THEN RETURN

; Run the RPCInit method.  This method will usually be the first one that is called on the
; client object.  The important keyword here is HOSTNAME.  This specifies the hostname of
; remote IDL server.  It performs all the tasks necessary to set up communication with the
; remote server (including checking for the existence of the server itself).  Like all
; methods in the IDL_RPC_CLIENT object, this method will return 1 for success and 0 for
; failure.

; Some notes on using this method.  To use this process without suppling any keywords, the remote
; host must not have port 111 blocked. This is because the RPC client object uses the port mapper
; on the remote to determine what port the port the IDL RPC server is listening to.  If port 111
; is blocked (as it will be by most firewalls), then the user must supply a hostname and port
; through which the portmapper can be accessed, presumbly through a SSH tunnel.

; Also, the timeout is currently set to 120 sec. so if something does go wrong, prepare for the
; client session to hang for a while.

IF NOT rpc->RPCInit (HOSTNAME = host,           $
                     PM_ADDRESS = pm_address,   $
                     PM_HOSTNAME = pm_hostname) THEN RETURN

; The RPCOutputCapture method informs the remote server how lines of output it is save in
; in its buffer.  If we were to call this method with a parameter of 0, it would tell the
; remote server to turn off its buffer and not save any output.  For this demo, we will use
; a value of 10.


IF NOT rpc->RPCOutputCapture (10) THEN RETURN

; Initialize ins to a NULL string.  We will use ins to capture input from the user.

ins = ''

; Main loop to receive user input and send it to the remote server.  The loop ends when the
; user types 'EXIT'.

WHILE (1) DO BEGIN

; Read the command to send to the remote IDL server.  The command is returned in ins.

  READF, 0, ins, PROMPT = host + '?'

; Get rid  of any white space and convert to upcase.  This will allow us to detect an exit.

  str = STRTRIM (STRCOMPRESS (STRUPCASE (ins)), 2)

; OK, if the user wants to exit, we quit the loop.  Otherwise we assume that whatever they
; typed in is a command.

  IF str EQ 'EXIT' THEN BREAK

; The RPCExecuteStr method takes a string as a parameter and sends it the remote IDL server.
; Athough this method does not check for it, remote commands should not contain an '$'
; character as this will only confuse the server.  Again, if this method fails for some reason
; it will return 0 and cause us to exit the program.  Otherwise it will return 1.

  IF NOT rpc->RPCExecuteStr (ins) THEN RETURN

; Time to pick up whatever output the command generated.  This is done in a loop that exits
; when there is no more output in the server's buffer.

  WHILE (1) DO BEGIN

; The RPCOuputGetStr picks up one line output from the remote serever's buffer.  Since to keep
; interface consistent, the method returns its execution status, the actual line of output must
; be retrieved using keywords.  In this case, we use the keyword LINE.  We also have a keyword
; FLAGS.  IDL servers will return 16 bits of status information with each line of ouput.
; Unfortunately, the value that is documented is -1 (buffer empty).

     IF NOT rpc->RPCOutputGetStr (LINE = line, FLAGS = flags) THEN RETURN

; OK, check the value returned with the FLAGS keyword.  If this is -1, then the buffer is now
; and we can exit this loop.

     IF flags EQ -1 THEN BREAK

; Otherwise, we have a line from the buffer, so lets display it.

     PRINT, host + '>', line

  ENDWHILE

ENDWHILE

; Time to finish up.  The RPCCleanup method closes a sesion with a remote server.  Mostly it
; just takes cares of housekeeping on the client side, but if its passed a parameter that
; resolves to TRUE, then it will also cause the remote IDL server to exit.

IF NOT rpc->RPCCleanup () THEN RETURN

; All done.  Get rid of the IDL RPC Client object and exit.

OBJ_DESTROY, rpc

RETURN

END