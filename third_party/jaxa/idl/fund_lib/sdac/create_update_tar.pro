;+
; Project     : SDAC
;                   
; Name        : Create_update_tar
;               
; Purpose     : This procedure creates a tar file suitable for updating a remote file system.
;               
; Category    : SSW_SYSTEM
;               
; Explanation : Based on a date of the previous update, an input, the elements of the path are
;	searched for updates and copied to a local directory for tarring.
;               
; Use         : Create_update_tar, last_update_time, ssw_instr $
;	[, temp_dir=temp_dir, more_path=more_path ]
;    
; Inputs      : 
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : 
;
; Calls	      :
;
; Common      : None
;               
; Restrictions: 
;               
; Side effects: None.
;               
; Prev. Hist  :
;
; Modified    : 
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;
;-            
;==============================================================================
pro create_update_tar, last_update_time, ssw_instr, temp_dir=temp_dir, more_path=more_path, $
	only_pro=only_pro


ndays= '-'+strtrim(ceil( (sys2ut() - anytim( last_update_time, /sec))/ 86400.),2)


home = curdir()
temp_dir = fcheck( temp_dir, concat_dir(home,'ssw_temp'+time2file(anytim(/ints,sys2ut())) ))
spawn,'mkdir '+temp_dir
if not exist(ssw_instr) then ssw_instr = strtrim(str_sep(getenv('SSW_INSTR'),' '),2)



files = 'out_'+ssw_strsplit(ssw_instr,'/',/tail) 
only_write_pro = (['',' | grep pro '])(keyword_set(only_pro))

comms = 'find '+ssw_instr+' -mtime ' + ndays + $
	only_write_pro+ '>'+concat_dir(temp_dir,files)  
cd,'$SSW'
for i=0,n_elements(comms)-1 do spawn,comms(i)

cd,temp_dir,curr=ssw
spawn,'cat '+arr2str(files,' ')+' > all_files2tar'

cd,ssw

spawn, 'tar cfR '+concat_dir(temp_dir,'ssw_update.tar')+' '+concat_dir(temp_dir,'all_files2tar')
spawn, 'compress '+concat_dir(temp_dir,'ssw_update.tar')
cd,home


spawn,'rm -rf '+concat_dir(temp_dir,'out_*')

end
