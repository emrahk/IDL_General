;	05-Feb-2003, Kim.  Added yaxis to saved_data structure

pro plotman_saved_data__define

saved_data = {plotman_saved_data,$
	data: ptr_new(), $
	xaxis: ptr_new(), $
	yaxis: ptr_new(), $
	control: ptr_new(), $
	info: ptr_new(), $
	class: '', $
	class_name: '', $
	save_mode: ''}

end