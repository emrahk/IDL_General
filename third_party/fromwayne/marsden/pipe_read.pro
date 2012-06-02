function pipe_read
	fname = ''
        y = call_external('npipe.so','_pipe_read',fname,100)
        return,strtrim(fname)
end
