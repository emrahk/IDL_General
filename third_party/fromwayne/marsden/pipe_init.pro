pro pipe_init
	x = call_external('npipe.so','_pipe_init')
        print,'PIPE_INIT RETURNED ',x
end
